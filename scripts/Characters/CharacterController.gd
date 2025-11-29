extends CharacterBody3D

@export var new_player_stats : PlayerStats

@export var camera_pivot: Node3D
@export var camera: Camera3D
@export var character_skin: Node3D

var mouse_sensitivity : float = 0.15
var camera_rotation : Vector2 = Vector2.ZERO
var last_movement_dir := Vector3.BACK
var is_jumping
var is_double_jump

func handle_press_skills():
	if Input.is_action_just_pressed("skill_e"):
		new_player_stats.can_jump = false
		print("Primeira skill")
		#usar_skill_1()

func handle_hold_skills():
	if Input.is_action_pressed("run"):
		new_player_stats.speed = new_player_stats.speed_base + 10
	if Input.is_action_just_released("skill_right_click"):
		print(new_player_stats.nickname ," usou ", new_player_stats.habilidades[0].name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	new_player_stats.scream("O Allossauro chegou!")

func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		camera_rotation = event.screen_relative * mouse_sensitivity

# Eventos que não afetam a gameplay, como UI
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
		new_player_stats.can_double_jump = true
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	is_jumping = Input.is_action_just_pressed("jump") and is_on_floor() and new_player_stats.can_jump
	is_double_jump = Input.is_action_just_pressed("jump") and not is_on_floor() and new_player_stats.can_double_jump

	# Handle jump.
	if is_jumping:
		velocity.y = new_player_stats.jump_height
	
	if is_double_jump:
		velocity.y=new_player_stats.jump_height
		new_player_stats.can_double_jump = false

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
		velocity = velocity.move_toward(direction * new_player_stats.speed, new_player_stats.acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector3.ZERO, new_player_stats.acceleration * delta)
	
	velocity.y = y_velocity
	
	move_and_slide()
	
	# Direção da frente da câmera (sem inclinação)
	var camera_forward := -camera.global_transform.basis.z
	camera_forward.y = 0
	camera_forward = camera_forward.normalized()

	# Personagem sempre olha para a frente da câmera
	if camera_forward.length() > 0.001:
		var target_angle := Vector3.BACK.signed_angle_to(camera_forward, Vector3.UP)
		var cur_angle := character_skin.global_rotation.y
		character_skin.global_rotation.y = lerp_angle(cur_angle, target_angle, 10.0 * delta)
	
	# Habilidade
	handle_press_skills()
	handle_hold_skills()
