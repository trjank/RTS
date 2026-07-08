class_name TeamBox extends VBoxContainer

@export var players_container: VBoxContainer
@export var name_label: Label
@export var color_rect: ColorRect

var team: Team:
	set = set_team

var _player_boxes: Dictionary[Player, PlayerBox] = {}

func get_player_box(player: Player) -> PlayerBox:
	return _player_boxes.get(player)

func set_team(new_team: Team) -> void:
	team = new_team
	name_label.text = team.display_name if team != null else ""
	color_rect.color = team.color if team != null else Color.WHITE
	update_players() 

func clear_players() -> void:
	for player in _player_boxes:
		_player_boxes[player].queue_free()
	_player_boxes.clear()

func update_players() -> void:
	clear_players()
	team.players.all(add_player)

func add_player(player: Player) -> void:
	if player in _player_boxes:
		return
	var player_box := PlayerBox.new()
	player_box.player = player
	_player_boxes[player] = player_box
	players_container.add_child(player_box)

func remove_player(player: Player) -> void:
	if not player in _player_boxes:
		return
	_player_boxes[player].queue_free()
	_player_boxes.erase(player)
