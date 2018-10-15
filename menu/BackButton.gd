extends Button

# use this button to return to the main menu

func _ready():
	connect('pressed', self, 'go_back')

# return to main menu
func go_back():
	get_tree().change_scene('res://menu/MainMenu.tscn')

# when the escape key is pressed, return to main menu
func _process(delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		go_back()