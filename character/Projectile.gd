extends RayCast

export var move_speed = 10
export var lifetime   = 5

var _player   = null
var _velocity = Vector3()

const EPSILON_IMPULSE = 0.1

func _process(delta):
	# restrict the life time of the projectile
	if lifetime > 0: lifetime -= delta
	else: destroy()


# the player who generated this projectile
func initialize(player):
	_player = player
	# ignore collision with player who emitted the projectile
	add_exception(_player)
	# add the projectile to the scene
	_player.root_node.add_child(self)
	# set position and orientation of the projectile
	global_transform.origin = _player.get_emitter()
	global_transform.basis  = _player.get_head_basis()
	# set movement of the projectile
	_velocity = _player.get_forward_look() * move_speed

# destroy the projectile once its life is over
func destroy():
	queue_free()