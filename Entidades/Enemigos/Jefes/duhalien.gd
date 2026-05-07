extends Jefe


@onready var rayo_laser: RayCast2D = $PathFollow2D/RayoLaser

func _physics_process(delta: float) -> void:
	super(delta)
	
	pass

func mover_path(delta: float) -> void:
	var nuevo_valor = path_follow_2d.progress_ratio + velocidad * delta * direccion
	set_progress_ratio(nuevo_valor)

	if path_follow_2d.progress_ratio >= 1.0:
		direccion = -1

	elif path_follow_2d.progress_ratio <= 0.0:
		direccion = 1

func set_progress_ratio(valor: float) -> void:
	super(valor)
	path_follow_2d.progress_ratio = clamp(valor, 0.0, 1.0)
	if direccion == 1:
		if snapped(path_follow_2d.progress_ratio,0.1) == cuando_ataca:
			threshold_alcanzado.emit()
	elif direccion == -1:
		if snapped(path_follow_2d.progress_ratio,0.1) == cuando_ataca:
			threshold_alcanzado.emit()

func atacar() -> void:
	super()
	atacando = true
	rayo_laser.activar_laser()
	await get_tree().create_timer(1.5).timeout
	detener_ataque()

func detener_ataque() -> void:
	atacando = false
	rayo_laser.desactivar_laser()

func _on_threshold_alcanzado() -> void:
	super()
	if !atacando:
		atacar()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Proyectil:
		recibir_daño()
