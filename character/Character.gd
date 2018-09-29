extends KinematicBody

enum TEAM{
	neutral,
	alpha,
	beta
}

# attributes
export var is_controlled = true
export var sensitivity = Vector2(0.003, 0.0025)
export var move_speed  = 7.5
export var jump_speed  = 7.5
export var gravity     = 10.0

export var team   = TEAM.neutral
export var health = 100

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
onready var _root_node   = get_tree().get_root()
onready var _camera_node = $Camera
onready var _feet_node   = $Feet
onready var _model_node  = $Model

# constants
const REACTION_TIME   = 0.2
const MAX_SLIDES      = 4
const STEEP_SLOPE     = deg2rad(45)
const MAX_ANGLE       = deg2rad(90)
const EPSILON_IMPULSE = 0.1
# inertia of objects on the ground and in the air
const INERTIA_GROUND = 0.9
const INERTIA_AIR    = 0.99
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
		_camera_node.make_current()
		
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



# physic synchronized update function
func _physics_process(delta):
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
		
	# handle movement of the body based on inputs
	if can_move_body:
		var move = _get_inputs(delta)
		_process_vertical_velocity(move, delta)
	
	# apply the velocity
	_velocity += _push_force
	_push_force = Vector3()
	move_and_slide(_velocity, _normal, current_speed / 2, MAX_SLIDES, STEEP_SLOPE)


# process the inputs to get the direction of movement
func _get_inputs(delta):
	if not is_controlled: return Vector3()
	
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
	return global_transform.basis.xform(Vector3(dir.x, 0, -dir.y))


# manage vertical velocity
func _process_vertical_velocity(movement, delta):
	# compute the velocity
	var vel_y = _velocity.y
	var vel   = movement * current_speed
	
	# we need inertia to handle push back forces
	var inertia = INERTIA_GROUND
	
	if is_on_floor():
		# wanted to jump ? => start jumping
		if _jump_timer > 0:
			_jump_timer = 0
			vel_y = jump_speed
	else:
		# when in the air, the inertia is even greater
		inertia = INERTIA_AIR
		
		# compute the gravity to apply based on the situation
		var grav = gravity * delta
		var high = is_controlled and Input.is_action_pressed('jump')
		
		if _velocity.y < 0: vel_y -= grav * FALL_MULTIPLIER # falling
		elif high:          vel_y -= grav                   # high jump
		else:               vel_y -= grav * JUMP_MULTIPLIER # low jump
	
	# motion is subject to inertia
	var airVel = Vector3(_velocity.x, 0, _velocity.z)
	vel = airVel * inertia + vel * (1 - inertia)
	
	# apply the velocity
	_velocity = vel
	if not is_on_floor() or vel_y > 0:
		_velocity.y += vel_y


## public methods ##

# add a push back force to the character
func add_force(force):
	_push_force += force

# allow to set both head and body control in one call
func set_head_body_move(v):
	can_move_head = v
	can_move_body = v

# override class check to allow attacks
func is_class(type): return type == "Character" or .is_type(type)
func    get_class(): return "Character"

# return true if the character is really grounded
func is_grounded(): return is_on_floor() or _feet_node.is_colliding()

# two characters are enemies if one is neutral or their teams are different
func is_enemy(other):
	# no cast in godot
	if not other.is_class('Character') or other == self: return false
	return team == TEAM.neutral or other.team == TEAM.neutral or team != other.team

# return the direction the head is looking at
func get_forward_look():
	return _camera_node.global_transform.basis.xform(Vector3(0, 0, -1)).normalized()

# return the position of the head in global space
func get_head_position():
	return _camera_node.global_transform.origin

# return the basis of the head
func get_head_basis():
	return _camera_node.global_transform.basis

## STATIC FUNCTIONS ##

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