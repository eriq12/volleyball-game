extends Area3D

class_name Volleyball

var velocity : Vector3 = Vector3(0,0,0)
var touch_ground : bool = false
var team_point : GameMaster.team = GameMaster.team.INDEFINITE

func _physics_process(delta: float) -> void:
	velocity = delta * ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector") + velocity
	position += delta * velocity
	if touch_ground:
		get_tree().root.get_child(0).add_point(team_point)
		touch_ground = false
		team_point = GameMaster.team.INDEFINITE

func _on_body_entered(body: Node3D) -> void:
	if body.is_class("StaticBody3D"):
		touch_ground = true
		if body.team_point != GameMaster.team.INDEFINITE:
			team_point = body.team_point
