class_name TeamSettings extends VBoxContainer

var battle: Battle:
	set = set_battle

var _team_boxes: Dictionary[Team, TeamBox] = {}

static func create() -> TeamSettings:
	return preload("res://battle/team/team_settings.tscn").instantiate()

## Returns null if the team box does not exist
func get_team_box(team: Team) -> TeamBox:
	return _team_boxes.get(team)

func set_battle(new_battle: Battle) -> void:
	if new_battle == battle:
		return
	_clear_teams()
	if battle != null:
		_disconnect_signals(battle)
	if new_battle != null:
		new_battle.for_each_team(add_team)
		_connect_signals(new_battle)
	battle = new_battle

func add_team(team: Team) -> void:
	if team in _team_boxes:
		return
	var team_box := TeamBox.create()
	team_box.team = team
	_team_boxes[team] = team_box
	add_child(team_box)

func remove_team(team: Team) -> void:
	if not team in _team_boxes:
		return
	_team_boxes[team].queue_free()
	_team_boxes.erase(team)

func _clear_teams() -> void:
	for team in _team_boxes:
		_team_boxes[team].queue_free()
	_team_boxes.clear()

func _disconnect_signals(old_battle: Battle) -> void:
	old_battle.team_created.disconnect(add_team)
	old_battle.team_removed.disconnect(remove_team)

func _connect_signals(new_battle: Battle) -> void:
	new_battle.team_created.connect(add_team)
	new_battle.team_removed.connect(remove_team)
