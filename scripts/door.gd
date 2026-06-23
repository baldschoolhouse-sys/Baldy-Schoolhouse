extends Node

@export var DoubleDoor: bool = false

@export var DoorClosed = Material
@export var DoorOpen = Material

var doorCollider = Area3D
var doorColliders
var doorConnector = null
var otherDoor = null
var doorTimer = Timer
var doorMesh = Mesh

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	doorColliders = find_children("Area3D")
	doorCollider = doorColliders[0]
	if(doorColliders.size() > 1):
		doorConnector = doorColliders[1]
	doorTimer = doorCollider.find_children("*", "Timer")[0]
	doorMesh = find_child("Door")

func connect_doors(body: Node3D):
	if(self != body.get_parent()):
		print(body)
		otherDoor = body.get_parent()
		print(str(self) + str(otherDoor))

func _on_door_collider_entered(body: Node3D, recursionCheck = false) -> void:
	if body.get_script().get_path().get_file() == "student.gd":
		doorMesh.set_material_override(DoorOpen)
		doorTimer.stop()
		print("Hi!")
		if(otherDoor != null && recursionCheck == false):
			recursionCheck = true
			otherDoor._on_door_collider_entered(body, recursionCheck)
			print("Hi2!")
	
func _on_door_collider_exited(body: Node3D, recursionCheck = false) -> void:
	if body.get_script().get_path().get_file() == "student.gd":
		doorTimer.start(3)
		print("Hello!")
		if(otherDoor != null && recursionCheck == false):
			recursionCheck = true
			otherDoor._on_door_collider_exited(body, recursionCheck)
			print("Hello2!")

func on_timeout():
	doorMesh.set_material_override(DoorClosed)
	print("Hello Again!")
