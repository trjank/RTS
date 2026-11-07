extends Label

const text_format := "Your ships — %d result%s"

func _on_ships_screen_searched_ships(_query: String, matches: int) -> void:
	text = text_format % [matches, "" if matches == 1 else "s"]
