class_name TrailData extends RefCounted

const SYNTAX: Dictionary[String, Variant.Type] = {
	"flicker_strength": TYPE_FLOAT,
	"roundness": TYPE_FLOAT,
	"glow": TYPE_FLOAT,
	"inner_color": TYPE_COLOR,
	"outer_color": TYPE_COLOR
}
const MIN_ROUNDNESS := 0.0
const MIN_GLOW := 0.0

static var DEFAULT := TrailData.new():
	set(__): push_error("(TrailData) TrailData.DEFAULT is immutable!")

var flicker_strength := 0.0:
	set = set_flicker_strength
var roundness := 1.0:
	set = set_roundness
var glow := 2.0:
	set = set_glow
var inner_color := Color.ORANGE
var outer_color := Color.RED

static func from_dict(dict: Dictionary, always_copy := false) -> TrailData:
	var data := TrailData.new()
	return data if data.load_dict(dict) or always_copy else DEFAULT

func to_dict() -> Dictionary:
	return TypeChecker.to_dict(self, SYNTAX)

func load_dict(dict: Dictionary) -> bool:
	return TypeChecker.load_dict(self, dict, SYNTAX, TypeChecker.CAST_NUMBERS_AND_COLORS)

func set_flicker_strength(new_flicker_strength: float) -> void:
	flicker_strength = absf(new_flicker_strength)

func set_roundness(new_roundness: float) -> void:
	roundness = maxf(new_roundness, MIN_ROUNDNESS)

func set_glow(new_glow: float) -> void:
	glow = maxf(new_glow, MIN_GLOW)
