class_name EnemigoZigZag
extends Enemigo
#tiene un patron de movimiento, ademas tiene su propio proyectil
#que es lento y luego de x tiempo explota, haciendo daño a todas
#las entidades

@export var amplitud_zigzag: float = 150.0
@export var duracion_zigzag: float = 1.0
@export var escena_explosivo: PackedScene

var posicion_x_inicial: float
var tween_zigzag: Tween


func _inicializar():
	posicion_x_inicial = global_position.x
	
	iniciar_zigzag()
	
	if timer_disparo:
		timer_disparo.start()


func iniciar_zigzag():
	tween_zigzag = create_tween()
	tween_zigzag.set_loops()

	tween_zigzag.tween_property(
		self,
		"global_position:x",
		posicion_x_inicial + amplitud_zigzag,
		duracion_zigzag
	).set_trans(Tween.TRANS_SINE)

	tween_zigzag.tween_property(
		self,
		"global_position:x",
		posicion_x_inicial - amplitud_zigzag,
		duracion_zigzag * 2
	).set_trans(Tween.TRANS_SINE)

	tween_zigzag.tween_property(
		self,
		"global_position:x",
		posicion_x_inicial,
		duracion_zigzag
	).set_trans(Tween.TRANS_SINE)


func _movimiento(delta):
	velocity.y = velocidad


func _atacar():
	if escena_explosivo == null:
		return
	
	var explosivo = escena_explosivo.instantiate()
	get_tree().current_scene.add_child(explosivo)

	explosivo.global_position = global_position
