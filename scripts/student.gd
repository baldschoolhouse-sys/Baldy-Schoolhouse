extends CharacterBody3D

const MOUSE_SENS: float = 0.4

const MAX_SPEED: float = 8
const ACCEL: float = 8
const DEACCEL: float = 16

var cur_speed: float = 4

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event) -> void:
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * MOUSE_SENS

func _physics_process(delta) -> void:
	if not is_on_floor(): velocity += get_gravity() * delta
	var input_direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
	var move_direction: Vector3 = (transform.basis * Vector3(input_direction.x, 0, -1 * input_direction.y)).normalized()
	
	if move_direction:
		cur_speed = move_toward(cur_speed, MAX_SPEED, ACCEL * delta)
		velocity.x = cur_speed * move_direction.x
		velocity.z = cur_speed * move_direction.z
		# Check if running
		if Input.is_action_pressed("run"):
			# We are running
			velocity.x *= 2
			velocity.z *= 2
	else:
		cur_speed = 0
		# I think this isn't accounting fully for where the player is facing - Jack 
		velocity.x = move_toward(velocity.x, cur_speed, DEACCEL * delta)
		velocity.z = move_toward(velocity.z, cur_speed, DEACCEL * delta)

	
	move_and_slide()
