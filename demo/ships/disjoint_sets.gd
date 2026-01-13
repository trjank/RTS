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
	_num_sets = _parents.size()
	_sizes.fill(1)
	for s in _num_sets:
		_parents[s] = s

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

# NOTE: Undo or removal is not supported
func union_sets(a: int, b: int) -> void:
	a = find_root_set(a)
	b = find_root_set(b)
	if a == b:
		return
	var combined_size := _sizes[a] + _sizes[b]
	_num_sets -= 1
	if _sizes[b] > _sizes[a]:
		_parents[a] = b
		_sizes[b] = combined_size
	else:
		_parents[b] = a
		_sizes[a] = combined_size
