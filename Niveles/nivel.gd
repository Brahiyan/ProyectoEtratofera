class_name Nivel extends Node2D

@export var multiplicador: float = 1.5

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var cielo_bajo: Sprite2D = $CieloBajo
@onready var camera_fija_espacio: Camera2D = $CameraFijaEspacio
@onready var nave: Nave = $Nave
@onready var parallax_2d_izquierda: Parallax2D = $Parallax2DIzquierda
@onready var parallax_2d_derecha: Parallax2D = $Parallax2DDerecha
@onready var gestor_enemigos: Node2D = $GestorEnemigos
@onready var gestor_juego: Node = $GestorJuego

#nivel mueve el parallax a la velocidad en que se encuentra la nave.
#todos los spawneables tienen una velocidad en Y 
#la nave se mueve unicamente en X 
#la dificultad radica en como desarrollar niveles para 
#que siempre el combustible y todo aparezca en el mismo lugar

func _ready() -> void:
	camera_fija_espacio.enabled = false
	nave.connect("en_espacio", activar_animacion_espacio)
	nave.connect("aterrizado", activar_animacion_aterrizaje)
	#get_tree().debug_collisions_hint = true
	#get_tree().debug_navigation_hint = true


func _physics_process(delta: float) -> void:
	parallax_2d_izquierda.autoscroll.y = -nave.velocidad_actual * multiplicador
	parallax_2d_derecha.autoscroll.y = -nave.velocidad_actual * multiplicador
	cielo_bajo.position.y += -nave.velocidad_actual * multiplicador * delta

func activar_animacion_espacio() -> void:
	if nave.estado == nave.Estados.ASCENDIENDO:
		camera_fija_espacio.enabled = true
		animation_player.play("transicion_ascenso_espacio")


func activar_animacion_aterrizaje() -> void:
	#Aca se va a ejecutar la animacion de aterrizaje
	pass
