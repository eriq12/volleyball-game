extends CharacterBody3D

class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 6
		

@export_category("Player Controls")
@export var hit_action : String = "P1_hit_ball"
@export var jump_action : String = "P1_jump"
@export var move_left_action : String = "P1_move_left"
@export var move_right_action : String = "P1_move_right"
@export var move_up_action : String = "P1_move_up"
@export var move_down_action : String = "P1_move_down"

# color
@onready var default_color : Color = $Highlight.modulate
@export var in_range_color : Color = Color.LIGHT_BLUE

# ball related data
var ball_in_range : bool = false
@onready var can_hit_indicator : Sprite3D = $Highlight
var can_hit_ball : bool :
	set(value):
		can_hit_indicator.visible = value
	get:
		return can_hit_indicator.visible

# team
var team : GameMaster.team

func _process(_delta: float) -> void:
	if ball_in_range and is_on_floor() and can_hit_ball and Input.is_action_pressed(hit_action):
		var gm = get_tree().root.get_child(0)
		gm.hit_ball(self)

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed(jump_action) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Vector2(velocity.x, velocity.z)
	if is_on_floor():
		input_dir = Input.get_vector(move_left_action, move_right_action, move_up_action, move_down_action)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func set_in_range(value:bool):
	ball_in_range = value
	if value:
		$Highlight.modulate = in_range_color
	else:
		$Highlight.modulate = default_color

func change_highlight(visible:bool):
	$Highlight.visible = visible

func _on_area_3d_area_entered(area: Area3D) -> void:
	set_in_range(true)

func _on_area_3d_area_exited(area: Area3D) -> void:
	set_in_range(false)
