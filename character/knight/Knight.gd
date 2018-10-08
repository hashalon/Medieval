extends "res://character/Character.gd"

# shield attributes
export var shield_speed = 3.0

# charge attributes
export var charge_speed  = 50.0
export var charge_time   = 0.05
export var charge_damage = 30
export var charge_force  = 10.0

# sword attributes
export var sword_damage = 50
export var sword_force  = 10.0
export var sword_speed  = 0.25

export var downthrust_speed = 10

# private members
var _swing_left    = false
var _swing_timer   = 0
var _swing_hit     = false
var _shield_raised = false
var _charge_timer  = 0

# nodes...
onready var _sword_zone  = $Camera/Sword


const ALMOST_ONE   = 0.99
const SHIELD_ANGLE = 50   # angle of protection provided by the shield

#func _ready():
#	._ready()


# regular update function
func _process(delta):
	if not is_controlled: return

	# reset state
	_shield_raised = false
	current_speed  = move_speed
	
	if _swing_timer > 0:
		# when the sword reach the middle, apply the hit
		if _swing_timer <= sword_speed / 2 and not _swing_hit:
			_swipe_sword(_swing_left)
			_swing_left = not _swing_left
			_swing_hit  = true
		_swing_timer -= delta
	elif not Input.is_action_pressed('attack'):
		_swing_left = true

	# if we are charging
	if _charge_timer > 0:
		_charge_timer -= delta
		
		# when the timer end, stop the charge
		if _charge_timer <= 0: _charge_end()
	
	elif Input.is_action_pressed('secondary'):
		_shield_raised = true
		current_speed = shield_speed

		# charge with the shield
		if Input.is_action_just_pressed('attack'):
			_charge_begin()

	# swing the sword
	elif Input.is_action_pressed('attack'):
		# alternate the direction of swing
		if _swing_timer <= 0:
			_swing_timer = sword_speed
			_swing_hit   = false
		
	._process(delta)

# we need to use a synchronized process for the charge
func _physics_process(delta):
	if not is_controlled: return
	
	# detect enemies on the path and collide with them
	if _charge_timer > 0:
		_push_enemies()

# set team of character
func set_team(team):
	.set_team(team)
	match team:
		TEAM.alpha: _sword_zone.set_collision_mask_bit(2, false)
		TEAM.beta:  _sword_zone.set_collision_mask_bit(3, false)
		TEAM.gamma: _sword_zone.set_collision_mask_bit(4, false)

# setup the character to start a charge
func _charge_begin():
	# disable controls
	set_head_body_move(false)
	# activate charge
	#_charge_ray.set_enabled(true)
	_charge_timer = charge_time
	# manage velocity
	_push_force   = Vector3()
	_velocity     = get_forward_look() * charge_speed
	current_speed = charge_speed
	
	# if the plane is bend, project the velocity on the plane
	if _normal.y < ALMOST_ONE:
		var plane = Plane(_normal, 0)
		_velocity = plane.project(_velocity)


# re-setup the character to move normally again
func _charge_end():
	# reactivate controls
	set_head_body_move(true)
	# disable charge
	#_charge_ray.set_enabled(false)
	_charge_timer = 0
	# reset velocity
	_velocity     = Vector3()
	current_speed = move_speed


# when charging, push any enemies on the way
func _push_enemies():
	# see each collided object
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		var obj = collision.collider
		
		# if the object is a character -> impact him
		if is_enemy(obj): 
			var dir = _velocity.normalized()
			if dir.y < EPSILON_IMPULSE: dir.y = EPSILON_IMPULSE
			obj.apply_damage(charge_damage, dir * charge_force)


# swipe the sword and push-damage the enemies
func _swipe_sword(swipe_left):
	var dir = Vector3(1, EPSILON_IMPULSE, -EPSILON_IMPULSE)
	if swipe_left: dir.x = -1
	var force = _camera_node.global_transform.basis.xform(dir) * sword_force
	
	# apply damage and push force to all bodies in the zone
	var bodies = _sword_zone.get_overlapping_bodies()
	for body in bodies:
		if is_enemy(body):
			# damage the character
			body.apply_damage(sword_damage, force)

## public methods ##
func apply_damage(damage, force):
	# no shield => nothing to do in particular
	if not _shield_raised:
		.apply_damage(damage, force)
		return
	
	# if the force is purely vertical, don't apply damages
	if force.x == 0 and force.z == 0:
		return
	
	# check direction of force
	var dir1 = global_transform.basis.xform(Vector3(0, 0, -1))
	var dir2 = -force
	# flatten the directions
	dir1.y = 0
	dir2.y = 0
	# check the angle between the two directions
	if dir1.angle_to(dir2) > SHIELD_ANGLE:
		.apply_damage(damage, force)