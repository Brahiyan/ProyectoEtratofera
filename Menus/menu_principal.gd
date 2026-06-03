extends Control

@export var nivel_uruguay: PackedScene
@export var nivel_japon: PackedScene

@onready var pantalla_inicio: CenterContainer = $PantallaDeInicio
@onready var selector_de_niveles: CenterContainer = $SelectorDeNiveles
@onready var btn_seleccionar_nivel: Button = $PantallaDeInicio/VBoxContainer/SeleccionarNivel
@onready var btn_uruguay: Button = $SelectorDeNiveles/VBoxContainer/NivelUruguay
@onready var sonido_seleccion: AudioStreamPlayer = $SonidoSeleccion
@onready var sonido_atras: AudioStreamPlayer = $SonidoAtras

@onready var label_high_score: Label = $LabelHighScore


func _ready() -> void:
	pantalla_inicio.visible = true
	selector_de_niveles.visible = false
	btn_seleccionar_nivel.grab_focus()

func _on_seleccionar_nivel_button_pressed() -> void:
	pantalla_inicio.visible = false
	selector_de_niveles.visible = true
	
	await get_tree().process_frame
	btn_uruguay.grab_focus()
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
	selector_de_niveles.visible = false
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

func _on_nivel_japon_focus_entered() -> void:
	var arr = Highscores.obtener_top_5("NivelJapon")
	var texto = Highscores.formatear_highscores(arr)
	label_high_score.text = texto
