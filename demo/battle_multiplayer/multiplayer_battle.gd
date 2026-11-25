class_name MultiplayerBattle extends Battle

class IPData:
	var ip_address := ""
	var is_banned := false
	var is_muted := false
	var connections := 0

const DEFAULT_PORT := 7000
const DEFAULT_PLAYER_CAP := 16
const SERVER_PEER_ID := 1
const MAX_CONNECTIONS_PER_IP := 2
const SESSION_ID_BITS := 128
const AUTH_TIMEOUT_SEC := 5.0

enum NetworkError {
	OK,
	ALREADY_CONNECTED,
	FAILED
}

static var recent: MultiplayerBattle

var _crypto := Crypto.new()
var _peer_id_to_player: Dictionary[int, MultiplayerPlayer] = {}
var _session_id_to_player: Dictionary[String, MultiplayerPlayer] = {}
var _ip_data: Dictionary[String, IPData] = {}

func _enter_tree() -> void:
	get_tree().set_multiplayer(MultiplayerAPI.create_default_interface() as SceneMultiplayer, get_path() )

func find_ip(ip: String) -> IPData:
	return _ip_data.get(ip)

func get_api() -> SceneMultiplayer:
	return multiplayer # Explicit typecast

func get_peer() -> ENetMultiplayerPeer:
	return multiplayer.multiplayer_peer # Explicit typecast

func get_player_from_peer_id(peer_id: int) -> MultiplayerPlayer:
	return _peer_id_to_player.get(peer_id)

func set_me(new_me: Player) -> bool:
	return super(new_me as MultiplayerPlayer)

func _new_player(player_name: String, color: Color, icon: Player.Icon) -> Player:
	return MultiplayerPlayer.new(player_name, color, icon)

func add_player(player_name: String, color := Color.WHITE, icon := Player.Icon.NONE) -> MultiplayerPlayer:
	return super(player_name, color, icon) # Explicit typecast

func is_server_muted(player: Player) -> bool:
	return true

func bind_commands() -> void:
	super()
	#
	var parser := chat_log.command_parser
	parser.add_command("host_server", host_server, {"<max_players>": TYPE_INT, "<port>": TYPE_INT}, [DEFAULT_PLAYER_CAP, DEFAULT_PORT] )
	parser.add_command("stop_server", stop_server, {} )
	recent = self

func connect_player(player_name: String, color := Color.WHITE, icon := Player.Icon.NONE) -> void:
	add_player(player_name, color, icon)

func _reconnect_player(new_peer_id: int) -> void:
	var old_peer_id := 0
	_peer_id_to_player.erase(old_peer_id)
	#_peer_id_to_player[new_peer_id] = player

func _connect_new_player(peer_id: int) -> void:
	var session_id := _crypto.generate_random_bytes(SESSION_ID_BITS)
	var player := add_player("")
	player.session_id = session_id
	get_api().send_auth(peer_id, session_id)

func server_auth(peer_id: int, payload: PackedByteArray) -> void:
	var ip_data := find_ip(get_peer().get_peer(peer_id).get_remote_address() )
	if ip_data != null and (ip_data.is_banned or MAX_CONNECTIONS_PER_IP <= ip_data.connections):
		return get_api().disconnect_peer(peer_id)
	var session_id := payload.get_string_from_utf8()
	if session_id in _session_id_to_player:
		_reconnect_player(peer_id)
	else:
		_connect_new_player(peer_id)
	get_api().complete_auth(peer_id)

func client_auth(peer_id: int, payload: PackedByteArray) -> void:
	me.session_id = payload
	# TODO: Save the session id locally

func join_server(address: String, port := DEFAULT_PORT) -> NetworkError:
	if get_api().has_multiplayer_peer() and get_api().multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED:
		return NetworkError.ALREADY_CONNECTED
	var peer := ENetMultiplayerPeer.new()
	if peer.create_client(address, port) != OK:
		return NetworkError.FAILED
	multiplayer.multiplayer_peer = peer
	chat_log.parse_commands = false
	return NetworkError.OK

func host_server(max_players := DEFAULT_PLAYER_CAP, port := DEFAULT_PORT) -> NetworkError:
	var peer := ENetMultiplayerPeer.new()
	if peer.create_server(port, max_players) != OK:
		return NetworkError.FAILED
	multiplayer.multiplayer_peer = peer
	chat_log.parse_commands = true
	broadcast("Server hosted on port %d" % port)
	return NetworkError.OK

func leave_server() -> void:
	if multiplayer.is_server():
		return
	print("Leaving?")

func stop_server() -> void:
	if not multiplayer.is_server():
		return
	serverwide_broadcast("Shutting down server...")

func is_peer_host(peer_id: int) -> bool:
	return host != null and get_player_from_peer_id(peer_id) == host

func is_peer_admin(peer_id: int) -> bool:
	if peer_id == SERVER_PEER_ID:
		return true
	var player := get_player_from_peer_id(peer_id)
	return player != null and player.is_admin

@rpc("authority", "call_local", "reliable")
func push_message(sender_id: int, sender: String, content: String, type := ChatLogMessage.Type.TEXT) -> bool:
	return super(sender_id, sender, content, type)

@rpc("authority", "call_local", "reliable")
func broadcast(content: String, type := ChatLogMessage.Type.TEXT) -> bool:
	return super(content, type)

@rpc("any_peer", "call_remote", "reliable")
func send_message(content: String, type := ChatLogMessage.Type.TEXT) -> bool:
	var sender := get_player_from_peer_id(multiplayer.get_remote_sender_id() )
	if not multiplayer.is_server() or sender == null or is_server_muted(sender):
		return false
	push_message.rpc(sender.id, sender.display_name, content, type)
	return true # Might fail client-side, but the request was successful

@rpc("any_peer", "call_remote", "reliable")
func _request_push_message(sender_id: int, sender: String, content: String, type: ChatLogMessage.Type) -> void:
	if not multiplayer.is_server() or not is_peer_admin(multiplayer.get_remote_sender_id() ):
		return # Need to ensure _request_push_message.rpc_id is not called on a non-server peer
	push_message.rpc(sender_id, sender, content, type)

@rpc("any_peer", "call_remote", "reliable")
func _request_broadcast(sender_id: int, sender: String, content: String, type: ChatLogMessage.Type) -> void:
	if not multiplayer.is_server() or not is_peer_admin(multiplayer.get_remote_sender_id() ):
		return # Need to ensure _request_broadcast.rcp_id is not called on a non-server peer
	push_message.rpc(sender_id, sender, content, type)

func send_serverwide_message(content: String, type := ChatLogMessage.Type.TEXT) -> void:
	if multiplayer.is_server():
		return send_message(content, type)
	send_message.rpc_id(SERVER_PEER_ID, content, type)

## Must have admin permissions on the server to work
func push_serverwide_message(sender_id: int, sender: String, content: String, type := ChatLogMessage.Type.TEXT) -> void:
	if multiplayer.is_server():
		return push_message.rpc(sender_id, sender, content, type)
	_request_push_message.rpc_id(SERVER_PEER_ID, sender_id, sender, content, type)

## Must have admin permissions on the server to work
func serverwide_broadcast(content: String, type := ChatLogMessage.Type.TEXT) -> void:
	if multiplayer.is_server():
		return broadcast.rpc(content, type)
	_request_broadcast.rpc_id(SERVER_PEER_ID, content, type)
