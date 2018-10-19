extends "res://character/Character.gd"

## CONSTANTS ##
const ALMOST_ONE   = 0.99
const SHIELD_ANGLE = 50   # angle of protection provided by the shield


## ATTRIBUTES ##

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


## PRIVATES ##
var _swing_left    = false
var _swing_timer   = 0
var _swing_hit     = false
var _shield_raised = false
var _charge_timer  = 0


## NODES ##
onready var _sword_zone   = $Head/Sword
onready var _shield_zone  = $Shield
onready var _shield_shape = $Shield/Shape


## TO OVERRIDE ##

# override class check to allow attacks
func is_class(type): return type == "Knight" or .is_class(type)
func get_class():    return         "Knight"

# set team of character
func set_team(team):
	.set_team(team)
	match team:
		TEAM.alpha:
			_sword_zone .set_collision_mask_bit(2, false)
			_shield_zone.set_collision_mask_bit(2, false)
		TEAM.beta:
			_sword_zone .set_collision_mask_bit(3, false)
			_shield_zone.set_collision_mask_bit(3, false)
		TEAM.gamma:
			_sword_zone .set_collision_mask_bit(4, false)
			_shield_zone.set_collision_mask_bit(4, false)


## NETWORKING ##


## ENGINE'S METHODS ##

#func _ready():
#	._ready()

# regular update function
func _process(delta):
	if is_controlled():
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
		elif not Input.is_action_pressed('attack'): _swing_left = true
	
		# if we are charging
		if _charge_timer > 0:
			_charge_timer -= delta
			_shield_raised = true
			
			# when the timer end, stop the charge
			if _charge_timer <= 0: _charge_end()
		
		elif Input.is_action_pressed('secondary'):
			_shield_raised = true
			current_speed = shield_speed
	
			# charge with the shield
			if Input.is_action_just_pressed('attack'): _charge_begin()
	
		# swing the sword
		elif Input.is_action_pressed('attack'):
			# alternate the direction of swing
			if _swing_timer <= 0:
				_swing_timer = sword_speed
				_swing_hit   = false
		
		# the shield zone needs to be active when the shield is raised
		_shield_shape.set_disabled(not _shield_raised)
		
	._process(delta)

# we need to use a synchronized process for the charge
func _physics_process(delta):
	if not is_controlled(): return
	
	# detect enemies on the path and collide with them
	if _charge_timer > 0: _push_enemies()


## PRIVATE METHODS ##

# setup the character to start a charge
func _charge_begin():
	# disable controls
	set_can_move(false)
	# activate charge
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
	set_can_move(true)
	# disable charge
	_charge_timer = 0
	# reset velocity
	_velocity     = Vector3()
	current_speed = move_speed


# when charging, push any enemies on the way
func _push_enemies():
	# prepare the force
	var dir = _velocity.normalized()
	if dir.y < EPSILON_IMPULSE: dir.y = EPSILON_IMPULSE
	var force = dir * charge_force
	
	# find all bodies on the way
	var bodies = _shield_zone.get_overlapping_bodies()
	for body in bodies:
		if is_enemy(body):
			# damage the character
			body.apply_damage(charge_damage, force)


# swipe the sword and push-damage the enemies
func _swipe_sword(swipe_left):
	# prepare the force
	var dir = Vector3(1, EPSILON_IMPULSE, -EPSILON_IMPULSE)
	if swipe_left: dir.x = -1
	var force = _head.global_transform.basis.xform(dir) * sword_force
	
	# apply damage and push force to all bodies in the zone
	var bodies = _sword_zone.get_overlapping_bodies()
	for body in bodies:
		if is_enemy(body):
			# damage the character
			body.apply_damage(sword_damage, force)




