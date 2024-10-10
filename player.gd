extends CharacterBody3D

class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 6
# joy input node
@onready var joy_input : JoyInput = $JoyInput
@export var controller_config : ControllerConfig = null
@export var device_id : int = 0

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

# sorry I don't know what to name these. Long story short it's to allow 
var jesus_take_the_wheel : bool = false
var jesus_commands_where : Vector2

# team
var team : GameMaster.team

func _ready() -> void:
	joy_input.set_config(controller_config)
	joy_input.set_device(device_id)

func _process(_delta: float) -> void:
	if joy_input.hit_pressed and can_hit_ball:
		var gm = get_tree().root.get_child(0)
		gm.request_hit_ball(self)

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if joy_input.jump_pressed and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Vector2(velocity.x, velocity.z)
	if is_on_floor():
		if jesus_take_the_wheel:
			input_dir = Vector2(jesus_commands_where.x - position.x, jesus_commands_where.y - position.z)
			if input_dir.length() < 0.1:
				input_dir = Vector2.ZERO
		else:
			input_dir = joy_input.input_direction
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

func command_to_go_to(location : Vector2):
	jesus_take_the_wheel = true
	jesus_commands_where = location
	set_process(false)

func relieve_of_command():
	jesus_take_the_wheel = false
	set_process(true)

func change_highlight(visible:bool):
	$Highlight.visible = visible

func _on_area_3d_area_entered(area: Area3D) -> void:
	set_in_range(true)

func _on_area_3d_area_exited(area: Area3D) -> void:
	set_in_range(false)

# require child node joy input
func _get_configuration_warnings() -> PackedStringArray:
	# try to find a child that is input
	var child_joy_input : JoyInput = null
	for child in get_children():
		if child is JoyInput:
			child_joy_input = child
			break
	if child_joy_input == null:
		return ["Player instance needs a controller!"]
	return []