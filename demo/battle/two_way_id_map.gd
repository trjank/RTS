## Why does this exist?
##
## Important data like ships, fleets, and unit logic are not designed to be copied.
## Rather, the data is reused and shared across nodes, which is memory efficient.
## However, sometimes copies do need to be made when different versions of a design exist.
## This allows you to find the original from the copied version, and vice versa.
class_name TwoWayIDMap

const CSV_HEADER: PackedStringArray = ["from_id", "to_id"]

var _forward: Dictionary[int, int] = {}
var _backward: Dictionary[int, int] = {}

func has_id(id: int) -> bool:
	return id in _forward or id in _backward

func has_old_id(old_id: int) -> bool:
	return old_id in _forward

func has_new_id(new_id: int) -> bool:
	return new_id in _backward

func other_id(id: int) -> int:
	return _forward[id] if id in _forward else _backward[id]

func find_new_id(old_id: int) -> int:
	return _forward[old_id]

func find_old_id(new_id: int) -> int:
	return _backward[new_id]

func link(from_id: int, to_id: int) -> void:
	_forward[from_id] = to_id
	_backward[to_id] = from_id

func _to_csv_line(from_id: int, to_id: int) -> PackedStringArray:
	return [String.num_int64(from_id), String.num_int64(to_id) ]

func _read_csv_line(line: PackedStringArray) -> void:
	if line.size() != 2:
		return
	var from_id := int(line[0] )
	var to_id := int(line[1] )
	link(from_id, to_id)

func load_csv(path: String, delimeter := ",") -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null or delimeter.join(file.get_csv_line(delimeter) ) != delimeter.join(CSV_HEADER):
		return false
	while not file.eof_reached():
		_read_csv_line(file.get_csv_line(delimeter) )
	return true

func save_csv(path: String, delimeter := ",") -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_csv_line(CSV_HEADER, delimeter)
	#
	for id in _forward:
		file.store_csv_line(_to_csv_line(id, _forward[id] ), delimeter)
	return true
