class_name Jefe extends Path2D

@onready var path_follow_2d: PathFollow2D = $PathFollow2D

@export var velocidad: float = 0.2          
@export var cuando_ataca: float = 0.3    

signal threshold_alcanzado


var direccion: int = 1     
var atacando: bool = false

func _ready() -> void:
	threshold_alcanzado.connect(_on_threshold_alcanzado)
	pass

func _physics_process(delta: float) -> void:
	mover_path(delta)
	#controlar_ataque()

func mover_path(delta: float) -> void:
	pass

func set_progress_ratio(valor: float) -> void:
	var anterior = path_follow_2d.progress_ratio
	path_follow_2d.progress_ratio = clamp(valor, 0.0, 1.0)
	if anterior < cuando_ataca and path_follow_2d.progress_ratio >= cuando_ataca:
		threshold_alcanzado.emit()

func controlar_ataque() -> void:
	if direccion == 1 and path_follow_2d.progress_ratio >= cuando_ataca and not atacando:
		atacar()
		atacando = true

func atacar() -> void:
	print("¡Atacando!")


func _on_threshold_alcanzado() -> void:
	
	pass
