class_name ChatLog extends RefCounted

const MAX_NUM_MESSAGES := 100

signal pushed_command(args: PackedStringArray)
signal pushed_message(message: ChatLogMessage)
signal popped_message(message: ChatLogMessage)

var parse_commands := true

var _messages: Array[ChatLogMessage] = []

func get_messages() -> Array[ChatLogMessage]:
	return _messages.duplicate()

func push_message(message: ChatLogMessage) -> ChatLogMessage:
	if message == null:
		return null
	if MAX_NUM_MESSAGES <= _messages.size():
		pop_message()
	if message.type & ChatLogMessage.Type.COMMAND:
		pushed_command.emit(message.content.split(" ", false) )
	_messages.append(message)
	pushed_message.emit(message)
	return message

func pop_message() -> ChatLogMessage:
	if _messages.is_empty():
		return null
	var message: ChatLogMessage = _messages.pop_front()
	popped_message.emit(message)
	return message

func save_txt(path: String, what := ChatLogMessage.Type.ALL) -> bool:
	if not path.ends_with(".txt"):
		return false
	var file := FileAccess.open(path, FileAccess.WRITE)
	#
	for message in _messages:
		if what & message.type:
			file.store_line(message.to_string() )
	return true
