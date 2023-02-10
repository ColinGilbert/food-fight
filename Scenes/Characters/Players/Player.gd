extends "res://Scenes/Characters/Character.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var motion: Vector3
var movement_state = 0 # idle is 0, run is 1
export var mouse_sensitivity = 1200

const SPEED = 10
const UP = Vector3(0, 1, 0)
const MIN_BLEND_SPEED = 0.125
const BLEND_TO_RUN = 0.075
const BLEND_TO_IDLE = 0.1

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	move()
	animate()
	
func _input(event):
	if event is InputEventMouseMotion:
		rotation = h_camera_rotation(event.relative.x/mouse_sensitivity)	
		$Camera.rotation = v_camera_rotation(event.relative.y/mouse_sensitivity)
	if Input.is_action_just_pressed("fire"):
		try_to_fire()
		
func move():
	var movement_direction_2d = get_2d_movement_direction() 
	var direction_from_cam = Vector3.ZERO
	var camera_xform = $Camera.global_transform
	direction_from_cam -= camera_xform.basis.z.normalized() * movement_direction_2d.x
	direction_from_cam += camera_xform.basis.x.normalized() * movement_direction_2d.y
	motion = Vector3(direction_from_cam.x, 0, direction_from_cam.z)
	move_and_slide(motion * SPEED, UP)


func face_forward(x, z):
	$Armature.rotation.y = atan2(x, z) - PI/2

func animate():
	if (motion * SPEED).length() > MIN_BLEND_SPEED:
		movement_state += BLEND_TO_RUN
	else:
		movement_state -= BLEND_TO_IDLE
	movement_state = clamp(movement_state, 0, 1)
	var animation = $Armature/AnimationTree
	animation["parameters/Move/blend_amount"] = movement_state

func h_camera_rotation(camera_rotation):
	return rotation + Vector3(0, -camera_rotation, 0)

func v_camera_rotation(camera_rotation):
	var rot = $Camera.rotation + Vector3(camera_rotation, 0, 0)
	rot.x = clamp(rot.x, PI/-8, PI/8)
	return rot

func get_2d_movement_direction():
	var x = Input.get_action_strength("forward") - Input.get_action_strength("back")
	var y = Input.get_action_strength("right") - Input.get_action_strength("left")
	var movement_direction = Vector2(x, y)
	if not movement_direction == Vector2.ZERO:
		face_forward(x, y)
	return movement_direction.normalized()
