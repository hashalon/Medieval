extends "res://character/Character.gd"

# attributes
export var fire_damage     = 8
export var cannon_pushback = 10.0
export var hover_fall      = 0.1

# get rays for the shotgun
onready var _rays = $Camera.get_children()


func _ready():
	._ready()
	
	for ray in _rays:
		ray.add_exception(self)

# regular update function
func _physics_process(delta):

	# fire small sparks (shotgun like)
	if Input.is_action_just_pressed('attack'):
		_fire_sparks()

	# fire a large cannon-ball that explode on impact
	elif Input.is_action_just_pressed('secondary'):
		_cannon_ball()
	
	#._physics_process(delta)
	
	# allow the wizard to hover
	if not is_grounded():
		if Input.is_action_pressed('jump') and _velocity.y < 0:
			_velocity.y = -hover_fall
	
	._physics_process(delta)



# throw a lightning bolt
func _fire_sparks():
	# because rays are disabled, we need to manually update each one of them when 
	for ray in _rays:
		ray.force_raycast_update()
		

# fire a cannon-ball
func _cannon_ball():
	var force = _camera_node.global_transform.basis.xform(Vector3(0, 0, cannon_pushback))
	add_force(force)

	# allow pushback only if touching the ground
#	if _bolt_target.is_colliding():
#		var obj = _bolt_target.get_collider()
#		if obj.is_class("Character"): return
#
#		# check distance from target point to deduce the force to apply
#		var point  = _bolt_target.get_collision_point()
#		var origin = global_transform.origin
#		point.y    = 0
#		origin.y   = 0
#		var dist   = origin.distance_to(point)
#		if dist <= 0: return
#
#		# push the character backward
#		var amp = bolt_pushback * (_bolt_distance - dist) / _bolt_distance
#		var force = _camera_node.global_transform.basis.xform(Vector3(0, 0, amp))
#		add_force(force)