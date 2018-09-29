extends RayCast

export var lifetime   = 5
export var move_speed = 30
export var gravity    = 30

var _player   = null
var _velocity = Vector3()

func _ready():
	pass

# move projectile quickly
func _physics_process(delta):
	# restrict the life time of the projectile
	if lifetime > 0: lifetime -= delta
	else: explode()
	
	# move the projectile
	_velocity.y -= gravity * delta
	global_translate(_velocity * delta)
	look_at(global_transform.origin + _velocity, Vector3(0, 1, 0))
	
	# detect collisions
	if is_colliding():
		var obj = get_collider()
		if _player.is_enemy(obj):
			# TODO: damage enemy
			pass
		explode()
	

# the player who generated this projectile
func prepare(player):
	_player = player
	add_exception(player)
	var dir = player.get_forward_look()
	look_at(dir, Vector3(0, 1, 0))
	global_transform.origin = player.get_head_position()
	_velocity = dir * move_speed

# explode and damage enemies in the radius
func explode():
	print("BOOM!")
	queue_free()