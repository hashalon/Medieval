extends "res://character/Character.gd"

# attributes
export var hover_fall    = 0.1
export var bolt_damage   = 8
export var bolt_pushback = 10.0

# nodes...
onready var _bolt_zone = $Camera/Bolt

func _ready():
	._ready()


# regular update function
func _physics_process(delta):
	
	# fire a lightning bolt (shotgun like)
	if Input.is_action_just_pressed('attack'):
		_lightning_bolt()
	
	# throw a magic-ball that bound against walls (MisterMV)
	if Input.is_action_just_pressed('secondary'):
		pass
	
	._physics_process(delta)
	
	# allow the wizard to hover
	if not is_grounded():
		if Input.is_action_pressed('jump') and _velocity.y < 0:
			_velocity.y = -hover_fall



# throw a lightning bolt
func _lightning_bolt():
	
	# find bodies in the zone of the bolt and apply damage to them
	var bodies = _bolt_zone.get_overlapping_bodies()
	for body in bodies:
		if body.is_class("Character") and body != self:
			# Damage enemies
			pass

