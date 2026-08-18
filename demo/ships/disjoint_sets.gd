class_name DisjointSets extends RefCounted

# See https://en.wikipedia.org/wiki/Disjoint-set_data_structure

var _num_sets := 0
var _parents := PackedInt32Array()
var _sizes := PackedInt32Array()

func count_items() -> int:
	return _parents.size()

func count_sets() -> int:
	return _num_sets

func get_size_of_set(s: int) -> int:
	return _sizes[find_root_set(s) ]

func find_root_set(s: int) -> int:
	var parent := _parents[s]
	return s if parent == s else find_root_set(parent)

func are_in_same_set(a: int, b: int) -> bool:
	return find_root_set(a) == find_root_set(b)

func reset() -> void:
	for s in _parents.size():
		_parents[s] = s
	_num_sets = _parents.size()
	_sizes.fill(1)

func resize(new_num_sets: int) -> void:
	_num_sets = new_num_sets
	_parents.resize(new_num_sets)
	_sizes.resize(new_num_sets)
	reset()

func create_set() -> int:
	var s := _parents.size()
	_num_sets += 1
	_parents.push_back(s)
	_sizes.push_back(1)
	return s

func _root_union(a: int, b: int) -> void:
	_parents[a] = b
	_sizes[b] = _sizes[a] + _sizes[b]
	_num_sets -= 1

# NOTE: Undo or removal is not supported
func union_sets(a: int, b: int) -> void:
	var a_root := find_root_set(a)
	var b_root := find_root_set(b)
	if a_root == b_root:
		return
	if _sizes[b_root] > _sizes[a_root]:
		_root_union(a_root, b_root)
	else:
		_root_union(b_root, a_root)
	assert(0 <= _num_sets)
