extends Node

# store all characters in the scene here
var _characters = {}

func _ready():
	pass

func _process(delta):
	#$Camera.make_current()
	pass

func add_character(character):
	_characters[character] = true

func remove_character(character):
	_characters.erase(character)

# return the list of characters of specified team in the given radius
func get_characters(team, position, radius):
	var out = []
	for c in _characters:
		if c.team == team and position.distance_to(c.global_transform.origin) < radius:
			out.append(c)
	return out

#func _ready():
#	var new_player = preload('res://player/Player.tscn').instance()
#	var id = get_tree().get_network_unique_id()
#	new_player.name = str(id)
#	new_player.set_network_master(id)
#	get_tree().get_root().add_child(new_player)
#	var info = Network.self_data
#	new_player.init(info.name, info.position, false)