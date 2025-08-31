extends Node

enum State {NONE, BATTLE, DESIGN}
enum UI {NONE, NAVBAR, MAIN_MENU, SETTINGS}

var state := State.NONE: set = set_state
var ui := UI.NONE: set = set_ui

# These should have the same order as the enums above
@export var state_nodes: Array[Node]
@export var ui_nodes: Array[Control]

static func toggle_node(node: Node, visible: bool)->void:
	if not node: return
	# Avoid overhead of creating and freeing nodes
	node.visible = visible
	node.process_mode = Node.PROCESS_MODE_INHERIT if visible else Node.PROCESS_MODE_DISABLED

# IMPORTANT: Ensure this _ready occurs AFTER all of the other nodes
func _ready()->void:
	for state_node in state_nodes:
		toggle_node(state_node, false)
	for ui_node in ui_nodes:
		toggle_node(ui_node, false)

func set_state(new_state: State)->void:
	toggle_node(state_nodes[state], false)
	toggle_node(state_nodes[new_state], true)
	state = new_state

func set_ui(new_ui: UI)->void:
	toggle_node(ui_nodes[ui], false)
	toggle_node(ui_nodes[new_ui], true)
	ui = new_ui
