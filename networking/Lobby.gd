extends Node

const PORT        = 26462
const MAX_PLAYERS = 32
const CHARACTER   = preload('res://character/Character.gd')

# list of players connected to the server
var players = {}

# contains info relative to the user of this instance
var user_info = {
	name  = 'unnamed',
	team  = CHARACTER.TEAM.neutral,
	score = 0
}

# store the maps selected in a specific order
# (for now just store one map)
var map_selected = null

# store the host in this object
var host = null

func _ready():
	# add all callbacks
	get_tree().connect('network_peer_connected'   , self, '_player_connected'   )
	get_tree().connect('network_peer_disconnected', self, '_player_disconnected')
	get_tree().connect('connected_to_server'      , self, '_connection_ok'      )
	get_tree().connect('connection_failed'        , self, '_connection_fail'    )
	get_tree().connect('server_disconnected'      , self, '_server_disconnected')


## PUBLIC METHODS ##

func create_host(map):
	# prepare a host
	var host = NetworkedMultiplayerENet.new()
	host.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	var err = host.create_server(PORT, MAX_PLAYERS - 1)
	if err != OK:
		print('Failed to create host.')
		return null
	
	# host is ready
	self.map_selected = map
	get_tree().set_network_peer(host)
	self.host = host
	return host


func join_host(ip):
	# get an IP to connect to
	if not ip.is_valid_ip_address():
		print('Invalid IP address.')
		return null
	
	# connect to host
	var host = NetworkedMultiplayerENet.new()
	host.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	var err = host.create_client(ip, PORT)
	if err != OK:
		print('Failed to connect to server: ' + ip)
		return null
	
	# client is ready
	get_tree().set_network_peer(host)
	self.host = host
	return host


## CALLBACKS ##

# player is now connected
func _player_connected(id):
	pass # unused

# player leaving server
func _player_disconnected(id):
	print(players[id].name + ' left server.')
	players.erase(id) # remove player

# player connecting to server
func _connection_ok():
	print(user_info.name + ' joined server.')
	var id = get_tree().get_network_unique_id()
	rpc('_register_player', id, user_info)

# couldn't even connect to the server
func _connection_fail():
	print('Failed to connect to server.')

# server kicked us of from the server
func _server_disconnected():
	print('Kicked out of server.')


## CALLBACKS for CLIENTS ##

# add the player to the list
remote func _register_player(id, data):
	
	# local player register itself in its own list
	players[id] = data
	
	# if we are the server, send info about other players to the new one
	if get_tree().is_network_server():
		
		# send map to load
		rset_id(id, 'map_selected', map_selected)
		
		# register server (but server is already in its own list so this line is not necessary...)
		rpc_id(id, '_register_player', 1, data)
		
		# register other remote players
		for peer_id in players:
			rpc_id(id, '_register_player', peer_id, players[peer_id])

# receive map to load
