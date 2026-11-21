class_name SaveState extends RefCounted

enum Type {
	NONE = 0,
	UNIT = 1 << 0,
	SHIP = 1 << 1,
	BULLET = 1 << 2,
	LASER = 1 << 3,
	DEATH_RAY = 1 << 4,
	ALL = UNIT | SHIP | BULLET | LASER | DEATH_RAY
}
enum SaveError {
	OK = 0,
	DUPLICATE_NODE = 1 << 0,
	INVALID_TYPE = 1 << 1,
	NO_OWNER = 1 << 2
}
enum LoadError {
	OK = 0,
	NO_MORE_DATA = 1 << 0,
	INVALID_TYPE = 1 << 1,
	MISSING_PLAYER = 1 << 2,
	INVALID_DATA = 1 << 3
}

const FILE_EXTENSION := ".bin"

static var type_to_class: Dictionary[Type, Script] = {
	Type.UNIT: Unit,
	Type.SHIP: Ship,
	Type.BULLET: Bullet,
	Type.LASER: Laser,
	Type.DEATH_RAY: DeathRay
}
static var class_to_type: Dictionary[Script, Type] = {
	Unit: Type.UNIT,
	Ship: Type.SHIP,
	Bullet: Type.BULLET,
	Laser: Type.LASER,
	DeathRay: Type.DEATH_RAY
}

var load_flags: int = Type.ALL
var save_flags: int = Type.ALL
var data: PackedByteArray:
	get = get_data, set = set_data

var _buffer := StreamPeerBuffer.new()
var _node_index: Dictionary[Node, int] = {}

func is_path_valid(path: String) -> bool:
	return not path.contains("..") and path.ends_with(FILE_EXTENSION)

func clear() -> void:
	_buffer.clear()
	_node_index.clear()

func has_node(node: Node3D) -> bool:
	return node in _node_index

func get_data() -> PackedByteArray:
	return _buffer.data_array

func set_data(new_data: PackedByteArray) -> void:
	_buffer.data_array = new_data
	_node_index.clear()

func typeof_node(node: Node) -> Type:
	return class_to_type.get(node.get_script(), Type.NONE)

func save_binary(path: String) -> bool:
	if not is_path_valid(path):
		return false
	var file := FileAccess.open(path, FileAccess.WRITE)
	return file != null and file.store_buffer(_buffer.data_array)

func load_binary(path: String) -> bool:
	if not is_path_valid(path):
		return false
	_buffer.data_array = FileAccess.get_file_as_bytes(path)
	return FileAccess.get_open_error() == OK

## The node must directly be owned by a player (does not store arbitrary node paths)
func serialize_node(node: Node3D, owner: Player) -> SaveError:
	var type := typeof_node(node)
	if type == Type.NONE or (load_flags & type) == 0:
		return SaveError.INVALID_TYPE
	if owner == null:
		return SaveError.NO_OWNER
	if node in _node_index:
		return SaveError.DUPLICATE_NODE
	var i := _buffer.get_position()
	var bytes: PackedByteArray = node.serialize()
	_buffer.put_u8(type)
	_buffer.put_64(owner.id)
	_buffer.put_u64(bytes.size() )
	_buffer.put_data(bytes)
	_node_index[node] = i
	return SaveError.OK

## Returns null if no node could be deserialized
func deserialize_node(battle: Battle) -> LoadError:
	assert(battle != null)
	#
	if _buffer.get_available_bytes() == 0:
		return LoadError.NO_MORE_DATA
	var i := _buffer.get_position()
	var type := _buffer.get_u8() as Type
	var player := battle.get_player_from_id(_buffer.get_64() )
	if not type in type_to_class:
		return LoadError.INVALID_TYPE
	if player == null:
		return LoadError.MISSING_PLAYER
	var node: Node3D = type_to_class[type].new()
	var bytes := _buffer.get_partial_data(_buffer.get_u64() )
	player.add_child(node)
	var success: bool = node.deserialize(bytes[1] )
	_node_index[node] = i
	return LoadError.OK if bytes[0] == OK and success else LoadError.INVALID_DATA
