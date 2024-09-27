extends Area3D

class_name Volleyball

var velocity : Vector3 = Vector3(0,0,0)
var gravity_scalar = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity_vector = ProjectSettings.get_setting("physics/3d/default_gravity_vector")

func _physics_process(delta: float) -> void:
	velocity = delta * gravity_scalar * gravity_vector + velocity
	position += delta * velocity

func _on_body_entered(body: Node3D) -> void:
	if body.is_class("StaticBody3D"):
		get_gm().on_ball_land(position.x, position.z)

func get_gm() -> GameMaster:
	return get_tree().root.get_child(0)
