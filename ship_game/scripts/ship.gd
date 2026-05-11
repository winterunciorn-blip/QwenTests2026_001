extends RigidBody3D

var target_speed: float = 0.0
var max_speed: float = 15.0
var acceleration: float = 5.0
var rotation_speed: float = 3.0

func _ready() -> void:
	# Lock rotation to keep ship upright on the water plane
	angular_damp = 10.0
	# Constrain rotation to Y-axis only (yaw) and lock vertical movement
	axis_lock_angular_x = true
	axis_lock_angular_z = true
	axis_lock_linear_y = true

func _physics_process(delta: float) -> void:
	# Keep ship constrained to horizontal plane (Y = 0)
	global_transform.origin.y = 0.0
	
	# Smooth acceleration/deceleration
	var current_speed = linear_velocity.length()
	if abs(target_speed - current_speed) > 0.1:
		if target_speed > current_speed:
			current_speed += acceleration * delta
		else:
			current_speed -= acceleration * delta
		current_speed = clamp(current_speed, 0, max_speed)
		
		# Apply velocity in the direction the ship is facing
		var forward = -global_transform.basis.z
		linear_velocity = forward * current_speed
	else:
		linear_velocity = -global_transform.basis.z * target_speed

func set_target_speed(speed: float) -> void:
	target_speed = clamp(speed, 0, max_speed)

func rotate_towards(direction: Vector3, delta: float) -> void:
	if direction.length() < 0.01:
		return
	
	var current_forward = -global_transform.basis.z
	var angle = current_forward.signed_angle_to(direction, Vector3.UP)
	
	if abs(angle) > 0.01:
		var rotation_step = rotation_speed * delta * sign(angle)
		rotation_step = clamp(rotation_step, -abs(angle), abs(angle))
		rotate_y(rotation_step)
