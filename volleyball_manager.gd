extends Node

# ball prefab
@export var volleyball_scene : PackedScene

# ball visuals
var volleyball : Volleyball
@onready var landing_indicator : Node3D = $LandingIndicator

var _gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	volleyball = volleyball_scene.instantiate()
	add_child(volleyball)
	landing_indicator.visible = false

#region other ball management
func pause_ball() -> void:
	volleyball.set_physics_process(false)

func resume_ball() -> void:
	volleyball.set_physics_process(true)

func move_ball(new_position:Vector3) -> void:
	volleyball.position = new_position

#endregion

#region indicator management
func show_indicator():
	landing_indicator.visible = true

func hide_indicator():
	landing_indicator.visible = false



#endregion

#region ball flight calculations
# assumes landing height of 0
func hit_ball_helper_by_time(flight_time: float, landing_x:float, landing_z:float) -> void:
	# set indicator
	landing_indicator.visible = true
	landing_indicator.position = Vector3(landing_x, 0, landing_z)
	
	# get ball velocity
	var vz = (landing_z - volleyball.position.z) / flight_time
	var vx = (landing_x - volleyball.position.x) / flight_time
	var vy = get_hit_set_vert_speed_by_time(volleyball.position.y, flight_time)
	
	volleyball.velocity = Vector3(vx, vy, vz)

# assumes landing height of 0
func get_hit_set_vert_speed_by_time(start_height:float, flight_time:float) -> float:
	return ( _gravity / 2 * pow(flight_time, 2) - start_height) / flight_time

# no assumption of flight time, assumes landing height of 0 for indicator
func hit_ball_helper_by_height(peak_height:float, landing_x:float, landing_z:float) -> void:
	# set indicator
	landing_indicator.visible = true
	landing_indicator.position = Vector3(landing_x, 0, landing_z)
	
	var starting_height : float = volleyball.position.y
	var vertical_speed : float = get_hit_set_vert_speed_by_height(starting_height, peak_height)
	var time = (vertical_speed + sqrt(vertical_speed ** 2 + 2 * _gravity * starting_height))/_gravity

	# get ball velocity
	var vz = (landing_z - volleyball.position.z)/time
	var vx = (landing_x - volleyball.position.x)/time

	# velocity
	volleyball.velocity = Vector3(vx, vertical_speed, vz)


# assumes delta height 
func get_hit_set_vert_speed_by_height(start_height:float, peak_height:float) -> float:
	var delta_height = peak_height - start_height
	return sqrt(2 * _gravity * delta_height)

#endregion
