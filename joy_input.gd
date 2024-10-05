extends Node

class_name JoyInput

@export var device : int = 0
@export_category("Player Controls")
@export var hit_button : JoyButton = JOY_BUTTON_X
@export var jump_button : JoyButton = JOY_BUTTON_A
@export var move_x_axis : JoyAxis = JOY_AXIS_LEFT_X
@export var move_y_axis : JoyAxis = JOY_AXIS_LEFT_Y
@export var deadzone : float = 0.1

# values
var hit_pressed : bool = false
var jump_pressed : bool = false
var _input_x : float = 0
var _input_y : float = 0
var input_direction : Vector2:
    get:
        return Vector2(_input_x, _input_y)

func _unhandled_input(event: InputEvent) -> void:
    if event.device != device:
        return
    if event is InputEventJoypadButton:
        if event.button_index == hit_button:
            hit_pressed = event.pressed
        elif event.button_index == jump_button:
            jump_pressed = event.pressed
    elif event is InputEventJoypadMotion:
        if event.axis == move_x_axis:
            _input_x = event.axis_value
            if abs(_input_x) < deadzone:
                _input_x = 0
        elif event.axis == move_y_axis:
            _input_y = event.axis_value
            if abs(_input_y) < deadzone:
                _input_y = 0
