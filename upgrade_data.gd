class_name UpgradeData
extends Resource

signal upgrade_bought(upgrade_id: StringName)

var upgrades: Dictionary = {
	"iron_output": {
		"name": "Iron Output",
		"description": "Same button, more iron.",
		"cost": { "iron": 2 },
		"amount": 0,
		"level": 0
	},
	"iron_mine_speed": {
		"name": "Iron Mining Speed",
		"description": "Mine iron. Faster.",
		"cost": { "iron": 2 },
		"amount": 0,
		"level": 0,
		"time": 5.0,
		"max_level": 10
	},
	"passive_iron_output": {
		"name": "Passive Iron Mining",
		"description": "This pickaxe is alive!",
		"cost": { "iron": 50 },
		"amount": 0,
		"level": 0,
		"time": 1.0
	},
	"coal_unlock": {
		"name": "Unlock Coal Mining",
		"description": "Is that coal??!!?!1",
		"cost": { "iron": 1000 },
		"amount": 0,
		"level": 0,
		"max_level": 1
	},
	"coal_mine_output": {
		"name": "Coal output",
		"description": "I think I found more coal here!",
		"cost": { "iron": 1100, "coal": 100 },
		"amount": 0,
		"level": 0,
		"time": 1.0
	},
	"coal_mine_speed": {
		"name": "Coal Mining Speed",
		"description": "Mine coal. Faster!",
		"cost": { "iron": 1500, "coal": 200 },
		"amount": 0,
		"level": 0,
		"time": 8.0,
		"max_level": 10
	}
}

func buy_upgrade(upgrade_id: StringName) -> void:
#	max level is a real game rule, not just UI.
	if is_upgrade_maxed(upgrade_id):
		return 
	
	match upgrade_id:
		&"iron_output":
			var iron_output = upgrades["iron_output"]
			iron_output["amount"] += 1
			iron_output["level"] += 1
			iron_output["cost"]["iron"] = ceili(iron_output["cost"]["iron"] * 1.15)
			upgrade_bought.emit(upgrade_id)
		&"iron_mine_speed":
			var iron_mine_speed = upgrades["iron_mine_speed"]
			iron_mine_speed["amount"] += 1
			iron_mine_speed["level"] += 1
			iron_mine_speed["cost"]["iron"] = ceili(iron_mine_speed["cost"]["iron"] * 1.20)
			iron_mine_speed["time"] = maxf(0.3, iron_mine_speed["time"] - 0.5)
			upgrade_bought.emit(upgrade_id)
		&"passive_iron_output":
			upgrades["passive_iron_output"]["amount"] += 1
			upgrades["passive_iron_output"]["level"] += 1
			upgrades["passive_iron_output"]["cost"]["iron"] = ceili(upgrades["passive_iron_output"]["cost"]["iron"] * 1.20)
			upgrade_bought.emit(upgrade_id)
		&"coal_unlock":
			var coal_unlock = upgrades["coal_unlock"]
			coal_unlock["amount"] += 1
			coal_unlock["level"] += 1
			upgrade_bought.emit(upgrade_id)
		&"coal_mine_output":
			var coal_output = upgrades["coal_mine_output"]
			coal_output["amount"] += 1
			coal_output["level"] += 1
			coal_output["cost"] = increase_cost("coal_mine_output", 1.15)
			upgrade_bought.emit(upgrade_id)
		&"coal_mine_speed":
			var coal_mine_speed = upgrades["coal_mine_speed"]
			coal_mine_speed["amount"] += 1
			coal_mine_speed["level"] += 1
			coal_mine_speed["cost"] = increase_cost("coal_mine_speed", 1.20)
			coal_mine_speed["time"] = maxf(0.3, coal_mine_speed["time"] - 0.5)
			upgrade_bought.emit(upgrade_id)

func increase_cost(upgrade_id: StringName, multiplier: float) -> Dictionary:
	var upgrade_cost = get_upgrade_cost(upgrade_id)
	var new_cost = {}
	
	for key in upgrade_cost:
		new_cost[key] = ceili(upgrade_cost[key] * multiplier)
	
	return new_cost

func get_upgrade(upgrade_id: StringName) -> Dictionary:
	return upgrades[upgrade_id].duplicate(true)

func get_upgrade_cost(upgrade_id: StringName) -> Dictionary:
#	return a copy so callers can't modify upgrades data
	return upgrades[upgrade_id]["cost"].duplicate()

func is_upgrade_maxed(upgrade_id: StringName) -> bool:
	var upgrade = upgrades[upgrade_id]
	
	if not upgrade.has("max_level"):
		return false
	
	return upgrade["level"] >= upgrade["max_level"]
	
func get_passive_iron_amount() -> int:
	return upgrades["passive_iron_output"]["amount"]

func get_passive_iron_output_time() -> float:
	return upgrades["passive_iron_output"]["time"]

func get_coal_per_click() -> int:
	return 1 + upgrades["coal_mine_output"]["amount"]

func get_mine_time() -> float:
	return upgrades["iron_mine_speed"]["time"]
	
func get_mine_coal_time() -> float:
	return upgrades["coal_mine_speed"]["time"]

func get_iron_per_click() -> int:
#	If multiplier upgrades are introduced later, they need to be calculated here
	return 1 + upgrades["iron_output"]["amount"]

func reset_upgrades() -> void:
#	reset all upgrade data to  initial here
	pass
	
