extends MeshInstance3D

@export var wave_speed: float = 1.5
var time: float = 0.0

func _process(delta: float) -> void:
	time += delta * wave_speed
	# Godot 4.x использует set_shader_parameter для передачи uniforms в шейдер
	if material_override != null:
		material_override.set_shader_parameter("time", time)
		# Передаем позицию камеры в шейдер
		var camera = get_viewport().get_camera_3d()
		if camera != null:
			material_override.set_shader_parameter("camera_position", camera.global_position)
