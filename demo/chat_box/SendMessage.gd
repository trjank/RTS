extends LineEdit

@export var messages: TextEdit

const username := "dev"

func _on_text_submitted(new_text)->void:
	if new_text == "":
		return
	messages.text += "%s: %s\n" % [username, new_text]
	text = ""
