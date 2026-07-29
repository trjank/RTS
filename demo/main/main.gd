class_name Main extends Node

signal state_changed(new_state: State)

enum State {
	MAIN_MENU,
	DESIGN,
	BATTLE,
	FLEET,
	SINGLEPLAYER,
	TRAINING_GROUNDS
}

const MAX_ADAPTIVE_FOV := 170.0
const DEFAULT_ADAPTIVE_FOV_RATIO := 1e-4

@export var base_fov := 75.0
@export var nodes: Dictionary[State, Node]
@export var camera: Camera3D
@export var camera_body: RigidBody3D
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

func get_world_node(node_state := state) -> Node3D:
	return _world_nodes[node_state]

func get_ui_node(node_state := state) -> Control:
	return _ui_nodes[node_state]

func get_adaptive_fov(ratio := DEFAULT_ADAPTIVE_FOV_RATIO) -> float:
	var screen_height := get_viewport().get_visible_rect().size.y
	var fov := rad_to_deg(2.0 * atan(screen_height * ratio) )
	return minf(fov, MAX_ADAPTIVE_FOV)

func change_camera(from: State, to: State) -> void:
	await get_tree().physics_frame
	#
	_camera_positions[from] = camera_body.position
	camera_body.position = _camera_positions[to]
	camera_body.linear_velocity = Vector3.ZERO
	camera_body.angular_velocity = Vector3.ZERO
	camera_body.freeze = to == State.MAIN_MENU

func set_state(new_state: State) -> void:
	if new_state == state:
		return
	toggle_node(_world_nodes[state], false)
	toggle_node(_ui_nodes[state], false)
	toggle_node(_world_nodes[new_state], true)
	toggle_node(_ui_nodes[new_state], true)
	change_camera(state, new_state)
	state = new_state
	state_changed.emit(new_state)

func _process(_dt: float) -> void:
	camera.fov = get_adaptive_fov() if state == State.MAIN_MENU else base_fov

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
	_camera_positions[substate] = camera_body.position
	_world_nodes[substate] = subworld
	_ui_nodes[substate] = subui
	toggle_node(subworld, state == substate)
	toggle_node(subui, state == substate)
