class_name WeaponModifiers extends RefCounted

enum SpecialFlags {
	NONE = 0
}

const SYNTAX: Dictionary[String, Variant.Type] = {
	"flat_damage": TYPE_FLOAT,
	"flat_range": TYPE_FLOAT,
	"flat_energy": TYPE_FLOAT,
	"flat_speed": TYPE_FLOAT,
	"flat_cooldown": TYPE_FLOAT,
	"flat_energy_drain": TYPE_FLOAT,
	"multiplier_damage": TYPE_FLOAT,
	"multiplier_range": TYPE_FLOAT,
	"multiplier_energy": TYPE_FLOAT,
	"multiplier_speed": TYPE_FLOAT,
	"multiplier_cooldown": TYPE_FLOAT,
	"multiplier_energy_drain": TYPE_FLOAT
}

static var NONE := WeaponModifiers.new():
	set(__): push_error("WeaponModifiers.NONE is immutable")

var flat_damage := 0.0
var flat_range := 0.0
var flat_energy := 0.0
var flat_speed := 0.0
var flat_cooldown := 0.0
var flat_energy_drain := 0.0
var multiplier_damage := 1.0
var multiplier_range := 1.0
var multiplier_energy := 1.0
var multiplier_speed := 1.0
var multiplier_cooldown := 1.0
var multiplier_energy_drain := 1.0
var special_flags: int = SpecialFlags.NONE

static func from_dict(dict: Dictionary, always_copy := false) -> WeaponModifiers:
	var modifiers := WeaponModifiers.new()
	return modifiers if modifiers.load_dict(dict) or always_copy else NONE

func to_dict() -> Dictionary:
	return TypeChecker.to_dict(self, SYNTAX)

func load_dict(dict: Dictionary) -> bool:
	return TypeChecker.load_dict(self, dict, SYNTAX, TypeChecker.CAST_NUMBERS)

func copy() -> WeaponModifiers:
	var modifiers := WeaponModifiers.new()
	modifiers.add(self)
	return modifiers

func calculate_damage(base_damage: float) -> float:
	return multiplier_damage * base_damage + flat_damage

func calculate_range(base_range: float) -> float:
	return multiplier_range * base_range + flat_range

func calculate_energy(base_energy: float) -> float:
	return multiplier_energy * base_energy + flat_energy

func calculate_speed(base_speed: float) -> float:
	return multiplier_speed * base_speed + flat_speed

func calculate_cooldown(base_cooldown: float) -> float:
	return multiplier_cooldown * base_cooldown + flat_cooldown

func calculate_energy_drain(base_energy_drain: float) -> float:
	return multiplier_energy_drain * base_energy_drain + flat_energy_drain

func reset_flat() -> void:
	flat_damage       = 0.0
	flat_range        = 0.0
	flat_energy       = 0.0
	flat_speed        = 0.0
	flat_cooldown     = 0.0
	flat_energy_drain = 0.0

func reset_multipliers() -> void:
	multiplier_damage       = 1.0
	multiplier_range        = 1.0
	multiplier_energy       = 1.0
	multiplier_speed        = 1.0
	multiplier_cooldown     = 1.0
	multiplier_energy_drain = 1.0

func reset_special_flags() -> void:
	special_flags = 0

func reset() -> void:
	reset_flat()
	reset_multipliers()
	reset_special_flags()

func add_flat(from: WeaponModifiers) -> void:
	flat_damage       += from.flat_damage
	flat_range        += from.flat_range
	flat_energy       += from.flat_energy
	flat_speed        += from.flat_speed
	flat_cooldown     += from.flat_cooldown
	flat_energy_drain += from.flat_energy_drain

func add_multipliers(from: WeaponModifiers) -> void:
	multiplier_damage       *= from.multiplier_damage
	multiplier_range        *= from.multiplier_range
	multiplier_energy       *= from.multiplier_energy
	multiplier_speed        *= from.multiplier_speed
	multiplier_cooldown     *= from.multiplier_cooldown
	multiplier_energy_drain *= from.multiplier_energy_drain

func add_special_flags(from: WeaponModifiers) -> void:
	special_flags |= from.special_flags

func add(from: WeaponModifiers) -> void:
	add_flat(from)
	add_multipliers(from)
	add_special_flags(from)

func apply_flat_efficiency(efficiency := 1.0) -> void:
	flat_damage       *= efficiency
	flat_range        *= efficiency
	flat_energy       *= efficiency
	flat_speed        *= efficiency
	flat_cooldown     *= efficiency
	flat_energy_drain *= efficiency

func apply_multiplier_efficiency(efficiency := 1.0) -> void:
	multiplier_damage       **= efficiency
	multiplier_range        **= efficiency
	multiplier_energy       **= efficiency
	multiplier_speed        **= efficiency
	multiplier_cooldown     **= efficiency
	multiplier_energy_drain **= efficiency

func apply_efficiency(efficiency := 1.0) -> void:
	apply_flat_efficiency(efficiency)
	apply_multiplier_efficiency(efficiency)
