extends Control

@onready var mine_animation_player: AnimationPlayer = %MineAnimationPlayer
@onready var mine_label: Label = %IronTotalLabel
@onready var output_upgrade_button: Button = %OutputUpgradeButton
@onready var speed_upgrade_button: Button = %SpeedUpgradeButton
@onready var reset_button: Button = %ResetButton
@onready var maxed_output_label: Label = %MaxedOutputLabel
@onready var passive_output_button: Button = %PassiveOutputButton
@onready var passive_output_timer: Timer = $PassiveOutputTimer
@onready var coal_total_label: Label = %CoalTotalLabel
@onready var coal_miner_unlock_button: Button = %CoalMinerUnlockButton
@onready var coal_miner_upgrade_button: Button = %CoalMinerUpgradeButton
@onready var mine_coal_button: Button = %MineCoalButton

var resources = {
	"iron": 1000,
	"coal": 1000
}
var output_cost = 2
var speed_cost = 2
var passive_output_cost = 2
var speed = 1
var output = 1
var coal_output = 1
var output_max = 10
var passive_output_time = 1
var passive_output = 0
var coal_miner_unlock_cost = 100
var coal_miner_upgrade_cost = {
	"iron": 100,
	"coal": 50
}


func _ready() -> void:
	if output == output_max:
			output_upgrade_button.disabled = true
	update_text()
	
func _on_button_pressed() -> void:
	mine_animation_player.play("mine")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	resources["iron"] += output
	update_text()


func _on_output_upgrade_button_pressed() -> void:
	if resources["iron"] >= output_cost:
		resources["iron"] -= output_cost
		output = output + 1
		output_cost += 1
		if output == output_max:
			output_upgrade_button.disabled = true
		update_text()

func _on_speed_upgrade_button_pressed() -> void:
	if resources["iron"] >= speed_cost:
		resources["iron"] -= speed_cost
		speed += 1
		mine_animation_player.speed_scale = speed
		update_text()
		

func _on_reset_button_pressed() -> void:
	resources["iron"] = 0
	output_cost = 2
	speed_cost = 2
	speed = 1
	output = 1
	output_max = 10
	passive_output_time = 1
	passive_output = 0
	mine_animation_player.speed_scale = speed
	update_text()

func update_text():
	mine_label.text = "Iron:" + str(resources["iron"])
	if resources["coal"] > 0:
		coal_total_label.text = "Coal:" + str(resources["coal"])
	coal_miner_unlock_button.text = "Coal Miner Unlock \nPrice: "+ str(coal_miner_unlock_cost)
	coal_miner_upgrade_button.text = "Coal Miner Upgrade \nPrice: "+ str(coal_miner_upgrade_cost["iron"]) + " iron + " + str(coal_miner_upgrade_cost["coal"]) + " coal" 
	output_upgrade_button.text = "Output \nPrice:"+ str(output_cost)+"\n Output: " + str(output) + "/" + str(output_max)
	speed_upgrade_button.text = "Speed \nPrice:"+ str(speed_cost)+"\n Speed: " + str(speed)
	if output == output_max:
		maxed_output_label.text = "MAXED"
	passive_output_button.text = "Passive Output\nCost: "+ str(passive_output_cost)+"\n Passive output: +" + str(passive_output)+ "/" + str(passive_output_time) + "sec"
	

func _on_passive_output_button_pressed() -> void:
	if resources["iron"] >= passive_output_cost:
		resources["iron"] -= passive_output_cost # charge you
		passive_output_cost += 1 # increase the cost
		passive_output += 1
		passive_output_timer.start(passive_output_time)
		update_text() 
	
func _on_passive_output_timer_timeout() -> void:
	resources["iron"] += passive_output
	update_text()


func _on_coal_miner_unlock_button_pressed() -> void:
	if resources["iron"] >= coal_miner_unlock_cost:
		resources["iron"] -= coal_miner_unlock_cost # charge you
		passive_output_cost += 1
		coal_output += 1
		mine_coal_button.visible = true
		update_text()

func _on_coal_miner_upgrade_button_pressed() -> void:
	if resources["iron"] >= coal_miner_upgrade_cost["iron"] and resources["coal"] >= coal_miner_upgrade_cost["coal"]:
		resources["iron"] -= coal_miner_upgrade_cost["iron"] # charge you
		resources["coal"] -= coal_miner_upgrade_cost["coal"] # charge you
		coal_miner_upgrade_cost["iron"] += 50
		coal_miner_upgrade_cost["coal"] += 50
		coal_output += 10
		update_text()


func _on_mine_coal_button_pressed() -> void:
	resources["coal"] += coal_output
	update_text()
