class_name Player extends Node3D

signal display_name_changed(old_display_name: String, new_display_name: String)
signal clan_changed(old_clan: String, new_clan: String)
signal icon_changed(old_icon: Texture2D, new_icon: Texture2D)
signal bot_status_changed

const MAX_CLAN_LENGTH := 10
const MAX_NAME_LENGTH := 25

var id := -1
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
var resources := StrategicResources.new():
	set = set_resources
var fleet: Fleet
var is_bot := false:
	set = set_bot_status
var is_admin := false
var mouse_position := Vector3.ZERO
var selection: Array[Target] = []

var _battle: Battle
var _battle_data := {}
var _ships := Node3D.new()
var _projectiles := Node3D.new()
var _ship_counts: Dictionary[ShipData, int] = {}

static func is_name_valid(new_name: String) -> bool:
	return new_name.length() <= MAX_NAME_LENGTH

func _init(init_display_name := "", init_color := Color.WHITE) -> void:
	display_name = init_display_name
	color = init_color
	add_child(_ships, false, Node.INTERNAL_MODE_BACK)
	add_child(_projectiles, false, Node.INTERNAL_MODE_BACK)

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

func count_total_ships() -> int:
	return _ships.get_child_count()

func count_total_projectiles() -> int:
	return _projectiles.get_child_count()

func set_resources(new_resources: StrategicResources) -> void:
	resources = new_resources if new_resources != null else resources

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
	new_display_name = new_display_name.left(MAX_NAME_LENGTH)
	#
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
	_ship_counts.clear()
	_ships.queue_free()
	_ships = Node3D.new()
	add_child(_ships, false, Node.INTERNAL_MODE_BACK)

func clear_projectiles() -> void:
	_projectiles.queue_free()
	_projectiles = Node3D.new()
	add_child(_projectiles, false, Node.INTERNAL_MODE_BACK)

## Only use this if you know what you're doing
func increment_count(ship: ShipData, amount := 1) -> void:
	_ship_counts[ship] = _ship_counts.get(ship, 0) + amount

## Only use this if you know what you're doing
func decrement_count(ship: ShipData, amount := 1) -> void:
	if _ship_counts.get(ship, 0) <= amount:
		return _ship_counts.erase(ship)
	_ship_counts[ship] -= amount

func spawn_ship(ship_data: ShipData, spawnpoint := Vector3.ZERO) -> Ship:
	if ship_data == null or ship_data.finalize() != ShipData.PlacementError.OK:
		return null
	var ship := Ship.create()
	increment_count(ship_data)
	_ships.add_child(ship)
	#ship_data.generate_image()
	ship.battle = get_battle()
	ship.data = ship_data
	ship.player_owner = self
	ship.position = spawnpoint
	return ship

func build_ship(ship_data: ShipData, spawnpoint := Vector3.ZERO) -> Ship:
	if ship_data == null or not resources.can_afford(ship_data.cost):
		return null
	resources.subtract(ship_data.cost)
	return spawn_ship(ship_data, spawnpoint)

func spawn_ship_slot(slot: int, spawnpoint := Vector3.ZERO) -> Ship:
	return spawn_ship(fleet.get_ship(slot), spawnpoint) if fleet != null else null

func build_ship_slot(slot: int, spawnpoint := Vector3.ZERO) -> Ship:
	return build_ship(fleet.get_ship(slot), spawnpoint) if fleet != null else null

func register_kill(unit: Unit) -> void:
	if team != null:
		team.register_kill(unit)
	# TODO: Player-specific kill rewards

func register_death(unit: Unit) -> void:
	if team != null:
		team.register_death(unit)
	if unit is Ship:
		decrement_count(unit.data)

func load_node(node: Node3D) -> void:
	if not node is Ship:
		return _projectiles.add_child(node)
	increment_count(node.data)
	_ships.add_child(node)

func save_to(save_state: SaveState) -> int:
	var error_flags: int = SaveState.SaveError.OK
	#
	for node in _ships.get_children():
		error_flags |= save_state.serialize_node(node, self)
	for node in _projectiles.get_children():
		error_flags |= save_state.serialize_node(node, self)
	return error_flags

func _physics_process(dt: float) -> void:
	if alive and team != null:
		resources.generate_resources(team.resource_rate, dt)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		set_team(null)
	if what == NOTIFICATION_PARENTED and _battle != null:
		push_error("(Player) Players should not be reparented!")
	# (Player nodes need to be internally handled by Battle to prevent bugs)
