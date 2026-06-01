class_name TypeChecker

# NOTE: In JSON, integers are parsed as floats (hence the conversion here)
const CAST_NUMBERS: Dictionary[Variant.Type, Variant.Type] = {
	TYPE_INT: TYPE_FLOAT,
	TYPE_FLOAT: TYPE_INT
}

## Use to validate user input (e.g. parsing JSON)
static func type_check_key(key: Variant, data: Dictionary, template: Dictionary[String, Variant.Type], strict_keys := true, allowed_casts: Dictionary[Variant.Type, Variant.Type] = {} ) -> bool:
	if not key in template:
		return not strict_keys
	var type := typeof(data[key] )
	var type_allowed := template[key]
	return type == type_allowed or allowed_casts.get(type, TYPE_NIL) == type_allowed

## Use to validate user input (e.g. parsing JSON)
static func type_check(data: Dictionary, template: Dictionary[String, Variant.Type], strict_keys := true, allowed_casts: Dictionary[Variant.Type, Variant.Type] = {} ) -> bool:
	return data.keys().all(type_check_key.bind(data, template, strict_keys, allowed_casts) )
