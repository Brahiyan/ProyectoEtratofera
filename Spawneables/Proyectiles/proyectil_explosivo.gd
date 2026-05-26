extends Proyectil

@export var vida: float = 2
@export var tiempo_explosion: float = 2.0
@export var velocidad_parpadeo: float = 0.15

@onready var area_explosion: Area2D = $AreaExplosion
@onready var timer: Timer = $Timer
@onready var sprite: Sprite2D = $Sprite2D

var tween_parpadeo: Tween


func _ready() -> void:
	area_explosion.monitorable = false
	area_explosion.monitoring = false
	timer.wait_time = tiempo_explosion
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	
	iniciar_parpadeo()
	direccion = Vector2.DOWN

func _physics_process(delta: float) -> void:
	super(delta)
	velocidad = move_toward(velocidad, 0, 3)
	

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
	set_deferred("area_explosion:monitoring",true)
	set_deferred("area_explosion:monitorable",true)
	
	sprite.hide()
	await get_tree().process_frame

	queue_free()

func _on_timer_timeout() -> void:
	explotar()

func _on_area_entered(area: Area2D) -> void:
	if area is Proyectil:
		reducir_vida()
