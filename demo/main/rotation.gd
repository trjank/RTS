class_name Rotation

enum Discrete {
	# DO NOT CHANGE THIS ORDER!
	ROT_0          = 0,
	ROT_90         = 1,
	ROT_180        = 2,
	ROT_270        = 3,
	FLIP_H_ROT_0   = 4,
	FLIP_H_ROT_90  = 5,
	FLIP_H_ROT_180 = 6,
	FLIP_H_ROT_270 = 7
}

const NUM_DISCRETE_STATES := 8
const INCREMENT := deg_to_rad(90.0)

static func is_valid(discrete: Discrete) -> bool:
	return Discrete.ROT_0 <= discrete and discrete <= Discrete.FLIP_H_ROT_270

static func to_valid(discrete: Discrete) -> Discrete:
	return posmod(discrete, 8) as Discrete

static func is_flip_h(discrete: Discrete) -> bool:
	return Discrete.FLIP_H_ROT_0 <= discrete

## Returns whether the rotation is an odd multiple of 90 degrees
static func is_even(discrete: Discrete) -> bool:
	return discrete % 2 == 0

## Returns whether the rotation is an even multiple of 90 degrees
static func is_odd(discrete: Discrete) -> bool:
	return discrete % 2 == 1

static func to_quadrant(discrete: Discrete) -> int:
	return discrete % 4

static func to_degrees(discrete: Discrete) -> float:
	return 90.0 * (discrete % 4)

static func to_radians(discrete: Discrete) -> float:
	return deg_to_rad(90.0) * (discrete % 4)

static func from_degrees(degrees: float, flipped := false) -> Discrete:
	# Maps 315º-45º to 0, 45º-135º to 1, 135º-225º to 2, 225º-315º to 3
	var quadrant := posmod(round(degrees / 90.0), 4)
	return (quadrant + 4 if flipped else quadrant) as Discrete

static func from_radians(radians: float, flipped := false) -> Discrete:
	return from_degrees(rad_to_deg(radians), flipped)
