class_name PlayerBox extends HBoxContainer

@export var clan_label: Label
@export var name_label: Label
@export var host_label: Label
@export var icon: TextureRect
@export var team_kick_button: Button

var player: Player:
	set = set_player

static func create() -> PlayerBox:
	return preload("res://battle/player/player_box.tscn").instantiate()

func is_empty() -> bool:
	return player == null

func set_player(new_player: Player) -> void:
	if player != null:
		_disconnect_signals(player)
	if new_player != null:
		_set_ui(new_player)
		_connect_signals(new_player)
	else:
		_clear_ui()
	player = new_player

func _disconnect_signals(old_player: Player) -> void:
	old_player.display_name_changed.disconnect(_update_name)
	old_player.clan_changed.disconnect(_update_clan)
	old_player.icon_changed.disconnect(_update_icon)
	old_player.bot_status_changed.disconnect(_update_bot_status)

func _connect_signals(new_player: Player) -> void:
	new_player.display_name_changed.connect(_update_name)
	new_player.clan_changed.connect(_update_clan)
	new_player.icon_changed.connect(_update_icon)
	new_player.bot_status_changed.connect(_update_bot_status)

func _update_name(_old_name: String, new_name: String) -> void:
	name_label.text = new_name

func _update_clan(_old_clan: String, new_clan: String) -> void:
	clan_label.text = new_clan

func _update_icon(_old_icon: Texture2D, new_icon: Texture2D) -> void:
	icon.texture = new_icon

func _update_bot_status() -> void:
	team_kick_button.visible = not player.is_bot

func _set_ui(new_player: Player) -> void:
	name_label.text = new_player.display_name
	clan_label.text = new_player.clan
	host_label.visible = new_player.is_host()
	icon.texture = new_player.icon
	team_kick_button.visible = not new_player.is_bot

func _clear_ui() -> void:
	name_label.text = "--"
	clan_label.text = "N/A"
	host_label.visible = false
	icon.texture = player.icon
	team_kick_button.visible = false

func _on_kick_button_pressed() -> void:
	if player == null or player.get_battle() == null:
		return push_error("(PlayerBox) Kick button should not be enabled!")
	player.get_battle().request_kick(player)

func _on_team_kick_button_pressed() -> void:
	if player == null or player.get_battle() == null:
		return push_error("(PlayerBox) Team kick button should not be enabled!")
	player.get_battle().request_team_kick(player)
