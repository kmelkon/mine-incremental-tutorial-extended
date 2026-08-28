class_name GameData
extends Resource

signal resources_changed()

var resources: Dictionary = {
	"iron": 1000,
	"coal": 1000
}
func add_resource(resource: String, amount: int) -> void:
	resources[resource] += amount
	resources_changed.emit()

func spend_resource(resource: String, amount: int) -> void:
	if can_spend_resource(resource, amount):
		resources[resource] -= amount
		resources_changed.emit()

func can_spend_resource(resource: String, amount: int) -> bool:
	return resources[resource] >= amount

func reset() -> void:
	resources["iron"] = 0
	resources["coal"] = 0
