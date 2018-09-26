extends "res://character/Character.gd"

# attributes
export var hook_speed = 200.0
# use the ray itself to define the maximum distance

# private members
var _hook_point = null # Vector3

# nodes...
onready var _target_ray = $Camera/Target


func _ready():
	._ready()


# regular update function
func _physics_process(delta):
	if not is_controlled: return
	
	# tells the user if he can fire the grappling-hook
	# (keep the ray always enabled so that we can see 
	# next hook anchor even when already hooked)
	if _target_ray.is_colliding():
		pass
	
	# fire an arrow
	if Input.is_action_just_pressed('attack'):
		pass
	
	# use grappling hook
	if Input.is_action_just_pressed('secondary'):
		# if the ray is in range then we can hook
		if _target_ray.is_colliding():
			can_move_body = false
			_hook_point   = _target_ray.get_collision_point()
		
	elif Input.is_action_just_released('secondary'):
		if _hook_point != null:
			_velocity = Vector3(0, jump_speed, 0)
		can_move_body = true
		_hook_point   = null
	
	# if the hook is anchored, move toward it
	if _hook_point != null:
		# velocity is proportional to distance from hook point
		var pos   = global_transform.origin
		var diff  = _hook_point - pos
		_velocity = diff * (hook_speed * delta)
		#add_force(diff * (hook_speed * delta))
	
	._physics_process(delta)
