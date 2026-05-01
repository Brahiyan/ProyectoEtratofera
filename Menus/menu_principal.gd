extends Control
#const NIVEL_1 = preload("res://Niveles/nivel_1.tscn")
const NIVEL_1 = preload("uid://y847urqha4ov")

func _input(event: InputEvent) -> void:
	if event.is_action("ENTER"):
		#var instancia = NIVEL_1.instantiate()
		#get_tree().root.add_child(instancia)
		get_tree().change_scene_to_file("res://Niveles/nivel_1.tscn")

		#get_tree().current_scene = instancia
		self.queue_free()
		#await get_tree().create_timer(.1).timeout
		#ESTO SE TIENE QUE MEJORAR
