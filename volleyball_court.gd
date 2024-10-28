extends Node3D

class_name VolleyballCourt

#region visuals
@onready var _team_ground_visual_group = $TeamGroundVisualGroup
@onready var _blue_ground_visual = $TeamGroundVisualGroup/BlueTeamGround
@onready var _red_ground_visual = $TeamGroundVisualGroup/RedTeamGround
@onready var _three_meter_area = $"TeamGroundVisualGroup/3MeterArea"
@onready var _ground_visual = $ActualGround/GroundVisual
#endregion

#region collisions
# ground
@onready var _ground_collider = $ActualGround/CollisionShape3D
# walls
@onready var _bounds_group = $Bounds
@onready var _center_wall = $Bounds/WallCenter
@onready var _west_wall = $Bounds/WallWest
@onready var _east_wall = $Bounds/WallEast
@onready var _north_wall = $Bounds/WallNorth
@onready var _south_wall = $Bounds/WallSouth
#endregion

@onready var _center_net = $Net

const BOUNDS_THICKNESS = 0.05
const BOUNDS_HEIGHT = 10
const GROUND_THICKNESS = 1
const TEAM_GROUND_VISUAL_OFFSET = 0.001
const NET_THICKNESS = 0.05

func set_dimensions(ground_length:float, ground_width:float, court_length:float, court_width:float, attack_line_distance:float, net_height:float) -> void:
	set_max_bounds(ground_length, ground_width)
	set_court_bounds(court_length, court_width, attack_line_distance)
	set_net_height(net_height, court_width)

func set_max_bounds(length:float, width:float) -> void:
	length = abs(length)
	width = abs(width)
	# set visuals
	_ground_visual.size = Vector3(length, GROUND_THICKNESS, width)
	_ground_visual.position = GROUND_THICKNESS * 0.5 * Vector3.DOWN
	# set bounds
	# set ground
	_ground_collider.shape.size = Vector3(length, 1, width)
	# set height for bounds
	_bounds_group.position = BOUNDS_HEIGHT * 0.5 * Vector3.UP
	# should set for center, east, and west
	_center_wall.shape.size = Vector3(BOUNDS_THICKNESS, BOUNDS_HEIGHT, width)
	_west_wall.position = length * 0.5 * Vector3.LEFT
	_east_wall.position = length * 0.5 * Vector3.RIGHT
	# should set for north and south
	_north_wall.shape.size = Vector3(length, BOUNDS_HEIGHT, BOUNDS_THICKNESS)
	_north_wall.position = width * 0.5 * Vector3.FORWARD
	_south_wall.position = width * 0.5 * Vector3.BACK

func set_court_bounds(length:float, width:float, attack_line_distance:float) -> void:
	var team_ground_length = length *  0.5 - attack_line_distance
	var team_ground_distance = attack_line_distance + team_ground_length * 0.5
	# team ground sizes
	_blue_ground_visual.size = Vector3(team_ground_length, GROUND_THICKNESS, width)
	_red_ground_visual.size = Vector3(team_ground_length, GROUND_THICKNESS, width)
	_three_meter_area.size = Vector3(attack_line_distance * 2, GROUND_THICKNESS, width)
	# team ground positions
	_team_ground_visual_group = (GROUND_THICKNESS * 0.5 - TEAM_GROUND_VISUAL_OFFSET) * Vector3.DOWN
	_blue_ground_visual.position = team_ground_distance * Vector3.LEFT
	_red_ground_visual.position = team_ground_distance * Vector3.RIGHT

func set_net_height(net_height:float, court_width:float) -> void:
	_center_net.size = Vector3(NET_THICKNESS, net_height, court_width)
	_center_net.position = Vector3.UP * (net_height / 2)