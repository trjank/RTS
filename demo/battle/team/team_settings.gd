class_name TeamSettings extends VBoxContainer

signal request_join_team(team: Team)
signal request_add_bot(team: Team)

var battle: Battle:
	set = set_battle

var _team_boxes: Dictionary[Team, TeamBox] = {}

static func create() -> TeamSettings:
	return preload("res://battle/team/team_settings.tscn").instantiate()

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
	team_box.request_join_team.connect(request_join_team.emit)
	team_box.request_add_bot.connect(request_add_bot.emit)
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
	request_join_team.disconnect(old_battle.request_join_team)
	request_add_bot.disconnect(old_battle.request_add_bot)
	old_battle.team_created.disconnect(add_team)
	old_battle.team_removed.disconnect(remove_team)

func _connect_signals(new_battle: Battle) -> void:
	request_join_team.connect(new_battle.request_join_team)
	request_add_bot.connect(new_battle.request_add_bot)
	new_battle.team_created.connect(add_team)
	new_battle.team_removed.connect(remove_team)
