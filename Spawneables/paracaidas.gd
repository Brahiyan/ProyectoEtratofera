extends Area2D


@onready var activo: bool = false 
var velocidad_caida: float 

func _physics_process(delta: float) -> void:
	if activo == true:
		position.y += -velocidad_caida * delta


func set_velocidad_caida(valor: float):
	velocidad_caida = valor


func _on_body_entered(body: Node2D) -> void:
	if body is Nave:
		body.aumentar_paracaidas()
		queue_free()
