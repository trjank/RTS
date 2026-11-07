class_name WeaponData extends PartData

const MIN_BURST_SHOTS := 1
const MIN_BURST_SEC := 0.0
const MIN_RELOAD_SEC := 0.1
const MIN_CHARGE_SEC := 0.0

var projectile_code := "NULL"
var barrel_z := 0.0
var center_z := 0.0
var burst_shots := MIN_BURST_SHOTS:
	set = set_burst_shots
var burst_sec := MIN_BURST_SEC:
	set = set_burst_sec
var reload_sec := MIN_RELOAD_SEC:
	set = set_reload_sec
var charge_sec := MIN_CHARGE_SEC:
	set = set_charge_sec
var target_prediction := false
var muzzle_flash_enabled := false
var muzzle_flash := ExplosionData.new()

func _init(const_code: String, const_size := DEFAULT_SIZE, _const_boundary := Boundary.NONE) -> void:
	super(const_code, const_size, Boundary.NONE)

func becomes_node_on_ship() -> bool:
	return true

func get_projectile() -> ProjectileData:
	return _manager.get_part(projectile_code) as ProjectileData

func set_burst_shots(new_burst_shots: int) -> void:
	burst_shots = maxi(new_burst_shots, MIN_BURST_SHOTS)

func set_burst_sec(new_burst_sec: float) -> void:
	burst_sec = maxf(new_burst_sec, MIN_BURST_SEC)

func set_reload_sec(new_reload_sec: float) -> void:
	reload_sec = maxf(new_reload_sec, MIN_RELOAD_SEC) 

func set_charge_sec(new_charge_sec: float) -> void:
	charge_sec = maxf(new_charge_sec, MIN_CHARGE_SEC)

func calculate_fire_cycle_time() -> float:
	return (burst_shots - 1) * burst_sec + reload_sec + charge_sec

func create_ship_data_part(id := ShipData.NULL_PART_ID, rect := Rect2i(), rotation := Rotation.Discrete.ROT_0, boundary := _boundary) -> ShipDataPart:
	return ShipDataWeapon.new(id, self, rect, rotation, boundary)

func create_part() -> Part:
	var weapon := Weapon.new()
	weapon.data = self
	return weapon
