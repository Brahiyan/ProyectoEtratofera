extends Control
const NIVEL_URUGUAY = preload("uid://y847urqha4ov")

@onready var pantalla_inicio: CenterContainer = $PantallaDeInicio
@onready var selector_de_niveles: CenterContainer = $SelectorDeNiveles
@onready var btn_seleccionar_nivel: Button = $PantallaDeInicio/VBoxContainer/SeleccionarNivel
@onready var btn_uruguay: Button = $SelectorDeNiveles/VBoxContainer/Uruguay


func _ready() -> void:
	pantalla_inicio.visible = true
	selector_de_niveles.visible = false
	btn_seleccionar_nivel.grab_focus()


func _on_seleccionar_nivel_button_pressed() -> void:
	pantalla_inicio.visible = false
	selector_de_niveles.visible = true
	
	await get_tree().process_frame
	btn_uruguay.grab_focus()
	
	print("Ir a selección de nivel")

func _on_como_jugar_button_pressed() -> void:
	await get_tree().process_frame
	
	print("Mostrar instrucciones")

func _on_creditos_button_pressed() -> void:
	await get_tree().process_frame
	
	print("Mostrar créditos")

func _on_volver_button_pressed() -> void:
	pantalla_inicio.visible = true
	selector_de_niveles.visible = false
	await get_tree().process_frame
	btn_seleccionar_nivel.grab_focus()

func _on_uruguay_button_pressed() -> void:
	get_tree().change_scene_to_packed(NIVEL_URUGUAY)

func _on_japon_button_pressed() -> void:
	#get_tree().change_scene_to_packed(NIVEL_URUGUAY)
	pass
