extends Node2D
@export var array_escenas: Array[PackedScene]

@onready var puntos_spawn : Array[Vector2] =[
	Vector2(250.0,-100),
	Vector2(-250.0,100),
	Vector2(0,-250),
	Vector2(0,250)
]


func _ready() -> void:
	spawnear_power_up()

func spawnear_power_up() -> void:
	if !puntos_spawn: return
	var instancia_power_up
	for i in puntos_spawn:
		instancia_power_up = array_escenas.pick_random().instantiate()
		instancia_power_up.position = i
		add_child(instancia_power_up)

func conectar_señales(nave_ref: Nave) -> void:
	for i in get_children():
		nave_ref.velocidad_cambiada.connect(i.set_velocidad_caida)
