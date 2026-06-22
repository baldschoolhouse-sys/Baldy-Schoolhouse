extends Area3D

var isWorking = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent().get_script().get_path().get_file() == "door.gd":
		isWorking = true


func _on_area_entered(area: Area3D) -> void:
	print(isWorking)
	if isWorking:
		get_parent().connect_doors(area)
