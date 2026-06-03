extends Proyectil

@export var vida: float = 2
@export var tiempo_explosion: float = 2.0
@export var velocidad_parpadeo: float = 0.15

@onready var area_explosion: Area2D = $AreaExplosion
@onready var timer: Timer = $Timer
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $AreaExplosion/CollisionShape2D
@onready var animacion_explosion: AnimatedSprite2D = $AnimacionExplosion

var tween_parpadeo: Tween


func _ready() -> void:
	#area_explosion.monitorable = false
	#area_explosion.monitoring = false
	timer.wait_time = tiempo_explosion
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	
	iniciar_parpadeo()
	direccion = Vector2.DOWN

func _physics_process(delta: float) -> void:
	super(delta)
	velocidad = move_toward(velocidad, 0, 2)
	velocidad_parpadeo = timer.time_left

func iniciar_parpadeo() -> void:
	tween_parpadeo = create_tween()
	tween_parpadeo.set_loops()

	tween_parpadeo.tween_property(
		sprite,
		"modulate",
		Color.RED,
		velocidad_parpadeo
	)

	tween_parpadeo.tween_property(
		sprite,
		"modulate",
		Color.WHITE,
		velocidad_parpadeo
	)

func reducir_vida(cantidad: int = 1) -> void:
	vida -= cantidad
	
	if vida <= 0:
		explotar()

func explotar() -> void:
	if tween_parpadeo:
		tween_parpadeo.kill()
	sprite.hide()
	animacion_explosion.show()
	animacion_explosion.play("Animacion_Explosion")
	#set_deferred("area_explosion:monitoring",true)
	#set_deferred("area_explosion:monitorable",true)
	
	var tween: Tween = create_tween()
	tween.tween_property(collision_shape_2d.shape,"radius",135,0.3)
	
	
	await tween.finished
	await get_tree().process_frame

	queue_free()

func _on_timer_timeout() -> void:
	explotar()

func _on_area_entered(area: Area2D) -> void:
	if area is Proyectil:
		reducir_vida()
