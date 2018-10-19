extends Control

# need access to lobby to change player parameters
onready var _net_man  = get_node('/root/NetworkManager')
onready var _ent_man  = get_node('/root/EntityManager' )
onready var _map      = get_node('/root/Map')
onready var _selector = $Menu/Characters


func _ready():
	# names here need to match classes' names
	_selector.add_item('Knight'   , 0)
	_selector.add_item('Rogue'    , 1)
	_selector.add_item('Wizard'   , 2)
	_selector.add_item('Dragonewt', 3)
	$Menu/Spawn.connect('pressed', self, 'spawn_character')


func _process(delta):
	# display spawn screen as soon as our character die
	if _ent_man.my_character == null:
		set_visible(true)

# generate a character at the selected location
func spawn_character():
	# id of player, character to use and position to spawn
	var index     = _selector.get_selected_id()
	var selection = _selector.get_item_text(index)
	var spawn     = _map.get_random_spawn(_net_man.my_player.team)
	var net_id    = get_tree().get_network_unique_id()
	
	# send command to spawn character for everyone
	_ent_man.rpc('spawn_character', net_id, selection, spawn.translation, Vector2(spawn.rotation.y, 0))
	
	# when spawning the character, hide the menu
	set_visible(false)