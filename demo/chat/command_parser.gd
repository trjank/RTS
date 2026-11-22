class_name CommandParser extends RefCounted

var _commands: Dictionary[String, Callable] = {}
var _arguments: Dictionary[String, Dictionary] = {}
var _defaults: Dictionary[String, PackedStringArray] = {}

func has_command(command: String) -> bool:
	return command in _commands

func get_payload(command: String) -> Callable:
	return _commands[command]

func get_signature(command: String) -> String:
	return "%s %s" % [command, " ".join(_arguments[command].keys() ) ]

func get_help_message(command := "") -> String:
	return "Usage: %s" % get_signature(command) if has_command(command) else "Available commands: %s" % ", ".join(_commands.keys() )

func clear() -> void:
	_commands.clear()
	_arguments.clear()
	_defaults.clear()

func add_command(command: String, payload: Callable, args: Dictionary[String, Variant.Type], defaults := PackedStringArray() ) -> void:
	assert(payload.get_argument_count() <= args.size() + defaults.size() )
	#
	_commands[command] = payload
	_arguments[command] = args
	_defaults[command] = defaults

func remove_command(command: String) -> void:
	_commands.erase(command)
	_arguments.erase(command)

func execute(command: String, args: PackedStringArray, start_index := 0) -> bool:
	if not has_command(command):
		return false
	var payload := _commands[command]
	var defaults := _defaults[command]
	var num_args := args.size() - start_index
	if payload.get_argument_count() > num_args + defaults.size():
		return false
	var types: Array[Variant.Type] = _arguments[command].values()
	var typed_args := []
	#
	for i in range(payload.get_argument_count() ):
		typed_args.append(type_convert(args[start_index + i] if i < num_args else defaults[i - num_args], types[i] ) )
	payload.callv(typed_args)
	return true
