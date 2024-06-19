class_name Menu
extends Window

static var camera: Array[Camera3D]


func _ready() -> void:
	update()
	_on_viewport_selected(0)


func update():
	$Scroll/VBox/FCam3D.clear()
	for i in camera:
		$Scroll/VBox/FCam3D.add_item(i.get_path())


func _on_window_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		$Scroll.scroll_horizontal -= event.relative.x
		$Scroll.scroll_vertical -= event.relative.y


func _on_viewport_selected(index: int) -> void:
	var cam := camera[index]
	var gizmo = cam.get_node("Marker/GizmoControl")
	$Scroll/VBox/Viewport.texture = camera[index].get_viewport().get_texture()
	
	%CLinear/VBox/HBox/Mode.current_tab = cam.get_node("Canvas/Control/Linear/Mode").current_tab
	%CLinear/VBox/HBox/Axis.current_tab = cam.get_node("Canvas/Control/Linear/Axis").current_tab
	
	%CLinear/VBox/Sleep/Auto.set_pressed_no_signal(cam.follow_position)
	%CLinear/VBox/Sleep/X.set_value_no_signal(cam.sleep_position.x)
	%CLinear/VBox/Sleep/Y.set_value_no_signal(cam.sleep_position.y)
	%CLinear/VBox/Sleep/Z.set_value_no_signal(cam.sleep_position.z)
	
	%CLinear/Velocity/SpinBox.set_value_no_signal(cam.linear_velocity)
	%CLinear/Smooth/SpinBox.set_value_no_signal(cam.linear_smooth)
	%CLinear/Booster/SpinBox.set_value_no_signal(cam.linear_booster)
	%CLinear/Limit/SpinBox.set_value_no_signal(cam.linear_limit)
	
	%CAngular/VBox/HBox/Mode.current_tab =  cam.get_node("Canvas/Control/Angular/Mode").current_tab
	%CAngular/VBox/HBox/Axis.current_tab = cam.get_node("Canvas/Control/Angular/Axis").current_tab
	
	%CAngular/VBox/Sleep/Auto.set_pressed_no_signal(cam.follow_rotation)
	%CAngular/VBox/Sleep/X.set_value_no_signal(cam.sleep_rotation.x)
	%CAngular/VBox/Sleep/Y.set_value_no_signal(cam.sleep_rotation.y)
	%CAngular/VBox/Sleep/Z.set_value_no_signal(cam.sleep_rotation.z)
	
	%CAngular/Velocity/SpinBox.set_value_no_signal(cam.angular_velocity)
	%CAngular/Smooth/SpinBox.set_value_no_signal(cam.angular_smooth)
	
	if is_instance_valid(gizmo):
		%GLinear/Velocity/SpinBox.set_value_no_signal(gizmo.linear_velocity)
		%GLinear/DScaler/SpinBox.set_value_no_signal(gizmo.d_scaler)
		%GLinear/DSLimit/SpinBox.set_value_no_signal(gizmo.d_scale_limit)
		
		%GAngular/Velocity/SpinBox.set_value_no_signal(gizmo.angular_velocity)


func _on_close_requested() -> void:
	queue_free()


func _on_camera_property_changed(value: Variant, property: String) -> void:
	var cam := camera[$Scroll/VBox/FCam3D.selected]
	match property:
		"linear_state":
			cam.linear_state = 1 + \
			%CLinear/VBox/HBox/Mode.current_tab * 2 + \
			%CLinear/VBox/HBox/Axis.current_tab
			cam.linear_state = 0
		"follow_position":
			cam.follow_position = value
		"sleep_position":
			cam.sleep_position = Vector3(%CLinear/VBox/Sleep/X.value,
			%CLinear/VBox/Sleep/Y.value,
			%CLinear/VBox/Sleep/Z.value)
		"linear_velocity":
			cam.linear_velocity = value
		"linear_smooth":
			cam.linear_smooth = value
		"linear_booster":
			cam.linear_booster = value
		"linear_limit":
			cam.linear_limit = value
		"angular_state":
			cam.angular_state = 1 + \
			%CAngular/VBox/HBox/Mode.current_tab *  + \
			%CAngular/VBox/HBox/Axis.current_tab
			cam.angular_state = 0
		"follow_rotation":
			cam.follow_rotation = value
		"sleep_rotation":
			cam.sleep_rotation = Vector4(%CAngular/VBox/Sleep/X.value,
			%CAngular/VBox/Sleep/Y.value,
			%CAngular/VBox/Sleep/Z.value,
			%CAngular/VBox/Sleep/Angle.value)
		"angular_velocity":
			cam.angular_velocity = value
		"angular_smooth":
			cam.angular_smooth = value


func _on_gizmo_property_changed(value: Variant, property: String) -> void:
	var cam := camera[$Scroll/VBox/FCam3D.selected]
	var gizmo = cam.get_node("Marker/GizmoControl")
	if is_instance_valid(gizmo):
		match property:
			"linear_velocity":
				gizmo.linear_velocity = value
			"d_scaler":
				gizmo.d_scale_limit = value
			"ds_limit":
				gizmo.d_scale_limit = value
			"agular_velocity":
				gizmo.angular_velocity = value
