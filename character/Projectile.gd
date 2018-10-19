extends RayCast

## CONSTANTS ##
const CHARACTER       = preload('res://character/Character.gd')
const EPSILON_IMPULSE = CHARACTER.EPSILON_IMPULSE

## ATTRIBUTES ##
export var move_speed = 10
export var lifetime   = 5

## PRIVATES ##
var _character = null
var _velocity  = Vector3()


## NODES ##
onready var _ent_man = get_node('/root/EntityManager')


## SLAVES ##
slave var _slave_position = Vector3()
slave var _slave_velocity = Vector3()


## TO OVERRIDE ##

# the character who generated this projectile
func initialize(character):
	_character = character
	# ignore collision with player who emitted the projectile
	add_exception(_character)
	# add the projectile to the scene
	# TODO: notify other peers
	_ent_man.add_child(self)
	# set position and orientation of the projectile
	global_transform.origin = _character.get_emitter()
	global_transform.basis  = _character.get_head_basis()
	# set movement of the projectile
	_velocity = _character.get_forward_look() * move_speed
	
	# update the collision mask of the projectile
	match _character.team:
		CHARACTER.TEAM.alpha: set_collision_mask_bit(2, false)
		CHARACTER.TEAM.beta:  set_collision_mask_bit(3, false)
		CHARACTER.TEAM.gamma: set_collision_mask_bit(4, false)

# destroy the projectile once its life is over
func destroy():
	queue_free()


## ENGINE ##

func _process(delta):
	# restrict the life time of the projectile
	if lifetime > 0: lifetime -= delta
	else: destroy()