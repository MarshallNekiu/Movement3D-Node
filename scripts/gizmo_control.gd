class_name GizmoControl
extends Node3D

enum INPUT_MODE{SLEEP, LINEAR, ANGULAR, LIN_ANG, ANG_LIN}
enum LINEAR_STATE{SLEEP, AXIS_X, AXIS_Y, AXIS_Z, AXIS_YX, AXIS_ZY, AXIS_XZ}
enum ANGULAR_STATE{SLEEP, AXIS_X, AXIS_Y, AXIS_Z}

@export_group("Linear")
@export var linear_state := LINEAR_STATE.SLEEP
@export var linear_direction := Vector2.ZERO
@export var linear_velocity := 5.0
@export var distance_scale := 0.1
@export var d_scaler := 0.05
@export var d_scale_limit := 1000.0
@export_group("Angular")
@export var angular_state := ANGULAR_STATE.SLEEP
@export var angular_direction := Vector2.ZERO
@export var angular_velocity := 3.0
@export_group("")

@export var gizmo: Node3D
@export var camera: Camera3D

var input_mode := INPUT_MODE.SLEEP


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_released():
			if linear_state:
				if angular_state:
					angular_state = ANGULAR_STATE.SLEEP
					angular_direction = Vector2.ZERO
					input_mode = INPUT_MODE.LINEAR
				else:
					linear_state = LINEAR_STATE.SLEEP
					linear_direction = Vector2.ZERO
					input_mode = INPUT_MODE.SLEEP
				distance_scale = 0.1
			elif angular_state:
				angular_state = ANGULAR_STATE.SLEEP
				angular_direction = Vector2.ZERO
				input_mode = INPUT_MODE.SLEEP
	elif event is InputEventScreenDrag:
		event.position = event.position - get_viewport().get_visible_rect().size * 0.5
		if input_mode == INPUT_MODE.LINEAR:
			linear_direction = event.position.normalized()
		elif input_mode == INPUT_MODE.ANGULAR:
			angular_direction = event.position.normalized()
		elif input_mode == INPUT_MODE.LIN_ANG:
			if event.index == 0:
				linear_direction = event.position.normalized()
			elif event.index == 1:
				angular_direction = event.position.normalized()
		elif input_mode == INPUT_MODE.ANG_LIN:
			if event.index == 0:
				angular_direction = event.position.normalized()
			elif event.index == 1:
				linear_direction = event.position.normalized()


func _process(delta: float) -> void:
	if is_instance_valid(gizmo) and gizmo.is_inside_tree():
		if linear_state:
			[linear_x, linear_y, linear_z, linear_yx, linear_zy, linear_xz][linear_state - 1].callv([delta])
			if is_instance_valid(camera):
				distance_scale = lerp(camera.global_position.distance_to(gizmo.global_position), d_scale_limit, d_scaler)
		
		if angular_state:
			[angular_x, angular_y, angular_z][angular_state - 1].callv([delta])


func linear_x(delta: float):
	gizmo.get_parent().global_translate(Vector3.RIGHT * linear_direction.x * delta * (linear_velocity + distance_scale))


func linear_y(delta: float):
	gizmo.get_parent().global_translate(Vector3.UP * -linear_direction.y * delta * (linear_velocity + distance_scale))


func linear_z(delta: float):
	gizmo.get_parent().global_translate(Vector3.FORWARD * linear_direction.y * delta * (linear_velocity + distance_scale))


func linear_yx(delta: float):
	gizmo.get_parent().global_translate(Vector3(linear_direction.x, -linear_direction.y, 0).normalized() * 0.5 * delta * (linear_velocity + distance_scale))


func linear_zy(delta: float):
	gizmo.get_parent().global_translate(Vector3(0, -linear_direction.y, -linear_direction.x).normalized() * 0.5 * delta * (linear_velocity + distance_scale))


func linear_xz(delta: float):
	gizmo.get_parent().global_translate(Vector3(linear_direction.x, 0, linear_direction.y).normalized() * 0.5 * delta * (linear_velocity + distance_scale))


func angular_x(delta: float):
	if angular_direction.x:
		gizmo.get_parent().global_rotate(Vector3(0, 0, -angular_direction.x).normalized(), delta * angular_velocity)


func angular_y(delta: float):
	if angular_direction.x:
		gizmo.get_parent().global_rotate(Vector3(0, angular_direction.x, 0).normalized(), delta * angular_velocity)


func angular_z(delta: float):
	if angular_direction.y:
		gizmo.get_parent().global_rotate(Vector3(angular_direction.y, 0, 0).normalized(), delta * angular_velocity)


func _on_area_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed():
			if shape_idx <= 2:
				if not angular_state:
					angular_state = 1 + shape_idx
					if not input_mode == INPUT_MODE.LINEAR:
						input_mode = INPUT_MODE.ANGULAR
					else:
						input_mode = INPUT_MODE.LIN_ANG
			else:
				if not linear_state:
					linear_state = 1 + shape_idx - 3
					if not input_mode == INPUT_MODE.ANGULAR:
						input_mode = INPUT_MODE.LINEAR
					else:
						input_mode = INPUT_MODE.ANG_LIN
