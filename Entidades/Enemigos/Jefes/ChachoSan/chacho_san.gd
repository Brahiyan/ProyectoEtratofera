extends Jefe


const PROYECTIL_CHACHO_SAN = preload("uid://beybop6whtirw")
const CURVA_ATAQUE_ZIG_ZAG = preload("uid://dhjbwfk64psyb")
const CURVA_ATAQUE_INICIAL = preload("uid://bcckwkx61ufxn")

var curva_inicial
var proximo_ataque_es_zig_zag: bool = false


func _ready() -> void:
	super()
	global_position.x = -1000
	timer_disparo.connect("timeout", _on_timer_disparo_timeout)
	curva_inicial = curve.duplicate()
	fase_de_ataque = FASE_DE_ATAQUE.ATAQUE_PRIMERA_FASE

func _physics_process(delta: float) -> void:
	super(delta)

func atacar() -> void:
	match fase_de_ataque:
		FASE_DE_ATAQUE.ATAQUE_PRIMERA_FASE:
			ataque_disparo()

		FASE_DE_ATAQUE.ATAQUE_SEGUNDA_FASE:
			ataque_zig_zag()


func cambiar_curva_a_zig_zag() -> void:
	if !nave_ref:
		return

	var nueva_curva: Curve2D = CURVA_ATAQUE_ZIG_ZAG.duplicate()

	# POSICION ACTUAL DEL BOSS
	var inicio = to_local(path_follow_2d.global_position)

	# MISMA X DEL BOSS, Y DE LA NAVE
	var altura_nave = to_local(Vector2(path_follow_2d.global_position.x, nave_ref.global_position.y))

	# INSERTAMOS LOS DOS PUNTOS AL INICIO
	nueva_curva.add_point(inicio, Vector2.ZERO, Vector2.ZERO, 0)
	nueva_curva.add_point(altura_nave, Vector2.ZERO, Vector2.ZERO, 1)

	# DESPLAZAMOS EL RESTO DE LA CURVA
	var punto_original = nueva_curva.get_point_position(2)
	var offset = altura_nave - punto_original

	for i in range(2, nueva_curva.point_count):
		var punto = nueva_curva.get_point_position(i)
		nueva_curva.set_point_position(i, punto + offset)

	curve = nueva_curva

	velocidad = 0.2
	path_follow_2d.progress_ratio = 0.0
	direccion = 1

func cambiar_curva_a_inicial() -> void:
	var nueva_curva: Curve2D = CURVA_ATAQUE_INICIAL.duplicate()

	var inicio = to_local(path_follow_2d.global_position)

	# Tomamos el primer punto original
	var primer_punto = nueva_curva.get_point_position(0)

	# Calculamos cuánto mover toda la curva
	var offset = inicio - primer_punto

	# Desplazamos todos los puntos
	for i in nueva_curva.point_count:
		var punto = nueva_curva.get_point_position(i)
		nueva_curva.set_point_position(i, punto + offset)

	atacando = false
	curve = nueva_curva
	velocidad = 0.5
	path_follow_2d.progress_ratio = 0.0
	direccion = 1


func ataque_disparo() -> void:
	if atacando and proximo_ataque_es_zig_zag: return
	var inst_proyectil = PROYECTIL_CHACHO_SAN.instantiate()
	inst_proyectil.global_position = path_follow_2d.position
	add_child(inst_proyectil)
	inst_proyectil.direccion =  Vector2.DOWN

func ataque_zig_zag() -> void:
	if atacando: return
	atacando = true
	await completo_recorrido
	detener_ataque()

func detener_ataque() -> void:
	atacando = false

func entro_en_pantalla() -> void:
	super()
	timer_disparo.start()

func set_progress_ratio(valor: float) -> void:
	super(valor)
	path_follow_2d.progress_ratio = clamp(valor, 0.0, 1.0)

func _on_timer_disparo_timeout() -> void:
	atacar()

func _on_completo_recorrido() -> void:
	print("COMPLETO RECORRIDO")
	if segunda_fase:
		proximo_ataque_es_zig_zag = !proximo_ataque_es_zig_zag


func _on_comenzo_recorrido() -> void:
	if proximo_ataque_es_zig_zag:
			cambiar_curva_a_zig_zag()
			fase_de_ataque = FASE_DE_ATAQUE.ATAQUE_SEGUNDA_FASE
	else:
			cambiar_curva_a_inicial()
			fase_de_ataque = FASE_DE_ATAQUE.ATAQUE_PRIMERA_FASE
	atacar()
