extends Node

class_name GameMaster

#region assets and instances

@export_category("Assets")
@onready var ui = $UserInterface
@export var volleyball_scene : PackedScene
var volleyball : Volleyball

#endregion

#region bounds related

@export_category("Court dimensions")
@export var court_length : float = 5.0
@export var court_width : float = 2.5
# to avoid the ball passing through the net
@export var attack_line_distance : float = 1.0

@export_category("Land dimensions")
@export var land_length : float = 7.5
@export var land_width : float = 5

#endregion

#region teams related

enum team {BLUE, RED, INDEFINITE = -1}
@export_category("Teams")
@export var red_team : Array[Player]
@export var blue_team : Array[Player]

var _blue_team_points : int = 0
var _red_team_points : int = 0

#endregion

#region ball related

@export_category("Ball rules")
@export var max_hits_per_side : int = 3
@export var blue_ball_spawn_point : Vector3
@export var red_ball_spawn_point : Vector3
@export var hit_set_air_time : float = 2.0
@export var ball_radius : float = 0.3
@export var hit_set_height : float = 20

# other ball related data
var hits_left_on_side : int = 0
var side_last_hit : team
var side : team
@onready var landing_indicator : Node3D = $LandingIndicator
var last_hitter : Player = null

#endregion

var _gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	$VolleyballCourt.set_dimensions(land_length * 2, land_width * 2, court_length * 2, court_width * 2, attack_line_distance)
	landing_indicator.visible = false
	for p in red_team:
		p.team = team.RED
	for p in blue_team:
		p.team = team.BLUE
	volleyball = volleyball_scene.instantiate()
	add_child(volleyball)
	randomize()
	# reduce land width, land length by ball radius to keep within bounds
	# and increase min distance by ball radius to keep clearance 
	land_length -= ball_radius
	land_width -= ball_radius
	attack_line_distance += ball_radius
	restart_volley(team.RED)

func add_point(scoring_team:team):
	assert(not scoring_team == team.INDEFINITE) 
	
	if scoring_team == team.BLUE:
		_blue_team_points += 1
	else:
		_red_team_points += 1
	ui.on_update_scores(_blue_team_points, _red_team_points)

func restart_volley(serving_side: team = team.BLUE) -> void:
	volleyball.set_physics_process(false)
	if serving_side == team.RED:
		volleyball.position = red_ball_spawn_point
	else:
		volleyball.position = blue_ball_spawn_point
	await get_tree().create_timer(1).timeout
	volleyball.set_physics_process(true)
	side = serving_side
	side_last_hit = serving_side
	hits_left_on_side = 0
	hit_set_ball()

func hit_set_ball(player:Player = null):
	# handle amount of hits left allowed
	if hits_left_on_side <= 1:
		hits_left_on_side = max_hits_per_side
		if side == team.BLUE:
			side = team.RED
			reset_team_can_hit(red_team, blue_team)
		else:
			side = team.BLUE
			reset_team_can_hit(blue_team, red_team)
	else:
		hits_left_on_side -= 1
		# reset last hitter and disable player who just hit
		if not last_hitter == null:
			last_hitter.can_hit_ball = true
		last_hitter = player
		if not last_hitter == null:
			last_hitter.can_hit_ball = false
			side_last_hit = last_hitter.team
	
	# choose next location
	var far_out = land_length
	var min_out = attack_line_distance
	var width = land_width
	if side == team.BLUE:
		far_out *= -1
		min_out *= -1
	var x = randf_range(min(far_out, min_out), max(min_out, far_out))
	var z = randf_range(-width, width)
	
	hit_ball_helper_by_height(hit_set_height, x, z)
	
#region helper methods

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
	print("delta height: %f" % delta_height)
	return sqrt(2 * _gravity * delta_height)

#endregion

func on_ball_land(landing_point_x: float, landing_point_z: float):
	# hide indicator
	landing_indicator.visible = false
	# pause volleyball
	volleyball.set_physics_process(false)
	# find who scored
	var scoring_team : team = team.INDEFINITE
	if abs(landing_point_x) >= court_length or abs(landing_point_z) >= court_width:
		scoring_team = team.BLUE if side_last_hit == team.RED else team.RED
	else:
		scoring_team = team.BLUE if landing_point_x > 0 else team.RED
	add_point(scoring_team)
	# wait a sec for everyone to figure out what's going on
	await get_tree().create_timer(1).timeout
	# continue the game
	restart_volley(scoring_team)

func reset_team_can_hit(can_hit_team:Array[Player], cannot_hit_team:Array[Player]):
		for p in can_hit_team:
			p.can_hit_ball = true
		for p in cannot_hit_team:
			p.can_hit_ball = false

#endregion
