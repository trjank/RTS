class_name Main extends Node

enum State {
	MAIN_MENU,
	SETTINGS,
	DESIGN,
	BATTLE,
	FLEET,
	SERVER_SELECTOR,
	CAMPAIGN_LEVEL_SELECT
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

static func toggle_node(node: Node, enable: bool) -> void:
	assert(node != null)
	node.visible = enable
	node.process_mode = Node.PROCESS_MODE_INHERIT if enable else Node.PROCESS_MODE_DISABLED

func _ready() -> void:
	for substate in nodes:
		prepare_subscene(substate, nodes[substate] )
	globals.main = self

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

func prepare_subscene(substate: State, subscene_root: Node) -> void:
	# NOTE: World nodes are affected by the camera while UI is not
	var subworld := subscene_root.get_node("World") as Node2D
	var subui := subscene_root.get_node("UI") as Control
	assert(subworld != null, str(subscene_root) )
	#      ^^^^^^^^ You must use this structure because mixing UI and 2D nodes causes issues
	assert(subui != null, str(subscene_root) )
	#      ^^^^^ You must use this structure because mixing UI and 2D nodes causes issues
	subworld.reparent(world)
	subui.reparent(ui)
	_camera_positions[substate] = Vector2.ZERO
	_world_nodes[substate] = subworld
	_ui_nodes[substate] = subui
	toggle_node(subworld, state == substate)
	toggle_node(subui, state == substate)
