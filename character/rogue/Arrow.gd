extends RayCast

export var lifetime   = 2
export var move_speed = 100

var _player   = null
var _velocity = Vector3()

func _ready():
	pass

func _physics_process(delta):
	# restrict the life time of the projectile
	if lifetime > 0: lifetime -= delta
	else: queue_free()
	
	# detect collisions
	if is_colliding():
		var obj = get_collider()
		if obj.is_class("Character"):
			# damage
			pass
		queue_free()
	# move the projectile
	global_translate(_velocity * delta)
	

# the player who generated this projectile
func prepare(player):
	_player = player
	add_exception(player)
	var dir = player.get_forward_look()
	look_at(dir, Vector3(0, 1, 0))
	global_transform.origin = player.get_head_position()
	_velocity = dir * move_speed