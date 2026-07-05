class_name SceneryTarget extends Target

var _scenery: Scenery

func is_alive() -> bool:
	return _scenery != null

func as_scenery() -> Scenery:
	return _scenery

func mine(storage: StrategicResources, rate: StrategicResources, dt := 1.0) -> void:
	if is_alive():
		_scenery.resources.transfer(storage, rate, dt)

func hit(damage: float, _from: Player = null, _penetration := 0.0) -> void:
	if is_alive():
		_scenery.hit(damage)
