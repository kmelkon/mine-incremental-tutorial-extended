class_name UpgradeData
extends Resource

signal upgrade_bought(upgrade_id: StringName)

var upgrades: Dictionary = {
	"pickaxe": {
		"name": "Pickaxe",
		"cost": { "iron": 250 },
		"amount": 0,
		"description": "It's an axe, what did you expect?",
		"level": 0,
		"max_level": 10
	},
	"iron_output": {
		"name": "Iron Output",
		"description": "Same button, more iron.",
		"cost": { "iron": 2 },
		"amount": 0,
		"level": 0
	},
	"iron_mine_speed": {
		"name": "Iron Mine Speed",
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
	}
}

func buy_upgrade(upgrade_id: StringName) -> void:
#	max level is a real game rule, not just UI.
	if is_upgrade_maxed(upgrade_id):
		return 
	
	match upgrade_id:
		&"pickaxe":
			upgrades["pickaxe"]["amount"] += 1
			upgrades["pickaxe"]["level"] += 1
			upgrades["pickaxe"]["cost"]["iron"] = ceili(upgrades["pickaxe"]["cost"]["iron"] * 1.15)
			upgrade_bought.emit(upgrade_id)
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

func get_upgrade(upgrade_id: StringName) -> Dictionary:
	return upgrades[upgrade_id].duplicate()

func get_upgrade_cost(upgrade_id: StringName) -> Dictionary:
#	return a copy so callers can't modify upgrades data
	return upgrades[upgrade_id]["cost"].duplicate()

func is_upgrade_maxed(upgrade_id: StringName) -> bool:
	var upgrade = upgrades[upgrade_id]
	
	if not upgrade.has("max_level"):
		return false
	
	return upgrade["level"] >= upgrade["max_level"]
	
func get_passive_iron_output() -> int:
	return upgrades["passive_iron_output"]["amount"]

func get_passive_iron_output_time() -> float:
	return upgrades["passive_iron_output"]["time"]

func get_coal_per_click() -> int:
#	TODO: placeholder until coal buttons are migrated
	return -1

func get_mine_time() -> float:
	return upgrades["iron_mine_speed"]["time"]

func get_iron_per_click() -> int:
#	If multiplier upgrades are introduced later, they need to be calculated here
	return 1 + upgrades["iron_output"]["amount"]

func reset_upgrades() -> void:
#	reset all upgrade data to  initial here
	pass
	
#	Migrate coal upgrades, since they will teach you multi-resource costs.
#	Add save/load after the game state has settled.
# 	show coal unlock button when player is nearing the unlock threshold
