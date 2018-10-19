extends Control

const CHARACTER = preload('res://character/Character.gd')

# need access to lobby for hosting
onready var _net_man = get_node('/root/NetworkManager')
onready var _ent_man = get_node('/root/EntityManager' )
onready var _map     = get_node('/root/Map')

func _ready():
	$Menu/BtnResume.connect('pressed', self, 'resume')
	$Menu/BtnLeave .connect('pressed', self, 'leave' )
	self.visible = false


func _process(delta):
	# toggle menu when pressing ESCAPE
	if Input.is_action_just_pressed('ui_cancel'):
		set_visible(not visible)
		
		# when the menu is visible, we need to use the mouse
		if visible: CHARACTER.release_mouse()
	
	# change control state of our character
	if _ent_man.my_character != null:
		_ent_man.my_character.set_can_move(not visible)


func resume():
	set_visible(false)
	CHARACTER.capture_mouse()

func leave():
	_net_man.leave_host()