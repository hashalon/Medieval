extends Control

# need access to lobby to change player parameters
onready var _net_man = get_node('/root/NetworkManager')

# panel with multiple tabs:
# user profile
# video-audio
# controls

func _ready():
	var field = $Container/Profile/Panel/NameField
	field.set_text(_net_man.my_player.name)
	field.connect('text_entered', self, 'on_name_changed')


func on_name_changed(new_name):
	if new_name == "": new_name = 'unnamed'
	_net_man.my_player.name = new_name
	print('name changed to: ' + new_name)