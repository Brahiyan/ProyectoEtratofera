extends Control

const HIGHSCORES_JPN = preload("uid://hd0qcf8ffxhd")
const HIGHSCORES_UR = preload("uid://5sdjuxgh7n3h")
const HIGHSCORES_VCO = preload("uid://b1hghvbfsof5p")

@export var nivel_uruguay: PackedScene
@export var nivel_japon: PackedScene

@onready var pantalla_inicio: CenterContainer = $PantallaDeInicio
@onready var btn_seleccionar_nivel: TextureButton = $PantallaDeInicio/VBoxContainer/SeleccionarNivel
@onready var sonido_seleccion: AudioStreamPlayer = $SonidoSeleccion
@onready var sonido_atras: AudioStreamPlayer = $SonidoAtras

@onready var label_high_score: Label = $SeleccionNivel/TextureRectHighscore/LabelHighScore
@onready var como_jugar: Control = $ComoJugar

@onready var uruguay: TextureButton = $SeleccionNivel/Uruguay
@onready var japon: TextureButton = $SeleccionNivel/Japon
@onready var seleccion_nivel: Control = $SeleccionNivel
@onready var texture_rect_highscore: TextureRect = $SeleccionNivel/TextureRectHighscore

@onready var creditos: Control = $Creditos
@onready var volver_creditos: Button = $Creditos/VolverCreditos
@onready var cd_cinematica: Timer = $CDCinematica
@onready var fondo_cinematica: ColorRect = $FondoCinematica
@onready var cinematica_comienzo: VideoStreamPlayer = $FondoCinematica/CinematicaComienzo



var tween_parpadeo: Tween

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("PAUSA") and cinematica_comienzo.is_playing():
		cinematica_comienzo.stop()
		fondo_cinematica.hide()
		cd_cinematica.start()

func _ready() -> void:
	pantalla_inicio.visible = true
	seleccion_nivel.visible = false
	btn_seleccionar_nivel.grab_focus()

func _on_seleccionar_nivel_button_pressed() -> void:
	pantalla_inicio.visible = false
	seleccion_nivel.visible = true
	
	await get_tree().process_frame
	uruguay.grab_focus()
	label_high_score.show()
	sonido_seleccion.play()
	cd_cinematica.stop()

func _on_creditos_button_pressed() -> void:
	await get_tree().process_frame
	sonido_seleccion.play()
	pantalla_inicio.visible = false
	creditos.visible = true
	volver_creditos.grab_focus()
	cd_cinematica.stop()

func _on_volver_button_pressed() -> void:
	pantalla_inicio.visible = true
	seleccion_nivel.visible = false
	await get_tree().process_frame
	btn_seleccionar_nivel.grab_focus()
	sonido_atras.play()
	label_high_score.hide()
	cd_cinematica.start()

func _on_uruguay_button_pressed() -> void:
	sonido_seleccion.play()
	await sonido_seleccion.finished
	como_jugar.show()
	await get_tree().create_timer(5).timeout
	get_tree().change_scene_to_packed(nivel_uruguay)

func _on_japon_button_pressed() -> void:
	sonido_seleccion.play()
	await sonido_seleccion.finished
	como_jugar.show()
	await get_tree().create_timer(5).timeout
	get_tree().change_scene_to_packed(nivel_japon)

func _on_nivel_uruguay_focus_entered() -> void:
	var arr = Highscores.obtener_top_5("NivelUruguay")
	var texto = Highscores.formatear_highscores(arr)
	label_high_score.text = texto
	texture_rect_highscore.texture = HIGHSCORES_UR
	titilar(uruguay)

func _on_nivel_volver_focus_entered() -> void:
	label_high_score.text = ""
	texture_rect_highscore.texture = HIGHSCORES_VCO

func _on_nivel_japon_focus_entered() -> void:
	var arr = Highscores.obtener_top_5("NivelJapon")
	var texto = Highscores.formatear_highscores(arr)
	label_high_score.text = texto
	texture_rect_highscore.texture = HIGHSCORES_JPN
	titilar(japon)

func _on_volver_creditos_pressed() -> void:
	pantalla_inicio.visible = true
	creditos.visible = false
	await get_tree().process_frame
	btn_seleccionar_nivel.grab_focus()
	sonido_atras.play()
	cd_cinematica.start()

func titilar(boton) -> void:
	if tween_parpadeo:
		tween_parpadeo.kill()
	tween_parpadeo = create_tween()
	tween_parpadeo.set_loops()
	tween_parpadeo.tween_property(
		boton,
		"modulate:a",
		0,
		0.25
	)
	tween_parpadeo.tween_property(
		boton,
		"modulate:a",
		1,
		0.25
	)

func _on_cinematica_comienzo_finished() -> void:
	fondo_cinematica.hide()
	cd_cinematica.start()

func _on_cd_cinematica_timeout() -> void:
	fondo_cinematica.show()
	cinematica_comienzo.play()

func _on_button_play_cinematica_pressed() -> void:
	cd_cinematica.stop()
	fondo_cinematica.show()
	cinematica_comienzo.play()
