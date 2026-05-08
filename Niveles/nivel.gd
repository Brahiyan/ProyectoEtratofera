class_name Nivel extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
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
	if gestor_enemigos.tiene_boss:
		gestor_enemigos.connect("termino_etapa_espacio", activar_animacion_descenso)
	else:
		gestor_enemigos.connect("enemigos_destruidos",activar_animacion_descenso)
	nave.connect("en_espacio", activar_animacion_espacio)
	nave.connect("en_descenso", activar_animacion_descenso)
	nave.connect("aterrizado", activar_animacion_aterrizaje)


func _physics_process(_delta: float) -> void:
	parallax_2d_izquierda.autoscroll.y = -nave.velocidad_actual * 1.5
	parallax_2d_derecha.autoscroll.y = -nave.velocidad_actual * 1.5

func activar_animacion_espacio() -> void:
	if nave.estado == nave.Estados.ASCENDIENDO:
		animation_player.play("transicion_ascenso_espacio")

func activar_animacion_descenso()-> void:
	if nave.estado == nave.Estados.ESPACIO:
		animation_player.play("transicion_espacio_descenso")

func activar_animacion_aterrizaje() -> void:
	pass
