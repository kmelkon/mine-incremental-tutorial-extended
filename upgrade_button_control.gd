class_name UpgradeButtonControl
extends Control

signal upgrade_requested(upgrade_id: StringName)

@onready var button: Button = $Button
@export var upgrade_id: StringName
var upgrade_data: UpgradeData
var game_data: GameData


@export var click_scale : Vector2 = Vector2(0.9, 0.9) 
@export var normal_scale : Vector2 = Vector2(1.0, 1.0) 
@export var duration : float = 0.1 

func setup(data: UpgradeData, shared_game_data: GameData) -> void:
	upgrade_data = data
	game_data = shared_game_data
	upgrade_data.upgrades_reset.connect(refresh)
	upgrade_data.upgrade_bought.connect(_on_upgrade_bought)
	game_data.resources_changed.connect(refresh)
	refresh()

func refresh() -> void:
	var cost_parts: Array[String] = []
	self.pivot_offset = self.size / 2
	var is_maxed = upgrade_data.is_upgrade_maxed(upgrade_id)
	var upgrade = upgrade_data.get_upgrade(upgrade_id)
	var is_affordable = game_data.can_afford(upgrade_data.get_upgrade_cost(upgrade_id))
	
	var upgrade_cost = upgrade_data.get_upgrade_cost(upgrade_id)
	for resource in upgrade_cost:
		cost_parts.append("%s %s" % [upgrade_cost[resource], resource])
		
	var cost_label = " + ".join(cost_parts)
	
	if is_maxed:
		button.disabled = true
		button.text = "%s\nLevel: %s" % [
		upgrade["name"],
		"MAXED",
		]
		button.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1.0))
		button.modulate = Color(1.0, 0.82, 0.2, 1.0)
	elif is_affordable:
		button.disabled = false
		button.text = "%s\nPrice: %s \nLevel: %s" % [
		upgrade["name"],
		cost_label,
		upgrade["level"],
		]
		button.add_theme_color_override("font_color", Color(0.0, 0.764, 0.0, 1.0))
		button.modulate = Color(1, 1, 1, 1)
	else:
		button.disabled = true
		button.text = "%s\nPrice: %s \nLevel: %s" % [
		upgrade["name"],
		cost_label,
		upgrade["level"],
		]
		button.modulate = Color(1.0, 0.55, 0.55, 1.0)
		button.add_theme_color_override("font_color", Color(1, 0, 0))

func _on_upgrade_bought(bought_id: StringName) -> void:
	# when an upgrade is bought and it matches this instance's upgrade_id then refresh the text
	if bought_id == upgrade_id:
		refresh()
		
func _on_button_pressed() -> void:

	upgrade_requested.emit(upgrade_id)


func _on_button_button_down() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", click_scale, duration).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT)


func _on_button_button_up() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", normal_scale, duration).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT)
