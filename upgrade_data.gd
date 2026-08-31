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
		"max_level": 10
	}
}

func buy_upgrade(upgrade_id: StringName) -> void:
	match upgrade_id:
		&"pickaxe":
			upgrades["pickaxe"]["amount"] += 1
			upgrades["pickaxe"]["level"] += 1
			upgrades["pickaxe"]["cost"]["iron"] = ceili(upgrades["pickaxe"]["cost"]["iron"] * 1.15)
			upgrade_bought.emit(upgrade_id)
		&"iron_output":
			upgrades["iron_output"]["amount"] += 1
			upgrades["iron_output"]["level"] += 1
			upgrades["iron_output"]["cost"]["iron"] = ceili(upgrades["iron_output"]["cost"]["iron"] * 1.15)
			upgrade_bought.emit(upgrade_id)
		&"iron_mine_speed":
			upgrades["iron_mine_speed"]["amount"] += 1
			upgrades["iron_mine_speed"]["level"] += 1
			upgrades["iron_mine_speed"]["cost"]["iron"] = ceili(upgrades["iron_mine_speed"]["cost"]["iron"] * 1.20)
			upgrade_bought.emit(upgrade_id)

func get_upgrade_cost(upgrade_id: StringName) -> int:
	match upgrade_id:
		&"pickaxe":
			return upgrades["pickaxe"]["cost"]["iron"]
		&"iron_output":
			return upgrades["iron_output"]["cost"]["iron"]
		&"iron_mine_speed":
			return upgrades["iron_mine_speed"]["cost"]["iron"]
	return -1
	
func reset_upgrades() -> void:
#	reset all upgrade data to  initial here
	pass
