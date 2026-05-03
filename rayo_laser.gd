extends RayCast2D

@onready var line_2d: Line2D = $Line2D

@export var max_length: float = 800.0
@export var growth_speed: float = 1200.0

var activo: bool
var current_length := 0.0


func _process(delta):
	if !activo: return
	
	current_length += growth_speed * delta
	current_length = min(current_length, max_length)	
	
	target_position = Vector2(0, current_length)
	force_raycast_update()
	
	var end_point: Vector2
	if self.is_colliding():
		end_point = to_local(get_collision_point())
	else:
		end_point = target_position
	line_2d.points = [Vector2.ZERO, end_point]


func activar_laser() ->void:
	current_length = 0.0
	enabled = true
	activo = true

func desactivar_laser() -> void:
	activo = false
	enabled = false
	line_2d.points = [Vector2.ZERO, Vector2.ZERO]
