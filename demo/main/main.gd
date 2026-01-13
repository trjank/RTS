class_name Main extends Node

enum State {
	MAIN_MENU,
	SETTINGS,
	DESIGN,
	BATTLE,
	FLEET,
	SERVER_SELECTOR
}

@export var nodes: Dictionary[State, Node]
@export var camera: Camera2D
@export var world: Node2D
@export var ui: CanvasLayer
@export var background: TextureRect

var _world_nodes: Dictionary[State, Node2D] = {}
var _ui_nodes: Dictionary[State, Control] = {}
var _camera_positions: Dictionary[State, Vector2] = {}

var state := State.MAIN_MENU:
	set = set_state

func change_camera(from: State, to: State) -> void:
	camera.position_smoothing_enabled = false
	_camera_positions[from] = camera.position
	camera.position = _camera_positions[to]
	camera.reset_smoothing()
	camera.position_smoothing_enabled = true

func set_state(new_state: State) -> void:
	toggle_node(_world_nodes[state], false)
	toggle_node(_ui_nodes[state], false)
	toggle_node(_world_nodes[new_state], true)
	toggle_node(_ui_nodes[new_state], true)
	change_camera(state, new_state)
	state = new_state

func _ready() -> void:
	for substate in nodes:
		prepare_subscene(substate, nodes[substate])
	globals.main = self

func toggle_node(node: Node, enable: bool) -> void:
	assert(node != null)
	node.visible = enable
	node.process_mode = Node.PROCESS_MODE_INHERIT if enable else Node.PROCESS_MODE_DISABLED

func prepare_subscene(substate: State, subscene_root: Node) -> void:
	var subworld := subscene_root.get_node("World") as Node2D
	var subui := subscene_root.get_node("UI") as Control
	# NOTE: Control and Node2D to not propagate visibility to each other
	# You MUST separate UI nodes (Control) and world nodes (Node2D)
	assert(subworld != null, str(subscene_root))
	assert(subui != null, str(subscene_root))
	subworld.reparent(world)
	subui.reparent(ui)
	_camera_positions[substate] = Vector2.ZERO
	_world_nodes[substate] = subworld
	_ui_nodes[substate] = subui
	toggle_node(subworld, state == substate)
	toggle_node(subui, state == substate)
