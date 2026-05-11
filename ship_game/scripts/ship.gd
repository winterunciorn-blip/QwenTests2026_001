extends RigidBody3D

var target_position: Vector3 = Vector3.ZERO
var is_moving: bool = false
var max_speed: float = 15.0
var acceleration: float = 5.0
var rotation_speed: float = 4.0

func _ready() -> void:
	# Lock rotation to keep ship upright on the water plane
	angular_damp = 10.0
	# Constrain rotation to Y-axis only (yaw) and lock vertical movement
	axis_lock_angular_x = true
	axis_lock_angular_z = true
	axis_lock_linear_y = true
	target_position = global_transform.origin

func _physics_process(delta: float) -> void:
	# Keep ship constrained to horizontal plane (Y = 0)
	global_transform.origin.y = 0.0
	
	if not is_moving:
		# Smooth deceleration to stop
		var current_speed = linear_velocity.length()
		if current_speed > 0.1:
			current_speed -= acceleration * 2.0 * delta
			current_speed = max(current_speed, 0)
			var forward = -global_transform.basis.z
			linear_velocity = forward * current_speed
		else:
			linear_velocity = Vector3.ZERO
		return
	
	# Calculate direction to target
	var direction = target_position - global_transform.origin
	direction.y = 0.0
	var distance = direction.length()
	
	if distance < 0.5:
		is_moving = false
		return
	
	direction = direction.normalized()
	
	# Rotate ship towards target
	var current_forward = -global_transform.basis.z
	var angle = current_forward.signed_angle_to(direction, Vector3.UP)
	
	if abs(angle) > 0.01:
		var rotation_step = rotation_speed * delta * sign(angle)
		rotation_step = clamp(rotation_step, -abs(angle), abs(angle))
		rotate_y(rotation_step)
	
	# Accelerate towards max speed
	var current_speed = linear_velocity.length()
	if current_speed < max_speed:
		current_speed += acceleration * delta
		current_speed = min(current_speed, max_speed)
	
	# Apply velocity in the direction the ship is facing
	var forward = -global_transform.basis.z
	linear_velocity = forward * current_speed

func set_target(pos: Vector3) -> void:
	target_position = pos
	is_moving = true
