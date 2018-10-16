extends "res://character/Character.gd"

# attributes...

# primary fire
export var fire_damage = 8
export var fire_force  = 2.0
export var fire_speed  = 1.0
# secondary fire
export var min_charge_time  = 0.05 # minimal charge amount
export var max_charge_time  = 2.0  # how long it takes to fully charge the cannon
export var cannon_pushback  = 10.0
export var min_charge_ratio = 0.5  # how powerfull is the cannon ball when minimal charge is applied
# hovering
export var hover_fall_speed = 0.1

var _ray_length   = 0
var _fire_timer   = 0
var _charge_timer = 0
var _is_charging  = false

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
func _process(delta):
	if not is_controlled(): return
	
	if _fire_timer > 0:
		_fire_timer -= delta
	
	# prepare cannon ball
	if Input.is_action_just_pressed('secondary'):
		_is_charging = true
	
	# release cannon ball
	elif Input.is_action_just_released('secondary'):
		
		# fire a large cannon-ball that explode on impact
		if _charge_timer > min_charge_time:
			if _charge_timer > max_charge_time:
				_cannon_ball(1)
			else:
				# charge ratio => power amount
				var ratio = (_charge_timer - min_charge_time) / (max_charge_time - min_charge_time)
				var power = min_charge_ratio + ratio * (1 - min_charge_ratio)
				_cannon_ball(power)
		
		_is_charging  = false
		_charge_timer = 0
	
	# charging the fire ball, block primary fire
	elif _is_charging:
		_charge_timer += delta
	
	# fire small sparks (shotgun like)
	elif Input.is_action_just_pressed('attack'):
		_fire_sparks()
	
	
	# allow the wizard to hover
	if not is_grounded():
		if Input.is_action_pressed('jump') and _velocity.y < 0:
			_velocity.y = -hover_fall_speed
	
	._process(delta)

# set team of character
func set_team(team):
	.set_team(team)
	var nb_bit = -1
	match team:
		TEAM.alpha: nb_bit = 2
		TEAM.beta:  nb_bit = 3
		TEAM.gamma: nb_bit = 4
	if nb_bit != -1:
		for ray in _rays:
			ray.set_collision_mask_bit(nb_bit, false)

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
				var dist  = global_transform.origin.distance_to(ray.get_collision_point())
				var ratio = (_ray_length - dist) / _ray_length
				
				# cumulate damages
				if characters.has(obj): characters[obj] += ratio
				else:                   characters[obj]  = ratio
	
	# apply damages
	for character in characters:
		var ratio = characters[character]
		character.apply_damage(ratio * fire_damage, get_forward_look() * ratio * fire_force)

# fire a cannon-ball
func _cannon_ball(power_ratio):
	# apply push back force to self
	var force = get_forward_look() * -cannon_pushback * power_ratio
	add_force(force)
	
	# create instance
	var ball = _ball_scene.instance()
	ball.initialize(self, power_ratio)


func is_class(type): return type == "Dragonewt" or .is_type(type)
func get_class():    return "Dragonewt"