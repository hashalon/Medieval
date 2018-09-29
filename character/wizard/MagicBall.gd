extends RayCast

export var lifetime   = 10
export var move_speed = 10

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
		if not obj.is_class("Character"):
			# bounce of walls only
			bounce(get_collision_normal())
	# move the projectile
	global_translate(_velocity * delta)
	

# the player who generated this projectile
func prepare(player):
	_player = player
	add_exception(player)
	var dir = player.get_forward_look()
	#look_at(dir, Vector3(0, 1, 0))
	# TODO: rotate directly via the spatial class !
	global_transform.basis  = player.get_head_basis()
	global_transform.origin = player.get_head_position()
	_velocity = dir * move_speed

# make the ball bounce of the plane defined by the given normal
func bounce(normal):
	var dir = -_velocity.reflect(normal).normalized()
	look_at(global_transform.origin + dir, Vector3(0, 1, 0))
	_velocity = dir * move_speed