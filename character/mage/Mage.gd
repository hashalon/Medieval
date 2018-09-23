extends "res://character/Character.gd"

# attributes
export var bolt_damage   = 8
export var bolt_pushback = 14.0

# nodes...
onready var _bolt_zone = $Camera/Bolt

#func _ready():
#	._ready()

#func _input(event):
#	._input(event)

# regular update function
func _physics_process(delta):
	
	# fire a lightning bolt (shotgun like)
	if Input.is_action_just_pressed('attack'):
		
		# apply push back force to self
		# (so that it can be used as a pseudo rocket jump)
		_lightning_bolt()
	
	# charge a fireball
	if Input.is_action_pressed('secondary'):
		pass
	
	# throw the fireball
	elif Input.is_action_just_released('secondary'):
		pass
	
	._physics_process(delta)


# throw a lightning bolt
func _lightning_bolt():
	
	# find bodies in the zone of the bolt and apply damage to them
	var bodies = _bolt_zone.get_overlapping_bodies()
	for body in bodies:
		pass
		
	# puch the character backward
	var force = _camera_node.global_transform.basis.xform(Vector3(0, 0, bolt_pushback))
	_velocity = force