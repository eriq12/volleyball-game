extends Node

# ball prefab
@export var volleyball_scene : PackedScene

# ball stats
@export var net_height : float = 2.43
var is_ball_above_net : bool = false
@export var height_threshold_can_hit : float = 1
var is_ball_hittable : bool = false

signal ball_above_net
signal ball_below_net
signal ball_is_hittable

# ball visuals
var volleyball : Volleyball
@onready var landing_indicator : Node3D = $LandingIndicator

var _gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	volleyball = volleyball_scene.instantiate()
	add_child(volleyball)
	landing_indicator.visible = false

func _physics_process(_delta: float) -> void:
	var new_ball_height_state : bool = volleyball.position.y >= net_height
	var new_ball_hittable_state : bool = volleyball.position.y <= height_threshold_can_hit
	if new_ball_height_state != is_ball_above_net:
		if new_ball_height_state:
			ball_above_net.emit()
		else:
			ball_below_net.emit()
	if new_ball_hittable_state && not is_ball_hittable:
		ball_is_hittable.emit()
	is_ball_above_net = new_ball_height_state
	is_ball_hittable = new_ball_hittable_state

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

## assumes player is on ground
func get_player_distance_from_landing(player:Player) -> float:
	return (player.position - landing_indicator.position).length()

func get_landing_position() -> Vector2:
	return Vector2(landing_indicator.position.x, landing_indicator.position.z)


#endregion

#region ball flight calculations
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

#region marked for deprecation

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

#endregion