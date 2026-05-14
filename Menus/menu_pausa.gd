extends Control

const MENU_PRINCIPAL = preload("res://Menus/menu_principal.tscn")

@export var gestor_juego: Node
@onready var btn_reiniciar: Button = $BotonesPausa/VBoxContainer/Reiniciar

var esta_pausado :bool= false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("PAUSA"):
		toggle_pausa()

func _ready() -> void:
	print(MENU_PRINCIPAL)
	visibility_changed.connect(_on_visibility_changed)

func reiniciar_partida() -> void:
	if get_tree().current_scene:
		get_tree().reload_current_scene()

func volver_al_inicio() -> void:
	
	pass

func toggle_pausa() -> void:
	esta_pausado = !esta_pausado
	get_tree().paused = esta_pausado
	visible = esta_pausado
	if esta_pausado:
		show()
	else:
		hide()

func _on_visibility_changed() -> void:
	if visible == true:
		btn_reiniciar.grab_focus()

func _on_reiniciar_button_pressed() -> void:
	reiniciar_partida()

func _on_volver_al_inicio_button_pressed() -> void:
	get_tree().paused = false
	esta_pausado = false
	get_tree().change_scene_to_file("res://Menus/menu_principal.tscn")
