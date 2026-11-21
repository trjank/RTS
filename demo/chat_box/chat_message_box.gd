class_name ChatMessageBox extends PlayerBox

const ICONS: Dictionary[ChatLogMessage.Type, Texture2D] = {
	ChatLogMessage.Type.ERROR: preload("res://icons/warning.png"),
	ChatLogMessage.Type.WARNING: preload("res://icons/warning.png"),
	ChatLogMessage.Type.COMMAND: preload("res://icons/warning.png")
}

@export var content_label: Label

var message: ChatLogMessage:
	set = set_message
var content := "":
	set = set_content

static func create() -> ChatMessageBox:
	return preload("res://chat_box/chat_message_box.tscn").instantiate()

func _ready() -> void:
	super()
	content_label.text = content

func set_content(new_content: String) -> void:
	if is_node_ready():
		content_label.text = new_content
	content = new_content

func set_message(new_message: ChatLogMessage) -> void:
	if message != null:
		_disconnect_message_signals(message)
	if new_message != null:
		_connect_message_signals(new_message)
	content = new_message.content if new_message != null else ""
	message = new_message
	update_ui()

func _clear_ui() -> void:
	if message == null:
		return super()
	name_label.text = message.sender
	clan_label.text = ""
	host_label.visible = false
	icon.texture = ICONS.get(message.type)
	team_kick_button.visible = false

func _connect_message_signals(new_message: ChatLogMessage) -> void:
	new_message.content_changed.connect(set_content)

func _disconnect_message_signals(old_message: ChatLogMessage) -> void:
	old_message.content_changed.disconnect(set_content)
