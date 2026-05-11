extends Node3D

@onready var ship: RigidBody3D = $Ship
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var water: MeshInstance3D = $Water

var target_position: Vector3 = Vector3.ZERO
var is_moving: bool = false

func _ready() -> void:
	# Initialize target position to ship's starting position
	target_position = ship.global_transform.origin
	# Set up camera to follow ship
	_update_camera()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Get the click position in world space
		var mouse_pos = event.position
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 1000
		
		var space_state = ship.get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to, 1, [ship])
		query.exclude = [ship]
		
		var result = space_state.intersect_ray(query)
		if result:
			target_position = result.position
			is_moving = true
			# Rotate ship to face the target
			_rotate_ship_towards_target()

func _process(delta: float) -> void:
	if is_moving:
		# Move ship towards target
		var direction = (target_position - ship.global_transform.origin).normalized()
		var distance = ship.global_transform.origin.distance_to(target_position)
		
		if distance < 0.5:
			is_moving = false
			ship.linear_velocity = Vector3.ZERO
		else:
			# Apply force in the direction the ship is facing
			var forward = -ship.global_transform.basis.z
			var speed = 15.0
			ship.linear_velocity = forward * speed
			
		# Continuously rotate ship towards target while moving
		_rotate_ship_towards_target()
	
	# Update camera to follow ship
	_update_camera()

func _rotate_ship_towards_target() -> void:
	var direction = (target_position - ship.global_transform.origin).normalized()
	if direction.length() > 0.01:
		var target_basis = Basis()
		target_basis.z = -direction
		target_basis.x = direction.cross(Vector3.UP).normalized()
		target_basis.y = Vector3.UP
		
		var target_quat = Quaternion(target_basis)
		ship.rotation = target_quat.get_euler()

func _update_camera() -> void:
	# Position camera behind and above the ship, following its direction
	var ship_forward = -ship.global_transform.basis.z
	var camera_offset = ship_forward * 8 + Vector3.UP * 5
	camera_pivot.global_transform.origin = ship.global_transform.origin + camera_offset
	camera_pivot.look_at(ship.global_transform.origin + Vector3.UP * 2)
