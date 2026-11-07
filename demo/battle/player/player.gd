class_name Player extends Node3D

signal display_name_changed(old_display_name: String, new_display_name: String)
signal clan_changed(old_clan: String, new_clan: String)
signal icon_changed(old_icon: Texture2D, new_icon: Texture2D)
signal bot_status_changed

const MAX_CLAN_LENGTH := 10

var display_name: String:
	set = set_display_name
var color: Color
var alive := false
var team: Team:
	set = set_team
var clan := "":
	set = set_clan
var icon: Texture2D = preload("res://icons/skull.png"):
	set = set_icon
var resources := StrategicResources.new()
var fleet: Fleet
var is_bot := false:
	set = set_bot_status
var is_admin := false
var mouse_position := Vector3.ZERO
var selection: Array[Target] = []

var _battle: Battle
var _battle_data := {}
var _ships := Node3D.new()
var _ship_counts: Dictionary[ShipData, int] = {}

func _init(init_display_name := "", init_color := Color.WHITE) -> void:
	display_name = init_display_name
	color = init_color
	add_child(_ships, false, Node.INTERNAL_MODE_BACK)

func is_me() -> bool:
	return _battle != null and self == _battle.me

func is_host() -> bool:
	return _battle != null and self == _battle.host

func get_battle() -> Battle:
	return _battle

func get_battle_data() -> Dictionary:
	return _battle_data

func count_ships(data: ShipData) -> int:
	return _ship_counts.get(data, 0)

func set_bot_status(bot_status: bool) -> void:
	if bot_status == is_bot:
		return
	is_bot = bot_status
	bot_status_changed.emit()

func set_clan(new_clan: String) -> void:
	new_clan = new_clan.left(MAX_CLAN_LENGTH)
	#
	if new_clan == clan:
		return
	var old_clan := clan
	clan = new_clan
	clan_changed.emit(old_clan, new_clan)

func set_icon(new_icon: Texture2D) -> void:
	if new_icon == icon or new_icon == null:
		return
	var old_icon := icon
	icon = new_icon
	icon_changed.emit(old_icon, new_icon)

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

func clear_ships() -> void:
	_ships.queue_free()
	_ships = Node3D.new()
	add_child(_ships, false, Node.INTERNAL_MODE_BACK)

func spawn_ship(ship_data: ShipData, spawnpoint := Vector3.ZERO) -> Ship:
	if ship_data.finalize() != ShipData.PlacementError.OK:
		print("SHIP HAS PROBLEMS")
	_ship_counts[ship_data] = _ship_counts.get(ship_data, 0) + 1
	# TODO: setup death decrementer
	var ship := Ship.create()
	_ships.add_child(ship)
	#ship_data.generate_image()
	ship.battle = get_battle()
	ship.data = ship_data
	ship.player_owner = self
	ship.position = spawnpoint
	return ship

func build_ship(ship_data: ShipData, spawnpoint := Vector3.ZERO) -> Ship:
	if not resources.can_afford(ship_data.cost):
		return null
	resources.subtract(ship_data.cost)
	return spawn_ship(ship_data, spawnpoint)

func spawn_ship_slot(slot: int, spawnpoint := Vector3.ZERO) -> Ship:
	return spawn_ship(fleet.get_ship(slot), spawnpoint) if fleet != null else null

func build_ship_slot(slot: int, spawnpoint := Vector3.ZERO) -> Ship:
	return build_ship(fleet.get_ship(slot), spawnpoint) if fleet != null else null

func register_death(unit: Unit) -> void:
	if team != null:
		team.register_death(unit)

func register_kill(unit: Unit) -> void:
	if team != null:
		team.register_kill(unit)

func _physics_process(dt: float) -> void:
	if alive and team != null:
		resources.generate_resources(team.resource_rate, dt)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		set_team(null)
	if what == NOTIFICATION_PARENTED and _battle != null:
		push_error("(Player) Players should not be reparented!")
	# (Player nodes need to be internally handled by Battle to prevent bugs)
