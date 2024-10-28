extends CharacterBody3D

class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 6
# joy input node
@onready var joy_input : JoyInput = $JoyInput
@export var controller_config : ControllerConfig = null
@export var device_id : int = 0

# ball related data
@onready var can_hit_indicator : Sprite3D = $Highlight
var can_hit_ball : bool :
	set(value):
		can_hit_indicator.visible = value
	get:
		return can_hit_indicator.visible

# rather than finding the game master, use signals
signal request_hit
signal request_jump

# sorry I don't know what to name these. Long story short it's to allow moving
# the player to where they need to be
var jesus_take_the_wheel : bool = false
var jesus_commands_where : Vector2
var on_location : bool = false
signal reached_location

# team
var team : GameMaster.team

func _ready() -> void:
	joy_input.set_config(controller_config)
	joy_input.set_device(device_id)

func _process(_delta: float) -> void:
	if joy_input.hit_pressed and can_hit_ball:
		request_hit.emit()

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if joy_input.jump_pressed and is_on_floor() and not jesus_take_the_wheel:
		request_jump.emit()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Vector2(velocity.x, velocity.z)
	if is_on_floor():
		if jesus_take_the_wheel:
			input_dir = get_jesus_input()
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

#region jesus taking wheel related code
func command_to_go_to(location : Vector2):
	jesus_take_the_wheel = true
	jesus_commands_where = location
	on_location = false
	set_process(false)

func relieve_of_command():
	jesus_take_the_wheel = false
	set_process(true)

func get_jesus_input() -> Vector2:
	var base_vector = Vector2(jesus_commands_where.x - position.x, jesus_commands_where.y - position.z)
	if base_vector.length() < 0.1:
		base_vector = Vector2.ZERO
		if not on_location:
			on_location = true
			reached_location.emit()
	return base_vector

#endregion

func change_highlight(new_visible:bool):
	$Highlight.visible = new_visible