class_name WeaponModifiers extends RefCounted

var flat_range := 0.0
var flat_energy := 0.0
var flat_speed := 0.0
var flat_cooldown := 0.0
var multiplier_range := 1.0
var multiplier_energy := 1.0
var multiplier_speed := 1.0
var multiplier_cooldown := 1.0

func combine_flat(other_modifiers: WeaponModifiers)->void:
	# NOTE: We update the current modifiers, not create a copy
	flat_range    += other_modifiers.flat_range
	flat_energy   += other_modifiers.flat_energy
	flat_speed    += other_modifiers.flat_speed
	flat_cooldown += other_modifiers.flat_cooldown

func combine_multipliers(other_modifiers: WeaponModifiers)->void:
	# NOTE: We update the current modifiers, not create a copy
	multiplier_range    *= other_modifiers.multiplier_range
	multiplier_energy   *= other_modifiers.multiplier_energy
	multiplier_speed    *= other_modifiers.multiplier_speed
	multiplier_cooldown *= other_modifiers.multiplier_cooldown

func combine(other_modifiers: WeaponModifiers)->void:
	combine_flat(other_modifiers)
	combine_multipliers(other_modifiers)
 
