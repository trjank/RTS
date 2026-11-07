class_name LogicBlockEditor extends PanelContainer

signal delete_requested(block: LogicBlock)

@export var conditions_container: HFlowContainer
@export var add_condition_button: Button
@export var delete_button: Button
@export var behavior_option_button: OptionButton

var logic_block: LogicBlock:
	set = set_logic_block

var _conditions: Dictionary[LogicBlockCondition, LogicBlockConditionEditor] = {}

static func create() -> LogicBlockEditor:
	return preload("res://unit_logic_editor/logic_block_editor.tscn").instantiate()

func set_logic_block(new_logic_block: LogicBlock) -> void:
	if logic_block != null:
		_disconnect_signals(logic_block)
	if new_logic_block != null:
		_connect_signals(new_logic_block)
	logic_block = new_logic_block
	toggle_edit(logic_block != null)

func toggle_edit(enabled: bool) -> void:
	delete_button.disabled = not enabled
	add_condition_button.disabled = not enabled

func _connect_signals(new_logic_block: LogicBlock) -> void:
	new_logic_block.condition_added.connect(add_condition)
	new_logic_block.condition_removed.connect(remove_condition)

func _disconnect_signals(old_logic_block: LogicBlock) -> void:
	old_logic_block.condition_added.disconnect(add_condition)
	old_logic_block.condition_removed.disconnect(remove_condition)

func add_condition(condition: LogicBlockCondition) -> void:
	var condition_editor := LogicBlockConditionEditor.create()
	conditions_container.add_child(condition_editor)
	condition_editor.logic_block_condition = condition
	_conditions[condition] = condition_editor
	add_condition_button.move_to_front()

func remove_condition(condition: LogicBlockCondition) -> void:
	_conditions[condition].queue_free()
	_conditions.erase(condition)

func _on_behavior_option_button_item_selected(index: int) -> void:
	logic_block.behavior = index as Unit.Behavior

func _on_delete_button_pressed() -> void:
	delete_requested.emit(logic_block)

func _on_add_condition_button_pressed() -> void:
	logic_block.add_condition()
