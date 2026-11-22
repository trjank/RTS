class_name ChatLogMessage extends RefCounted

signal type_changed(new_type: Type)
signal sender_changed(new_sender: String)
signal content_changed(new_content: String)

enum Type {
	NONE = 0,
	TEXT = 1 << 0,
	ERROR = 1 << 1,
	WARNING = 1 << 2,
	COMMAND = 1 << 3,
	ALL = TEXT | ERROR | WARNING | COMMAND
}

const TYPE_PREFIXES: Dictionary[Type, String] = {
	Type.TEXT: "",
	Type.ERROR: "ERROR ",
	Type.WARNING: "/!\\ ",
	Type.COMMAND: "> "
}
const MAX_LENGTH := 1000
const NO_SENDER_ID := -1

var type := Type.TEXT:
	set = set_type
var sender_id := NO_SENDER_ID
var sender := "":
	set = set_sender
var content := "":
	set = set_content
var timestamp := ""

static func from_player(player: Player, init_content: String, init_type := Type.TEXT, init_timestamp := Time.get_time_string_from_system() ) -> ChatLogMessage:
	return ChatLogMessage.new(player.id, player.display_name, init_content, init_type, init_timestamp)

func _init(init_sender_id: int, init_sender: String, init_content: String, init_type := Type.TEXT, init_timestamp := Time.get_time_string_from_system() ) -> void:
	type = init_type
	sender_id = init_sender_id
	sender = init_sender
	content = init_content
	timestamp = init_timestamp

func set_type(new_type: Type) -> void:
	if new_type == type:
		return
	type = new_type
	type_changed.emit(new_type)

func set_sender(new_sender: String) -> void:
	if new_sender == sender:
		return
	sender = new_sender
	sender_changed.emit(new_sender)

func set_content(new_content: String) -> void:
	new_content = new_content.left(MAX_LENGTH)
	if new_content == content:
		return
	content = new_content
	content_changed.emit(new_content)

func _to_string() -> String:
	return "[%s] %s%s%s: %s" % [timestamp, TYPE_PREFIXES[type], sender, "#%d" % sender_id if sender_id != NO_SENDER_ID else "", content]
