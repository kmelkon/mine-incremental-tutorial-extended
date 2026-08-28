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
	}
}

func buy_upgrade(upgrade_id: StringName) -> void:
	match upgrade_id:
		&"pickaxe":
			upgrades["pickaxe"]["amount"] += 1
			upgrades["pickaxe"]["level"] += 1
			upgrades["pickaxe"]["cost"]["iron"] = ceil(upgrades["pickaxe"]["cost"]["iron"] * 1.15)
			upgrade_bought.emit(upgrade_id)
		&"iron_output":
			upgrades["iron_output"]["amount"] += 1
			upgrades["iron_output"]["level"] += 1
			upgrades["iron_output"]["cost"]["iron"] = ceil(upgrades["iron_output"]["cost"]["iron"] * 1.15)
			upgrade_bought.emit(upgrade_id)

func get_upgrade_cost(upgrade_id: StringName) -> int:
	match upgrade_id:
		&"pickaxe":
			return upgrades["pickaxe"]["cost"]["iron"]
		&"iron_output":
			return upgrades["iron_output"]["cost"]["iron"]
	return -1
