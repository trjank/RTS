class_name Player extends Node3D

signal display_name_changed(old_display_name: String, new_display_name: String)

const MAX_CLAN_LENGTH := 10

var display_name: String:
	set = set_display_name
var color: Color
var alive := false
var team: Team:
	set = set_team
var clan := "":
	set = set_clan
var icon := preload("res://icons/skull.png")
var resources := StrategicResources.new()
var is_admin := false

func _init(init_display_name := "", init_color := Color.WHITE) -> void:
	display_name = init_display_name
	color = init_color

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		set_team(null)

func set_clan(new_clan: String) -> void:
	clan = new_clan.left(MAX_CLAN_LENGTH)

func set_display_name(new_display_name: String) -> void:
	if new_display_name == display_name:
		return
	var old_display_name := display_name
	display_name = new_display_name
	display_name_changed.emit(old_display_name, new_display_name)

func set_team(new_team: Team) -> void:
	if new_team == team or (new_team != null and new_team.is_full() ):
		return
	if team != null:
		team.remove_player(self)
	if new_team != null:
		new_team.add_player(self)
	team = new_team

func spawn_ship(ship_data: ShipData, spawnpoint := Vector3.ZERO) -> Ship:
	var ship := Ship.create()
	add_child(ship)
	ship.data = ship_data
	ship.player_owner = self
	ship.position = spawnpoint
	return ship

func register_death(unit: Unit) -> void:
	if team != null:
		team.register_death(unit)
	# TODO: Additional penalties?

func register_kill(unit: Unit) -> void:
	if team != null:
		team.register_kill(unit)
	# TODO: Bounty system?

func _physics_process(dt: float) -> void:
	if not alive or team == null:
		return
	resources.generate_resources(team.resource_rate, dt)
