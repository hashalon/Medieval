extends "res://character/Character.gd"

# TODO: turn lighting bolt into a machinegun like weapon

# attributes

# lightning bolts
export var bolt_charge_time = 1.0
export var bolt_dps         = 20
export var bolt_move_speed  = 3.0

# downthrust attack
export var downthrust_speed  = 2.0
export var downthrust_damage = 20
export var downthrust_force  = 15.0

# private members
var _bolt_charge_timer = 0
var _is_downthrusting  = false

# nodes...
onready var _bolt_zone   = $Camera/Bolt
onready var _impact_zone = $Impact

# projectile
onready var _ball_scene = load("res://character/wizard/MagicBall.tscn")

#func _ready():
#	._ready()


# regular update function
func _process(delta):
	
	current_speed = move_speed
	
	# firing lightning bolts
	if Input.is_action_pressed('primary'):
		current_speed = bolt_move_speed
		if _bolt_charge_timer <= 0:
			_lightning_bolt(delta)
		else:
			_bolt_charge_timer -= delta
	
	# if we are downthrusting
	elif _is_downthrusting:
		_velocity.y -= downthrust_speed * delta
		if is_grounded():
			_is_downthrusting = false
			if _impact_enemies(): _velocity.y = -_velocity.y
			else:                 _velocity   = Vector3()

	elif Input.is_action_just_pressed('jump') and not is_grounded():
		_is_downthrusting = true
		_velocity.y = -downthrust_speed

	# fire a lightning bolt (shotgun like)
	elif Input.is_action_just_pressed('attack'):
		_bolt_charge_timer = bolt_charge_time

	# throw a magic-ball that bound against walls (MisterMV)
	elif Input.is_action_just_pressed('secondary'):
		_magic_ball()

	._process(delta)


# throw continuous lightning bolts
func _lightning_bolt(delta):

	# find bodies in the zone of the bolt and apply damage to them
	var bodies = _bolt_zone.get_overlapping_bodies()
	var damage = bolt_dps * delta
	for body in bodies:
		if is_enemy(body):
			body.add_damage(damage) # Damage enemies

# throw a magic ball
func _magic_ball():
	# generate the ball
	var ball = _ball_scene.instance()
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