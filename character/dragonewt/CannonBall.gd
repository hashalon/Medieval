extends "res://character/Projectile.gd"

export var gravity          = 30
export var impact_damage    = 30
export var impact_force     = 30
export var explosion_damage = 20
export var explosion_force  = 20

onready var _explosion_zone   = $Explosion
onready var _explosion_radius = $Explosion/Radius.shape.radius

var _power_ratio = 1

func _ready():
	add_exception(_explosion_zone)
	

# maybe use _physics_process to detect collisions
func _process(delta):
	
	# move the projectile
	_velocity.y -= gravity * delta
	global_translate(_velocity * delta)
	look_at(global_transform.origin + _velocity, Vector3(0, 1, 0))
	
	# detect collisions
	if is_colliding():
		var obj = get_collider()
		if _player.is_enemy(obj):
			# TODO: damage enemy
			
			# push back the enemy
			var dir = _velocity.normalized()
			if dir.y < EPSILON_IMPULSE: dir.y = EPSILON_IMPULSE
			obj.apply_damage(impact_damage * _power_ratio, dir * impact_force * _power_ratio)
			
		destroy()
	
	._process(delta)

func initialize(player, power_ratio):
	.initialize(player)
	_velocity   *= power_ratio
	_power_ratio = power_ratio

# explode and damage enemies in the radius
func destroy():
	# apply damage and force to all bodies in the explosion radius
	var bodies = _explosion_zone.get_overlapping_bodies()
	var damage = explosion_damage * _power_ratio
	var force  = explosion_force  * _power_ratio
	for body in bodies:
		if _player.is_enemy(body):
			
			# compute the ratio of exposition to the explosion
			var vec   = body.global_transform.origin - global_transform.origin
			var dist  = vec.length()
			var power = (_explosion_radius - dist) / _explosion_radius
			
			# damage the enemy and push him back
			body.apply_damage(power * damage, vec.normalized() * power * force)
	
	.destroy()