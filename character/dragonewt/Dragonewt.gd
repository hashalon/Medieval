extends "res://character/Character.gd"

# attributes
export var fire_damage     = 8
export var cannon_pushback = 10.0
export var hover_fall      = 0.1

var _ray_length = 0

# get rays for the shotgun
onready var _rays = $Camera.get_children()

# projectile
onready var _ball_scene = load("res://character/dragonewt/CannonBall.tscn")

func _ready():
	._ready()
	
	# ignore self for each ray
	for ray in _rays:
		ray.add_exception(self)
	_ray_length = abs(_rays[0].get_cast_to().z)

# regular update function
func _physics_process(delta):

	# fire small sparks (shotgun like)
	if Input.is_action_just_pressed('attack'):
		_fire_sparks()

	# fire a large cannon-ball that explode on impact
	elif Input.is_action_just_pressed('secondary'):
		_cannon_ball()
	
	#._physics_process(delta)
	
	# allow the wizard to hover
	if not is_grounded():
		if Input.is_action_pressed('jump') and _velocity.y < 0:
			_velocity.y = -hover_fall
	
	._physics_process(delta)



# throw a lightning bolt
func _fire_sparks():
	var characters = {} # dictionary
	
	# because rays are disabled, we need to manually update each one of them when 
	for ray in _rays:
		ray.force_raycast_update()
		
		# for each ray, see if we collided with something
		if ray.is_colliding():
			var obj = ray.get_collider()
			if is_enemy(obj):
				var dist   = global_transform.origin.distance_to(ray.get_collision_point())
				var damage = fire_damage * (_ray_length - dist) / _ray_length
				
				# cumulate damages
				if characters.has(obj):
					characters[obj] += damage
				else:
					characters[obj] = damage
	
	# apply damages
	for chr in characters:
		var dmg = characters[chr]
		print("damage " + str(dmg))

# fire a cannon-ball
func _cannon_ball():
	# apply push back force to self
	var force = get_forward_look() * -cannon_pushback
	add_force(force)
	
	# create instance
	var ball = _ball_scene.instance()
	ball.prepare(self)
	_root_node.add_child(ball)
	
	# allow pushback only if touching the ground
#	if _bolt_target.is_colliding():
#		var obj = _bolt_target.get_collider()
#		if obj.is_class("Character"): return
#
#		# check distance from target point to deduce the force to apply
#		var point  = _bolt_target.get_collision_point()
#		var origin = global_transform.origin
#		point.y    = 0
#		origin.y   = 0
#		var dist   = origin.distance_to(point)
#		if dist <= 0: return
#
#		# push the character backward
#		var amp = bolt_pushback * (_bolt_distance - dist) / _bolt_distance
#		var force = _camera_node.global_transform.basis.xform(Vector3(0, 0, amp))
#		add_force(force)