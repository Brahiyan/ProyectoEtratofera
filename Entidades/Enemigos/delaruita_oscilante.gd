extends Enemigo
class_name EnemigoOscilador

@export var distancia_movimiento: float = 700.0 # La cantidad de pixeles que se mueve por la pantalla
@export var duracion_mov: float = 2.0 # Esto es lo que tarda en hacer el movimiento
@export var tiempo_espera: float = 0.5 #esto es lo que tarda en arrancar el movimiento para el lado opuesto
@export var amplitud_vertical: float = 150.0
@export var proyectil: PackedScene

var tween: Tween
var spawn_x: float
var posicion_inicial: Vector2
var en_punto_a: bool = true 


func _physics_process(delta):
	super(delta)
	chequear_raycast()

func _inicializar():
	spawn_x =global_position.x
	posicion_inicial = global_position

func _iniciar_oscilacion():
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	
	var destino_x = spawn_x + (distancia_movimiento if en_punto_a else -distancia_movimiento)
	var destino_y = position.y + (amplitud_vertical)
	
	
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:x", destino_x, duracion_mov)
	tween.tween_property(self, "position:y", destino_y, duracion_mov)
	tween.tween_interval(0.1)
	tween.tween_callback(_cambiar_destino)

func _cambiar_destino():
	en_punto_a = !en_punto_a  
	_iniciar_oscilacion()


func _atacar():
	if nave_ref and proyectil and timer_disparo.is_stopped():
		var p = proyectil.instantiate()
		p.global_position = position
		get_parent().add_child(p)
		p.direccion = global_position.direction_to(nave_ref.global_position)
		
		timer_disparo.start()
