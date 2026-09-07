class_name GameData
extends Resource

signal resources_changed()

var last_saved: float = 0.0
var elapsed_time: float = 0.0
var resources: Dictionary = {
	"iron": 0,
	"coal": 0
}
func add_resource(resource: String, amount: int) -> void:
	resources[resource] += amount
	resources_changed.emit()

func can_afford(cost: Dictionary) -> bool:
	for resource in cost:
		if resources.get(resource, 0) < cost[resource]:
			return false
	return true

func spend_resources(cost: Dictionary) -> void:
	if not can_afford(cost):
		return
	
	for resource in cost:
		resources[resource] -= cost[resource]
		
	resources_changed.emit()

func to_dict() -> Dictionary:
	return {
		"last_saved": Time.get_unix_time_from_system(),
		"resources": resources.duplicate(true)
	}

func from_dict(saved_game_resources: Dictionary) -> void:
	var now  = Time.get_unix_time_from_system()
	for res_key in saved_game_resources["resources"]:
		resources[res_key] = int(saved_game_resources["resources"][res_key])
	if not saved_game_resources.has("last_saved"):
		last_saved = 0
	else:
		last_saved = float(saved_game_resources["last_saved"])
		# max 8 hours of elapsed time to prevent excessive resource gain
		elapsed_time = clampf(now - last_saved, 0, 28800)

func reset() -> void:
	resources["iron"] = 0
	resources["coal"] = 0
	resources_changed.emit()
