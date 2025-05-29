extends LineEdit

@export var messages: TextEdit

const username := "dev"

func _on_text_submitted(new_text)->void:
	messages.text += "%s: %s\n" % [username, new_text]
	text = ""
