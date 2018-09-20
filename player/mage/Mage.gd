extends "res://player/Player.gd"

# attributes
export var fire_damage = 10


#func _ready():
#	._ready()

#func _input(event):
#	._input(event)

# regular update function
func _process(delta):
	._process(delta)
	
	# fire a lightning bolt (shotgun like)
	if Input.is_action_just_pressed('attack'):
		pass
	
	# charge a fireball
	if Input.is_action_pressed('secondary'):
		pass
	# throw the fireball
	elif Input.is_action_just_released('secondary'):
		pass
