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

const bounds_thickness = 0.05
const bounds_height = 10
const ground_thickness = 1
const team_ground_visual_offset = 0.001

func set_dimensions(ground_length:float, ground_width:float, court_length:float, court_width:float, attack_line_distance) -> void:
	set_max_bounds(ground_length, ground_width)
	set_court_bounds(court_length, court_width, attack_line_distance)

func set_max_bounds(length:float, width:float) -> void:
	length = abs(length)
	width = abs(width)
	# set visuals
	_ground_visual.size = Vector3(length, ground_thickness, width)
	_ground_visual.position = ground_thickness * 0.5 * Vector3.DOWN
	# set bounds
	# set ground
	_ground_collider.shape.size = Vector3(length, 1, width)
	# set height for bounds
	_bounds_group.position = bounds_height * 0.5 * Vector3.UP
	# should set for center, east, and west
	_center_wall.shape.size = Vector3(bounds_thickness, bounds_height, width)
	_west_wall.position = length * 0.5 * Vector3.LEFT
	_east_wall.position = length * 0.5 * Vector3.RIGHT
	# should set for north and south
	_north_wall.shape.size = Vector3(length, bounds_height, bounds_thickness)
	_north_wall.position = width * 0.5 * Vector3.FORWARD
	_south_wall.position = width * 0.5 * Vector3.BACK

func set_court_bounds(length:float, width:float, attack_line_distance:float) -> void:
	var team_ground_length = length *  0.5 - attack_line_distance
	var team_ground_distance = attack_line_distance + team_ground_length * 0.5
	# team ground sizes
	_blue_ground_visual.size = Vector3(team_ground_length, ground_thickness, width)
	_red_ground_visual.size = Vector3(team_ground_length, ground_thickness, width)
	_three_meter_area.size = Vector3(attack_line_distance * 2, ground_thickness, width)
	# team ground positions
	_team_ground_visual_group = (ground_thickness * 0.5 - team_ground_visual_offset) * Vector3.DOWN
	_blue_ground_visual.position = team_ground_distance * Vector3.LEFT
	_red_ground_visual.position = team_ground_distance * Vector3.RIGHT
