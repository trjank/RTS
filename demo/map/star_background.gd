@tool
class_name StarBackground extends EditorScript

# NOTE: You can right click this script and select "Run" to generate an image

# NOTE: Ensure this file does not already exist (the script will not overwrite)
const EXPORT_PATH := "res://map/generated_background.png"

func _run() -> void:
	print("(StarBackground) Exported image to %s" % EXPORT_PATH)
