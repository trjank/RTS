class_name Terminal extends Window

const WELCOME_MESSAGE := """
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WELCOME TO PROJECT STARDUST!
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"""

@export var chat_box: ChatBox

var chat_log := ChatLog.new():
	set = set_chat_log

func _ready() -> void:
	chat_box.chat_log = chat_log
	bind_commands()
	broadcast(WELCOME_MESSAGE)
	broadcast("Type '%s help' for a list of commands" % chat_log.command_prefix)

func set_chat_log(new_chat_log: ChatLog) -> void:
	if is_node_ready():
		chat_box.chat_log = new_chat_log
	chat_log = new_chat_log

func bind_commands() -> void:
	var parser := chat_log.command_parser
	parser.add_command("help", broadcast_help_message, {"<command>": TYPE_STRING}, [""] )
	parser.add_command("clear", chat_log.clear, {} )
	parser.add_command("version", broadcast_version, {} )
	parser.add_command("join_server", cmd_join_server, {"<address>": TYPE_STRING, "<port>": TYPE_INT}, [MultiplayerBattle.DEFAULT_PORT] )
	parser.add_command("host_server", cmd_host_server, {"<max_players>": TYPE_INT, "<port>": TYPE_INT}, [MultiplayerBattle.DEFAULT_PLAYER_CAP, MultiplayerBattle.DEFAULT_PORT] )
	parser.add_var("part_properties", TYPE_STRING, broadcast_part_properties, Callable() )

func cmd_join_server(address: String, port := MultiplayerBattle.DEFAULT_PORT) -> void:
	if MultiplayerBattle.recent == null:
		return broadcast("No multiplayer battle available")
	MultiplayerBattle.recent.join_server(address, port)

func cmd_host_server(max_players := MultiplayerBattle.MAX_NUM_PLAYERS, port := MultiplayerBattle.DEFAULT_PORT) -> void:
	if MultiplayerBattle.recent == null:
		return broadcast("No multiplayer battle available")
	MultiplayerBattle.recent.host_server(max_players, port)

func broadcast_part_properties() -> void:
	broadcast("Valid part properties: %s" % ", ".join(PartManager.PART_PROPERTIES.keys() ) )

func broadcast_version() -> void:
	broadcast("Version: alpha")

func broadcast_help_message(command := "") -> void:
	broadcast(chat_log.command_parser.get_help_message(command) )

func broadcast(content: String) -> void:
	chat_log.push_message(ChatLogMessage.new(-1, "Game", content) )

func _on_close_requested() -> void:
	hide()
