extends Control

const MAP_PATH = 'res://maps/'

# need access to network manager for hosting
onready var _net_man = get_node('/root/NetworkManager')

# provide a list of map to select and run a game
onready var _maps = $Menu/Maps

func _ready():
	$Menu/Buttons/BtnHost.connect('pressed', self, 'host_game')
	
	# add the maps to the list
	var map_files = list_files_in_directory(MAP_PATH)
	for map in map_files:
		_maps.add_item(map)

func host_game():
	# pick the map selected
	if _maps.get_selected_items().size() <= 0: return
	var index = _maps.get_selected_items()[0]
	var map = _maps.get_item_text(index)
	if map == null: return
	
	# prepare a host
	var host = _net_man.create_host(MAP_PATH + map)
	if host == null: return
	
	# host is ready


# list the files in a directory
static func list_files_in_directory(path):
    var files = []
    var dir = Directory.new()
    dir.open(path)
    dir.list_dir_begin()

    while true:
        var file = dir.get_next()
        if file == "":
            break
        elif not file.begins_with("."):
            files.append(file)

    dir.list_dir_end()

    return files