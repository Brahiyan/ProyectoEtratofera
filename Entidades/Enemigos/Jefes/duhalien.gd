extends Jefe

#@onready var rayo_laser: RayCast2D = $PathFollow2D/RayoLaser
@onready var disparar_der: Area2D = $DispararDer
@onready var disparar_izq: Area2D = $DispararIzq
@onready var rayo_laser_2: Area2D = $PathFollow2D/RayoLaser2

const PROYECTIL_DUHALIEN = preload("uid://db12usifrhihm")

var curva_dis_mov: Curve2D
var emitio_comienzo_recorrido: bool = false
var emitio_final_recorrido : bool = false
var modo_carga: bool = false


var patron_mov_inicial
var proximo_ataque_es_carga: bool = false

func _ready() -> void:
	super()
	punto_regreso = curve.get_point_position(0)
	curva_dis_mov = curve.duplicate()
	timer_disparo.connect("timeout",_on_timer_disparo_timeout)

func _physics_process(delta: float) -> void:
	super(delta)


func set_progress_ratio(valor: float) -> void:
	super(valor)
	path_follow_2d.progress_ratio = clamp(valor, 0.0, 1.0)

func atacar() -> void:
	if atacando: return
	match fase_de_ataque:

		FASE_DE_ATAQUE.ATAQUE_PRIMERA_FASE:
			ataque_laser()

		FASE_DE_ATAQUE.ATAQUE_SEGUNDA_FASE:
			ataque_carga()

func ataque_laser() -> void:
	curve = curva_dis_mov
	atacando = true
	rayo_laser_2.activar_laser()
	await rayo_laser_2.termino_disparar
	
	detener_ataque()

func ataque_carga() -> void:
	# Acá iría animación de anticipación
	atacando = true
	velocidad = 0.4
	desactivar_threshold()
	crear_curva_carga()
	await completo_recorrido
	detener_ataque()
	activar_threshold()
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
			fase_de_ataque = FASE_DE_ATAQUE.ATAQUE_PRIMERA_FASE
		else:
			fase_de_ataque = FASE_DE_ATAQUE.ATAQUE_SEGUNDA_FASE

func desactivar_threshold()-> void:
	disparar_der.set_deferred("monitorable",false)
	disparar_der.set_deferred("monitoring",false)
	disparar_izq.set_deferred("monitorable",false)
	disparar_izq.set_deferred("monitoring",false)

func disparar_proyectil() -> void:
	if nave_ref:
		var inst_proyectil = PROYECTIL_DUHALIEN.instantiate()
		inst_proyectil.global_position = path_follow_2d.position
		add_child(inst_proyectil)
		inst_proyectil.direccion =  path_follow_2d.global_position.direction_to(nave_ref.global_position)

func activar_threshold() -> void:
	disparar_der.set_deferred("monitorable",true)
	disparar_der.set_deferred("monitoring",true)
	disparar_izq.set_deferred("monitorable",true)
	disparar_izq.set_deferred("monitoring",true)


func _on_area_2d_body_shape_entered(_body_rid: RID,body: Node2D,_body_shape_index: int,_local_shape_index: int) -> void:
	if body is Nave:
		body.recibir_daño(daño)

func _on_disparar_izq_area_entered(area: Area2D) -> void:
	if direccion == -1:
		atacar()

func _on_disparar_der_area_entered(area: Area2D) -> void:
	if direccion == 1:
		atacar()

func _on_cargar_area_entered(area: Area2D) -> void:
	if proximo_ataque_es_carga:
		atacar()


func _on_rayo_laser_2_body_entered(body: Node2D) -> void:
	if body is Nave:
		body.recibir_daño(daño)

func _on_timer_disparo_timeout() -> void:
	disparar_proyectil()
