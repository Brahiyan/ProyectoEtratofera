class_name Nave extends CharacterBody2D

enum Estados {
	QUIETO,
	ASCENDIENDO,
	ESPACIO,
	DESCENDIENDO
}

const NAVE_PARACAIDAS = preload("uid://cbw0sgkgxrv0q")
const PROYECTIL_NAVE = preload("uid://dm881hqrw7mpd")

const vida_maxima: int = 10
@export var vida: int = 10:
	set(nuevo_valor):
		
		vida = clampi(nuevo_valor, 0, vida_maxima)
		cambio_vida.emit(vida)
		if vida <= 0:
			destruir_nave()


@export_group("Velocidad")
@export var fuerza_propulsion: int = 100 #La velocidad con la que "sube"
@export var velocidad_maxima: float = 900.0 # Un tope a la velocidad
@export var velocidad_horizontal: float = 500.0 #La velocidad con la que se mueve horizontament
@export var velocidad_maxima_turbo: float = 1200 # El empuje que da el powerup de boost
@export var velocidad_descenso: float = 3000
@export_group("Combustible")
@export var combustible_maximo: float = 100.0
@export var consumo_combustible: float = 0.05 #la cantidad de combustible que consume por frame

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_2d: Camera2D = $Camera2D
@onready var cd_disparo: Timer = $CDDisparo
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var bolohada: Sprite2D = $Path2D/PathFollow2D/Bolohada
@onready var marker_2d: Marker2D = $Marker2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sonido_disparo: AudioStreamPlayer = $SonidoDisparo
@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D



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
var estado: Estados = Estados.QUIETO

#booleanos
var despego: bool = false
@export var invunerable: bool = false
var llego_zona_intermedia: bool = false
var escudo_activo: bool = false
var aterrizo: bool = false


signal aterrizado
signal cambio_altura(nueva_altura)
signal combustible_cambiado(nuevo_combustible)
signal cambio_vida(nueva_vida)
signal en_descenso
signal en_espacio
signal ha_despegado
signal murio
signal perdio_paracaidas
signal velocidad_cambiada(nueva_velocidad)

func _ready():
	altura_inicial = position.y
	combustible = combustible_maximo
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

func _physics_process(delta):
	path_follow_2d.progress += 600 * delta
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
	gestionar_movimiento(delta)
	
	move_and_slide()


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
				pass
				movimiento_descenso(delta)
			
func movimiento_espacio(delta: float) -> void:
	velocidad_actual = move_toward(velocidad_actual,-velocidad_maxima,fuerza_propulsion*delta)

func movimiento_descenso(delta: float) -> void:
	velocidad_actual = move_toward(velocidad_actual,velocidad_descenso,fuerza_propulsion*delta)

func movimiento_ascenso(delta: float) -> void:
	if combustible <= 0:
		altura = position.y
		calcular_altura()
		
		velocidad_actual = move_toward(velocidad_actual,velocidad_maxima,fuerza_propulsion*delta)
		if velocidad_actual >= velocidad_maxima:
			await get_tree().create_timer(10.0).timeout
			destruir_nave()
	else:
		altura = position.y
		calcular_altura()
		velocidad_actual = move_toward(velocidad_actual,-velocidad_maxima,fuerza_propulsion*delta)


#func mover_horizontal() -> void:
	#if Input.is_action_pressed("DERECHA"):
		#velocity.x = Vector2.RIGHT.x * velocidad_horizontal
	#elif Input.is_action_pressed("IZQUIERDA"):
		#velocity.x = Vector2.LEFT.x * velocidad_horizontal
	#else: velocity.x = Vector2.ZERO.x

func mover_horizontal() -> void:
	var suavizado := 8.0
	var direccion = Input.get_axis("IZQUIERDA", "DERECHA")
	var objetivo = direccion * velocidad_horizontal

	velocity.x += (
		objetivo - velocity.x
	) * suavizado * get_physics_process_delta_time()

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


func aumentar_vida(cantidad: int) -> void:
	vida += cantidad
	print(vida)

func reducir_velocidad(cantidad: float = 200):
	if not despego or estado == Estados.ESPACIO: return
	if combustible <= 0: 
		return
	if estado == Estados.DESCENDIENDO:
		quitar_combustible(consumo_combustible)
		velocidad_actual += -50
		return
	velocidad_actual = move_toward(velocidad_actual, 0, cantidad)
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
	
	if invunerable: return
	else: 
		vida -= daño
		activar_invuneravilidad()

func activar_invuneravilidad() -> void:
	invunerable = true
	animation_player.play("invunerable")

func desactivar_escudo() -> void:
	if escudo_activo: 
		escudo_activo = false
		bolohada.hide()

func disparar_proyectil() -> void:
	if !cd_disparo.is_stopped(): return
	cd_disparo.start()
	var instancia_proyectil = PROYECTIL_NAVE.instantiate()
	get_parent().add_child(instancia_proyectil)
	instancia_proyectil.position = marker_2d.global_position
	sonido_disparo.play()

func cambiar_estado_espacio()-> void:
	if estado == Estados.ASCENDIENDO:
		en_espacio.emit()
		estado = Estados.ESPACIO

func cambiar_estado_descenso()-> void:
	pass
	#if estado == Estados.ESPACIO:
		#sprite_2d.rotate(deg_to_rad(180))
		#en_descenso.emit()
		#estado = Estados.DESCENDIENDO

func destruir_nave() -> void:
	frenar_en_seco()
	murio.emit()
	despego = false

func aterrizar_nave() -> void:
	frenar_en_seco()
	aterrizado.emit()
	aterrizo = true


func _on_murio() -> void:
	#ejecuatar animacion de destruccion
	#queue_free()
	pass
