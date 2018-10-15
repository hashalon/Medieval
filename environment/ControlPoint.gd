extends Area

var _index = 0
onready var _spawns = get_children()


# return a spawn using round robin method
func request_spawn():
	_index += 1
	if _index >= _spawns.size():
		_index = 0
	return _spawns[_index]