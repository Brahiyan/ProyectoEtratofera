extends Path2D
class_name Obstaculos


enum TipoDebuff {
	VELOCIDAD_MENOS,
	COMBUSTIBLE_MENOS,
	QUITAR_PARACAIDAS
}

@export var cantidad: float = 0.3
@export var cantidad_de_paracaidas: int = 1

@export var tipo: TipoDebuff = TipoDebuff.VELOCIDAD_MENOS
@export var velocidad_path: float = 0.2

@onready var path_follow_2d: PathFollow2D = $PathFollow2D
@onready var sprite_2d: Sprite2D = $PathFollow2D/Sprite2D
@onready var sonido_obstaculo: AudioStreamPlayer = $SonidoObstaculo
@onready var velocidad_caida: float= 0.0

func _ready():
	if global_position.x > 0:
		scale.x = -1

func _physics_process(delta: float) -> void:
	path_follow_2d.progress_ratio += velocidad_path * delta
	position.y += -velocidad_caida * .7  * delta

func _on_body_entered(body):
	if body is Nave:
		aplicar_efecto(body)
		queue_free()

func aplicar_efecto(nave):
	match tipo:
		TipoDebuff.VELOCIDAD_MENOS:
			if nave.escudo_activo:
				nave.desactivar_escudo()
			else:
				nave.reducir_velocidad()
		TipoDebuff.COMBUSTIBLE_MENOS:
			if nave.escudo_activo:
				nave.desactivar_escudo()
			else:
				nave.quitar_combustible(cantidad)
		TipoDebuff.QUITAR_PARACAIDAS:
			nave.quitar_paracaidas()

func set_velocidad_caida(valor: float) -> void:
	velocidad_caida= valor

func _on_area_2d_area_entered(area: Area2D) -> void:
	destruir_obstaculo()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func ejecutar_efecto_de_sonido() -> void:
	if sonido_obstaculo.stream:
		sonido_obstaculo.play()

func destruir_obstaculo() -> void:
	sprite_2d.hide()
	ejecutar_efecto_de_sonido()
	await sonido_obstaculo.finished
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Nave:
		aplicar_efecto(body)
		destruir_obstaculo()
