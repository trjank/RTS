class_name UnitLogicEditor extends Node

signal db_changed(new_db: UnitLogicDatabase)
signal unit_logic_changed(new_unit_logic: UnitLogic)

@export var create_unit_logic_button: Button
@export var create_block_button: Button
@export var loaded_container: VBoxContainer
@export var block_container: VBoxContainer

var unit_logic: UnitLogic:
	set = set_unit_logic
var db: UnitLogicManager:
	set = set_db

var _loaded: Dictionary[UnitLogic, LoadedUnitLogic] = {}
var _blocks: Dictionary[LogicBlock, LogicBlockEditor] = {}

func _ready() -> void:
	db = Globals.unit_logic_db

func set_unit_logic(new_unit_logic: UnitLogic) -> void:
	clear_blocks()
	if unit_logic != null:
		_disconnect_logic_signals(unit_logic)
	if new_unit_logic != null:
		_setup_new_unit_logic(new_unit_logic)
	unit_logic = new_unit_logic
	toggle_block_edit()
	unit_logic_changed.emit(new_unit_logic)

func set_db(new_db: UnitLogicManager) -> void:
	clear_loaded()
	if db != null:
		_disconnect_db_signals(db)
	if new_db != null:
		_setup_new_db(new_db)
	unit_logic = null
	db = new_db
	toggle_logic_edit()
	db_changed.emit(new_db)

func toggle_block_edit() -> void:
	create_block_button.disabled = unit_logic == null

func toggle_logic_edit() -> void:
	create_unit_logic_button.disabled = db == null

func clear_loaded() -> void:
	for loaded in _loaded:
		_loaded[loaded].queue_free()
	_loaded.clear()

func clear_blocks() -> void:
	for block in _blocks:
		_blocks[block].queue_free()
	_blocks.clear()

func add_loaded(logic: UnitLogic) -> void:
	if logic in _loaded:
		return push_error("Unit logic is already loaded")
	var loaded := LoadedUnitLogic.create()
	loaded_container.add_child(loaded)
	loaded.unit_logic = logic
	_loaded[logic] = loaded
	_connect_loaded_signals(loaded)

func add_block(logic_block: LogicBlock) -> void:
	if logic_block in _blocks:
		return push_error("Logic block is already added")
	var block := LogicBlockEditor.create()
	block_container.add_child(block)
	block.logic_block = logic_block
	_blocks[logic_block] = block
	_connect_block_signals(block)

func remove_loaded(logic: UnitLogic) -> void:
	_loaded[logic].queue_free()
	_loaded.erase(logic)

func remove_block(logic_block: LogicBlock) -> void:
	_blocks[logic_block].queue_free()
	_blocks.erase(logic_block)

func save(lazy := true) -> bool:
	return unit_logic != null and unit_logic.serialize(lazy) and unit_logic.save(lazy)

func undo(lazy := true) -> bool:
	return unit_logic != null and unit_logic.sync(lazy)

func _connect_loaded_signals(loaded: LoadedUnitLogic) -> void:
	loaded.pressed.connect(on_loaded_unit_logic_pressed.bind(loaded) )
	unit_logic_changed.connect(loaded.on_editor_unit_logic_changed)

func _connect_block_signals(block: LogicBlockEditor) -> void:
	block.delete_requested.connect(remove_block)

func _connect_logic_signals(new_unit_logic: UnitLogic) -> void:
	new_unit_logic.cleared.connect(clear_blocks)
	new_unit_logic.block_added.connect(add_block)
	new_unit_logic.block_removed.connect(remove_block)

func _connect_db_signals(new_db: UnitLogicManager) -> void:
	new_db.unit_logic_created.connect(add_loaded)
	new_db.unit_logic_deleted.connect(remove_loaded)

func _disconnect_logic_signals(old_unit_logic: UnitLogic) -> void:
	old_unit_logic.cleared.disconnect(clear_blocks)
	old_unit_logic.block_added.disconnect(add_block)
	old_unit_logic.block_removed.disconnect(remove_block)

func _disconnect_db_signals(old_db: UnitLogicManager) -> void:
	old_db.unit_logic_created.disconnect(add_loaded)
	old_db.unit_logic_deleted.disconnect(remove_loaded)

func _setup_new_unit_logic(new_unit_logic: UnitLogic) -> void:
	for block in new_unit_logic._blocks:
		add_block(block)
	_connect_logic_signals(new_unit_logic)

func _setup_new_db(new_db: UnitLogicManager) -> void:
	for id in new_db._loaded_unit_logic:
		add_loaded(new_db._loaded_unit_logic[id] )
	_connect_db_signals(new_db)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"save"):
		save()
	if event.is_action_pressed(&"undo"):
		undo()

func on_loaded_unit_logic_pressed(loaded: LoadedUnitLogic) -> void:
	unit_logic = loaded.unit_logic

func _on_create_block_button_pressed() -> void:
	unit_logic.add_block()

func _on_create_unit_logic_button_pressed() -> void:
	db.create_unit_logic(UnitLogic.new() )
