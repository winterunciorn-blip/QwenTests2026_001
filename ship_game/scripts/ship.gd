extends RigidBody3D

func _ready() -> void:
	# Lock rotation to keep ship upright on the water plane
	angular_damp = 10.0
	# Constrain rotation to Y-axis only (yaw) and lock vertical movement
	axis_lock_angular_x = true
	axis_lock_angular_z = true
	axis_lock_linear_y = true

func _physics_process(_delta: float) -> void:
	# Keep ship constrained to horizontal plane (Y = 0)
	global_transform.origin.y = 0.0
