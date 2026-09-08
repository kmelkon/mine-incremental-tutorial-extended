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
@onready var offline_progress_dialog: AcceptDialog = %OfflineProgressDialog
@onready var offline_progress_label: Label = %OfflineProgressLabel
@onready var floating_effects_overlay: Control = %FloatingEffectsOverlay
@onready var audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D
@onready var upgrade_button_stream_player: AudioStreamPlayer2D = %UpgradeButtonStreamPlayer

var game_data: GameData = GameData.new()
var upgrade_data: UpgradeData = UpgradeData.new()
var utils: Utils = Utils.new()
var iron_mine_tween: Tween
var coal_mine_tween: Tween


func _ready() -> void:
	load_game()
 	# Disable automatic closing so we can save first
	get_tree().auto_accept_quit = false
	
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
		upgrade_button.setup(upgrade_data, game_data)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Call your save function here
		save_game()

		# Now allow the game to quit
		get_tree().quit()

func _on_button_pressed() -> void:
	mine_iron_button.disabled = true
	audio_stream_player_2d.play()
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
	audio_stream_player_2d.play()
	
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
	mine_label.text = "Iron: %s" % utils.format_number(game_data.resources["iron"])
	coal_total_label.text = "Coal: %s" % utils.format_number(game_data.resources["coal"])

	_refresh_coal_unlock_visibility()

func _on_upgrade_button_control_upgrade_requested(upgrade_id: StringName) -> void:
	upgrade_button_stream_player.play()
	var cost = upgrade_data.get_upgrade_cost(upgrade_id)
	print(upgrade_id)
	
	if game_data.can_afford(cost) and not upgrade_data.is_upgrade_maxed(upgrade_id):
		game_data.spend_resources(cost)
		upgrade_data.buy_upgrade(upgrade_id)
		
		if upgrade_id == &"passive_iron_output":
			passive_output_timer.start(upgrade_data.get_passive_iron_output_time())
		
		if upgrade_id == &"coal_unlock":
			coal_total_label.visible = true
			coal_progress_bar.visible = true
			coal_mine_upgrade_button_control.visible = true
			mine_coal_button.visible = true
			coal_mine_speed_upgrade_button_control.visible = true
			

func _on_mine_iron_tween_complete() -> void:
	var iron_output_per_click = upgrade_data.get_iron_per_click()
	mine_iron_button.disabled = false
	game_data.add_resource("iron", iron_output_per_click)
	
	var floating_iron_amount_tween = get_tree().create_tween()
	var initial_pb_position = progress_bar.get_global_position() + Vector2(progress_bar.size.x, progress_bar.size.y / 2)

	var floating_label = Label.new()
	floating_label.add_theme_font_size_override("font_size", 24)
	floating_label.add_theme_color_override("font_color", Color(1, 0.6, 1))
	floating_label.text = "+%s" % utils.format_number(iron_output_per_click)
	floating_effects_overlay.add_child(floating_label)
	floating_label.global_position = initial_pb_position
	floating_label.scale = Vector2.ZERO
	floating_label.pivot_offset = floating_label.size / 2

	floating_iron_amount_tween.tween_property(floating_label, "position", initial_pb_position + Vector2(0, -50), 0.3)
	floating_iron_amount_tween.parallel().tween_property(floating_label, "scale", Vector2(1.5, 1.5), 0.2)
	floating_iron_amount_tween.tween_property(floating_label, "scale", Vector2.ZERO, 0.2)
	floating_iron_amount_tween.parallel().tween_property(floating_label, "modulate:a", 0.0, 0.3)

	floating_iron_amount_tween.connect("finished", Callable(floating_label, "queue_free"))
	
	_refresh_coal_unlock_visibility()

func _on_mine_coal_tween_complete() -> void:
	var coal_output_per_click = upgrade_data.get_coal_per_click()
	mine_coal_button.disabled = false
	game_data.add_resource("coal", coal_output_per_click)

	var floating_coal_amount_tween = get_tree().create_tween()
	var initial_pb_position = coal_progress_bar.get_global_position() + Vector2(coal_progress_bar.size.x, coal_progress_bar.size.y / 2)

	var floating_label = Label.new()
	floating_label.add_theme_font_size_override("font_size", 24)
	floating_label.add_theme_color_override("font_color", Color(0.068, 0.673, 0.765, 1.0))
	floating_label.text = "+%s" % utils.format_number(coal_output_per_click)
	floating_effects_overlay.add_child(floating_label)
	floating_label.global_position = initial_pb_position
	floating_label.scale = Vector2.ZERO
	floating_label.pivot_offset = floating_label.size / 2

	floating_coal_amount_tween.tween_property(floating_label, "position", initial_pb_position + Vector2(0, -50), 0.3)
	floating_coal_amount_tween.parallel().tween_property(floating_label, "scale", Vector2(1.5, 1.5), 0.2)
	floating_coal_amount_tween.tween_property(floating_label, "scale", Vector2.ZERO, 0.2)
	floating_coal_amount_tween.parallel().tween_property(floating_label, "modulate:a", 0.0, 0.3)

	floating_coal_amount_tween.connect("finished", Callable(floating_label, "queue_free"))
	
func _refresh_coal_unlock_visibility() -> void:
	coal_unlock_button_control.visible = game_data.resources["iron"] >= 700

# TODO: tween the buttons into existence instead of popping them into existence
# TODO: display the passive output /second somewhere for both coal and iron


func _on_auto_save_timer_timeout() -> void:
	save_game()
	
func save_game() -> void:
	var save_dict  = {
		"version": 1,
		"game": {},
		"upgrades": {}
	}
	save_dict["game"] = game_data.to_dict()
	save_dict["upgrades"] = upgrade_data.to_dict()

	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	if save_file == null:
		push_error("Error opening save file: %s" % FileAccess.get_open_error())
		return
	
	var json_text = JSON.stringify(save_dict)
	
	save_file.store_string(json_text)

func load_game() -> void:
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.
		
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	if save_file == null:
		push_error("Error opening save file: %s" % FileAccess.get_open_error())
		return

	var json_string = save_file.get_as_text()
	var json = JSON.new()
	# Check if there is any error while parsing the JSON string, skip in case of failure.
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", save_file, " at line ", json.get_error_line())
		return
		
	var save_data = json.data
	
	if save_data is Dictionary:
		if "game" in save_data:
			game_data.from_dict(save_data["game"])
		if "upgrades" in save_data:
			upgrade_data.from_dict(save_data["upgrades"])
	
	if game_data.elapsed_time > 0:
		var passive_iron_amount = upgrade_data.get_passive_iron_amount()
		if passive_iron_amount > 0:
			var total_passive_iron = int(passive_iron_amount * (game_data.elapsed_time / upgrade_data.get_passive_iron_output_time()))
			game_data.add_resource("iron", total_passive_iron)
			# TODO: format the elapsed time nicely into: under 60 seconds: 45s / under 60 minutes: 12m / under 24 hours: 3h 18m
			var elapsed_seconds := int(game_data.elapsed_time)
			var hours := elapsed_seconds / 3600
			var minutes := (elapsed_seconds % 3600) / 60
			var seconds := elapsed_seconds % 60

			offline_progress_label.text = "You were away for %02d:%02d:%02d and gained %s iron!" % [hours, minutes, seconds, utils.format_number(total_passive_iron)]
			offline_progress_dialog.popup_centered()

	refresh_loaded_upgrade_state()
	save_game()


func refresh_loaded_upgrade_state() -> void: 
	if upgrade_data.get_upgrade("coal_unlock")["level"] >= 1:
		coal_total_label.visible = true
		coal_mine_upgrade_button_control.visible = true
		coal_progress_bar.visible = true
		mine_coal_button.visible = true
		coal_mine_speed_upgrade_button_control.visible = true
	
	if upgrade_data.get_passive_iron_amount() >= 1:
		passive_output_timer.start(upgrade_data.get_passive_iron_output_time())
