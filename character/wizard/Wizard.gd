extends "res://character/Character.gd"


## ATTRIBUTES ##

# lightning bolts
export var bolt_charge_time = 1.0
export var bolt_dps         = 20
export var bolt_move_speed  = 2.0

# magic ball
export var magic_ball_time = 2.0

# downthrust attack
export var downthrust_speed  = 2.0
export var downthrust_damage = 20
export var downthrust_force  = 15.0

## PRIVATES ##
var _bolt_charge_timer = 0
var _magic_ball_timer  = 0
var _is_downthrusting  = false

## NODES ##
onready var _bolt_zone   = $Head/Bolt
onready var _impact_zone = $Impact

## SCENES ##
onready var _ball_projectile = load("res://character/wizard/MagicBall.tscn")


## TO OVERRIDE ##

func is_class(type): return type == "Wizard" or .is_class(type)
func get_class():    return         "Wizard"


# set team of character
func set_team(team):
	.set_team(team)
	match team:
		TEAM.alpha:
			_bolt_zone  .set_collision_mask_bit(2, false)
			_impact_zone.set_collision_mask_bit(2, false)
		TEAM.beta:
			_bolt_zone  .set_collision_mask_bit(3, false)
			_impact_zone.set_collision_mask_bit(3, false)
		TEAM.gamma:
			_bolt_zone  .set_collision_mask_bit(4, false)
			_impact_zone.set_collision_mask_bit(4, false)



## ENGINE ##

#func _ready():
#	._ready()


# regular update function
func _process(delta):
	if is_controlled():
		if _magic_ball_timer > 0:
			_magic_ball_timer -= delta
		
		current_speed = move_speed
		
		# if we are downthrusting
		if _is_downthrusting:
			_velocity.y -= downthrust_speed * delta
			if is_grounded():
				_is_downthrusting = false
				if _impact_enemies(): _velocity.y = -_velocity.y
				else:                 _velocity   = Vector3()
	
		elif Input.is_action_just_pressed('jump') and not is_grounded():
			_is_downthrusting = true
			_velocity.y = -downthrust_speed
	
		# fire lightning bolts like
		elif Input.is_action_just_pressed('attack'):
			_bolt_charge_timer = bolt_charge_time
		
		# firing lightning bolts
		elif Input.is_action_pressed('attack'):
			current_speed = bolt_move_speed
			if _bolt_charge_timer > 0: _bolt_charge_timer -= delta
			else:                      _lightning_bolt(delta)
	
		# throw a magic-ball that bound against walls (MisterMV)
		elif Input.is_action_just_pressed('secondary'):
			if _magic_ball_timer <= 0:
				_magic_ball_timer = magic_ball_time
				_magic_ball()

	._process(delta)


## PRIVATES ##

# throw continuous lightning bolts
func _lightning_bolt(delta):

	# find bodies in the zone of the bolt and apply damage to them
	var bodies = _bolt_zone.get_overlapping_bodies()
	var damage = bolt_dps * delta
	for body in bodies:
		if is_enemy(body):
			body.apply_damage(damage, Vector3()) # Damage enemies


# throw a magic ball
func _magic_ball():
	# generate the ball
	var ball = _ball_projectile.instance()
	ball.initialize(self)


# impact enemies when downthrusting
func _impact_enemies():
	var impacted_one = false

	# impact all bodies in the radius
	var bodies = _impact_zone.get_overlapping_bodies()
	for body in bodies:

		# if the object is a character -> impact him
		if is_enemy(body):
			var dir = (body.global_transform.origin - global_transform.origin).normalized()
			dir.y = EPSILON_IMPULSE
			body.apply_damage(downthrust_damage, dir * downthrust_force)
			impacted_one = true
	
	# if atleast one have been impacted, we can bounce from it
	return impacted_one
	

