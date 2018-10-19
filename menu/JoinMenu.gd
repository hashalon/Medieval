extends Control

# need access to lobby to connect to host
onready var _net_man = get_node('/root/NetworkManager')

# display a ip field, a connect button and a little message output to see errors

func _ready():
	$Menu/Buttons/BtnJoin.connect('pressed', self, "join_game")

func join_game():
	# get an IP to connect to
	var ip   = $Menu/IpField.get_text()
	var host = _net_man.join_host(ip)
	if host == null: return
	
	# connect to host