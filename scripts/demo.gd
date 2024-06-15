extends Node3D

@onready var gizmo := $AreaGenerator/GizmoMesh


func _ready() -> void:
	$Camera.gizmo = gizmo
	$Window/Camera.gizmo = gizmo
	$Window2/Camera.gizmo = gizmo


func _process(delta: float) -> void:
	$CanvasLayer/Label.text = str(delta)


func _on_area_generator_select(node: Node3D) -> void:
	gizmo.get_parent().remove_child(gizmo)
	node.add_child(gizmo, true, Node.INTERNAL_MODE_BACK)


func _on_gizmo_mesh_tree_entered() -> void:
	if is_instance_valid(gizmo):
		$Camera.focus = gizmo.get_parent()
		$Window/Camera.focus = gizmo.get_parent()
		$Window2/Camera.focus = gizmo.get_parent()
