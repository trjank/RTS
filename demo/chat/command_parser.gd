class_name CommandParser extends RefCounted

signal failed_command(command: String)
signal failed_get(var_name: String)
signal failed_set(var_name: String, value: String)

class Command extends RefCounted:
	var payload := Callable()
	var arguments := {}
	var defaults := PackedStringArray()

class Variable extends RefCounted:
	var type := TYPE_STRING
	var getter := Callable()
	var setter := Callable()

var silent_failures := false

var _commands: Dictionary[String, Command] = {}
var _variables: Dictionary[String, Variable] = {}

func has_command(command: String) -> bool:
	return command in _commands

func get_command(command: String) -> Command:
	return _commands.get(command)

func get_variable(var_name: String) -> Variable:
	return _variables.get(var_name)

func get_signature(command: String) -> String:
	return "%s %s" % [command, " ".join(_commands[command].arguments.keys() ) ]

func get_help_message(command := "") -> String:
	return "Usage: %s" % get_signature(command) if has_command(command) else "Available commands: %s" % ", ".join(_commands.keys() )

func get_command_list() -> Array[String]:
	return _commands.keys()

func get_variable_list() -> Array[String]:
	return _variables.keys()

func clear_commands() -> void:
	_commands.clear()

func clear_variables() -> void:
	_variables.clear()

func handle_failed_command(command: String) -> bool:
	if not silent_failures:
		failed_command.emit(command)
	return false

func handle_failed_get(var_name: String) -> bool:
	if not silent_failures:
		failed_get.emit(var_name)
	return false

func handle_failed_set(var_name: String, value: String) -> bool:
	if not silent_failures:
		failed_set.emit(var_name, value)
	return false

func get_var(var_name: String) -> bool:
	var data := get_variable(var_name)
	if data == null:
		return handle_failed_get(var_name)
	data.getter.call()
	return true

func set_var(var_name: String, value: String) -> bool:
	var data := get_variable(var_name)
	if data == null:
		return handle_failed_set(var_name, value)
	data.setter.call(value == "true" if data.type == TYPE_BOOL else type_convert(value, data.type) )
	return true

func add_var(var_name: String, type: Variant.Type, getter: Callable, setter: Callable) -> void:
	if _variables.is_empty():
		expose_variables()
	var data := Variable.new()
	data.type = type
	data.getter = getter
	data.setter = setter
	_variables[var_name] = data

func remove_var(var_name: String) -> bool:
	return _variables.erase(var_name)

func expose_variables() -> void:
	add_command("get", get_var, {"<variable>": TYPE_STRING} )
	add_command("set", set_var, {"<variable>": TYPE_STRING, "<value>": TYPE_STRING} )

func add_command(command: String, payload: Callable, args: Dictionary[String, Variant.Type], defaults := PackedStringArray() ) -> bool:
	if command in _commands or payload.get_argument_count() > args.size() + defaults.size():
		return false
	var data := Command.new()
	data.payload = payload
	data.arguments = args
	data.defaults = defaults
	_commands[command] = data
	return true

func remove_command(command: String) -> bool:
	return _commands.erase(command)

func execute(command: String, args: PackedStringArray, start_index := 0) -> bool:
	var data := get_command(command)
	var num_args := args.size() - start_index
	if data == null or data.payload.get_argument_count() > num_args + data.defaults.size():
		return handle_failed_command(command)
	var types: Array[Variant.Type] = data.arguments.values()
	var typed_args := []
	#
	for i in range(data.payload.get_argument_count() ):
		typed_args.append(type_convert(args[start_index + i] if i < num_args else data.defaults[i - num_args], types[i] ) )
	data.payload.callv(typed_args)
	return true
