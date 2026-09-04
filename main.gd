extends Control

@onready var mine_label: Label = %IronTotalLabel
@onready var reset_button: Button = %ResetButton
@onready var passive_output_timer: Timer = $PassiveOutputTimer
@onready var coal_total_label: Label = %CoalTotalLabel
@onready var mine_coal_button: Button = %MineCoalButton
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var mine_iron_button: Button = %MineButton
@onready var coal_unlock_button_control: UpgradeButtonControl = %CoalUnlockUpgradeButtonControl
@onready var coal_mine_upgrade_button_control: UpgradeButtonControl = %CoalMineUpgradeButtonControl
@onready var coal_progress_bar: ProgressBar = %CoalProgressBar
@onready var coal_mine_speed_upgrade_button_control: UpgradeButtonControl = %CoalMineSpeedUpgradeButtonControl

var game_data: GameData = GameData.new()
var upgrade_data: UpgradeData = UpgradeData.new()
var iron_mine_tween: Tween
var coal_mine_tween: Tween


func _ready() -> void:
	game_data.resources_changed.connect(_on_resources_changed)
	_on_resources_changed()
	
	progress_bar.max_value = 100
	progress_bar.value = 0
	
	coal_progress_bar.max_value = 100
	coal_progress_bar.value = 0
	
	_refresh_coal_unlock_visibility()
	# this will set up every upgrade button we add in the future instead of doing it manually one by one like it's 1990
	for node in get_tree().get_nodes_in_group("upgrade_buttons"):
		var upgrade_button := node as UpgradeButtonControl
		upgrade_button.setup(upgrade_data)

func _process(delta: float) -> void:
	pass
		
		
func _on_button_pressed() -> void:
	mine_iron_button.disabled = true
	progress_bar.value = 0
	var mine_speed_time = upgrade_data.get_mine_time()
	
	iron_mine_tween = create_tween()
	iron_mine_tween.tween_property(
		progress_bar,
		"value",
		progress_bar.max_value,
		mine_speed_time
	)
	iron_mine_tween.finished.connect(_on_mine_iron_tween_complete)
	
func _on_mine_coal_button_pressed() -> void:
	mine_coal_button.disabled = true
	coal_progress_bar.value = 0
	
	var mine_coal_speed_time = upgrade_data.get_mine_coal_time()
	
	coal_mine_tween = create_tween()
	coal_mine_tween.tween_property(
		coal_progress_bar,
		"value",
		coal_progress_bar.max_value,
		mine_coal_speed_time
	)
	coal_mine_tween.finished.connect(_on_mine_coal_tween_complete)

func _on_reset_button_pressed() -> void:
	game_data.reset()
	upgrade_data.reset_upgrades()

	passive_output_timer.stop()

	progress_bar.value = 0
	coal_progress_bar.value = 0

	mine_iron_button.disabled = false
	mine_coal_button.disabled = false

	coal_progress_bar.visible = false
	mine_coal_button.visible = false
	coal_mine_upgrade_button_control.visible = false
	coal_mine_speed_upgrade_button_control.visible = false
	
	if iron_mine_tween and iron_mine_tween.is_valid():
		iron_mine_tween.kill()

	if coal_mine_tween and coal_mine_tween.is_valid():
		coal_mine_tween.kill()


func _on_passive_output_timer_timeout() -> void:
	var passive_iron_amount = upgrade_data.get_passive_iron_amount()
	game_data.add_resource("iron", passive_iron_amount)
	
	_refresh_coal_unlock_visibility()

func _on_resources_changed() -> void:
	mine_label.text = "Iron: %s" % game_data.resources["iron"]
	coal_total_label.text = "Coal: %s" % game_data.resources["coal"]

	_refresh_coal_unlock_visibility()

func _on_upgrade_button_control_upgrade_requested(upgrade_id: StringName) -> void:
	var cost = upgrade_data.get_upgrade_cost(upgrade_id)
	print(upgrade_id)
	
	if game_data.can_afford(cost) and not upgrade_data.is_upgrade_maxed(upgrade_id):
		game_data.spend_resources(cost)
		upgrade_data.buy_upgrade(upgrade_id)
		
		if upgrade_id == &"passive_iron_output":
			passive_output_timer.start(upgrade_data.get_passive_iron_output_time())
		
		if upgrade_id == &"coal_unlock":
			coal_progress_bar.visible = true
			coal_mine_upgrade_button_control.visible = true
			mine_coal_button.visible = true
			coal_mine_speed_upgrade_button_control.visible = true
			

func _on_mine_iron_tween_complete() -> void:
	var iron_output_per_click = upgrade_data.get_iron_per_click()
	mine_iron_button.disabled = false
	game_data.add_resource("iron", iron_output_per_click)
	
	_refresh_coal_unlock_visibility()

func _on_mine_coal_tween_complete() -> void:
	var coal_output_per_click = upgrade_data.get_coal_per_click()
	mine_coal_button.disabled = false
	game_data.add_resource("coal", coal_output_per_click)
	
func _refresh_coal_unlock_visibility() -> void:
	coal_unlock_button_control.visible = game_data.resources["iron"] >= 700

# TODO: tween the buttons into existence instead of popping them into existence
# TODO: display the passive output /second somewhere for both coal and iron


func _on_auto_save_timer_timeout() -> void:
	var save_dict  = {
		"version": 1,
		"game": {},
		"upgrades": {}
	}
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	
	save_dict["game"] = game_data.to_dict()
	save_dict["upgrades"] = upgrade_data.to_dict()
	
	var json_text = JSON.stringify(save_dict)
	
	save_file.store_string(json_text)
	
