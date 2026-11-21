class_name Terminal extends Window

@export var chat_box: ChatBox

func _ready() -> void:
	chat_box.chat_log = ChatLog.new()

func _on_close_requested() -> void:
	hide()
