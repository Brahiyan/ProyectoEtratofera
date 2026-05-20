class_name Jefe extends Path2D

@onready var path_follow_2d: PathFollow2D = $PathFollow2D

@export var velocidad: float = 0.2     
@export var velocidad_de_entrada: float = 600.0     
@export var vida_maxima: int = 10
@export var cuando_ataca: Array[float]     

@onready var en_pantalla: bool = false
@onready var sonido_muerte: AudioStreamPlayer = $SonidoMuerte

var nave_ref: Nave
signal threshold_alcanzado
signal boss_destruido

var atacando: bool = false
var direccion: int = 1     
var vida_actual: int: set = _setear_vida_actual

func _ready() -> void:
	threshold_alcanzado.connect(_on_threshold_alcanzado)
	boss_destruido.connect(_on_boss_destruido)
	vida_actual = vida_maxima

func _physics_process(delta: float) -> void:
	if !en_pantalla:
		entrar_pantalla(delta)
	else:
		mover_path(delta)

func mover_path(delta: float) -> void:
	pass

func set_progress_ratio(valor: float) -> void:
	pass

func atacar() -> void:
	pass

func _on_threshold_alcanzado() -> void:
	pass

func entro_en_pantalla() -> void:
	en_pantalla = true

func salio_pantalla() -> void:
	en_pantalla = false

func recibir_daño(daño:int = 1) -> void:
	_setear_vida_actual(-daño)

func _setear_vida_actual(cantidad: int) -> void:
	vida_actual += cantidad
	print(vida_actual)
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
	ejecutar_efecto_de_sonido_muerte()
	await sonido_muerte.finished
	queue_free()
	pass
