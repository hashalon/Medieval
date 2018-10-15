extends Control

# need access to lobby to change player parameters
onready var _lobby = get_tree().get_root().get_node('Lobby')

# panel with multiple tabs:
# user profile
# video-audio
# controls

func _ready():
	var field = $Container/Profile/Panel/NameField
	field.set_text(_lobby.user_info.name)
	field.connect('text_entered', self, 'on_name_changed')


func on_name_changed(new_name):
	if new_name == "": new_name = 'unnamed'
	_lobby.user_info.name = new_name
	print('name changed to: ' + new_name)