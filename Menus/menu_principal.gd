extends Control

@export var nivel_uruguay: PackedScene
@export var nivel_japon: PackedScene

@onready var pantalla_inicio: CenterContainer = $PantallaDeInicio
@onready var btn_seleccionar_nivel: TextureButton = $PantallaDeInicio/VBoxContainer/SeleccionarNivel
@onready var sonido_seleccion: AudioStreamPlayer = $SonidoSeleccion
@onready var sonido_atras: AudioStreamPlayer = $SonidoAtras

@onready var label_high_score: Label = $SeleccionNivel/LabelHighScore
@onready var nombre_nivel: Label = $SeleccionNivel/Panel/NombreNivel

@onready var uruguay: TextureButton = $SeleccionNivel/Uruguay
@onready var japon: TextureButton = $SeleccionNivel/Japon
@onready var seleccion_nivel: Control = $SeleccionNivel

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
	print("Ir a selección de nivel")

func _on_como_jugar_button_pressed() -> void:
	await get_tree().process_frame
	sonido_seleccion.play()
	print("Mostrar instrucciones")

func _on_creditos_button_pressed() -> void:
	await get_tree().process_frame
	sonido_seleccion.play()
	print("Mostrar créditos")

func _on_volver_button_pressed() -> void:
	pantalla_inicio.visible = true
	seleccion_nivel.visible = false
	await get_tree().process_frame
	btn_seleccionar_nivel.grab_focus()
	sonido_atras.play()
	label_high_score.hide()

func _on_uruguay_button_pressed() -> void:
	sonido_seleccion.play()
	await sonido_seleccion.finished
	get_tree().change_scene_to_packed(nivel_uruguay)

func _on_japon_button_pressed() -> void:
	sonido_seleccion.play()
	await sonido_seleccion.finished
	get_tree().change_scene_to_packed(nivel_japon)


func _on_nivel_uruguay_focus_entered() -> void:
	var arr = Highscores.obtener_top_5("NivelUruguay")
	var texto = Highscores.formatear_highscores(arr)
	label_high_score.text = texto
	nombre_nivel.text = "HIGHSCORE URUGUAY:"

func _on_nivel_volver_focus_entered() -> void:
	label_high_score.text = ""
	nombre_nivel.text = "HIGHSCORE:"

func _on_nivel_japon_focus_entered() -> void:
	var arr = Highscores.obtener_top_5("NivelJapon")
	var texto = Highscores.formatear_highscores(arr)
	label_high_score.text = texto
	nombre_nivel.text = "HIGHSCORE JAPON:"
