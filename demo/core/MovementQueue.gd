class_name MovementQueue extends RefCounted

static var MAX_SIZE := 10

var __queue : Array[Node2D] = []

func is_empty() -> bool:
	return __queue.is_empty()

func peek() -> Node2D:
	return __queue[0]

func size() -> int:
	return __queue.size()

func pop() -> Node2D:
	return __queue.pop_front()

func push(move_cmd: Node2D) -> bool:
	if __queue.size() == MAX_SIZE: return false
	__queue.push_back(move_cmd)
	return true
