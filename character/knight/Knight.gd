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
export var sword_force  = 5.0

export var downthrust_speed = 10

# private members
var _shield_raised = false
var _charge_timer  = 0
var _is_downthrusting = false

# nodes...
onready var _sword_zone  = $Camera/Sword


const ALMOST_ONE = 0.99


func _ready():
	._ready()


# regular update function
func _physics_process(delta):
	if not is_controlled: return

	# reset state
	_shield_raised = false
	current_speed  = move_speed

	# if we are charging
	if _charge_timer > 0:
		_charge_timer -= delta
		
		# detect enemies on the path and collide with them
		_push_enemies()
		
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
		# find direction of swipe: either left or right
		_swipe_sword(false)
		
	._physics_process(delta)


# setup the character to start a charge
func _charge_begin():
	# disable controls
	set_head_body_move(false)
	# activate charge
	#_charge_ray.set_enabled(true)
	_charge_timer = charge_time
	# manage velocity
	_push_force   = Vector3()
	_velocity     = global_transform.basis.xform(Vector3(0, 0, -1)).normalized() * charge_speed
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
			if dir.y < 0: dir.y = 0
			obj.add_force(dir * charge_force)
			# TODO: damages


# swipe the sword and push-damage the enemies
func _swipe_sword(swipe_left):
	var dir = Vector3(1, 0, 0)
	if swipe_left: dir = Vector3(-1, 0, 0)
	var force = _camera_node.global_transform.basis.xform(dir) * sword_force
	
	# apply damage and push force to all bodies in the zone
	var bodies = _sword_zone.get_overlapping_bodies()
	for body in bodies:
		if is_enemy(body):
			body.add_force(force)
			# damage the character



## public methods ##
func add_force(force):
	# TODO: check direction of force when shield is raised
	.add_force(force)