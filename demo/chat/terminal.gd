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
	parser.add_command("version", broadcast_version, {} )
	parser.add_command("join_server", Callable(), {} )

func broadcast_version() -> void:
	broadcast("Version: alpha")

func broadcast_help_message(command := "") -> void:
	broadcast(chat_log.command_parser.get_help_message(command) )

func broadcast(content: String) -> void:
	chat_log.push_message(ChatLogMessage.new(-1, "Game", content) )

func _on_close_requested() -> void:
	hide()
