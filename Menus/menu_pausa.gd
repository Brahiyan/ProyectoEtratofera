extends Control

@export var gestor_juego: Node
var esta_pausado :bool= false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("PAUSA"):
		toggle_pausa()
	if event.is_action_pressed("ENTER") and esta_pausado:
		toggle_pausa()
		reiniciar_partida()


func reiniciar_partida() -> void:
	if get_tree().current_scene:
		get_tree().reload_current_scene()

func toggle_pausa() -> void:
	esta_pausado = !esta_pausado
	get_tree().paused = esta_pausado

	if esta_pausado:
		show()
	else:
		hide()
