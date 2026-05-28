class_name Enemigo extends CharacterBody2D


signal enemigo_muerto
@export var cantidad_parpadeos: int = 4
@export var duracion_parpadeo: float = 0.1
@export var velocidad_ataque: float = 500.0
@export var velocidad: float = 300.0 # la velocidad con la que se desplaza hacia abajo
@export var vida_maxima: int = 3 
@export var daño: int = 1 #El daño que le hace a la nave


@onready var animacion_explosion: AnimatedSprite2D = $AnimacionExplosion
@onready var sprite: Sprite2D = $Sprite2D
@onready var timer_disparo: Timer = $TimerDisparo
@onready var area_golpe: Area2D = $AreaGolpe
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var sonido_muerte: AudioStreamPlayer = $SonidoMuerte

var atacando: bool
var direccion: Vector2 = Vector2.ZERO
var en_pantalla: bool = false
var nave_ref: Node2D = null
var tween_daño: Tween
var vida_actual: int

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
	ejecutar_animacion_daño()
	if vida_actual <= 0:
		morir()

func morir():
	enemigo_muerto.emit()
	animacion_explosion.show()
	animacion_explosion.play("Animacion_Explosion")
	ejecutar_efecto_de_sonido_muerte()
	area_golpe.set_deferred("monitorable", false)
	area_golpe.set_deferred("monitoring", false)
	sprite.hide()
	await sonido_muerte.finished
	queue_free()


func ejecutar_efecto_de_sonido_muerte() -> void:
	if sonido_muerte.stream:
		sonido_muerte.play()

func _on_nave_entra_golpe(body: Node2D):
	if body is Nave or body is Proyectil:
		self.recibir_daño()
		body.recibir_daño(daño)


func _physics_process(delta):
	entrar_pantalla()
	_movimiento(delta)
	move_and_slide()


func ejecutar_animacion_daño() -> void:
	if tween_daño:
		tween_daño.kill()

	tween_daño = create_tween()

	for i in cantidad_parpadeos:
		tween_daño.tween_property(
			self,
			"sprite:modulate",
			Color.RED,
			duracion_parpadeo
		)

		tween_daño.tween_property(
			self,
			"sprite:modulate",
			Color.WHITE,
			duracion_parpadeo
		)

func entrar_pantalla() -> void:
	if !en_pantalla:
		velocity.y = velocidad
	else:
		velocity.y = Vector2.ZERO.y

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	en_pantalla = true
	area_golpe.collision_mask = 16 | 1 #16 es la cara 5 en el bitmap.

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	en_pantalla = false
	if global_position.y > nave_ref.global_position.y +200:
		queue_free()


func _on_area_golpe_area_entered(area: Area2D) -> void:
	if area is ProyectilNave:
		recibir_daño()


func _on_timer_disparo_timeout() -> void:
	pass # Replace with function body.
