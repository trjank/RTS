class_name Player extends Node3D

var display_name: String
var color: Color
var alive := false
var team: Team:
	set = set_team
var resources := StrategicResources.new()

func _init(init_display_name := "", init_color := Color.WHITE) -> void:
	display_name = init_display_name
	color = init_color

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		set_team(null)

func set_team(new_team: Team) -> void:
	if team != null:
		team.players.erase(self)
	if new_team != null:
		new_team.players.push_back(self)
	team = new_team

func spawn_ship(ship_data: ShipData, spawnpoint := Vector3.ZERO) -> Ship:
	var ship := Ship.create()
	add_child(ship)
	ship.data = ship_data
	ship.player_owner = self
	ship.position = spawnpoint
	ExplodeTest.explode(ship)
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
