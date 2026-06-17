extends Area3D

var isWorking = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent().get_script().get_path().get_file() == "door.gd":
		isWorking = true

func _on_timer_timeout() -> void:
	if isWorking:
		get_parent().on_timeout()

func _on_door_collider_exited(body: Node3D) -> void:
	if isWorking:
		get_parent()._on_door_collider_exited(body)

func _on_door_collider_entered(body: Node3D) -> void:
	if isWorking:
		get_parent()._on_door_collider_entered(body)
