extends Jefe

@onready var rayo_laser: RayCast2D = $PathFollow2D/RayoLaser

@onready var fase_de_ataque: FASE_DE_ATAQUE = FASE_DE_ATAQUE.DISPARO_MOVIMIENTO

enum FASE_DE_ATAQUE{
	DISPARO_MOVIMIENTO,
	DISPARO_QUIETO,
	CARGA,
	RECUPERACION
}

signal comenzo_recorrido
signal completo_recorrido

var curva_dis_mov: Curve2D

var emitio_comienzo_recorrido: bool = false
var emitio_final_recorrido : bool = false

var mover: bool = true
var modo_carga: bool = false

var punto_regreso
var patron_mov_inicial
var proximo_ataque_es_carga: bool = false
var segunda_fase: bool = false

func _ready() -> void:
	super()
	punto_regreso = curve.get_point_position(0)
	rayo_laser.comenzo_disparar.connect(_on_rayo_comenzo_disparar)
	rayo_laser.termino_disparar.connect(_on_rayo_termino_disparar)
	curva_dis_mov = curve.duplicate()

func _physics_process(delta: float) -> void:
	super(delta)

func mover_path(delta: float) -> void:
	if !mover: return
	var nuevo_valor = path_follow_2d.progress_ratio + velocidad * delta * direccion
	set_progress_ratio(nuevo_valor)
	if is_equal_approx(path_follow_2d.progress_ratio, 1.0):
		direccion = -1
		completo_recorrido.emit()
	#if path_follow_2d.progress_ratio >= 1.0:
		#direccion = -1
		#completo_recorrido.emit()

	elif path_follow_2d.progress_ratio <= 0.0:
		direccion = 1
		comenzo_recorrido.emit()

func set_progress_ratio(valor: float) -> void:
	super(valor)
	path_follow_2d.progress_ratio = clamp(valor, 0.0, 1.0)

func atacar() -> void:
	if atacando: return
	match fase_de_ataque:

		FASE_DE_ATAQUE.DISPARO_MOVIMIENTO:
			ataque_laser()

		FASE_DE_ATAQUE.CARGA:
			ataque_carga()

		FASE_DE_ATAQUE.DISPARO_QUIETO:
			pass

func ataque_laser() -> void:
	curve = curva_dis_mov
	atacando = true
	rayo_laser.activar_laser()
	await rayo_laser.termino_disparar
	detener_ataque()

func ataque_carga() -> void:
	# Acá iría animación de anticipación
	atacando = true
	velocidad = 0.4
	crear_curva_carga()
	await completo_recorrido
	detener_ataque()
	velocidad = 0.15
	path_follow_2d.progress_ratio = 0.0
	curve = curva_dis_mov
	fase_de_ataque = FASE_DE_ATAQUE.DISPARO_MOVIMIENTO

func crear_curva_carga() -> void:
	var nueva_curva := Curve2D.new()
	var inicio = to_local(path_follow_2d.global_position)
	var destino = to_local(nave_ref.global_position)
	nueva_curva.add_point(inicio)
	nueva_curva.add_point(destino)
	nueva_curva.add_point(punto_regreso)
	curve = nueva_curva
	path_follow_2d.progress_ratio = 0.0
	direccion = 1

func detener_ataque() -> void:
	atacando = false
	if segunda_fase:
		proximo_ataque_es_carga = !proximo_ataque_es_carga
		if proximo_ataque_es_carga:
			fase_de_ataque = FASE_DE_ATAQUE.CARGA
		else:
			fase_de_ataque = FASE_DE_ATAQUE.DISPARO_MOVIMIENTO

func _setear_vida_actual(cantidad: int) -> void:
	super(cantidad)
	if vida_actual <= vida_maxima * 0.5:
		segunda_fase = true

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Proyectil:
		recibir_daño()

func _on_rayo_termino_disparar() -> void:
	if fase_de_ataque == FASE_DE_ATAQUE.DISPARO_QUIETO:
		mover = true

func _on_rayo_comenzo_disparar() -> void:
	if fase_de_ataque == FASE_DE_ATAQUE.DISPARO_QUIETO:
		mover = false

func _on_area_2d_body_shape_entered(_body_rid: RID,body: Node2D,_body_shape_index: int,_local_shape_index: int) -> void:
	if body is Nave:
		body.recibir_daño()

func _on_disparar_izq_area_entered(area: Area2D) -> void:
	if direccion == -1:
		atacar()

func _on_disparar_der_area_entered(area: Area2D) -> void:
	if direccion == 1:
		atacar()

func _on_cargar_area_entered(area: Area2D) -> void:
	if proximo_ataque_es_carga:
		atacar()
