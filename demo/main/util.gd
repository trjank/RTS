class_name Util extends Object

const CAST_NUMERICS: Dictionary[Variant.Type, Variant.Type] = {
	TYPE_INT: TYPE_FLOAT,
	TYPE_FLOAT: TYPE_INT
}

static func type_check(data: Dictionary, template: Dictionary[String, Variant.Type], strict_keys := true, allowed_casts: Dictionary[Variant.Type, Variant.Type] = {} ) -> bool:
	# NOTE: This is useful for validating user input (e.g. parsing JSON)
	return data.keys().all(func (key: Variant) -> bool:
		if not key in template:
			return not strict_keys
		var type := typeof(data[key] )
		var type_allowed := template[key]
		return type == type_allowed or allowed_casts.get(type, TYPE_NIL) == type_allowed
	)
