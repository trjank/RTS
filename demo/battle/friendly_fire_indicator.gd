extends Button

@export var battle: Battle
@export var animation_duration_sec := 0.1

func _ready() -> void:
	self_modulate.a = 1.0 if battle.friendly_fire_enabled else 0.0

func toggle(enabled: bool) -> void:
	create_tween().tween_property(self, "self_modulate:a", 1.0 if enabled else 0.0, animation_duration_sec)

func _on_pressed() -> void:
	toggle(false)

func _on_battle_friendly_fire_changed(enabled: bool) -> void:
	toggle(enabled)

func _on_battle_started() -> void:
	toggle(battle.friendly_fire_enabled)
