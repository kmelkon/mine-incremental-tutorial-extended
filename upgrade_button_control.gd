extends Control

signal upgrade_requested(upgrade_id: StringName)

@export var upgrade_id: StringName
@export var cost := 10
@export var upgrade_amount := 1


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	print("upgrade button PRESSED!")
	upgrade_requested.emit(upgrade_id)
