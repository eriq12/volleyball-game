extends Node

class_name GameMaster

#region assets and instances

@export_category("Assets")
@onready var ui = $UserInterface

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
@export var red_team : Node
@export var blue_team : Node

var _blue_team_points : int = 0
var _red_team_points : int = 0

#endregion

#region ball related

@onready var volleyball_manager = $VolleyballManager

@export_category("Ball rules")
@export var max_hits_per_side : int = 3
@export var blue_ball_spawn_point : Vector3
@export var red_ball_spawn_point : Vector3
@export var hit_set_air_time : float = 2.0
@export var ball_radius : float = 0.3
@export var hit_set_height : float = 3
@export var hit_pass_height : float = 2
@export var pass_land_variance : float = 1

# other ball related data
var number_hits_on_side : int = 0
var side_last_hit : team
var side : team
var last_hitter : Player = null

#endregion


func _ready() -> void:
	$VolleyballCourt.set_dimensions(land_length * 2, land_width * 2, court_length * 2, court_width * 2, attack_line_distance)
	for p in red_team.get_children():
		p.team = team.RED
	for p in blue_team.get_children():
		p.team = team.BLUE
	
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
	volleyball_manager.pause_ball()
	if serving_side == team.RED:
		volleyball_manager.move_ball(red_ball_spawn_point)
	else:
		volleyball_manager.move_ball(blue_ball_spawn_point)
	await get_tree().create_timer(1).timeout
	side = serving_side
	side_last_hit = serving_side
	number_hits_on_side = max_hits_per_side
	hit_ball()
	volleyball_manager.resume_ball()

func hit_ball(player:Player = null):
	# handle amount of hits left allowed
	if number_hits_on_side >= max_hits_per_side - 1:
		number_hits_on_side = 0
		if side == team.BLUE:
			side = team.RED
			reset_team_can_hit(red_team, blue_team)
		else:
			side = team.BLUE
			reset_team_can_hit(blue_team, red_team)
	else:
		number_hits_on_side += 1
		# reset last hitter and disable player who just hit
		if not last_hitter == null:
			last_hitter.can_hit_ball = true
		last_hitter = player
		if not last_hitter == null:
			last_hitter.can_hit_ball = false
			side_last_hit = last_hitter.team
	
	# choose next location
	var location : Vector2 = Vector2.ZERO
	var far_out = land_length
	var min_out = ball_radius
	var court_far_out = court_length
	var court_min_out = attack_line_distance
	var width = land_width
	if side == team.BLUE:
		far_out *= -1
		min_out *= -1
		court_far_out *= -1
		court_min_out *= -1
	var x_left_bound = min(far_out, min_out)
	var x_right_bound = max(far_out, min_out)
	var court_x_left_bound = min(court_far_out, court_min_out)
	var court_x_right_bound = max(court_far_out, court_min_out)
	# pass
	if number_hits_on_side > 0:
		var teammate = get_closest_teammate(player)
		var rand_angle = randf_range(0, 2 * PI)
		var rand_magnitude = randf_range(0, pass_land_variance)
		location.x = clamp(teammate.position.x + cos(rand_angle) * rand_magnitude, x_left_bound, x_right_bound)
		location.y = clamp(teammate.position.z + cos(rand_angle) * rand_magnitude, -width, width)
	# set
	else:
		location.x = randf_range(court_x_left_bound, court_x_right_bound)
		location.y = randf_range(-court_width, court_width)
	
	volleyball_manager.hit_ball_helper_by_height(hit_pass_height if number_hits_on_side == 1 else hit_set_height, location.x, location.y)
	
#region helper methods

func on_ball_land(landing_point_x: float, landing_point_z: float):
	disable_all_team(blue_team if side == team.BLUE else red_team)
	volleyball_manager.hide_indicator()
	volleyball_manager.pause_ball()
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

func reset_team_can_hit(can_hit_team:Node, cannot_hit_team:Node):
	for p in can_hit_team.get_children():
		p.can_hit_ball = true
	disable_all_team(cannot_hit_team)

func disable_all_team(cannot_hit_team:Node):
	for p in cannot_hit_team.get_children():
			p.can_hit_ball = false

# use manhattan approx
func get_closest_teammate(player:Player) -> Player:
	var closest_teammate : Player = null
	var closest_distance : float = land_length + land_width
	var player_x : float = player.position.x
	var player_z : float = player.position.z
	for p in player.get_parent().get_children():
		if not p == player:
			var teammate_x : float = p.position.x
			var teammate_z : float = p.position.z
			var distance = abs(player_x - teammate_x) + abs(player_z - teammate_z)
			if distance < closest_distance:
				closest_teammate = p
				closest_distance = distance
	return closest_teammate


#endregion
