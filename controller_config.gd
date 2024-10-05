extends Resource

class_name ControllerConfig

@export_category("Player Controls")
@export var hit_button : JoyButton = JOY_BUTTON_X
@export var jump_button : JoyButton = JOY_BUTTON_A
@export var move_x_axis : JoyAxis = JOY_AXIS_LEFT_X
@export var move_y_axis : JoyAxis = JOY_AXIS_LEFT_Y
@export var deadzone : float = 0.1