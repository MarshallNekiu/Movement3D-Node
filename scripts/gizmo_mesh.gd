extends Node3D


func _process(delta: float) -> void:
	global_rotation = Vector3.ZERO
	$SelectedUp.quaternion = get_parent().quaternion
