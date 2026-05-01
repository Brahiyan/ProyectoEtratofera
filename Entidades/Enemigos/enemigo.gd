class_name Enemigo extends CharacterBody2D


signal enemigo_muerto

@export var velocidad: float = 300.0 # la velocidad con la que se desplaza hacia abajo
@export var vida_maxima: int = 3 
@export var daño: int = 1 #El daño que le hace a la nave

@onready var sprite: Sprite2D = $Sprite2D
@onready var timer_disparo: Timer = $TimerDisparo
@onready var area_golpe: Area2D = $AreaGolpe
@onready var ray_cast_2d: RayCast2D = $RayCast2D

var en_pantalla: bool = false
var vida_actual: int
var nave_ref: Node2D = null

func _ready():
	vida_actual = vida_maxima
	_conectar_señales()
	_inicializar()

func _inicializar():
	pass

func _conectar_señales():
	if area_golpe:
		area_golpe.body_entered.connect(_on_nave_entra_golpe)
	if timer_disparo:
		timer_disparo.timeout.connect(_atacar)


func _movimiento(delta: float):
	pass

func _atacar():
	pass

func recibir_daño(cantidad: int = 1):
	vida_actual -= cantidad
	if vida_actual <= 0:
		morir()

func morir():
	enemigo_muerto.emit()
	queue_free()


func _on_nave_entra_golpe(body: Node2D):
	if body is Nave or body is Proyectil:
		self.recibir_daño()
		body.recibir_daño(daño)


func _physics_process(delta):
	entrar_pantalla(delta)
	chequear_raycast()
	_movimiento(delta)
	move_and_slide()

func chequear_raycast() -> void:
	if ray_cast_2d.is_colliding():
		var obj_col = ray_cast_2d.get_collider()
		if obj_col is Nave:
			_atacar()
	elif !ray_cast_2d.is_colliding():
		timer_disparo.stop()
		 

func entrar_pantalla(delta) -> void:
	if !en_pantalla:
		velocity.y = velocidad
	else:
		velocity.y = Vector2.ZERO.y


func _on_area_golpe_area_entered(area: Area2D) -> void:
	if area is Proyectil:
		self.recibir_daño()


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	en_pantalla = true
	area_golpe.collision_mask = 16 #16 es la cara 5 en el bitmap.
