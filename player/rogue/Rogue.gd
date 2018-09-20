extends "res://player/Player.gd"

# attributes
export var grappling_speed = 20


#func _ready():
#	._ready()

#func _input(event):
#	._input(event)

# regular update function
func _process(delta):
	._process(delta)
	
	# fire an arrow
	if Input.is_action_just_pressed('attack'):
		pass
	
	# use grappling hook
	if Input.is_action_pressed('secondary'):
		# (1) make hook go toward target
		# (2) make character go toward target
		# /!\ velocity is proportional to distance from hook point
		pass
