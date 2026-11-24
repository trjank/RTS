class_name MultiplayerBattle extends Battle

const DEFAULT_PORT := 7000
const DEFAULT_PLAYER_CAP := 16
const SERVER_PEER_ID := 1

enum NetworkError {
	OK,
	ALREADY_CONNECTED,
	FAILED
}

# IDEA: generate random session id or string for reconnect attempts that is only exposed to the server
# Cant use player's name because everyone has access to that
# Cant use player id because everyone needs access to that
# Need a cryptographically secure RNG

## Used in lieu of accounts to validate users (do not share!)
var session_id := ""

var _peer_id_to_player: Dictionary[int, Player] = {}

func setup() -> void:
	chat_log.parse_commands = multiplayer.is_server()

func get_player_from_peer_id(peer_id: int) -> Player:
	return _peer_id_to_player.get(peer_id)

func is_server_muted(player: Player) -> bool:
	return false

func bind_commands() -> void:
	super()
	#
	var parser := chat_log.command_parser
	parser.add_command("host_server", host_server, {"<max_players>": TYPE_INT, "<port>": TYPE_INT}, [DEFAULT_PLAYER_CAP, DEFAULT_PORT] )
	parser.add_command("stop_server", stop_server, {} )

func join_server(address: String, port := DEFAULT_PORT) -> NetworkError:
	if multiplayer.has_multiplayer_peer() and multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED:
		return NetworkError.ALREADY_CONNECTED
	var peer := ENetMultiplayerPeer.new()
	if peer.create_client(address, port) != OK:
		return NetworkError.FAILED
	multiplayer.multiplayer_peer = peer
	return NetworkError.OK

func host_server(max_players := DEFAULT_PLAYER_CAP, port := DEFAULT_PORT) -> NetworkError:
	var peer := ENetMultiplayerPeer.new()
	if peer.create_server(port, max_players) != OK:
		return NetworkError.FAILED
	multiplayer.multiplayer_peer = peer
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
