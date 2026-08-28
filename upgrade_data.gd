class_name UpgradeData
extends Resource

signal upgrade_bought()


var upgrades: Dictionary = {
	"pickaxe": {
		"cost": { "iron": 250 },
		"amount": 0,
		"description": "It's an axe, what did you expect?",
		"level": 0,
		"max_level": 10
	},
}

func buy_upgrade(upgrade_id: StringName) -> void:
	upgrades["pickaxe"]["amount"] += 1
	upgrades["pickaxe"]["level"] += 1
	upgrades["pickaxe"]["cost"]["iron"] *= 1.15
	upgrade_bought.emit()
