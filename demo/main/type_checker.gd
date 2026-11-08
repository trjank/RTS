class_name TypeChecker

# NOTE: In JSON, integers are parsed as floats (hence the conversion here)
const CAST_NUMBERS: Dictionary[Variant.Type, Variant.Type] = {
	TYPE_INT: TYPE_FLOAT,
	TYPE_FLOAT: TYPE_INT
}
const CAST_COLORS: Dictionary[Variant.Type, Variant.Type] = {
	TYPE_STRING: TYPE_COLOR
}
const CAST_NUMBERS_AND_COLORS: Dictionary[Variant.Type, Variant.Type] = {
	TYPE_INT: TYPE_FLOAT,
	TYPE_FLOAT: TYPE_INT,
	TYPE_STRING: TYPE_COLOR
}

## NOTE: You can pass the enum directly for enum_dict (e.g. format_enum(3, Error) )
static func format_enum(flags: int, enum_dict: Dictionary, delimiter := " | ") -> String:
	var strings := PackedStringArray()
	#
	for property in enum_dict:
		if flags & enum_dict[property] or flags == enum_dict[property]:
			strings.append(property)
	return delimiter.join(strings)

static func type_check_key(key: Variant, data: Dictionary, template: Dictionary[String, Variant.Type], strict_keys := true, allowed_casts: Dictionary[Variant.Type, Variant.Type] = {} ) -> bool:
	if not key in template:
		return not strict_keys
	var type := typeof(data[key] )
	var type_allowed := template[key]
	return type == type_allowed or allowed_casts.get(type, TYPE_NIL) == type_allowed

static func type_check(data: Dictionary, template: Dictionary[String, Variant.Type], strict_keys := true, allowed_casts: Dictionary[Variant.Type, Variant.Type] = {} ) -> bool:
	return data.keys().all(type_check_key.bind(data, template, strict_keys, allowed_casts) )

static func to_dict(object: Object, syntax: Dictionary[String, Variant.Type] ) -> Dictionary:
	var dict := {}
	for property in syntax:
		dict[property] = object.get(property)
	return dict

static func load_dict(object: Object, dict: Dictionary, syntax: Dictionary[String, Variant.Type], allowed_casts: Dictionary[Variant.Type, Variant.Type] = {} ) -> bool:
	if not type_check(dict, syntax, true, allowed_casts):
		return false
	for property in dict:
		object.set(property, dict[property] )
	return true
