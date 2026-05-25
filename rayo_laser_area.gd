extends Area2D

@onready var line_2d: Line2D = $Line2D
@onready var timer: Timer = $Timer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var largo_maximo: float = 1000.0
@export var velocidad_rayo: float = 1200.0

# Tiempo que queda prendido luego de expandirse
@export var duracion_laser: float = 2.0

signal comenzo_disparar
signal termino_disparar

var activo: bool = false
var largo_actual: float = 0.0
var expandido_completo: bool = false

func _ready() -> void:
	largo_maximo = line_2d.texture.get_width()
	timer.timeout.connect(_on_timer_timeout)

func _physics_process(delta: float) -> void:
	if !activo:
		return

	if !expandido_completo:

		largo_actual += velocidad_rayo * delta
		largo_actual = min(largo_actual, largo_maximo)

		collision_shape_2d.shape.size.y = largo_actual
		collision_shape_2d.position.y = largo_actual / 2

		if largo_actual >= largo_maximo:
			expandido_completo = true
			#timer.start(duracion_laser)

	line_2d.points = [Vector2.ZERO,Vector2(0,largo_actual) ]


func activar_laser() -> void:
	if activo:
		return
	timer.start()
	comenzo_disparar.emit()

	activo = true
	expandido_completo = false
	largo_actual = 0.0

func desactivar_laser() -> void:
	timer.stop()
	collision_shape_2d.shape.size.y = 0
	collision_shape_2d.position.y = 0
	activo = false
	line_2d.points = []

func _on_timer_timeout() -> void:
	desactivar_laser()
	termino_disparar.emit()
