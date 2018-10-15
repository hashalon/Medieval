extends Node

# only handle capture the flag mode
# (we cannot assume we will have enough players for Control Points mode, we need AI for that)

# for each team (alpha, beta), gather spawn points
onready var _spawns_alpha = $Spawns/Alpha.get_children()
onready var _spawns_beta  = $Spawns/Beta .get_children()


func _ready():
	pass

