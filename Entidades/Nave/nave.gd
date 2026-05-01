class_name Nave extends CharacterBody2D

enum Estados {
	QUIETO,
	ASCENDIENDO,
	ESPACIO,
	DESCENDIENDO,
	PARACAIDAS
}

const NAVE_PARACAIDAS = preload("uid://cbw0sgkgxrv0q")
const PROYECTIL_NAVE = preload("uid://dm881hqrw7mpd")

@export var vida: int = 5:
	set(nuevo_valor):
		vida = nuevo_valor
		cambio_vida.emit(vida)
		if vida <= 0:
			destruir_nave()
@export_group("Velocidad")
@export var fuerza_propulsion: int = 100 #La velocidad con la que "sube"
@export var velocidad_maxima: float = 900.0 # Un tope a la velocidad
@export var velocidad_horizontal: float = 500.0 #La velocidad con la que se mueve horizontament
@export var velocidad_maxima_turbo: float = 1500 # El empuje que da el powerup de boost
@export var velocidad_descenso: float = 3000
@export_group("Combustible")
@export var combustible_maximo: float = 100.0
@export var consumo_combustible: float = 0.07 #la cantidad de combustible que consume por frame

@onready var marker_2d: Marker2D = $Marker2D
@onready var camera_2d: Camera2D = $Camera2D
@onready var bolohada: Sprite2D = $Bolohada
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D


var altura_inicial: float
var altura: float :
	set(value):
		altura = value
		cambio_altura.emit(altura)
var combustible: float 
var velocidad_actual: float:
	set(new_value):
		velocidad_actual = new_value
		velocidad_cambiada.emit(velocidad_actual)
var direccion: float
var tiempo_acumulado: float = 0.0
var estado: Estados = Estados.QUIETO
var paracaidas_a_agarrar: int = 3
var paracaidas_agarrados: int = 0:
	set(nuevo_valor):
		paracaidas_agarrados = nuevo_valor
		agarro_paracaida.emit()
		if paracaidas_agarrados >= paracaidas_a_agarrar:
			agarro_todos_paracaidas.emit()

#booleanos
var despego: bool = false
var llego_zona_intermedia: bool = false
var escudo_activo: bool = false
var aterrizo: bool = false

signal agarro_todos_paracaidas
signal agarro_paracaida
signal aterrizado
signal cambio_altura(nueva_altura)
signal combustible_cambiado(nuevo_combustible)
signal cambio_vida(nueva_vida)
signal en_descenso
signal en_espacio
signal ha_despegado
signal murio
signal tiempo_actualizado(tiempo_total)
signal velocidad_cambiada(nueva_velocidad)

func _ready():
	altura_inicial = position.y
	combustible = 100
	camera_2d.zoom = Vector2(.5,.5)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ENTER"):
		if despego != true:
			despego = true
			estado = Estados.ASCENDIENDO
			ha_despegado.emit()
	if !aterrizo:
		if event.is_action_released("FRENAR"):
			reducir_velocidad()
		if event.is_action_pressed("DISPARAR"):
			disparar_proyectil()
		
		if event.is_action_pressed("ABRIR_PARACAIDAS"):
			cambiar_estado_abrir_paracaidas()

func _physics_process(delta):
	if !despego:
		return

	if Input.is_action_pressed("SUBIR"):
		mover_arriba()
	elif Input.is_action_pressed("BAJAR"):
		mover_abajo()
	else:
		velocity.y = 0
	calcular_altura()
	mover_horizontal()
	acumular_tiempo(delta)
# El tiempo lo debe manejar el gestor de juego.
	gestionar_movimiento(delta)
	#velocity.x = move_toward(velocity.x,0, 100*delta)
	
	move_and_slide()

func acumular_tiempo(delta: float) -> void:
	if aterrizo: return
	tiempo_acumulado += delta
	tiempo_actualizado.emit(tiempo_acumulado)

func gestionar_movimiento(delta):
	if !aterrizo:
		match estado:
			Estados.QUIETO:
				pass
	
			Estados.ASCENDIENDO:
				movimiento_ascenso(delta)
				quitar_combustible(consumo_combustible)
	
			Estados.ESPACIO:
				movimiento_espacio(delta)
	
			Estados.DESCENDIENDO:
				movimiento_descenso(delta)
			
			Estados.PARACAIDAS:
				movimiento_paracaidas(delta)

func movimiento_espacio(delta: float) -> void:
	velocidad_actual = move_toward(velocidad_actual,-velocidad_maxima,fuerza_propulsion*delta)
	#velocity.y = move_toward(velocity.y,-velocidad_maxima, fuerza_propulsion*delta)

func movimiento_descenso(delta: float) -> void:
	#aca tiene que ir una variable con la velocidad de caida.
	velocidad_actual = move_toward(velocidad_actual,velocidad_descenso,fuerza_propulsion*delta)
	#velocity.y = move_toward(velocity.y,velocidad_maxima, fuerza_propulsion*delta)

func movimiento_ascenso(delta: float) -> void:
	if combustible <= 0:
		altura = position.y
		calcular_altura()
		velocidad_actual = move_toward(velocidad_actual,velocidad_maxima,fuerza_propulsion*delta)
	else:
		altura = position.y
		calcular_altura()
		velocidad_actual = move_toward(velocidad_actual,-velocidad_maxima,fuerza_propulsion*delta)

func movimiento_paracaidas(delta:float) -> void:
	velocidad_actual = move_toward(velocidad_actual,450,200*delta)

func mover_horizontal() -> void:
	if Input.is_action_pressed("DERECHA"):
		velocity.x = Vector2.RIGHT.x * velocidad_horizontal
	elif Input.is_action_pressed("IZQUIERDA"):
		velocity.x = Vector2.LEFT.x * velocidad_horizontal
	else: velocity.x = Vector2.ZERO.x

	#velocity.x = Input.get_axis("IZQUIERDA","DERECHA") * velocidad_horizontal

func mover_arriba() -> void:
	if estado == Estados.ASCENDIENDO or estado == Estados.DESCENDIENDO: return 
	velocity.y = -fuerza_propulsion * 2.7

func mover_abajo() -> void:
	if estado == Estados.ASCENDIENDO or estado == Estados.DESCENDIENDO: return 
	velocity.y = fuerza_propulsion * 2.7

func aumentar_velocidad(_cantidad: float):
	if not despego: return
	velocidad_actual = -velocidad_maxima_turbo
	velocidad_cambiada.emit(velocidad_actual)

func aumentar_paracaidas() -> void:
	paracaidas_agarrados += 1

func reducir_velocidad():
	if not despego or estado == Estados.PARACAIDAS or estado == Estados.ESPACIO: return
	if combustible <= 0: 
		return
	if estado == Estados.DESCENDIENDO:
		quitar_combustible(consumo_combustible)
		velocidad_actual += -50
		return
	velocidad_actual = move_toward(velocidad_actual, 0, 200)
	velocidad_cambiada.emit(velocidad_actual)

func agregar_combustible(cantidad: float):
	if not despego: return
	combustible += cantidad
	combustible = min(combustible_maximo, combustible)
	combustible_cambiado.emit(combustible)

func quitar_combustible(cantidad: float):
	if not despego: return
	combustible -= cantidad
	combustible = max(0, combustible)
	combustible_cambiado.emit(combustible)

func activar_escudo() -> void:
	escudo_activo = true
	bolohada.show()

func frenar_en_seco() ->void:
	velocidad_actual = 0
	#velocidad_actual = move_toward(velocidad_actual,0, 500)

func calcular_altura() ->void:
	altura = altura_inicial - altura

func recibir_daño(daño: int = 1) -> void:
	if escudo_activo: 
		desactivar_escudo()
		#remover animacion de escudo
		return
	vida -= daño

func desactivar_escudo() -> void:
	if escudo_activo: 
		escudo_activo = false
		bolohada.hide()

func disparar_proyectil() -> void:
	var instancia_proyectil = PROYECTIL_NAVE.instantiate()
	get_parent().add_child(instancia_proyectil)
	instancia_proyectil.position = marker_2d.global_position

func cambiar_estado_espacio()-> void:
	if estado == Estados.ASCENDIENDO:
		en_espacio.emit()
		estado = Estados.ESPACIO

func cambiar_estado_descenso()-> void:
	if estado == Estados.ESPACIO:
		sprite_2d.rotate(deg_to_rad(180))
		en_descenso.emit()
		estado = Estados.DESCENDIENDO

func cambiar_estado_abrir_paracaidas() -> void:
	if estado == Estados.DESCENDIENDO:
		sprite_2d.rotate(deg_to_rad(180))
		sprite_2d.texture = NAVE_PARACAIDAS
		estado = Estados.PARACAIDAS

func destruir_nave() -> void:
	frenar_en_seco()
	murio.emit()
	despego = false
	aterrizo = true

func aterrizar_nave() -> void:
	frenar_en_seco()
	aterrizado.emit()
	aterrizo = true


func _on_murio() -> void:
	#ejecuatar animacion de destruccion
	#queue_free()
	pass
