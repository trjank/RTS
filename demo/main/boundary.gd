class_name Boundary

# NOTE: There are 256 possible combinations of the bit flags below
const NONE                := 0
const RIGHT_EDGE          := 1 << 0
const TOP_RIGHT_CORNER    := 1 << 1
const TOP_EDGE            := 1 << 2
const TOP_LEFT_CORNER     := 1 << 3
const LEFT_EDGE           := 1 << 4
const BOTTOM_LEFT_CORNER  := 1 << 5
const BOTTOM_EDGE         := 1 << 6
const BOTTOM_RIGHT_CORNER := 1 << 7

const ALL_EDGES := RIGHT_EDGE | TOP_EDGE | LEFT_EDGE | BOTTOM_EDGE
const ALL_CORNERS := TOP_RIGHT_CORNER | TOP_LEFT_CORNER | BOTTOM_LEFT_CORNER | BOTTOM_RIGHT_CORNER
const FULL := ALL_EDGES | ALL_CORNERS

const _FLIP_H_TABLE: PackedInt32Array = [0,16,8,24,4,20,12,28,2,18,10,26,6,22,14,30,1,17,9,25,5,21,13,29,3,19,11,27,7,23,15,31,128,144,136,152,132,148,140,156,130,146,138,154,134,150,142,158,129,145,137,153,133,149,141,157,131,147,139,155,135,151,143,159,64,80,72,88,68,84,76,92,66,82,74,90,70,86,78,94,65,81,73,89,69,85,77,93,67,83,75,91,71,87,79,95,192,208,200,216,196,212,204,220,194,210,202,218,198,214,206,222,193,209,201,217,197,213,205,221,195,211,203,219,199,215,207,223,32,48,40,56,36,52,44,60,34,50,42,58,38,54,46,62,33,49,41,57,37,53,45,61,35,51,43,59,39,55,47,63,160,176,168,184,164,180,172,188,162,178,170,186,166,182,174,190,161,177,169,185,165,181,173,189,163,179,171,187,167,183,175,191,96,112,104,120,100,116,108,124,98,114,106,122,102,118,110,126,97,113,105,121,101,117,109,125,99,115,107,123,103,119,111,127,224,240,232,248,228,244,236,252,226,242,234,250,230,246,238,254,225,241,233,249,229,245,237,253,227,243,235,251,231,247,239,255]

static func is_valid(boundary: int) -> bool:
	return boundary & FULL == boundary

static func to_valid(boundary: int) -> bool:
	return boundary & FULL

static func rotate(boundary: int, turns: int) -> int:
	turns = 2 * posmod(turns, 4)
	var l_shift := boundary << turns
	var r_shift := boundary >> (8 - turns)
	return (l_shift | r_shift) & FULL

static func flip_h(boundary: int) -> int:
	return _FLIP_H_TABLE[boundary]

static func transform(boundary: int, discrete: Rotation.Discrete) -> int:
	boundary = flip_h(boundary) if Rotation.is_flip_h(boundary) else boundary
	return rotate(boundary, Rotation.to_quadrant(discrete) )

static func inverse_transform(boundary: int, discrete: Rotation.Discrete) -> int:
	boundary = rotate(boundary, -Rotation.to_quadrant(discrete) )
	return flip_h(boundary) if Rotation.is_flip_h(discrete) else boundary
