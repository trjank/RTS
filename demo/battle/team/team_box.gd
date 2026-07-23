class_name TeamBox extends VBoxContainer

signal request_join_team(this_team: Team)
signal request_add_bot(this_team: Team)

@export var players_container: VBoxContainer
@export var name_label: Label
@export var color_rect: ColorRect
@export var join_button: Button
@export var add_bot_button: Button

var team: Team:
	set = set_team

var _player_boxes: Dictionary[Player, PlayerBox] = {}

static func create() -> TeamBox:
	return preload("res://battle/team/team_box.tscn").instantiate()

func get_player_box(player: Player) -> PlayerBox:
	return _player_boxes.get(player)

func set_team(new_team: Team) -> void:
	_clear_players()
	if team != null:
		_disconnect_signals(team)
	if new_team != null:
		_connect_signals(new_team)
		_set_ui(new_team)
		new_team._players.all(add_player)
	else:
		_clear_ui()
	team = new_team
	toggle_buttons()

func add_player(player: Player) -> void:
	if player in _player_boxes:
		return
	var player_box := PlayerBox.create()
	player_box.player = player
	_player_boxes[player] = player_box
	players_container.add_child(player_box)
	toggle_buttons()

func remove_player(player: Player) -> void:
	if not player in _player_boxes:
		return
	_player_boxes[player].queue_free()
	_player_boxes.erase(player)
	toggle_buttons()

func toggle_buttons() -> void:
	join_button.visible = team != null and not team.contains_me()
	add_bot_button.visible = team != null and not team.is_full()

func _clear_players() -> void:
	for player in _player_boxes:
		_player_boxes[player].queue_free()
	_player_boxes.clear()

func _disconnect_signals(old_team: Team) -> void:
	old_team.display_name_changed.disconnect(_update_name)
	old_team.player_joined.disconnect(add_player)
	old_team.player_left.disconnect(remove_player)

func _connect_signals(new_team: Team) -> void:
	new_team.display_name_changed.connect(_update_name)
	new_team.player_joined.connect(add_player)
	new_team.player_left.connect(remove_player)

func _update_name(_old_name: String, new_name: String) -> void:
	name_label.text = new_name

func _set_ui(new_team: Team) -> void:
	name_label.text = new_team.display_name
	color_rect.color = new_team.color

func _clear_ui() -> void:
	name_label.text = ""
	color_rect.color = Color.WHITE

func _on_join_button_pressed() -> void:
	request_join_team.emit(team)

func _on_add_bot_button_pressed() -> void:
	request_add_bot.emit(team)
