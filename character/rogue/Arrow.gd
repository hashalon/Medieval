extends "res://character/Projectile.gd"

## ATTRIBUTES ##
export var impact_damage = 30
export var impact_force  = 15.0


## ENGINE ##

# maybe use _physics_process to detect collisions
func _physics_process(delta):
	# detect collisions
	if is_colliding():
		var obj = get_collider()
		if _character.is_enemy(obj):
			# damage
			
			# push back the enemy
			var dir = _velocity.normalized()
			if dir.y < EPSILON_IMPULSE: dir.y = EPSILON_IMPULSE
			obj.apply_damage(impact_damage, dir * impact_force)
			
		destroy()
	# move the projectile
	global_translate(_velocity * delta)