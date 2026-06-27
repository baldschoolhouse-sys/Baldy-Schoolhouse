extends CharacterBody3D

const MOUSE_SENS: float = 0.4

const MAX_SPEED: float = 8
const ACCEL: float = 8
const DEACCEL: float = 16
const PLAYER_REACH = 3.0

var cur_speed: float = 4
var cur_speed_2: float = 4

var collisionNode
var cameraNode

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	collisionNode = get_node("Collision")
	cameraNode = find_child("Camera3D")
		
func _input(event) -> void:
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * MOUSE_SENS
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var mousepos = get_viewport().get_mouse_position()

		var origin = cameraNode.project_ray_origin(mousepos)
		var end = origin + cameraNode.project_ray_normal(mousepos) * PLAYER_REACH
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_areas = true

		var result = get_world_3d().direct_space_state.intersect_ray(query)
		
		if(!result.is_empty()):
			var clickedObject = result['collider']
			if(clickedObject.get_parent()):
				var doorScript = clickedObject.get_parent()
				print(doorScript)
				if (doorScript.get_script().get_path().get_file() == "door.gd"):
					doorScript.openDoor(false)
					doorScript._on_door_collider_exited(self, false)
		
func _physics_process(delta) -> void:
	if not is_on_floor(): velocity += get_gravity() * delta
	var input_direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
	var move_direction: Vector3 = (transform.basis * Vector3(input_direction.x, 0, -1 * input_direction.y)).normalized()
	
	if move_direction:
		cur_speed = move_toward(cur_speed, MAX_SPEED, ACCEL * delta)
		cur_speed_2 = cur_speed
		velocity.x = cur_speed * move_direction.x
		velocity.z = cur_speed * move_direction.z
		# Check if running
		if Input.is_action_pressed("run"):
			# We are running
			velocity.x *= 2
			velocity.z *= 2
	else:
		cur_speed_2 = move_toward(cur_speed_2, 0, DEACCEL * delta)
		# I think this isn't accounting fully for where the player is facing - Jack 
		velocity.x *= (cur_speed_2 / MAX_SPEED)
		velocity.z *= (cur_speed_2 / MAX_SPEED)
		
		cur_speed = 0
	
		# I think this isn't accounting fully for where the player is facing - Jack 
		#cur_speed = 0
		#velocity.x = move_toward(velocity.x, cur_speed, DEACCEL * delta)
		#velocity.z = move_toward(velocity.z, cur_speed, DEACCEL * delta)
	
	#print("cur_speed: " + str(cur_speed))
	#print("cur_speed_2: " + str(cur_speed_2))
	#print("VX: " + str(velocity.x))
	#print("VZ: " + str(velocity.z))
	#print("VXMT: " + str(move_toward(velocity.x, cur_speed, DEACCEL * delta)))
	#print("VZMT: " + str(move_toward(velocity.z, cur_speed, DEACCEL * delta)))
	
	move_and_slide()
	
