extends "res://character/Character.gd"

# attributes
export var bolt_damage   = 8
export var bolt_pushback = 10.0

# nodes...
onready var _bolt_zone = $Camera/Bolt

func _ready():
	._ready()


# regular update function
func _physics_process(delta):
	
	# if we are downthrusting
	if _is_downthrusting:
		_velocity.y = -downthrust_speed
		if is_grounded():
			_downthrust_end()
	
	elif Input.is_action_just_pressed('jump') and not is_grounded():
		_downthrust_begin()
	
	# fire a lightning bolt (shotgun like)
	elif Input.is_action_just_pressed('attack'):
		_lightning_bolt()
	
	# throw a magic-ball that bound against walls (MisterMV)
	elif Input.is_action_just_pressed('secondary'):
		pass
	
	._physics_process(delta)



# throw a lightning bolt
func _lightning_bolt():
	
	# find bodies in the zone of the bolt and apply damage to them
	var bodies = _bolt_zone.get_overlapping_bodies()
	for body in bodies:
		if is_enemy(body):
			# Damage enemies
			pass


# downthrust to impact enemies
func _downthrust_begin():
	# impact the ground with the sword !
	_velocity = Vector3(0, -downthrust_speed, 0)
	_is_downthrusting = true
	# look downward
	can_move_head = false
	_camera_node.rotation.x = -MAX_ANGLE

func _downthrust_end():
	_is_downthrusting = false
	can_move_head     = true
	# impact enemies !