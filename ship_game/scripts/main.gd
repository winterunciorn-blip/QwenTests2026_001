extends Node3D

@onready var ship: RigidBody3D = $Ship
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var water: MeshInstance3D = $Water

var target_position: Vector3 = Vector3.ZERO
var is_moving: bool = false
var stop_distance: float = 0.5

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

func _process(delta: float) -> void:
	if is_moving:
		# Calculate direction to target
		var direction = (target_position - ship.global_transform.origin).normalized()
		var distance = ship.global_transform.origin.distance_to(target_position)
		
		if distance < stop_distance:
			is_moving = false
			ship.set_target_speed(0.0)
		else:
			# Set target speed for smooth acceleration
			ship.set_target_speed(ship.max_speed)
			
		# Continuously rotate ship towards target while moving
		ship.rotate_towards(direction, delta)
	
	# Update camera to follow ship
	_update_camera()

func _update_camera() -> void:
	# Position camera behind and above the ship, following its direction
	var ship_forward = -ship.global_transform.basis.z
	var camera_offset = ship_forward * 8 + Vector3.UP * 5
	camera_pivot.global_transform.origin = ship.global_transform.origin + camera_offset
	camera_pivot.look_at(ship.global_transform.origin + Vector3.UP * 2)
