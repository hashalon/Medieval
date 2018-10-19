extends Node


const CHARACTER = preload('res://character/Character.gd')

# global camera to use if we don't have a local character yet
onready var _global_camera = $Points/Camera

# only handle team match
# (we cannot assume we will have enough players for Control Points mode, we need AI for that)

# for each team (alpha, beta), gather spawn points
onready var _spawns_alpha   = $Points/Alpha.get_children()
onready var _spawns_beta    = $Points/Beta .get_children()
onready var _spawns_neutral = []

func _ready():
	# add game menu and spawn menu
	var menu_spawn = load('res://hud/SpawnSelector.tscn').instance()
	var menu_game  = load('res://menu/GameMenu.tscn'    ).instance()
	get_tree().get_root().add_child(menu_spawn)
	get_tree().get_root().add_child(menu_game )
	
	for spawn in _spawns_alpha:
		_spawns_neutral.append(spawn)
	for spawn in _spawns_beta:
		_spawns_neutral.append(spawn)


# return a spawn point to use
func get_random_spawn(team):
	# select the spawn list to use based on the team
	var spawns = _spawns_neutral
	match team:
		CHARACTER.TEAM.alpha: spawns = _spawns_alpha
		CHARACTER.TEAM.beta:  spawns = _spawns_beta
	# pick a random spawn from the list
	var index = randi() % spawns.size()
	return spawns[index]


# set the global camera as the active one
func reset_camera():
	_global_camera.make_current()

