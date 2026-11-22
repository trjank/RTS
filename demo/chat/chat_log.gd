class_name ChatLog extends RefCounted

const MAX_NUM_MESSAGES := 100

signal pushed_message(message: ChatLogMessage)
signal popped_message(message: ChatLogMessage)

var command_prefix := "$"
var command_parser := CommandParser.new():
	set(__): push_error("(ChatLog) Do not create a new command parser!")
var parse_commands := true

var _messages: Array[ChatLogMessage] = []

func get_messages() -> Array[ChatLogMessage]:
	return _messages.duplicate()

func try_command(message: ChatLogMessage) -> void:
	if message.type & ChatLogMessage.Type.COMMAND == 0:
		return
	var args := message.content.split(" ", false)
	if not parse_commands or args.size() < 2 or args[0] != command_prefix:
		return message.set_type(ChatLogMessage.Type.TEXT)
	command_parser.execute(args[1], args, 2)

func push_message(message: ChatLogMessage, try_as_command := true) -> ChatLogMessage:
	if message == null:
		return null
	if MAX_NUM_MESSAGES <= _messages.size():
		pop_message()
	if try_as_command and message.content.begins_with(command_prefix):
		message.type = ChatLogMessage.Type.COMMAND
	_messages.append(message)
	pushed_message.emit(message)
	try_command(message)
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
