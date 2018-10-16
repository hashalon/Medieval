extends Control

# need access to lobby to change player parameters
onready var _lobby = get_tree().get_root().get_node('Lobby')
onready var _selector = $Menu/Characters
onready var _map = get_node('/root/Map')

func _ready():
	_selector.add_item('Knight'   , 0)
	_selector.add_item('Rogue'    , 1)
	_selector.add_item('Wizard'   , 2)
	_selector.add_item('Dragonewt', 3)
	$Menu/Spawn.connect('pressed', self, 'spawn_character')


# generate a character at the selected location
func spawn_character():
	# id of player, character to use and position to spawn
	var index     = _selector.get_selected_id()
	var selection = _selector.get_item_text(index)
	var position  = _map.get_random_spawn(_lobby.my_player.team).translation
	var net_id = get_tree().get_network_unique_id()
	
	# send command to spawn character for everyone
	_lobby.rpc('spawn_character', net_id, selection, position)
	
	# when spawning the character, hide the menu
	self.visible = false