extends Control

@onready var mine_animation_player: AnimationPlayer = %MineAnimationPlayer
@onready var mine_label: Label = %IronTotalLabel
@onready var speed_upgrade_button: Button = %SpeedUpgradeButton
@onready var reset_button: Button = %ResetButton
@onready var passive_output_button: Button = %PassiveOutputButton
@onready var passive_output_timer: Timer = $PassiveOutputTimer
@onready var coal_total_label: Label = %CoalTotalLabel
@onready var coal_miner_unlock_button: Button = %CoalMinerUnlockButton
@onready var coal_miner_upgrade_button: Button = %CoalMinerUpgradeButton
@onready var mine_coal_button: Button = %MineCoalButton

var game_data: GameData = GameData.new()
var upgrade_data: UpgradeData = UpgradeData.new()

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
var coal_miner_unlocked = false


func _ready() -> void:
	game_data.resources_changed.connect(_on_resources_changed)
	# this will set up every upgrade button we add in the future instead of doing it manually one by one like it's 1990
	for node in get_tree().get_nodes_in_group("upgrade_buttons"):
		var upgrade_button := node as UpgradeButtonControl
		upgrade_button.setup(upgrade_data)
	update_text()

func _process(delta: float) -> void:
	if coal_miner_unlocked:
		coal_miner_unlock_button.disabled = true
		
func _on_button_pressed() -> void:
	mine_animation_player.play("mine")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	game_data.add_resource("iron", output)
	update_text()

func _on_speed_upgrade_button_pressed() -> void:
	if game_data.can_spend_resource("iron", speed_cost):
		game_data.spend_resource("iron", speed_cost)
		speed += 1
		mine_animation_player.speed_scale = speed
		update_text()
		

func _on_reset_button_pressed() -> void:
	game_data.reset()
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
	mine_label.text = "Iron:" + str(game_data.resources["iron"])
	if coal_miner_unlocked:
		coal_total_label.text = "Coal:" + str(game_data.resources["coal"])
	coal_miner_unlock_button.text = "Coal Miner Unlock \nPrice: "+ str(coal_miner_unlock_cost)
	coal_miner_upgrade_button.text = "Coal Miner Upgrade \nPrice: "+ str(coal_miner_upgrade_cost["iron"]) + " iron + " + str(coal_miner_upgrade_cost["coal"]) + " coal" 
	speed_upgrade_button.text = "Speed \nPrice:"+ str(speed_cost)+"\n Speed: " + str(speed)
	passive_output_button.text = "Passive Output\nCost: "+ str(passive_output_cost)+"\n Passive output: +" + str(passive_output)+ "/" + str(passive_output_time) + "sec"
	

func _on_passive_output_button_pressed() -> void:
	if game_data.can_spend_resource("iron", passive_output_cost):
		game_data.spend_resource("iron", passive_output_cost)
		passive_output_cost += 1 # increase the cost
		passive_output += 1
		passive_output_timer.start(passive_output_time)
		update_text() 
	
func _on_passive_output_timer_timeout() -> void:
	game_data.add_resource("iron", passive_output)
	update_text()


func _on_coal_miner_unlock_button_pressed() -> void:
	if game_data.can_spend_resource("iron", coal_miner_unlock_cost) and coal_miner_unlocked == false:
		game_data.spend_resource("iron", coal_miner_unlock_cost)
		coal_output += 1
		mine_coal_button.visible = true
		coal_miner_unlocked = true
		update_text()

func _on_coal_miner_upgrade_button_pressed() -> void:
	if game_data.can_spend_resource("iron", coal_miner_upgrade_cost["iron"]) and game_data.can_spend_resource("coal", coal_miner_upgrade_cost["coal"]):
		game_data.spend_resource("iron", coal_miner_upgrade_cost["iron"])
		game_data.spend_resource("coal", coal_miner_upgrade_cost["coal"])
		coal_miner_upgrade_cost["iron"] += 50
		coal_miner_upgrade_cost["coal"] += 50
		coal_output += 10
		update_text()


func _on_mine_coal_button_pressed() -> void:
	game_data.add_resource("coal", coal_output)
	update_text()
	
func _on_resources_changed() -> void:
	update_text()


func _on_upgrade_button_control_upgrade_requested(upgrade_id: StringName) -> void:
	var cost = upgrade_data.get_upgrade_cost(upgrade_id)
	
	match upgrade_id:
		&"pickaxe":
			# main asks upgrade data: "how much does a pick axe cost?"
			# main asks game data: "can player afford this upgrade?"
			if game_data.can_spend_resource("iron", cost):
				# main spends iron (or whatever is needed
				game_data.spend_resource("iron", cost)
				# main tells upgrade data: buy upgrade with this upgrade id
				upgrade_data.buy_upgrade(upgrade_id)
				print("pickaxe BOUGHT!")
		&"iron_output":
			if game_data.can_spend_resource("iron", cost):
				game_data.spend_resource("iron", cost)
				upgrade_data.buy_upgrade(upgrade_id)
				output += 1
				print("IRON OUTPUT BOUGHT")
