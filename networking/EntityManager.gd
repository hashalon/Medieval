extends Node

## PUBLIC ##
var my_character = null

## NODES ##
onready var _net_man = get_node('/root/NetworkManager')

## SCENES ##

# List of character that can be selected
const CHARACTERS = {
	'Dragonewt': preload('res://character/dragonewt/Dragonewt.tscn'),
	'Knight':    preload('res://character/knight/Knight.tscn'      ),
	'Rogue':     preload('res://character/rogue/Rogue.tscn'        ),
	'Wizard':    preload('res://character/wizard/Wizard.tscn'      )
}

# List of projectiles that can be created
const PROJECTILES = {
	#'Arrow':      preload('res://character/archer/Arrow.tscn'        ),
	'MagicBall':  preload('res://character/wizard/MagicBall.tscn'    ),
	'CannonBall': preload('res://character/dragonewt/CannonBall.tscn')
}

#func _ready():
#	pass


## MANAGE CHARACTERS ##

# spawn character on all peers
sync func spawn_character(peer_id, character_name, spawn_position, orientation):
	# check that we try to spawn a valid character
	if not CHARACTERS.has(character_name):
		print('invalid character: ' + character_name)
		return
	# generate the character
	var player    = _net_man.players[peer_id]
	var character = CHARACTERS[character_name].instance()
	character.set_name(str(peer_id))
	# add the character
	add_child(character)
	character.init(peer_id, player.team, -1, spawn_position, orientation)
	
	if peer_id == get_tree().get_network_unique_id():
		my_character = character
		print(character_name + ' spawned for me.')
	else:
		print(character_name + ' spawned for player ' + player.name)


# remove a character
sync func delete_character(peer_id):
	var id = str(peer_id)
	if not has_node(id):
		print("Couldn't find character with ID " + id)
		return
	var character = get_node(id)
	# set our character as null
	if character == my_character: my_character = null
	# remove the node
	remove_child(character)


## MANAGE PROJECTILES ##

# spawn projectile on all peers
sync func spawn_projectile(peer_id, projectile_name, spawn_position, basis):
	# check that we try to spawn a valid projectile
	if not PROJECTILES.has(projectile_name):
		print('invalid projectile: ' + projectile_name)
		return
	# generate the projectile
	var player     = _net_man.players[peer_id]
	var projectile = PROJECTILES[projectile_name].instance()
	# don't rename the projectile...
	add_child(projectile)
	# TODO: init the projectile