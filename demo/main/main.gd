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
@export var camera: Camera3D
@export var world: Node3D
@export var ui: CanvasLayer
@export var background: TextureRect

var _world_nodes: Dictionary[State, Node3D] = {}
var _ui_nodes: Dictionary[State, Control] = {}
var _camera_positions: Dictionary[State, Vector3] = {}

var state := State.MAIN_MENU:
	set = set_state

static func toggle_node(node: Node, enable: bool) -> void:
	assert(node != null)
	#
	node.visible = enable
	node.process_mode = Node.PROCESS_MODE_INHERIT if enable else Node.PROCESS_MODE_DISABLED

func _ready() -> void:
	for substate in nodes:
		prepare_subscene(substate, nodes[substate] )
	globals.main = self

func change_camera(from: State, to: State) -> void:
	var parent := camera.get_parent_node_3d()
	_camera_positions[from] = parent.position
	parent.position = _camera_positions[to]

func set_state(new_state: State) -> void:
	toggle_node(_world_nodes[state], false)
	toggle_node(_ui_nodes[state], false)
	toggle_node(_world_nodes[new_state], true)
	toggle_node(_ui_nodes[new_state], true)
	change_camera(state, new_state)
	state = new_state

func prepare_subscene(substate: State, subscene_root: Node) -> void:
	# NOTE: World nodes are affected by the camera while UI is not
	var subworld := subscene_root.get_node("World") as Node3D
	var subui := subscene_root.get_node("UI") as Control
	assert(subworld != null, str(subscene_root) )
	#      ^^^^^^^^ You must use this structure because mixing UI and 3D nodes causes issues
	assert(subui != null, str(subscene_root) )
	#      ^^^^^ You must use this structure because mixing UI and 3D nodes causes issues
	subworld.reparent(world)
	subui.reparent(ui)
	_camera_positions[substate] = Vector3.ZERO
	_world_nodes[substate] = subworld
	_ui_nodes[substate] = subui
	toggle_node(subworld, state == substate)
	toggle_node(subui, state == substate)
