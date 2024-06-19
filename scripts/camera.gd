class_name FocusCamera3D
extends Camera3D

enum STATE{SLEEP, LOCAL_Z, LOCAL_XY, RELATIVE_Z, RELATIVE_XY, GLOBAL_Z, GLOBAL_XY}

@export_group("Linear")
@export var linear_state := STATE.SLEEP:
	set(x):
		linear_state = x
		if x:
			$Canvas/Control/Linear/Mode.current_tab = [0, 0, 1, 1, 2, 2][x - 1]
			$Canvas/Control/Linear/Axis.current_tab = [0, 1, 0, 1, 0, 1][x - 1]
@export var linear_direction := Vector2.ZERO
@export var linear_velocity := 5.0
@export_range(0.0, 1.0)
var linear_smooth := 0.05
@export var linear_boost := 1.0
@export var linear_booster := 0.005
@export var linear_limit := 250.0
@export_group("Angular")
@export var angular_state := STATE.SLEEP:
	set(x):
		angular_state = x
		if x:
			$Canvas/Control/Angular/Mode.current_tab = [0, 0, 1, 1, 2, 2][x - 1]
			$Canvas/Control/Angular/Axis.current_tab = [0, 1, 0, 1, 0, 1][x - 1]
@export var angular_directiom := Vector2.ZERO
@export var angular_velocity := 3.0
@export_range(0.0, 1.0)
var angular_smooth := 0.01
@export_category("Relative")
@export var focus: Node3D
@export var follow_position := true:
	set(x):
		follow_position = x
		$Canvas/Control/Linear/Sleep/Auto.set_pressed_no_signal(x)
@export var sleep_position := Vector3(3, 2, 10):
	set(x):
		sleep_position = x
		$Canvas/Control/Linear/Sleep/X.set_value_no_signal(x.x)
		$Canvas/Control/Linear/Sleep/Y.set_value_no_signal(x.y)
		$Canvas/Control/Linear/Sleep/Z.set_value_no_signal(x.z)
@export var follow_rotation := true:
	set(x):
		follow_rotation = x
		$Canvas/Control/Angular/Sleep/Auto.set_pressed_no_signal(x)
@export var sleep_rotation := Vector4(0, 1, 0, 0):
	set(x):
		sleep_rotation = x
		$Canvas/Control/Angular/Sleep/X.set_value_no_signal(sleep_rotation.x)
		$Canvas/Control/Angular/Sleep/Y.set_value_no_signal(sleep_rotation.y)
		$Canvas/Control/Angular/Sleep/Z.set_value_no_signal(sleep_rotation.z)
		$Canvas/Control/Angular/Sleep/Angle.set_value_no_signal(sleep_rotation.w)

var canvas_scale := Vector2.ONE
var gizmo: Node3D:
	set(x):
		gizmo = x
		$Marker/GizmoControl.gizmo = x


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_released():
			var x := $Canvas/Control/Linear.position.lerp($Canvas/Control/Angular.position, 0.5) * canvas_scale as Vector2
			if event.position.x < x.x:
				linear_state = STATE.SLEEP
				linear_boost = 1.0
			elif event.position.x > x.x:
				angular_state = STATE.SLEEP


func _on_control_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.get("position"):
		if shape_idx == 0:
			linear_direction = Vector2(event.position - $Canvas/Control/Linear.position * canvas_scale).normalized()
		elif shape_idx == 1:
			angular_directiom = Vector2(event.position - $Canvas/Control/Angular.position * canvas_scale).normalized()
	if event is InputEventScreenTouch:
		if event.is_pressed():
			if shape_idx == 0:
				if not linear_state:
					linear_state = 1 + $Canvas/Control/Linear/Mode.current_tab * 2 + $Canvas/Control/Linear/Axis.current_tab
			elif shape_idx == 1:
				if not angular_state:
					angular_state = 1 + $Canvas/Control/Angular/Mode.current_tab * 2 + $Canvas/Control/Angular/Axis.current_tab


func _ready() -> void:
	$Marker/GizmoControl.camera = self
	update_canvas()


func _process(delta: float) -> void:
	if linear_state:
		[linear_local_z, linear_local_xy, linear_relative_z, linear_relative_xy, linear_global_z, linear_global_xy][linear_state - 1].callv([linear_direction, delta])
		linear_boost = lerp(linear_boost, linear_limit, linear_booster)
	
	if angular_state:
		[angular_local_z, angular_local_xy, angular_relative_z, angular_relative_xy, angular_global_z, angular_global_xy][angular_state - 1].callv([angular_directiom, delta])
	
	if is_instance_valid(focus):
		if follow_position:
			var target_gp := focus.global_position + sleep_position
			global_position = global_position.lerp(target_gp, linear_smooth)
		if follow_rotation:
			var a := Vector3(sleep_rotation.x, sleep_rotation.y, sleep_rotation.z)
			if a:
				var target_q := Quaternion(a.normalized(), deg_to_rad(sleep_rotation.w))
				quaternion = quaternion.slerp(target_q, angular_smooth)
		$Marker/GizmoControl.global_position = global_position + global_position.direction_to(focus.global_position)
		$Marker/GizmoControl.global_rotation = Vector3.ZERO
	
	debug([str("gpos/grot", Vector3i(global_position), Vector3i(global_rotation_degrees)),
	str("linear(state/direction)", $Marker/GizmoControl.linear_state, Vector2($Marker/GizmoControl.linear_direction).snapped(Vector2.ONE * 0.01)),
	str("angular(state/direction)", $Marker/GizmoControl.angular_state, Vector2($Marker/GizmoControl.angular_direction).snapped(Vector2.ONE * 0.01)),
	str("input mode", $Marker/GizmoControl.input_mode)])


func debug(data: Array):
	$Canvas/Label.text = ""
	var txt := ""
	for i in data:
		txt += str(i, "\n")
	$Canvas/Label.text = txt


func linear_local_z(direction: Vector2, delta: float) -> void:
	translate(Vector3.BACK * direction.y * delta * linear_velocity * linear_boost)


func linear_local_xy(direction: Vector2, delta: float) -> void:
	translate(Vector3(direction.x, -direction.y, 0).normalized() * delta * linear_velocity * linear_boost)


func linear_relative_z(direction: Vector2, delta: float) -> void:
	if is_instance_valid(focus):
		global_transform.origin = focus.global_transform.origin +\
		(global_transform.origin - focus.global_transform.origin).rotated(Vector3.FORWARD, delta * direction.x * linear_velocity)
		if $Canvas/Control/Angular/Mode.current_tab == 1:
			global_rotate(Vector3.FORWARD, delta * direction.x * linear_velocity)


func linear_relative_xy(direction: Vector2, delta: float) -> void:
	if is_instance_valid(focus):
		global_transform.origin = focus.global_transform.origin +\
		(global_transform.origin - focus.global_transform.origin).rotated(Vector3(direction.y, direction.x, 0).normalized(), 0.5 * delta * linear_velocity)
		if $Canvas/Control/Angular/Mode.current_tab == 1:
			global_rotate(Vector3(direction.y, direction.x, 0).normalized(), 0.5 * delta * linear_velocity)


func linear_global_z(direction: Vector2, delta: float) -> void:
	global_translate(Vector3.BACK * direction.y * delta * linear_velocity * linear_boost)


func linear_global_xy(direction: Vector2, delta: float) -> void:
	global_translate(Vector3(direction.x, -direction.y, 0).normalized() * delta * linear_velocity * linear_boost)


func angular_local_z(direction: Vector2, delta) -> void:
	rotate_object_local(Vector3.FORWARD, direction.x * delta * angular_velocity)


func angular_local_xy(direction: Vector2, delta) -> void:
	rotate_object_local(-Vector3(direction.y, direction.x, 0).normalized(), 0.5 * delta * angular_velocity)


func angular_relative_z(direction: Vector2, delta) -> void:
	if is_instance_valid(focus):
		rotate_object_local(Vector3.FORWARD, direction.x * delta * angular_velocity)


func angular_relative_xy(direction: Vector2, delta) -> void:
	if is_instance_valid(focus):
		rotate_object_local(-Vector3(direction.y, direction.x, 0).normalized(), 0.5 * delta * angular_velocity)


func angular_global_z(direction: Vector2, delta) -> void:
	global_rotate(Vector3.BACK, direction.x * delta * angular_velocity)


func angular_global_xy(direction: Vector2, delta) -> void:
	global_rotate(-Vector3(direction.y, direction.x, 0).normalized(), 0.5 * delta * angular_velocity)


func update_canvas():
	canvas_scale = get_viewport().get_visible_rect().size / Vector2(1920.0, 1080.0)
	$Canvas.transform.x.x = canvas_scale.x
	$Canvas.transform.y.y = canvas_scale.y


func _on_tree_exiting() -> void:
	get_viewport().size_changed.disconnect(update_canvas)
	Menu.camera.erase(self)


func _on_tree_entered() -> void:
	get_viewport().size_changed.connect(update_canvas)
	Menu.camera.append(self)


func _on_linear_auto_toggled(toggled_on: bool) -> void:
	follow_position = toggled_on


func _on_angular_auto_toggled(toggled_on: bool) -> void:
	follow_rotation = toggled_on


func _on_linear_sleep_value_changed(value: float) -> void:
	sleep_position = Vector3($Canvas/Control/Linear/Sleep/X.value, $Canvas/Control/Linear/Sleep/Y.value, $Canvas/Control/Linear/Sleep/Z.value)


func _on_angular_value_changed(value: float) -> void:
	sleep_rotation = Vector4(($Canvas/Control/Angular/Sleep/X.value),
	($Canvas/Control/Angular/Sleep/Y.value),
	($Canvas/Control/Angular/Sleep/Z.value),
	($Canvas/Control/Angular/Sleep/Angle.value))
