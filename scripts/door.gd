extends Node

@export var DoorClosed = Material
@export var DoorOpen = Material

var doorCollider = Area3D

var doorTimer = Timer
var doorMesh = Mesh

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	doorCollider = find_child("Area3D")
	doorTimer = doorCollider.find_children("*", "Timer")[0]
	doorMesh = find_child("Door")

func _on_door_collider_entered(body: Node3D) -> void:
	if body.get_script().get_path().get_file() == "student.gd":
		doorMesh.set_material_override(DoorOpen)
		doorTimer.stop()
		print("Hi!")
		
func _on_door_collider_exited(body: Node3D) -> void:
	if body.get_script().get_path().get_file() == "student.gd":
		doorTimer.start(3)
		print("Hello!")
		
func on_timeout():
	doorMesh.set_material_override(DoorClosed)
	print("Hello Again!")
