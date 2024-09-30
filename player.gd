extends CharacterBody3D

class_name Player

const SPEED = 2.5
const JUMP_VELOCITY = 4.5
const HIT_LOCK_TIME = 0.5
const HIT_RECOVER_TIME = 0.2


@export_category("Player Controls")
@export var hit_action : String = "P1_hit_ball"
@export var jump_action : String = "P1_jump"
@export var move_left_action : String = "P1_move_left"
@export var move_right_action : String = "P1_move_right"
@export var move_up_action : String = "P1_move_up"
@export var move_down_action : String = "P1_move_down"

# ball related data
var ball_in_range : bool = false
@onready var can_hit_indicator : Sprite3D = $Highlight

@export_category("Indicator Related Settings")
@export var ready_set_color : Color = Color.BLUE
@export var hit_color : Color = Color.MEDIUM_AQUAMARINE
@onready var original_color : Color = can_hit_indicator.modulate

enum state {CANNOT_HIT = -1, HAS_HIT = 0, CAN_HIT = 1, READY_SET = 2, READY_SPIKE = 3}

var player_state : state = state.CANNOT_HIT

# team
var team : GameMaster.team

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if is_on_floor():
		if Input.is_action_just_pressed(jump_action):
			velocity.y = JUMP_VELOCITY
		elif Input.is_action_just_pressed(hit_action) and player_state == state.CAN_HIT:
			ready_set_ball()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector(move_left_action, move_right_action, move_up_action, move_down_action)
	var direction : Vector3 = Vector3(velocity.x, 0, velocity.z).normalized()
	if is_on_floor():
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func change_highlight(highlight_new_visible:bool, color:Color):
	can_hit_indicator.visible = highlight_new_visible
	can_hit_indicator.modulate = color

#region state management
func allow_hit() -> void:
	set_state(state.CAN_HIT, true)

func disallow_hit() -> void:
	set_state(state.CANNOT_HIT)

func set_state(new_state:state, override:bool=false) -> void:
	if player_state == state.CANNOT_HIT and not override:
		return
	player_state = new_state
	match player_state:
		state.CAN_HIT:
			change_highlight(true, original_color)
			self.set_physics_process(true)
		state.HAS_HIT:
			change_highlight(true, hit_color)
			self.set_physics_process(false)
		state.READY_SET:
			change_highlight(true, ready_set_color)
			self.set_physics_process(false)
		_: # for state.CANNOT_HIT and other things to pretend this as default state
			change_highlight(false, original_color)
			self.set_physics_process(true)

#endregion

#region ball hitting

func hit_set_ball() -> void:
	get_tree().root.get_child(0).hit_set_ball()
	set_state(state.HAS_HIT)
	await get_tree().create_timer(HIT_RECOVER_TIME).timeout
	set_state(state.CAN_HIT)


func _on_area_3d_area_entered(_area: Area3D) -> void:
	if player_state == state.READY_SET:
		hit_set_ball()
		return
	ball_in_range = true

func _on_area_3d_area_exited(_area: Area3D) -> void:
	ball_in_range = false

func ready_set_ball() -> void:
	if ball_in_range:
		hit_set_ball()
		return
	set_state(state.READY_SET)
	await get_tree().create_timer(HIT_LOCK_TIME).timeout
	set_state(state.CAN_HIT)
#endregion
