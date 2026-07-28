class_name WeaponModifiers extends RefCounted

enum SpecialFlags {}

const SYNTAX: Dictionary[String, Variant.Type] = {
	"flat_damage": TYPE_FLOAT,
	"flat_range": TYPE_FLOAT,
	"flat_energy": TYPE_FLOAT,
	"flat_speed": TYPE_FLOAT,
	"flat_cooldown": TYPE_FLOAT,
	"multiplier_damage": TYPE_FLOAT,
	"multiplier_range": TYPE_FLOAT,
	"multiplier_energy": TYPE_FLOAT,
	"multiplier_speed": TYPE_FLOAT,
	"multiplier_cooldown": TYPE_FLOAT
}

static var NONE := StrategicResources.new():
	set(__): push_error("WeaponModifiers.NONE is immutable")

var flat_damage := 0.0
var flat_range := 0.0
var flat_energy := 0.0
var flat_speed := 0.0
var flat_cooldown := 0.0
var multiplier_damage := 1.0
var multiplier_range := 1.0
var multiplier_energy := 1.0
var multiplier_speed := 1.0
var multiplier_cooldown := 1.0
var special_flags := 0

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

func reset_flat() -> void:
	flat_damage = 0.0
	flat_range = 0.0
	flat_energy = 0.0
	flat_speed = 0.0
	flat_cooldown = 0.0

func reset_multipliers() -> void:
	multiplier_damage = 1.0
	multiplier_range = 1.0
	multiplier_energy = 1.0
	multiplier_speed = 1.0
	multiplier_cooldown = 1.0

func reset_special_flags() -> void:
	special_flags = 0

func reset() -> void:
	reset_flat()
	reset_multipliers()
	reset_special_flags()

func add_flat(from: WeaponModifiers) -> void:
	flat_damage += from.flat_damage
	flat_range += from.flat_range
	flat_energy += from.flat_energy
	flat_speed += from.flat_speed
	flat_cooldown += from.flat_cooldown

func add_multipliers(from: WeaponModifiers) -> void:
	multiplier_damage *= from.multiplier_damage
	multiplier_range *= from.multiplier_range
	multiplier_energy *= from.multiplier_energy
	multiplier_speed *= from.multiplier_speed
	multiplier_cooldown *= from.multiplier_cooldown

func add_special_flags(from: WeaponModifiers) -> void:
	special_flags |= from.special_flags

func add(from: WeaponModifiers) -> void:
	add_flat(from)
	add_multipliers(from)
	add_special_flags(from)
