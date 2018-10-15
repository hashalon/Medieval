extends Control

func _ready():
	$ButtonJoin   .connect('button_down', self, 'open_join'   )
	$ButtonHost   .connect('button_down', self, 'open_host'   )
	$ButtonProfile.connect('button_down', self, 'open_profile')
	$ButtonOptions.connect('button_down', self, 'open_options')
	$ButtonQuit   .connect("button_down", self, 'quit_game'   )

func open_join():
	get_tree().change_scene('res://menu/ConnectionDialog.tscn')

func open_host():
	get_tree().change_scene('res://menu/CreateGame.tscn')

func open_profile():
	get_tree().change_scene('')
	pass

func open_options():
	get_tree().change_scene('')
	pass

func quit_game():
	get_tree().quit()