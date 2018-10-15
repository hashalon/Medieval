extends ConfirmationDialog

onready var _lobby_node = get_tree().get_root().get_node('Lobby')

func _ready():
	register_text_enter($IpField)
	connect('confirmed', self, 'on_joining')

## PUBLIC METHODS ##

func on_joining():
	# get an IP to connect to
	var ip   = _ip_field.get_text()
	var host = _lobby_node.join_host(ip)
	if host == null:
		_display_message('Failed to connect!', true)
		return
	
	# connect to host
	_display_message('Connecting...', false)


## PRIVATE METHODS ##

func _display_message(text, isError):
	print(text)
	if isError: pass
	else:       pass