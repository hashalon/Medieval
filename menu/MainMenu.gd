extends Control

# provide a list of buttons to access other menus

func _ready():
	$Menu/BtnJoin.connect('pressed', self, 'open_menu', ['res://menu/JoinMenu.tscn'])
	$Menu/BtnHost.connect('pressed', self, 'open_menu', ['res://menu/HostMenu.tscn'])
	$Menu/BtnOpts.connect('pressed', self, 'open_menu', ['res://menu/Options.tscn' ])
	$Menu/BtnQuit.connect("pressed", self, 'quit_game')


func open_menu(menu_path):
	get_tree().change_scene(menu_path)


func quit_game():
	get_tree().quit()