class_name ChatBox extends VBoxContainer

@export var message_container: VBoxContainer
@export var send_message_input: LineEdit
@export var battle: Battle

var chat_log: ChatLog:
	set = set_chat_log
var my_name := "me"
var command_prefix := "$ "

var _message_boxes: Dictionary[ChatLogMessage, ChatMessageBox]

func _ready() -> void:
	chat_log = chat_log if battle == null else battle.chat_log

func get_message_box(message: ChatLogMessage) -> ChatMessageBox:
	return _message_boxes.get(message)

func set_chat_log(new_chat_log: ChatLog) -> void:
	if chat_log == new_chat_log:
		return
	clear()
	if chat_log != null:
		_disconnect_signals(chat_log)
	if new_chat_log != null:
		_connect_signals(new_chat_log)
	chat_log = new_chat_log
	send_message_input.editable = chat_log != null

func clear() -> void:
	for node in message_container.get_children():
		node.queue_free()

func determine_type(content: String) -> ChatLogMessage.Type:
	return ChatLogMessage.Type.COMMAND if content.begins_with(command_prefix) else ChatLogMessage.Type.TEXT

func generate_message(content: String) -> ChatLogMessage:
	var me := battle.me if battle != null else null
	var type := determine_type(content)
	return ChatLogMessage.from_player(me, content, type) if me != null else ChatLogMessage.new(ChatLogMessage.NO_SENDER_ID, my_name, content, type)

func _connect_signals(new_chat_log: ChatLog) -> void:
	new_chat_log.pushed_message.connect(push_message)
	new_chat_log.popped_message.connect(pop_message)

func _disconnect_signals(old_chat_log: ChatLog) -> void:
	old_chat_log.pushed_message.disconnect(push_message)
	old_chat_log.popped_message.disconnect(pop_message)

func push_message(message: ChatLogMessage) -> void:
	if message in _message_boxes:
		return push_warning("(ChatBox) Duplicate message")
	var message_box := ChatMessageBox.create()
	message_box.player = battle.get_player_from_id(message.sender_id) if battle != null else null
	message_box.message = message
	message_container.add_child(message_box)
	_message_boxes[message] = message_box

func pop_message(message: ChatLogMessage) -> void:
	if not message in _message_boxes:
		return push_warning("(ChatBox) Unabled to delete non-existant message")
	_message_boxes[message].queue_free()
	_message_boxes.erase(message)

func _on_send_message_text_submitted(new_text: String) -> void:
	if chat_log == null or new_text == "":
		return
	chat_log.push_message(generate_message(new_text) )
	send_message_input.clear()
