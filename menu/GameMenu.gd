extends Control

const CHARACTER = preload('res://character/Character.gd')

# need access to lobby for hosting
onready var _lobby = get_tree().get_root().get_node('Lobby')
onready var _map   = get_node('/root/Map')

func _ready():
	$Menu/BtnResume.connect('pressed', self, 'resume')
	$Menu/BtnLeave .connect('pressed', self, 'leave' )
	self.visible = false


func resume():
	set_visible(false)
	CHARACTER.capture_mouse()

func leave():
	_lobby.leave_host()