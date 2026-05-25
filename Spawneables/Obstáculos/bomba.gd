extends Obstaculos


var direccion : int = 1
#
#func _ready():
	#if global_position.x < 0:
		#direccion = 1
	#elif global_position.x >= 1000:
		#direccion = -1
	#se_mueve = true

func _physics_process(delta: float) -> void:
	super(delta)
	#if se_mueve:
		#print(position)
		#position.x += direccion * velocidad_caida * delta
	#position.y -= velocidad_caida * delta
