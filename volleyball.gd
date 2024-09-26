extends Area3D

class_name Volleyball

var velocity : Vector3 = Vector3(0,0,0)
var on_ground : bool = false
var blue_team_touch : bool = true

func _physics_process(delta: float) -> void:
	if not on_ground:
		velocity = delta * ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector") + velocity
	position += delta * velocity

func _on_body_entered(body: Node3D) -> void:
	if body.is_class("StaticBody3D"):
		on_ground = true
		velocity = Vector3.ZERO

func _on_body_exited(body: Node3D) -> void:
	if body.is_class("StaticBody3D"):
		on_ground = false
