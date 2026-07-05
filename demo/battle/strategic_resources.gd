class_name StrategicResources extends RefCounted

static var NONE := StrategicResources.new():
	set = set_none

const SYNTAX: Dictionary[String, Variant.Type] = {
	"alloy": TYPE_FLOAT,
	"energy": TYPE_FLOAT,
	"military_science": TYPE_FLOAT,
	"min_alloy": TYPE_FLOAT,
	"min_energy": TYPE_FLOAT,
	"min_military_science": TYPE_FLOAT,
	"max_alloy": TYPE_FLOAT,
	"max_energy": TYPE_FLOAT,
	"max_military_science": TYPE_FLOAT
}

var alloy := 0.0:
	set = set_alloy
var energy := 0.0:
	set = set_energy
var military_science := 0.0:
	set = set_military_science
var min_alloy := 0.0
var min_energy := 0.0
var min_military_science := 0.0
var max_alloy := INF
var max_energy := INF
var max_military_science := INF

static func set_none(__: StrategicResources) -> void:
	push_error("StrategicResources.NONE is immutable")

static func from_dict(dict: Dictionary, always_copy := false) -> StrategicResources:
	var resources := StrategicResources.new()
	return resources if resources.load_dict(dict) or always_copy else NONE

func to_dict() -> Dictionary:
	var dict := SYNTAX.duplicate()
	for property in dict:
		dict[property] = get(property)
	return dict

func load_dict(dict: Dictionary) -> bool:
	if not TypeChecker.type_check(dict, SYNTAX, true, TypeChecker.CAST_NUMBERS):
		return false
	for property in dict:
		set(property, dict[property] )
	return true

func set_alloy(new_alloy: float) -> void:
	alloy = clampf(new_alloy, min_alloy, max_alloy)

func set_energy(new_energy: float) -> void:
	energy = clampf(new_energy, min_energy, max_energy)

func set_military_science(new_military_science: float) -> void:
	military_science = clampf(new_military_science, min_military_science, max_military_science)

func can_afford(needs: StrategicResources) -> bool:
	return alloy <= needs.alloy and energy <= needs.energy and military_science <= needs.military_science

func reset() -> void:
	alloy = 0.0
	energy = 0.0
	military_science = 0.0

## NOTE: This does not make a copy
func add_alloy(from: StrategicResources, multiplier := 1.0) -> void:
	alloy += from.alloy * multiplier
	min_alloy += from.min_alloy * multiplier
	max_alloy += from.max_alloy * multiplier

## NOTE: This does not make a copy
func add_energy(from: StrategicResources, multiplier := 1.0) -> void:
	energy += from.energy * multiplier
	min_energy += from.min_energy * multiplier
	max_energy += from.max_energy * multiplier

## NOTE: This does not make a copy
func add_military_science(from: StrategicResources, multiplier := 1.0) -> void:
	military_science += from.military_science * multiplier
	min_military_science += from.min_military_science * multiplier
	max_military_science += from.max_military_science * multiplier

## NOTE: This does not make a copy
func add(from: StrategicResources, multiplier := 1.0) -> void:
	add_alloy(from, multiplier)
	add_energy(from, multiplier)
	add_military_science(from, multiplier)

## This ensures total alloy is always conserved
func transfer_alloy(to: StrategicResources, alloy_limit := INF) -> void:
	var alloy_transfer := minf(minf(alloy, to.max_alloy - to.alloy), alloy_limit)
	alloy -= alloy_transfer
	to.alloy += alloy_transfer

## This ensures total energy is always conserved
func transfer_energy(to: StrategicResources, energy_limit := INF) -> void:
	var energy_transfer := minf(minf(energy, to.max_energy - to.energy), energy_limit)
	energy -= energy_transfer
	to.energy += energy_transfer

## This ensures total military science is always conserved
func transfer_military_science(to: StrategicResources, military_science_limit := INF) -> void:
	var military_science_transfer := minf(minf(military_science, to.max_military_science - to.military_science), military_science_limit)
	military_science -= military_science_transfer
	to.military_science += military_science_transfer

## This ensures total tactical resources are always conserved
func transfer(to: StrategicResources, rate: StrategicResources, dt := 1.0) -> void:
	transfer_alloy(to, rate.alloy * dt)
	transfer_energy(to, rate.energy * dt)
	transfer_military_science(to, rate.military_science * dt)

func generate_resources(rate: StrategicResources, dt := 1.0) -> void:
	alloy += rate.alloy * dt
	energy += rate.energy * dt
	military_science += rate.military_science * dt
