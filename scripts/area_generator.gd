extends Node3D

signal select(node: Node3D)


func _ready() -> void:
	for i in range(200):
		add_child($Base.duplicate())
		get_child(-1).position = 2 * Vector3(sin(i) * 100, cos(i) * (i % 10), sin(tan(i) * 100) * 100).rotated(Vector3.RIGHT, deg_to_rad(i))
		get_child(-1).scale = Vector3(randf_range(0.1, 5), randf_range(0.1, 5), randf_range(0.1, 5))
		get_child(-1).rotation = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
		get_child(-1).input_event.connect(_on_area_3d_input_event.bind(get_child(-1)))


func _on_area_3d_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int, node: CollisionObject3D) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed():
			emit_signal("select", node)
