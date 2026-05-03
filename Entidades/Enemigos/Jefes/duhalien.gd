extends Jefe


@onready var rayo_laser: RayCast2D = $PathFollow2D/RayoLaser


func mover_path(delta: float) -> void:
	#path_follow_2d.progress_ratio += velocidad * delta * direccion
	#if path_follow_2d.progress_ratio >= 1.0:
		#path_follow_2d.progress_ratio = 1.0
		#direccion = -1
		#atacando = false  
	#elif path_follow_2d.progress_ratio <= 0.0:
		#path_follow_2d.progress_ratio = 0.0
		#direccion = 1
	var nuevo = path_follow_2d.progress_ratio + velocidad * delta * direccion
	set_progress_ratio(nuevo)

	if path_follow_2d.progress_ratio >= 1.0:
		direccion = -1
		atacando = false

	elif path_follow_2d.progress_ratio <= 0.0:
		direccion = 1

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
	atacar()
