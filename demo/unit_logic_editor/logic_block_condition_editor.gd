class_name LogicBlockConditionEditor extends PanelContainer

const COLORS: Dictionary[Unit.Condition, Color] = {
	Unit.Condition.SPEED: Color(0x5e61ffff)
}
const DEFAULT_COLOR := Color(0xffc45eff)

@export var condition_dropdown: OptionButton
@export var comparison_dropdown: OptionButton
@export var spin_box: SpinBox

var logic_block_condition: LogicBlockCondition:
	set = set_logic_block_condition

static func create() -> LogicBlockConditionEditor:
	return preload("res://unit_logic_editor/logic_block_condition_editor.tscn").instantiate()

func set_logic_block_condition(new_logic_block_condition: LogicBlockCondition) -> void:
	logic_block_condition = new_logic_block_condition
	toggle_edit(new_logic_block_condition != null)

func toggle_edit(enabled: bool) -> void:
	condition_dropdown.disabled = not enabled
	comparison_dropdown.disabled = not enabled
	spin_box.editable = enabled

func _update_color() -> void:
	self_modulate = COLORS.get(logic_block_condition.condition, DEFAULT_COLOR)

func _on_condition_option_button_item_selected(index: int) -> void:
	logic_block_condition.condition = Unit.Condition[condition_dropdown.get_item_text(index).to_upper().replace(" ", "_") ]

func _on_comparison_option_button_item_selected(index: int) -> void:
	logic_block_condition.comparison = index as LogicBlockCondition.Comparison

func _on_spin_box_value_changed(value: float) -> void:
	logic_block_condition.compare_value = value
