extends CharacterBody3D

const MOUSE_SENS: float = 0.2
const RUNNING_MULTIPLIER_VALUE = 1.8
const MAX_SPEED: float = 7.2
const ACCEL: float = 12
const DEACCEL: float = 1
const PLAYER_REACH = 4.0

var cur_speed: float = 4
var cur_speed_2: float = 4

var collisionNode
var cameraNode
var subViewportNode
var backgroundNode
var headNode
var centerContainerNode
var skidNode

var screensize

var mouseCaptured = true
var fullscreen = false

var runningMultiplier = 1.0

func _ready() -> void:
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	collisionNode = get_node("Collision")
	headNode = find_child("Head")
	cameraNode = find_child("Camera3D")
	subViewportNode = find_child("SubViewport")
	centerContainerNode = find_child("CenterContainer")
	skidNode = find_child("Skid")
	
	DisplayServer.window_set_min_size(subViewportNode.size)
	
	subViewportNode.get_parent().visible = true
	centerContainerNode.visible = true
	
	screensize = get_viewport().get_visible_rect().size
	backgroundNode = get_node("BackgroundTile")
	backgroundNode.region_rect = Rect2(0, 0, screensize.x, screensize.y)
	
func _input(event) -> void:
	if event is InputEventMouseMotion:
		cameraNode.rotation_degrees.y -= event.relative.x * MOUSE_SENS
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var mousepos = Vector2(subViewportNode.size.x/2, subViewportNode.size.y/2)

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
	if event is InputEventKey:
		if Input.is_key_pressed(KEY_QUOTELEFT):
			if(mouseCaptured):
				mouseCaptured = false
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			else:
				mouseCaptured = true
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if Input.is_key_pressed(KEY_F11):
			if(fullscreen):
				fullscreen = false
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			else:
				fullscreen = true
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
				
func _physics_process(delta) -> void:
	screensize = get_viewport().get_visible_rect().size
	backgroundNode.region_rect = Rect2(0, 0, screensize.x, screensize.y)
	
	if not is_on_floor(): velocity += get_gravity() * delta
	var input_direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
	var move_direction: Vector3 = (cameraNode.transform.basis * Vector3(input_direction.x, 0, -1 * input_direction.y)).normalized()
	
	if move_direction:
		# Check if running
		if Input.is_action_pressed("run"):
			# We are running
			runningMultiplier = RUNNING_MULTIPLIER_VALUE
		else:
			runningMultiplier = 1.0
			
		cur_speed = move_toward(cur_speed, MAX_SPEED*runningMultiplier, (ACCEL*runningMultiplier) * delta)
		cur_speed_2 = cur_speed
		velocity.x = cur_speed * move_direction.x
		velocity.z = cur_speed * move_direction.z
	else:
		cur_speed_2 = move_toward(cur_speed_2, 0, DEACCEL * delta)
		
		if(cur_speed_2 > 4.0):
			velocity.x *= (cur_speed_2 / (MAX_SPEED*RUNNING_MULTIPLIER_VALUE))
			velocity.z *= (cur_speed_2 / (MAX_SPEED*RUNNING_MULTIPLIER_VALUE))
		else:
			velocity.x *= (cur_speed_2 / MAX_SPEED)
			velocity.z *= (cur_speed_2 / MAX_SPEED)
			
		if(cur_speed >= 12.0):
				skidNode.play()
		
		cur_speed = 0
	
	#print("cur_speed: " + str(cur_speed))
	#print("cur_speed_2: " + str(cur_speed_2))
	#print("VX: " + str(velocity.x))
	#print("VZ: " + str(velocity.z))
	#print("VXMT: " + str(move_toward(velocity.x, cur_speed, DEACCEL * delta)))
	#print("VZMT: " + str(move_toward(velocity.z, cur_speed, DEACCEL * delta)))
	
	move_and_slide()
	cameraNode.position = Vector3(position.x, position.y + headNode.position.y, position.z)
