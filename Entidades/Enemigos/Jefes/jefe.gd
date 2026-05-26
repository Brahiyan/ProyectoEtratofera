class_name Jefe extends Path2D

@export var cantidad_parpadeos: int = 4
@export var daño: int = 3
@export var duracion_parpadeo: float = 0.1
@export var nave_ref: Nave
@export var velocidad: float = 0.2     
@export var velocidad_de_entrada: float = 600.0     
@export var vida_maxima: int = 10

@onready var area_2d: Area2D = $PathFollow2D/Area2D
@onready var en_pantalla: bool = false
@onready var fase_de_ataque: FASE_DE_ATAQUE = FASE_DE_ATAQUE.DISPARO_MOVIMIENTO
@onready var path_follow_2d: PathFollow2D = $PathFollow2D
@onready var sonido_muerte: AudioStreamPlayer = $SonidoMuerte
@onready var sonido_risa: AudioStreamPlayer = $SonidoRisa
@onready var sprite_2d: Sprite2D = $PathFollow2D/Sprite2D
@onready var timer_disparo: Timer = $TimerDisparo

enum FASE_DE_ATAQUE{
	ATAQUE_PRIMERA_FASE,
	ATAQUE_SEGUNDA_FASE,
	DISPARO_MOVIMIENTO,
	CARGA,
	RECUPERACION
}


signal boss_destruido
signal comenzo_recorrido
signal completo_recorrido
signal threshold_alcanzado

var atacando: bool = false
var direccion: int = 1     
var mover: bool = true
var punto_regreso
var segunda_fase: bool = false
var tween_daño: Tween
var vida_actual: int: set = _setear_vida_actual


func _ready() -> void:
	sonido_risa.play()
	area_2d.set_deferred("monitorable", false)
	area_2d.set_deferred("monitoring", false)

	threshold_alcanzado.connect(_on_threshold_alcanzado)
	boss_destruido.connect(_on_boss_destruido)
	vida_actual = vida_maxima

func _physics_process(delta: float) -> void:
	if !en_pantalla:
		entrar_pantalla(delta)
	else:
		mover_path(delta)

func mover_path(delta: float) -> void:
	if !mover: return
	var nuevo_valor = path_follow_2d.progress_ratio + velocidad * delta * direccion
	set_progress_ratio(nuevo_valor)
	if is_equal_approx(path_follow_2d.progress_ratio, 1.0):
		direccion = -1
		completo_recorrido.emit()

	elif path_follow_2d.progress_ratio <= 0.0:
		direccion = 1
		comenzo_recorrido.emit()

func set_progress_ratio(valor: float) -> void:
	pass

func atacar() -> void:
	pass

func detener_ataque() -> void:pass

func _on_threshold_alcanzado() -> void:
	pass

func entro_en_pantalla() -> void:
	area_2d.set_deferred("monitorable", true)
	area_2d.set_deferred("monitoring", true)
	
	en_pantalla = true


func ejecutar_animacion_daño() -> void:
	if tween_daño:
		tween_daño.kill()

	tween_daño = create_tween()

	for i in cantidad_parpadeos:
		tween_daño.tween_property(
			self,
			"sprite_2d:modulate",
			Color.RED,
			duracion_parpadeo
		)

		tween_daño.tween_property(
			self,
			"sprite_2d:modulate",
			Color.WHITE,
			duracion_parpadeo
		)


func salio_pantalla() -> void:
	en_pantalla = false

func recibir_daño(daño:int = 1) -> void:
	_setear_vida_actual(-daño)
	ejecutar_animacion_daño()

func _setear_vida_actual(cantidad: int) -> void:
	vida_actual += cantidad
	print(vida_actual)
	if vida_actual <= vida_maxima * 0.5:
		segunda_fase = true
	if vida_actual <= 0:
		#ejecutar animacion de destruccion, luego emitir boss destruido
		boss_destruido.emit()


func entrar_pantalla(delta) -> void:
	position.y += velocidad_de_entrada * delta

func ejecutar_efecto_de_sonido_muerte()-> void:
	if sonido_muerte.stream:
		sonido_muerte.play()

func _on_boss_destruido() -> void:
	#ejecuatar animacion de destruccionee
	sprite_2d.hide()
	ejecutar_efecto_de_sonido_muerte()
	await sonido_muerte.finished
	queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is ProyectilNave:
		recibir_daño()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Nave:
		body.recibir_daño(daño)
