class_name PowerUp extends Area2D

enum TipoPowerUp {
	A_DEFINIR,
	AUMENTAR_COMBUSTIBLE,
	AUMENTAR_VELOCIDAD,
	AUMENTAR_VIDA,
	ESCUDO
	
}

const BOLOHADA = preload("uid://dbv1eju3dhmiw")
const FAJO_DOLARES = preload("uid://dm2txs12clkfq")
const COMBUSTIBLE = preload("uid://bhmlk6j1a4dom")
const VIDA = preload("uid://hn01rqetmh4h")


@export var cantidad: float = 10.0
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sonido_buff: AudioStreamPlayer = $SonidoBuff
@onready var timer: Timer = $Timer
@export var tipo: TipoPowerUp = TipoPowerUp.AUMENTAR_COMBUSTIBLE

var velocidad_caida: float = 0.0
var velocidad_horizontal: float = 50.0
var desciende: bool = true: set = set_desciende
var direccion_x: float 

func _physics_process(delta: float) -> void:
	if desciende:
		movimiento_ascenso(delta)
	else:
		movimiento_espacio(delta)

func _ready():
	definir_tipo()
	definir_imagen()
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is Nave:
		aplicar_efecto(body)
		destruir_powerup()

func set_velocidad_caida(valor: float):
	velocidad_caida = valor

func aplicar_efecto(nave):
	match tipo:
		TipoPowerUp.AUMENTAR_COMBUSTIBLE:
			nave.agregar_combustible(cantidad)
		TipoPowerUp.AUMENTAR_VELOCIDAD:
			nave.aumentar_velocidad(cantidad)
		TipoPowerUp.AUMENTAR_VIDA:
			nave.aumentar_vida(cantidad)
		TipoPowerUp.ESCUDO:
			nave.activar_escudo()

func definir_tipo()-> void:
	if tipo == TipoPowerUp.A_DEFINIR:
		var temp = randi_range(1,TipoPowerUp.size()-1)
		tipo = temp as TipoPowerUp

func definir_imagen() -> void:
	match tipo:
		TipoPowerUp.AUMENTAR_COMBUSTIBLE:
			sprite_2d.texture = COMBUSTIBLE
			sprite_2d.scale = Vector2(0.1,0.1)
		TipoPowerUp.AUMENTAR_VELOCIDAD:
			sprite_2d.texture = FAJO_DOLARES
			sprite_2d.scale = Vector2(0.1,0.1)
		TipoPowerUp.AUMENTAR_VIDA:
			sprite_2d.texture = VIDA
		TipoPowerUp.ESCUDO:
			sprite_2d.texture = BOLOHADA
			sprite_2d.scale = Vector2(0.05,0.05)

func destruir_powerup() -> void:
	sprite_2d.hide()
	ejecutar_efecto_de_sonido()
	await sonido_buff.finished
	queue_free()

func ejecutar_efecto_de_sonido() -> void:
	if sonido_buff.stream:
		sonido_buff.play()

func movimiento_ascenso(delta: float) -> void:
	position.y += -velocidad_caida * delta

func movimiento_espacio(delta:float) -> void:
	position.x += 400 *  direccion_x * delta

func obtener_direccion(posicion_de_spawn: Vector2) -> void:
	if posicion_de_spawn.x < 0:
		direccion_x = 1
	else: direccion_x = -1

func set_desciende(valor:bool) -> void:
	desciende = valor
	if desciende == false:
		randi_range(0,1)
		tipo = [TipoPowerUp.AUMENTAR_VIDA, TipoPowerUp.ESCUDO].pick_random()
		definir_imagen()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
