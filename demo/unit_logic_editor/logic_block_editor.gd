class_name LogicBlockEditor extends PanelContainer

@export var delete_button: Button
@export var behavior_option_button: OptionButton

signal delete_requested(block: LogicBlock)

var logic_block: LogicBlock:
	set = set_logic_block

static func create() -> LogicBlockEditor:
	return preload("res://unit_logic_editor/logic_block_editor.tscn").instantiate()

func set_logic_block(new_logic_block: LogicBlock) -> void:
	logic_block = new_logic_block
	delete_button.disabled = logic_block == null

func _on_behavior_option_button_item_selected(index: int) -> void:
	logic_block.behavior = index as Unit.Behavior

func _on_delete_button_pressed() -> void:
	delete_requested.emit(logic_block)
