class_name UpgradeButtonControl
extends Control

signal upgrade_requested(upgrade_id: StringName)

@onready var button: Button = $Button
@export var upgrade_id: StringName
var upgrade_data: UpgradeData

func setup(data: UpgradeData) -> void:
	upgrade_data = data
	# button listens to when an upgrade is bought
	upgrade_data.upgrade_bought.connect(_on_upgrade_bought)
	refresh()

func refresh() -> void:
	var cost_parts: Array[String] = []
	
	var is_maxed = upgrade_data.is_upgrade_maxed(upgrade_id)
	var upgrade = upgrade_data.get_upgrade(upgrade_id)
	
	var upgrade_cost = upgrade_data.get_upgrade_cost(upgrade_id)
	for resource in upgrade_cost:
		cost_parts.append("%s %s" % [upgrade_cost[resource], resource])
		
	var cost_label = " + ".join(cost_parts)
	
	button.text = "%s\nPrice: %s \nLevel: %s" % [
		upgrade["name"],
		cost_label,
		upgrade["level"],
	]
	
	button.disabled = is_maxed

func _on_upgrade_bought(bought_id: StringName) -> void:
	# when an upgrade is bought and it matches this instance's upgrade_id then refresh the text
	if bought_id == upgrade_id:
		refresh()
		
func _on_button_pressed() -> void:
	upgrade_requested.emit(upgrade_id)
