extends Node

@onready var ui = $UserInterface

@export_category("Assets")
@export var volleyball_scene : PackedScene
var volleyball : Volleyball


@export_category("Court dimensions")
@export var court_length : float = 5.0
@export var court_width : float = 2.5
@export var min_distance_from_net : float = 1.0

var _blue_team_points : int = 0
var _red_team_points : int = 0

@export_category("Ball rules")
@export var max_hits_per_side : int = 3
var hits_left_on_side : int = 0
var on_blue_side : bool = false
@export var ball_spawn_point : Vector3
@export var max_travel_speed : float
@onready var landing_indicator : Node3D = $LandingIndicator
@export var hit_set_air_time : float = 2.0


func _ready() -> void:
	volleyball = volleyball_scene.instantiate()
	add_child(volleyball)
	volleyball.position = ball_spawn_point
	randomize()
	hit_set_ball()

func add_point(blue_team:bool):
	if blue_team:
		_blue_team_points += 1
	else:
		_red_team_points += 1
	ui.on_update_scores(_blue_team_points, _red_team_points)

func hit_set_ball():
	# handle amount of hits left allowed
	if hits_left_on_side <= 1:
		hits_left_on_side = max_hits_per_side
		on_blue_side = not on_blue_side
	else:
		hits_left_on_side -= 1
	
	# choose next location
	var far_out = -court_length if on_blue_side else court_length
	var min_out = -min_distance_from_net if on_blue_side else min_distance_from_net
	var z = randf_range(-court_width, court_width)
	var x = randf_range(min(far_out, min_out), max(min_out, far_out))
	landing_indicator.position = Vector3(x, 0, z)
	
	# get ball velocity
	var vz = (z - volleyball.position.z) / hit_set_air_time
	var vx = (x - volleyball.position.x) / hit_set_air_time
	var vy = get_hit_set_vert_speed(volleyball.position.y)
	
	volleyball.velocity = Vector3(vx, vy, vz)
	
func get_hit_set_vert_speed(start_height:float) -> float:
	return ( ProjectSettings.get_setting("physics/3d/default_gravity") / 2 * pow(hit_set_air_time, 2) - start_height) / hit_set_air_time
