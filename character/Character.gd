extends KinematicBody

# attributes
export var is_controlled = true
export var sensitivity = Vector2(0.003, 0.0025)
export var move_speed  = 7.5
export var jump_speed  = 7.5
export var gravity     = 10.0

# modifiers
onready var current_speed = move_speed
var can_move_head = true
var can_move_body = true

# private members
var _velocity   = Vector3()        # velocity to apply
var _normal     = Vector3(0, 1, 0) # normal of the ground
var _push_force = Vector3()        # force to apply to the body
var _jump_timer = 0                # reaction timer for jumping

# nodes...
onready var _camera_node = $Camera
onready var _feet_node   = $Feet
onready var _model_node  = $Model

# constants
const REACTION_TIME  = 0.2
const MAX_SLIDES     = 4
const STEEP_SLOPE    = deg2rad(45)
const MAX_ANGLE      = deg2rad(90)
const AIR_RESISTANCE = 0.1
# used to alter the gravity applied when doing a high jump or low jump
const FALL_MULTIPLIER = 3
const JUMP_MULTIPLIER = 2
# angle of direction to tell if the character can run forward
const RUN_ANGLE_LIMIT = deg2rad(90 - (70/2))

# when the character is created
func _ready():
	if is_controlled: 
		capture_mouse()
		_model_node.visible = false
		
# manage mouse movements
func _input(event):
	if not is_controlled: return
	
	# handle head movements
	if event is InputEventMouseMotion and can_move_head:
		rotation.y -= event.relative.x * sensitivity.x
		_camera_node.rotation.x = clamp(_camera_node.rotation.x 
			- event.relative.y * sensitivity.y, -MAX_ANGLE, MAX_ANGLE)
	
	if Input.is_key_pressed(KEY_ESCAPE): 
		get_tree().quit()

# regular update function
func _physics_process(delta):
	if not is_controlled: return
	
	# TODO:... when we press the escape key, release the mouse
	if Input.is_key_pressed(KEY_ESCAPE): 
		release_mouse()
		is_controlled = false
		get_tree().quit()
	
	# check for ground normal
	if _feet_node.is_colliding():
		_normal = _feet_node.get_collision_normal()
	else:
		_normal = Vector3(0, 1, 0)
	
	# cannot control body
	if can_move_body:
		
		# we may want to jump, process jump reaction time
		if Input.is_action_just_pressed('jump'): _jump_timer = REACTION_TIME
		if _jump_timer > 0: _jump_timer -= delta
		
		# detect user movement
		var dir = Vector2()
		if Input.is_action_pressed('left' ): dir.x -= 1
		if Input.is_action_pressed('right'): dir.x += 1
		if Input.is_action_pressed('up'   ): dir.y += 1
		if Input.is_action_pressed('down' ): dir.y -= 1
		if dir.length_squared() > 1: dir = dir.normalized()
		
		# turn input into movement
		var move = global_transform.basis.xform(Vector3(dir.x, 0, -dir.y))
		
		# compute the velocity
		var vel_y = _velocity.y
		var vel   = move * current_speed
		
		if is_on_floor():
			# wanted to jump ? => start jumping
			if _jump_timer > 0:
				_jump_timer = 0
				vel_y = jump_speed
		else:
			# when moving in the air, apply a little air resistance
			var airVel = Vector3(_velocity.x, 0, _velocity.z)
			vel = airVel * AIR_RESISTANCE + vel * (1 - AIR_RESISTANCE)
			
			# compute the gravity to apply based on the situation
			var grav = gravity * delta
			if _velocity.y < 0:                   # falling
				vel_y -= grav * FALL_MULTIPLIER
			elif Input.is_action_pressed('jump'): # high jump
				vel_y -= grav
			else:                                 # low jump
				vel_y -= grav * JUMP_MULTIPLIER
		
		# apply the velocity
		_velocity = vel
		if not is_on_floor() or vel_y > 0:
			_velocity.y += vel_y
	
	# apply the velocity
	_velocity += _push_force
	_push_force = Vector3()
	move_and_slide(_velocity, _normal, current_speed / 2, MAX_SLIDES, STEEP_SLOPE)


# add a push back force to the character
func add_force(force):
	_push_force += force

# allow to set both head and body control in one call
func set_head_body_move(v):
	can_move_head = v
	can_move_body = v

func is_type(type): return type == "Character" or .is_type(type)
func    get_type(): return "Character"

# capture and release mouse
static func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

static func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# return true if the angle is in the defined range
static func in_angular_range(angle):
	return (PI - RUN_ANGLE_LIMIT) > angle and angle > RUN_ANGLE_LIMIT

# slave variables
#slave var slave_position = Vector3()
#slave var slave_movement = Vector3()

#func _physics_process(delta):
#	var dir = Vector2()
#	if is_network_master():
#		if Input.is_action_pressed('left'):
#			dir.x -= 1
#		if Input.is_action_pressed('right'):
#			dir.x += 1
#		if Input.is_action_pressed('up'):
#			dir.y += 1
#		if Input.is_action_pressed('down'):
#			dir.y -= 1
#		rset_unreliable('slave_pos', position)
#		rset_unreliable('slave_mov', dir)
#		_move(dir)
#	else:
#		_move(slave_dir)
#		position = slave_pos
#
#	if get_tree().is_network_server():
#		Network.update_position(int(name), position)
#
#func _move(dir):
#	if dir == Vector2():
#		return
#	else:
#		move_and_collide(Vector3(dir.x, 0, dir.z))
#
#func damage(value):
#	health -= value
#	if health <= 0:
#		health = 0
#		rpc('_die')
#
#sync func _die():
#	set_physics_process(false)
#	print('DEAD !')
#
#func init(nickname, start_pos, is_slave):
#	global_position = start_pos
#	if is_slave:
#		print('is slave')