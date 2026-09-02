class_name GameData
extends Resource

signal resources_changed()

var resources: Dictionary = {
#	TODO: change back to 0 before "release"
	"iron": 10000,
	"coal": 10000
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

func reset() -> void:
	resources["iron"] = 0
	resources["coal"] = 0
