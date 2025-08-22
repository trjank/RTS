class_name JSONPartManager extends PartManager

const PART_IMAGES_FOLDER := "res://part_images/"
const DEFAULT_JSON_PATH  := "user://part_data.json"

func safe_set_image(part: PartData, path: String):
	if path.contains(".."): return
	path = PART_IMAGES_FOLDER + path
	part.set_image_path(path)

func load_part(code: String, data: Dictionary)->void:
	var subtype: String = data.get("subtype", "PartData")
	var image_path: String = data.get("image_path", "not_found.png")
	var part := new_part(code, subtype)
	data.erase("subtype")
	data.erase("image_path")
	data.erase("script")
	# TODO: Add more safety checks?
	for key in data:
		part.call("set_" + key, data[key])
	safe_set_image(part, image_path)

func load_json(path: String = DEFAULT_JSON_PATH)->void:
	var text := FileAccess.get_file_as_string(path)
	var dict: Dictionary = JSON.parse_string(text)
	
	for code in dict:
		load_part(code, dict[code])
