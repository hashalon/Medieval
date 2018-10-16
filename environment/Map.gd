extends Node


const CHARACTER = preload('res://character/Character.gd')

# global camera to use if we don't have a local character yet
onready var _global_camera = $Points/Camera
onready var _game_menu     = $GameMenu

# only handle team match
# (we cannot assume we will have enough players for Control Points mode, we need AI for that)

# for each team (alpha, beta), gather spawn points
onready var _spawns_alpha   = $Points/Alpha.get_children()
onready var _spawns_beta    = $Points/Beta .get_children()
onready var _spawns_neutral = []

func _ready():
	for spawn in _spawns_alpha:
		_spawns_neutral.append(spawn)
	for spawn in _spawns_beta:
		_spawns_neutral.append(spawn)

func _process(delta):
	# on ESCAPE key, display a menu
	if Input.is_action_just_pressed('ui_cancel'):
		if _game_menu.is_visible(): # menu was active
			_game_menu.set_visible(false)
			CHARACTER.capture_mouse()
		else:
			_game_menu.set_visible(true)
			CHARACTER.release_mouse()

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

func is_game_menu_visible():
	return _game_menu.is_visible()
