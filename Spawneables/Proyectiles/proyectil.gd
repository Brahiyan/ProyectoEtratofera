class_name Proyectil extends Area2D

@export var velocidad: float = 500

@onready var direccion: Vector2 = Vector2.UP

func _physics_process(delta: float) -> void:
	position += direccion * velocidad * delta

func _on_area_entered(_area: Area2D) -> void:
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Nave:
		body.recibir_daño()
		queue_free()
