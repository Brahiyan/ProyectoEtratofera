class_name Jefe extends Path2D

@onready var path_follow_2d: PathFollow2D = $PathFollow2D

@export var velocidad: float = 0.2     
@export var velocidad_de_entrada: float = 600.0     
@export var vida: int = 10: set = _setear_vida
@export var cuando_ataca: Array[float]     
@onready var sonido_muerte: AudioStreamPlayer = $SonidoMuerte

var nave_ref
signal threshold_alcanzado
signal boss_destruido

var direccion: int = 1     
var atacando: bool = false
@onready var en_pantalla: bool = false

func _ready() -> void:
	threshold_alcanzado.connect(_on_threshold_alcanzado)
	boss_destruido.connect(_on_boss_destruido)

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
	print("¡Atacando!")

func _on_threshold_alcanzado() -> void:
	pass

func entro_en_pantalla() -> void:
	en_pantalla = true

func salio_pantalla() -> void:
	en_pantalla = false

func recibir_daño(daño:int = 1) -> void:
	_setear_vida(-daño)

func _setear_vida(cantidad: int) -> void:
	vida += cantidad
	print(vida)
	if vida <= 0:
		#ejecutar animacion de destruccion, luego emitir boss destruido
		boss_destruido.emit()
		pass

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
