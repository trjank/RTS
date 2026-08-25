@abstract class_name UnitLogicManager extends RefCounted

@warning_ignore("unused_signal") signal unit_logic_created(unit_logic: UnitLogic)
@warning_ignore("unused_signal") signal unit_logic_deleted(unit_logic: UnitLogic)

const INVALID_ID := -1

@abstract func size() -> int
@abstract func get_unit_logic(id: int) -> UnitLogic
@abstract func create_unit_logic(unit_logic: UnitLogic) -> bool
@abstract func delete_unit_logic(unit_logic: UnitLogic) -> bool
## NOTE: This does not automatically update unit_logic.saved (use unit_logic.save() instead for that)
@abstract func save_unit_logic(unit_logic: UnitLogic) -> bool
## NOTE: This does not automatically update unit_logic.saved (use unit_logic.sync() instead for that)
@abstract func sync_unit_logic(unit_logic: UnitLogic) -> bool
