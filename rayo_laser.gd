extends RayCast2D

@onready var line_2d: Line2D = $Line2D

@export var largo_maximo: float = 1000.0
@export var velocidad_rayo: float = 1200.0

var activo: bool
var largo_actual := 0.0

func _physics_process(delta):
	if !activo: return
	
	largo_actual += velocidad_rayo * delta
	largo_actual = min(largo_actual, largo_maximo)
	
	target_position = Vector2(0, largo_actual)
	force_raycast_update()
	
	var end_point: Vector2
	if self.is_colliding():
		chequear_colision()
		end_point = target_position
		
		#end_point = to_local(get_collision_point())
	else:
		end_point = target_position
	line_2d.points = [Vector2.ZERO, end_point]


func chequear_colision() -> void:
	var objeto_colisionado = get_collider()
	if objeto_colisionado is Nave:
		objeto_colisionado.recibir_daño(1)

func activar_laser() ->void:
	largo_actual = 0.0
	enabled = true
	activo = true

func desactivar_laser() -> void:
	activo = false
	enabled = false
	line_2d.points = [Vector2.ZERO, Vector2.ZERO]
