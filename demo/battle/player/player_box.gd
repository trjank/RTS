class_name PlayerBox extends HBoxContainer

@export var clan_label: Label
@export var name_label: Label
@export var host_label: Label
@export var admin_label: Label
@export var icon: TextureRect
@export var team_kick_button: Button

var player: Player:
	set = set_player

static func create() -> PlayerBox:
	return preload("res://battle/player/player_box.tscn").instantiate()

func _ready() -> void:
	update_ui()

func is_empty() -> bool:
	return player == null

func set_player(new_player: Player) -> void:
	if player != null:
		_disconnect_signals(player)
	if new_player != null:
		_connect_signals(new_player)
	player = new_player
	update_ui()

func _disconnect_signals(old_player: Player) -> void:
	old_player.display_name_changed.disconnect(_update_ui_callback)
	old_player.clan_changed.disconnect(_update_ui_callback)
	old_player.icon_changed.disconnect(_update_ui_callback)
	old_player.bot_status_changed.disconnect(_update_ui_callback)

func _connect_signals(new_player: Player) -> void:
	new_player.display_name_changed.connect(_update_ui_callback)
	new_player.clan_changed.connect(_update_ui_callback)
	new_player.icon_changed.connect(_update_ui_callback)
	new_player.bot_status_changed.connect(_update_ui_callback)

func update_ui() -> void:
	if not is_node_ready():
		return
	if player == null:
		return _clear_ui()
	_set_ui()

func _update_ui_callback(_useless_1 = null, _useless_2 = null) -> void:
	update_ui()

func _set_ui() -> void:
	name_label.text = player.display_name
	clan_label.text = player.clan
	host_label.visible = player.is_host()
	admin_label.visible = player.is_admin
	team_kick_button.visible = not player.is_bot
	icon.texture = player.get_texture()

func _clear_ui() -> void:
	name_label.text = "--"
	clan_label.text = ""
	host_label.visible = false
	admin_label.visible = false
	team_kick_button.visible = false
	icon.texture = null

func _on_kick_button_pressed() -> void:
	player.get_battle().kick(player)

func _on_team_kick_button_pressed() -> void:
	player.get_battle().team_kick(player)
