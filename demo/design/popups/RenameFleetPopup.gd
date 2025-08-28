extends AcceptDialog

signal valid_rename(new_name: String)

@export var warning_label: Label
@export var name_edit: LineEdit

const RESERVED_NAME := "*Unnamed"

func _on_confirmed():
	var new_name := name_edit.text.strip_edges()
	match new_name:
		"":
			warning_label.text = "No name provided!"
		RESERVED_NAME:
			warning_label.text = "Name is invalid!"
		_:
			warning_label.text = "Name is valid"
			valid_rename.emit(new_name)
			hide()
