extends KinematicBody

# attributes
export var is_controlled = true
export var sensitivity = Vector2(0.005, 0.003)
export var speed       = 10.0
export var jump_speed  = 7.5
export var gravity     = 10

# private members
var _velocity   = Vector3()        # velocity to apply
var _normal     = Vector3(0, 1, 0) # normal of the ground
var _jump_timer = 0                # reaction timer for jumping
var _push_force = Vector3()        # force to apply to the body

# constants
const REACTION_TIME  = 0.02
const MAX_SLIDES     = 4
const STEEP_SLOPE    = deg2rad(45)
const MAX_ANGLE      = deg2rad(90)
const AIR_RESISTANCE = 0.95
# used to alter the gravity applied when doing a high jump or low jump
const FALL_MULTIPLIER = 3
const JUMP_MULTIPLIER = 2

func _ready():
	if is_controlled: 
		capture_mouse()
		set_physics_process(true)
		set_process_input(true)
		

func _input(event):
	# handle head movements
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * sensitivity.x
		$Camera.rotation.x = clamp($Camera.rotation.x 
			- event.relative.y * sensitivity.y, -MAX_ANGLE, MAX_ANGLE)
	
	# when we press the escape key, release the mouse
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()

# regular update function
func _process(delta):
	if not is_controlled: return
	
	# release the mouse
	if Input.is_action_just_pressed('ui_menu'): release_mouse()
	
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
	var move = Quat(transform.basis) * Vector3(dir.x, 0, -dir.y)
	
	# check for ground normal
	if $Feet.is_colliding():
		_normal = $Feet.get_collision_normal()
	
	# compute the velocity
	var vel_y = _velocity.y
	var vel   = move * speed
	
	if is_on_floor():
		# start jumping
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
	_velocity    = vel
	_velocity.y += vel_y
	
	# apply the velocity
	move_and_slide(_velocity + _push_force, _normal, speed / 2, MAX_SLIDES, STEEP_SLOPE)
	_push_force *= AIR_RESISTANCE

# synchronized with physic engine
#func _physics_process(delta):
#	if not is_controlled: return
#	pass
	
func push(force):
	_push_force += force

# capture and release mouse
static func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
static func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


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