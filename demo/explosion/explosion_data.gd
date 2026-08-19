class_name ExplosionData extends RefCounted

const MIN_VOLATILITY := 0.0
const MAX_VOLATILITY := 1.0

const PROPERTIES: Dictionary[String, Variant.Type] = {
	"fade_delay": TYPE_FLOAT,
	"volatility": TYPE_FLOAT,
	"speed": TYPE_FLOAT,
	"glow": TYPE_FLOAT,
	"color": TYPE_COLOR
}

static var DEFAULT := ExplosionData.new():
	set(__): push_error("(ExplosionData) ExplosionData.DEFAULT is immutable!")

var fade_delay := 1.0
var volatility := 1.0:
	set = set_volatility
var speed := 1.0
var glow := 1.0
var color := Color.ORANGE

static func from_dict(dict: Dictionary, always_copy := false) -> ExplosionData:
	var data := ExplosionData.new()
	return data if data.load_dict(dict) or always_copy else DEFAULT

func to_dict() -> Dictionary:
	return TypeChecker.to_dict(self, PROPERTIES)

func load_dict(dict: Dictionary) -> bool:
	return TypeChecker.load_dict(self, dict, PROPERTIES, TypeChecker.CAST_NUMBERS_AND_COLORS)

func set_volatility(new_volatility: float) -> void:
	volatility = clampf(new_volatility, MIN_VOLATILITY, MAX_VOLATILITY)
