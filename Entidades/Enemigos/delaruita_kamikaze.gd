extends Enemigo

var direccion_vector: Vector2 = Vector2.ZERO
#TIENE QUE IR MAS RÁpido a la nave

func _physics_process(delta: float) -> void:
	if !en_pantalla:
		entrar_pantalla()
	elif atacando:
		mover_hacia_player(delta)
	else:
		_movimiento(delta)
	move_and_slide()

func _movimiento(_delta: float):
	velocity = Vector2.DOWN * velocidad

func calcular_direccion() -> void:
	if nave_ref:
		direccion_vector = (nave_ref.global_position - global_position).normalized()

func _on_area_deteccion_body_entered(body: Node2D) -> void:
	if body is Nave:
		calcular_direccion()
		atacando = true

func _on_area_golpe_body_entered(body: Node2D) -> void:
	if body is Nave:
		print("¡Impacto!")
		body.recibir_daño(daño)
		queue_free() # o animación de choque

func mover_hacia_player(delta: float) -> void:
	velocity += direccion_vector * velocidad_ataque * delta
