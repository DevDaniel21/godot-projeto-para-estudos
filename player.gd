extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const ACCELERATION = 15

@onready var camera_pivot: Node3D = $camera_pivot
@onready var camera: Camera3D = $camera_pivot/SpringArm3D/camera
@onready var dino_skin: Node3D = $dino

var mouse_sensitivity : float = 0.15
var camera_rotation : Vector2 = Vector2.ZERO
var last_movement_dir := Vector3.BACK
var is_jumping
var is_double_jump
var can_double_jump := true

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		camera_rotation = event.screen_relative * mouse_sensitivity

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if Input.is_action_just_pressed("left_click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	camera_pivot.rotation.x += camera_rotation.y * delta
	camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-35), deg_to_rad(20))
	camera_pivot.rotation.y -= camera_rotation.x * delta
	
	camera_rotation = Vector2.ZERO
	
	if is_on_floor():
		can_double_jump = true
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	is_jumping = Input.is_action_just_pressed("ui_accept") and is_on_floor()
	is_double_jump = Input.is_action_just_pressed("ui_accept") and not is_on_floor() and can_double_jump
	
	# Handle jump.
	if is_jumping:
		velocity.y = JUMP_VELOCITY
		
	if is_double_jump:
		velocity.y=JUMP_VELOCITY
		can_double_jump = false
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var forward := camera.global_basis.z
	var right := camera.global_basis.x
	var direction := (forward * input_dir.y + right * input_dir.x).normalized()
	direction.y = 0.0
	
	var y_velocity = velocity.y
	velocity.y = 0.0
	
	if direction:
		velocity = velocity.move_toward(direction * SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector3.ZERO, ACCELERATION * delta)
	
	velocity.y = y_velocity
	
	move_and_slide()
	# Direção da frente da câmera (sem inclinação)
	var camera_forward := -camera.global_transform.basis.z
	camera_forward.y = 0
	camera_forward = camera_forward.normalized()

	# Personagem sempre olha para a frente da câmera
	if camera_forward.length() > 0.001:
		var target_angle := Vector3.BACK.signed_angle_to(camera_forward, Vector3.UP)
		var cur_angle := dino_skin.global_rotation.y
		dino_skin.global_rotation.y = lerp_angle(cur_angle, target_angle, 10.0 * delta)
