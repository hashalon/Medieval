extends "res://character/Projectile.gd"

export var contact_damage = 10

onready var _damage_zone = $Damage

func _ready():
	add_exception(_damage_zone)

# maybe use _physics_process to detect collisions
func _process(delta):
	
	# move the projectile
	global_translate(_velocity * delta)
	
	# get all bodies on the path of the magic ball
	var bodies = _damage_zone.get_overlapping_bodies()
	for body in bodies:
		if _player.is_enemy(body):
			body.add_damage(contact_damage) # damage enemy
	
	._process(delta)

func _physics_process(delta):
	# detect collisions
	if is_colliding():
		var obj = get_collider()
		if not obj.is_class("Character"):
			# bounce of walls only
			bounce(get_collision_normal())

func initialize(player, power_ratio):
	.initialize(player)
	
	# update the collision mask of the projectile
	match _player.team:
		CHARACTER.TEAM.alpha: _damage_zone.set_collision_mask_bit(2, false)
		CHARACTER.TEAM.beta:  _damage_zone.set_collision_mask_bit(3, false)
		CHARACTER.TEAM.gamma: _damage_zone.set_collision_mask_bit(4, false)

# make the ball bounce of the plane defined by the given normal
func bounce(normal):
	var dir = -_velocity.reflect(normal).normalized()
	look_at(global_transform.origin + dir, Vector3(0, 1, 0))
	_velocity = dir * move_speed