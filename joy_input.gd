extends Node

class_name JoyInput

var device : int = 0
var config : ControllerConfig

# values
var hit_pressed : bool = false
var jump_pressed : bool = false
var _input_x : float = 0
var _input_y : float = 0
var input_direction : Vector2:
    get:
        return Vector2(_input_x, _input_y)

func _unhandled_input(event: InputEvent) -> void:
    if config == null:
        return
    if event.device != device:
        return
    if event is InputEventJoypadButton:
        if event.button_index == config.hit_button:
            hit_pressed = event.pressed
        elif event.button_index == config.jump_button:
            jump_pressed = event.pressed
    elif event is InputEventJoypadMotion:
        if event.axis == config.move_x_axis:
            _input_x = event.axis_value
            if abs(_input_x) < config.deadzone:
                _input_x = 0
        elif event.axis == config.move_y_axis:
            _input_y = event.axis_value
            if abs(_input_y) < config.deadzone:
                _input_y = 0

func set_device(new_id: int):
    device = new_id

func set_config(new_config: ControllerConfig):
    config = new_config