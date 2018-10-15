extends Control


onready var _lobby_node = get_tree().get_root().get_node('Lobby')


func _ready():
	$Controls/ButtonPlay.connect('button_down', self, 'on_hosting')
	$Controls/ButtonBack.connect('button_down', self, 'on_back')


func on_hosting():
	# prepare a host
	var host = _lobby_node.create_host()
	if host == null:
		_display_message('Failed to host!', true)
		return
	
	# host is ready
	_display_message('Starting server...', false)

func on_back():
	pass

## PRIVATE METHODS ##

func _display_message(text, isError):
	print(text)
	if isError: pass
	else:       pass