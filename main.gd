extends Control

@onready var mine_animation_player: AnimationPlayer = $AnimationPlayer
@onready var mine_label: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MineSpace/MarginContainer/VBoxContainer/Label
@onready var output_upgrade_button: Button = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/OutputUpgradeButton
@onready var speed_upgrade_button: Button = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/SpeedUpgradeButton
@onready var reset_button: Button = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/HBoxContainer/ResetButton
@onready var maxed_output_label: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/OutputUpgradeButton/MaxedOutputLabel
@onready var passive_output_button: Button = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/PassiveOutputButton
@onready var passive_output_timer: Timer = $PassiveOutputTimer


var iron = 10
var output_cost = 2
var speed_cost = 2
var passive_output_cost = 2
var speed = 1
var output = 1
var output_max = 10
var passive_output_time = 1
var passive_output = 0


func _ready() -> void:
	if output == output_max:
			output_upgrade_button.disabled = true
	update_text()
	
func _on_button_pressed() -> void:
	mine_animation_player.play("mine")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	iron += output
	update_text()


func _on_output_upgrade_button_pressed() -> void:
	if iron >= output_cost:
		iron = iron - output_cost
		output = output + 1
		output_cost += 1
		if output == output_max:
			output_upgrade_button.disabled = true
		update_text()

func _on_speed_upgrade_button_pressed() -> void:
	if iron >= speed_cost:
		iron -= speed_cost
		speed += 1
		mine_animation_player.speed_scale = speed
		update_text()
		

func _on_reset_button_pressed() -> void:
	iron = 0
	output_cost = 2
	speed_cost = 2
	speed = 1
	output = 1
	mine_animation_player.speed_scale = speed
	print(iron, output_cost, output, speed_cost, speed)
	update_text()

func update_text():
	mine_label.text = "Iron:" + str(iron)
	output_upgrade_button.text = "Output \nPrice:"+ str(output_cost)+"\n Output: " + str(output) + "/" + str(output_max)
	speed_upgrade_button.text = "Speed \nPrice:"+ str(speed_cost)+"\n Speed: " + str(speed)
	if output == output_max:
		maxed_output_label.text = "MAXED"
	passive_output_button.text = "Passive Output\nCost: "+ str(passive_output_cost)+"\n Passive output: +" + str(passive_output)+ "/" + str(passive_output_time) + "sec"
	

func _on_passive_output_button_pressed() -> void:
	if iron >= passive_output_cost:
		iron -= passive_output_cost # charge you
		passive_output_cost += 1 # increase the cost
		passive_output += 1
		passive_output_timer.start(passive_output_time)
		update_text() 
	
func _on_passive_output_timer_timeout() -> void:
	iron += passive_output
	update_text()
