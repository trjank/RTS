class_name StandardMode extends Gamemode

const CAPITAL_SHIP_SLOT := 0

var _normal_ship_cost_limit := StrategicResources.from_dict({
	"alloy": 1000.0
})
var _capital_ship_cost_limit := StrategicResources.from_dict({
	"alloy": 2000.0
})

func _init() -> void:
	name = "Standard"
	teams = [Team.APHELIONS, Team.FEDERATION, Team.SYZYGYSTS, Team.OCCULTARCHS]

func is_normal_ship_compatible(ship: ShipData) -> bool:
	return ship != null and ship.cost.can_afford(_normal_ship_cost_limit)

func is_capital_ship_compatible(ship: ShipData) -> bool:
	return ship != null and not ship.is_empty() and ship.cost.can_afford(_capital_ship_cost_limit)

func is_ship_compatible(ship: ShipData, slot: int) -> bool:
	return is_capital_ship_compatible(ship) if slot == CAPITAL_SHIP_SLOT else is_normal_ship_compatible(ship)

func _field_capital_ship(player: Player) -> void:
	player.get_battle_data()["capital_ship"] = player.spawn_ship_slot(CAPITAL_SHIP_SLOT)
	#capital_ship.died.connect(player.alive)

func on_battle_start(battle: Battle) -> void:
	battle.for_each_player(_field_capital_ship)
