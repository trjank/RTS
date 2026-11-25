class_name ChatBox extends VBoxContainer

@export var panel_container: PanelContainer
@export var message_container: VBoxContainer
@export var send_message_input: LineEdit
@export var battle: Battle
@export var collapsed := false:
	set = set_collapsed
## This is ignored if Battle is defined
@export var sender := "me"
## This is ignored if Battle is defined
@export var sender_id := ChatLogMessage.NO_SENDER_ID

var chat_log: ChatLog:
	set = set_chat_log

var _message_boxes: Dictionary[ChatLogMessage, ChatMessageBox]

func _ready() -> void:
	update_visibility()
	chat_log = battle.chat_log if battle != null else null

func get_message_box(message: ChatLogMessage) -> ChatMessageBox:
	return _message_boxes.get(message)

func set_collapsed(is_collapsed: bool) -> void:
	collapsed = is_collapsed
	update_visibility()

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

func _connect_signals(new_chat_log: ChatLog) -> void:
	new_chat_log.cleared.connect(clear)
	new_chat_log.pushed_message.connect(push_message)
	new_chat_log.popped_message.connect(pop_message)

func _disconnect_signals(old_chat_log: ChatLog) -> void:
	old_chat_log.cleared.disconnect(clear)
	old_chat_log.pushed_message.disconnect(push_message)
	old_chat_log.popped_message.disconnect(pop_message)

func update_visibility() -> void:
	if not is_node_ready():
		return
	panel_container.visible = not collapsed
	send_message_input.visible = not collapsed

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
	if battle == null:
		chat_log.push_message(ChatLogMessage.new(sender_id, sender, new_text) )
	else: # Let the battle handle any network requests
		battle.send_serverwide_message(new_text)
	send_message_input.clear()

func _on_collapse_button_pressed() -> void:
	collapsed = not collapsed
