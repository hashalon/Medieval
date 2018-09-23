extends "res://character/Character.gd"

# shield attributes
export var shield_speed = 3.0

# charge attributes
export var charge_speed  = 50.0
export var charge_time   = 0.1
export var charge_damage = 30

# sword attributes
export var sword_damage = 50


# private members
var _shield_raised = false
var _charge_timer  = 0

# nodes...
onready var _sword_zone  = $Camera/Sword
onready var _charge_ray  = $Charge
onready var _charge_cast = $Charge.get_cast_to().normalized()

const ALMOST_ONE = 0.99

func _ready():
	._ready()
	

#func _input(event):
#	._input(event)


# regular update function
func _physics_process(delta):
	if not is_controlled: return

	# reset state
	_shield_raised = false
	current_speed  = move_speed

	# if we are charging
	if _charge_timer > 0:
		_charge_timer -= delta
		
		# correct cast distance
		_charge_ray.set_cast_to(_charge_cast * (charge_speed * delta))
		
		# check for collisions forward
		if _charge_ray.is_colliding():
			end_charge()
			var obj = _charge_ray.get_collider()
			# TODO: apply pushback force to object
		
		# when the timer end, stop the charge
		if _charge_timer <= 0: end_charge()

	elif Input.is_action_pressed('secondary'):
		_shield_raised = true
		current_speed = shield_speed

		# charge with the shield
		if Input.is_action_just_pressed('attack'):
			start_charge()

	# swing the sword
	elif Input.is_action_pressed('attack'):
		# find direction of swipe: either left or right
		var dir = Vector3(1, 0, 0)
		
		# apply damage and push force to all bodies in the zone
		var bodies = _sword_zone.get_overlapping_bodies()
		for body in bodies:
			# TODO: check body type (character or other)
			pass
	
	._physics_process(delta)

# setup the character to start a charge
func start_charge():
	# disable controls
	set_head_body_move(false)
	# activate charge
	_charge_ray.set_enabled(true)
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
func end_charge():
	# reactivate controls
	set_head_body_move(true)
	# disable charge
	_charge_ray.set_enabled(false)
	_charge_timer = 0
	# reset velocity
	_velocity     = Vector3()
	current_speed = move_speed

func push_enemies():
	# see each collided object
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		var obj = collision.collider
		
		# if the object is a character -> impact him
		if obj.is_type("Player"): # no cast in godot
			
			pass
		
	pass

# regular update function
#func _process(delta):
#	._process(delta)
#	if not is_controlled: return
#	can_move_body = true
#
#	# raise the shield
#	if _is_charging:
#		can_move_body = false
#
#		# project the charge motion on the ground
#		var forward   = global_transform.basis.xform(Vector3(0, 0, 1))
#		var motion    = _normal.cross(_normal.cross(forward))
#		var collision = move_and_collide(motion * charge_speed * delta)
#		if collision != null:
#			_is_charging = false
#			var obj = collision.collider
#			# TODO: push_back enemy and apply damage
#
#	elif Input.is_action_pressed('secondary'):
#		_shield_raised = true
#
#		# charge with the shield
#		if Input.is_action_just_pressed('attack'):
#			_is_charging = true
#			_push_force  = Vector3()
#			_velocity    = Vector3()
#			_charge_direction = global_transform.basis.xform(Vector3(0, 0, -1))
#
#	# swing the sword
#	elif Input.is_action_pressed('attack'):
#		pass