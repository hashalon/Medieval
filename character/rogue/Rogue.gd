extends "res://character/Character.gd"

# attributes
export var hook_speed  = 200.0
# use the ray itself to define the maximum distance

# private members
var _hook_point = null # Vector3
var _jump_count = 0

# nodes...
onready var _hook_ray = $Camera/Hook

# projectile
onready var _arrow_scene = load("res://character/rogue/Arrow.tscn")

#func _ready():
#	._ready()


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
		var arrow = _arrow_scene.instance()
		arrow.initialize(self)
	
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
		_jump_count = 0
	elif Input.is_action_just_pressed('jump'):
		_jump_count += 1
		if _jump_count < 2: _velocity.y = jump_speed
	
	._physics_process(delta)

# hook and unhook
func _hook_begin():
	can_move_body = false
	_hook_point   = _hook_ray.get_collision_point()

func _hook_end():
	if _hook_point != null:
		_velocity = Vector3(0, jump_speed, 0)
	can_move_body = true
	_hook_point   = null
	_jump_count   = 0
	

