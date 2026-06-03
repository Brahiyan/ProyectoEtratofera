class_name Nivel extends Node2D

@export var multiplicador: float = 1.5
@export var animacion_llegada: VideoStream
@export var animacion_despegue: VideoStream



@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var cielo_bajo: Sprite2D = $CieloBajo
@onready var camera_fija_espacio: Camera2D = $CameraFijaEspacio
@onready var cobertor: ColorRect = $UI/Cobertor
@onready var nave: Nave = $Nave
@onready var parallax_2d_izquierda: Parallax2D = $Parallax2DIzquierda
@onready var parallax_2d_derecha: Parallax2D = $Parallax2DDerecha
@onready var gestor_enemigos: Node2D = $GestorEnemigos
@onready var gestor_juego: Node = $GestorJuego
@onready var video_stream_player: VideoStreamPlayer = $UI/VideoStreamPlayer


@onready var barra_combustible: TextureProgressBar = $"UI/ContenedorBarras/BarraCombustible"
@onready var barra_vida: TextureProgressBar = $"UI/ContenedorBarras/BarraVida"
@onready var label_altura: Label = $"UI/LabelAltura"
@onready var game_over: Control = $UI/GameOver
@onready var label_explicativo: Label = $"UI/LabelExplicativo"
@onready var label_combustible: Label = $"UI/LabelCombustible"
@onready var label_velocidad: Label = $"UI/LabelVelocidad"
@onready var panel_perder: ColorRect = $"UI/PanelPerder"
@onready var pantalla_perder: Label = $"UI/PanelPerder/PantallaPerder"
@onready var button_reiniciar: Button = $"UI/PanelPerder/ButtonReiniciar"
@onready var button_menu: Button = $"UI/PanelPerder/ButtonMenu"


#nivel mueve el parallax a la velocidad en que se encuentra la nave.
#todos los spawneables tienen una velocidad en Y 
#la nave se mueve unicamente en X 
#la dificultad radica en como desarrollar niveles para 
#que siempre el combustible y todo aparezca en el mismo lugar

func _ready() -> void:
	camera_fija_espacio.enabled = false
	nave.en_espacio.connect(activar_animacion_espacio)
	nave.murio.connect(_on_nave_murio)
	nave.ha_despegado.connect(_on_ha_despegado)
	game_over.linea.text_submitted.connect(_on_text_submitted.unbind(1))
	gestor_enemigos.termino_etapa_espacio.connect(activar_animacion_llegada)
	video_stream_player.stream = animacion_despegue
	activar_animacion_despegue()
	
	
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

func activar_animacion_despegue() -> void:
	video_stream_player.play()
	
	await video_stream_player.finished
	video_stream_player.hide()
	cambiar_animacion()
	nave.despegar()

func cambiar_animacion()-> void:
	video_stream_player.stream = animacion_llegada

func activar_animacion_llegada() -> void:
	animation_player.play("animacion_llegada")
	await video_stream_player.finished
	video_stream_player.hide()
	game_over.linea.grab_focus()
	game_over.show()

func _on_ha_despegado() -> void:
	label_explicativo.hide()

func _on_nave_murio() -> void:
	panel_perder.show()
	button_reiniciar.grab_focus()


func _on_button_reiniciar_pressed() -> void:
	get_tree().reload_current_scene()


func _on_button_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/menu_principal.tscn")

func _on_text_submitted() -> void:
	game_over.hide()
	
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Menus/menu_principal.tscn")
