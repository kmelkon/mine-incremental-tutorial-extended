class_name GameData
extends Resource

signal resources_changed()

var last_saved
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
	resources = saved_game_resources["resources"]
	last_saved = saved_game_resources["last_saved"]

func reset() -> void:
	resources["iron"] = 0
	resources["coal"] = 0
	resources_changed.emit()
