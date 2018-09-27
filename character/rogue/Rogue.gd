extends "res://character/Character.gd"

# attributes
export var hook_speed  = 200.0
export var double_jump = 5.0
# use the ray itself to define the maximum distance

# private members
var _hook_point = null # Vector3
var _has_jumped = false

# nodes...
onready var _hook_ray = $Camera/Hook


func _ready():
	._ready()


# regular update function
func _physics_process(delta):
	if not is_controlled: return
	
	# tells the user if he can fire the grappling-hook
	# (keep the ray always enabled so that we can see 
	# next hook anchor even when already hooked)
	if _hook_ray.is_colliding():
		pass
	
	# fire an arrow
	if Input.is_action_just_pressed('attack'):
		pass
	
	# use grappling hook
	if Input.is_action_just_pressed('secondary'):
		# if the ray is in range then we can hook
		if _hook_ray.is_colliding():
			_hook_begin()
		
	elif Input.is_action_just_released('secondary'):
		_hook_end()
	
	# if the hook is anchored, move toward it
	if _hook_point != null:
		# velocity is proportional to distance from hook point
		var pos   = global_transform.origin
		var diff  = _hook_point - pos
		_velocity = diff * (hook_speed * delta)
	
	# allow multiple jumps
	if is_grounded():
		_has_jumped = false
	else:
		if Input.is_action_just_pressed('jump') and not _has_jumped:
			_velocity.y = double_jump
			_has_jumped = true
	
	._physics_process(delta)

# hook and unhook
func _hook_begin():
	can_move_body = false
	_hook_point   = _hook_ray.get_collision_point()

func _hook_end():
	if _hook_point != null:
		_velocity = Vector3(0, double_jump, 0)
	can_move_body = true
	_hook_point   = null
	_has_jumped   = false
	

