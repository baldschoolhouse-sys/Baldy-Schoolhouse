extends Node

@export var DoubleDoor: bool = false

@export var DoorClosed = Material
@export var DoorOpen = Material

var doorCollider
var doorColliders
var doorConnector = null
var otherDoor = null
var doorTimer = Timer
var doorMesh = Mesh

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	doorMesh = find_child("Door")
	if(DoubleDoor):
		doorColliders = find_children("Area3D")
		doorTimer = doorColliders[0].find_children("*", "Timer")[0]
	else:
		doorColliders = find_children("*", "StaticBody3D")
		doorTimer = doorMesh.get_parent().find_children("*", "Timer")[0]
	if(doorColliders.size() > 1):
		doorConnector = doorColliders[1]
	if(doorColliders.size() > 0):
		doorCollider = doorColliders[0]

func connect_doors(body: Node3D):
	if(self != body.get_parent()):
		print(body)
		otherDoor = body.get_parent()
		print(str(self) + str(otherDoor))

func _on_door_collider_entered(body: Node3D) -> void:
	if body.get_script().get_path().get_file() == "student.gd":
		openDoor()
		doorTimer.stop()

func openDoor(recursionCheck = false):
		print("Hi!")
		doorMesh.set_material_override(DoorOpen)
		if(otherDoor != null && recursionCheck == false):
			recursionCheck = true
			otherDoor.openDoor(recursionCheck)
			print("Hi2!")
		if(!DoubleDoor):
			doorCollider.set_collision_layer_value(2, false)
			
func closeDoor():
	doorMesh.set_material_override(DoorClosed)
	print("Hello Again!")
	if(!DoubleDoor):
		doorCollider.set_collision_layer_value(2, true)
			
func _on_door_collider_exited(body: Node3D, recursionCheck = false) -> void:
	if body.get_script().get_path().get_file() == "student.gd":
		doorTimer.start(3)
		print("Hello!")
		if(otherDoor != null && recursionCheck == false):
			recursionCheck = true
			otherDoor._on_door_collider_exited(body, recursionCheck)
			print("Hello2!")

func on_timeout():
	closeDoor()
