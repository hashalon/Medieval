extends "res://character/Character.gd"

# attributes
export var bolt_damage      = 8
export var downthrust_speed = 2.0
export var impact_force     = 15.0

# private members
var _is_downthrusting = false

# nodes...
onready var _bolt_zone   = $Camera/Bolt
onready var _impact_zone = $Impact

# projectile
onready var _ball_scene = load("res://character/wizard/MagicBall.tscn")

func _ready():
	._ready()


# regular update function
func _physics_process(delta):
	
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
		print("DOWN !")
	
	# fire a lightning bolt (shotgun like)
	elif Input.is_action_just_pressed('attack'):
		_lightning_bolt()
	
	# throw a magic-ball that bound against walls (MisterMV)
	elif Input.is_action_just_pressed('secondary'):
		_magic_ball()
	
	._physics_process(delta)



# throw a lightning bolt
func _lightning_bolt():
	
	# find bodies in the zone of the bolt and apply damage to them
	var bodies = _bolt_zone.get_overlapping_bodies()
	for body in bodies:
		if is_enemy(body):
			# Damage enemies
			print("LIGHTNING BOLT!")
			pass

# throw a magic ball
func _magic_ball():
	# generate the ball
	var ball = _ball_scene.instance()
	ball.prepare(self)
	_root_node.add_child(ball)

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
			body.add_force(dir * impact_force)
			# TODO: damages
			impacted_one = true
	
	return impacted_one