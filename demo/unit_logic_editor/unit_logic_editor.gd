class_name UnitLogicEditor extends Node

signal db_changed(new_db: UnitLogicDatabase)
signal unit_logic_changed(new_unit_logic: UnitLogic)

@export var loaded_container: VBoxContainer
@export var block_container: VBoxContainer

var unit_logic: UnitLogic:
	set = set_unit_logic
var db: UnitLogicDatabase:
	set = set_db

var _loaded: Dictionary[UnitLogic, LoadedUnitLogic] = {}
var _blocks: Dictionary[LogicBlock, LogicBlockEditor] = {}

func set_unit_logic(new_unit_logic: UnitLogic) -> void:
	_clear_blocks()
	if unit_logic != null:
		_disconnect_signals(unit_logic)
	if new_unit_logic != null:
		_setup_new_unit_logic(new_unit_logic)
	unit_logic = new_unit_logic
	unit_logic_changed.emit(new_unit_logic)

func set_db(new_db: UnitLogicDatabase) -> void:
	_clear_loaded()
	if db != null:
		_disconnect_db_signals(db)
	if new_db != null:
		_setup_new_db(new_db)
	unit_logic = null
	db = new_db
	db_changed.emit(new_db)

func _disconnect_db_signals(old_db: UnitLogicDatabase) -> void:
	old_db.unit_logic_created.disconnect(_add_loaded)
	old_db.unit_logic_deleted.disconnect(_remove_loaded)

func _disconnect_signals(old_unit_logic: UnitLogic) -> void:
	old_unit_logic.block_added.disconnect(_add_block)
	old_unit_logic.block_removed.disconnect(_remove_block)

func _setup_new_db(new_db: UnitLogicDatabase) -> void:
	for logic in new_db._loaded_unit_logic:
		_add_loaded(new_db._loaded_unit_logic[logic] )
	new_db.unit_logic_created.connect(_add_loaded)
	new_db.unit_logic_deleted.connect(_remove_loaded)

func _setup_new_unit_logic(new_unit_logic: UnitLogic) -> void:
	for block in new_unit_logic._blocks:
		_add_block(block)
	new_unit_logic.block_added.connect(_add_block)
	new_unit_logic.block_removed.connect(_remove_block)

func _clear_loaded() -> void:
	for loaded in _loaded:
		_loaded[loaded].queue_free()
	_loaded.clear()

func _clear_blocks() -> void:
	for block in _blocks:
		_blocks[block].queue_free()
	_blocks.clear()

func _add_loaded(logic: UnitLogic) -> void:
	var loaded := LoadedUnitLogic.create()
	unit_logic_changed.connect(loaded.on_editor_unit_logic_changed)
	loaded.unit_logic = logic
	loaded_container.add_child(loaded)

func _add_block(logic_block: LogicBlock) -> void:
	var block := LogicBlockEditor.create()
	block.logic_block = logic_block
	block_container.add_child(block)

func _remove_loaded(logic: UnitLogic) -> void:
	_loaded[logic].queue_free()
	_loaded.erase(logic)

func _remove_block(logic_block: LogicBlock) -> void:
	_blocks[logic_block].queue_free()
	_blocks.erase(logic_block)

func _input(event: InputEvent) -> void:
	if unit_logic != null and event.is_action_pressed(&"save"):
		unit_logic.save()

func _on_create_block_button_pressed() -> void:
	if unit_logic == null:
		return push_warning("No unit logic to add to")
	unit_logic.add_block()

func _on_create_unit_logic_button_pressed() -> void:
	if db == null:
		return push_warning("No database to add to")
	db.create_unit_logic(UnitLogic.new() )
