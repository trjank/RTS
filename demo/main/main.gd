class_name Main extends Node2D

enum State {MAIN_MENU, SETTINGS, DESIGN, BATTLE, FLEET, SERVER_SELECTOR}

var state := State.MAIN_MENU: set = set_state

@onready var _state_nodes: Dictionary[State, Node] = {
	State.MAIN_MENU: $MainMenu,
	State.SETTINGS: $SettingsMenu,
	State.DESIGN: $Design,
	State.BATTLE: $Battle,
	State.FLEET: $Fleets,
	State.SERVER_SELECTOR: null
}

static func toggle_node(node: Node, enable: bool)->void:
	if not node: return
	# Preserves data and avoids overhead of creating and freeing nodes
	node.visible = enable
	node.process_mode = Node.PROCESS_MODE_INHERIT if enable else Node.PROCESS_MODE_DISABLED

func set_state(new_state: State)->void:
	toggle_node(_state_nodes[state], false)
	toggle_node(_state_nodes[new_state], true)
	state = new_state

func _ready()->void:
	globals.main = self
	# Visibility works differently for CanvasLayer nodes
	for node in get_tree().get_nodes_in_group("CanvasLayerToggle"):
		node.get_parent().visibility_changed.connect(func()->void: node.visible = node.get_parent().visible)
	# Ensure that states are initially hidden
	for node in _state_nodes.values():
		toggle_node(node, _state_nodes[state] == node)
