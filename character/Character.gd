extends KinematicBody

# collision layout:
# 0 : world
# 1 : neutral
# 2 : alpha
# 3 : beta
# 4 : gamma

enum  TEAM { neutral, alpha, beta, gamma }
const MANAGER = preload('res://character/Manager.gd')


## CONSTANTS ##
const REACTION_TIME   = 0.2
const MAX_SLIDES      = 4
const STEEP_SLOPE     = deg2rad(45)
const MAX_ANGLE       = deg2rad(90)
const EPSILON_IMPULSE = 0.2
# inertia of objects on the ground and in the air
const INERTIA_GROUND = 0.9
const INERTIA_AIR    = 0.99
# used to alter the gravity applied when doing a high jump or low jump
const FALL_MULTIPLIER = 3
const JUMP_MULTIPLIER = 2
# angle of direction to tell if the character can run forward
const RUN_ANGLE_LIMIT = deg2rad(90 - (70/2))


## ATTRIBUTES ##
export var sensitivity = Vector2(0.003, 0.0025)
export var move_speed  = 7.5
export var jump_speed  = 7.5
export var gravity     = 10.0

export(TEAM) var team = TEAM.neutral
export var health = 100


## MODIFIERS ##
onready var current_speed = move_speed
var can_move_head = true
var can_move_body = true


## PRIVATES ##
var _velocity   = Vector3()        # velocity to apply
var _normal     = Vector3(0, 1, 0) # normal of the ground
var _push_force = Vector3()        # force to apply to the body
var _jump_timer = 0                # reaction timer for jumping


## NODES ##
onready var manager = get_tree().get_root().get_node('Root')
onready var _camera_node = $Camera
onready var _feet_node   = $Feet
onready var _model_node  = $Model


## SLAVES ##
slave var _slave_position = Vector3()
slave var _slave_velocity = Vector3()


## ENGINE'S METHODS ##

# when the character is created
func _ready():
	if is_network_master(): 
		make_controllable()
	if team != TEAM.neutral:
		set_team(team)
	manager.add_character(self)


# manage mouse movements
func _input(event):
	if not is_network_master(): return
	
	# handle head movements
	if event is InputEventMouseMotion and can_move_head:
		rotation.y -= event.relative.x * sensitivity.x
		_camera_node.rotation.x = clamp(_camera_node.rotation.x 
			- event.relative.y * sensitivity.y, -MAX_ANGLE, MAX_ANGLE)


# physic synchronized update function
func _process(delta):
	if is_network_master():
		# check for ground normal
		#_normal = _feet_node.get_collision_normal() if _feet_node.is_colliding() else Vector3(0, 1, 0)
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
		
		# send pose to others
		rpc_unreliable('set_pose', translation, _velocity, rotation.y, _camera_node.rotation.x)
	
	# apply for all (local and remotes)
	move_and_slide(_velocity, _normal, current_speed / 2, MAX_SLIDES, STEEP_SLOPE)
	
	# check health
	if health <= 0: die()


## PRIVATE METHODS ##

# process the inputs to get the direction of movement
func _get_inputs(delta):
	if not is_network_master(): return Vector3()
	
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
		var high = is_network_master() and Input.is_action_pressed('jump')
		
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


## SLAVE METHODS ##

# synchronize character motion to other peers
slave func set_pose(pos, vel, rot_h, rot_v):
	translation = pos
	_velocity   = vel
	rotation.y  = rot_h
	_camera_node.rotation.x = rot_v


## PUBLIC METHODS ##

# add force or damage the character
func add_force(force):
	_push_force += force

func add_damage(damage): 
	health -= damage
	if health < 0: health = 0

# add force and damages to the character
func apply_damage(damage, force):
	_push_force += force
	health      -= damage
	if health < 0: health = 0


# set this character as the controlled one
func make_controllable():
	#is_controlled = true
	MANAGER.capture_mouse()
	_model_node.visible = false
	_camera_node.make_current()

# set the team of the character
func set_team(team):
	self.team = team
	if team != TEAM.neutral:
		set_collision_layer_bit(1, false)
		match team:
			TEAM.alpha: set_collision_layer_bit(2, true)
			TEAM.beta:  set_collision_layer_bit(3, true)
			TEAM.gamma: set_collision_layer_bit(4, true)


# kill the character
func die():
	manager.remove_character(self)
	set_network_master(1)


# allow to set both head and body control in one call
func set_head_body_move(v):
	can_move_head = v
	can_move_body = v


# override class check to allow attacks
func is_class(type): return type == "Character" or .is_type(type)
func get_class():    return "Character"

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

# return position and rotation of the head
func get_head_position(): return _camera_node.global_transform.origin
func get_head_basis():    return _camera_node.global_transform.basis

# return the emitter of the character (for projectiles)
func get_emitter(): return _camera_node.global_transform.origin


## STATIC FUNCTIONS ##

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