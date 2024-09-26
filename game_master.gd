extends Node

class_name GameMaster

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
var side : team = team.BLUE
@export var blue_ball_spawn_point : Vector3
@export var red_ball_spawn_point : Vector3
@onready var landing_indicator : Node3D = $LandingIndicator
@export var hit_set_air_time : float = 2.0

enum team {BLUE, RED, INDEFINITE = -1}

func _ready() -> void:
	volleyball = volleyball_scene.instantiate()
	add_child(volleyball)
	randomize()
	restart_volley()

func restart_volley(serving_side: team = team.BLUE) -> void:
	if serving_side == team.RED:
		volleyball.position = red_ball_spawn_point
	else:
		volleyball.position = blue_ball_spawn_point
	side = serving_side
	hits_left_on_side = 0
	hit_set_ball()

func add_point(scoring_team:team):
	if scoring_team == team.INDEFINITE:
		scoring_team = side
	
	if scoring_team == team.BLUE:
		_blue_team_points += 1
	else:
		_red_team_points += 1
	ui.on_update_scores(_blue_team_points, _red_team_points)
	restart_volley(scoring_team)

func hit_set_ball():
	# handle amount of hits left allowed
	if hits_left_on_side <= 1:
		hits_left_on_side = max_hits_per_side
		side = team.RED if side == team.BLUE else team.BLUE
	else:
		hits_left_on_side -= 1
	
	# choose next location
	var far_out = court_length
	var min_out = min_distance_from_net
	if side == team.BLUE:
		far_out *= -1
		min_out *= -1
	var z = randf_range(-court_width, court_width)
	var x = randf_range(min(far_out, min_out), max(min_out, far_out))
	landing_indicator.position = Vector3(x, 0, z)
	
	# get ball velocity
	var vz = (z - volleyball.position.z) / hit_set_air_time
	var vx = (x - volleyball.position.x) / hit_set_air_time
	var vy = get_hit_set_vert_speed(volleyball.position.y, hit_set_air_time)
	
	volleyball.velocity = Vector3(vx, vy, vz)
	
func get_hit_set_vert_speed(start_height:float, flight_time:float) -> float:
	return ( ProjectSettings.get_setting("physics/3d/default_gravity") / 2 * pow(flight_time, 2) - start_height) / flight_time
