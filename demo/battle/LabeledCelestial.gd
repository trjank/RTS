extends Celestial

const MAKE_TEXT_UPRIGHT := true

@export var indicators: Control

func _process(dt):
	if MAKE_TEXT_UPRIGHT:
		indicators.rotation = -rotation
