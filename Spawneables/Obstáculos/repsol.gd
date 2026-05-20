extends Obstaculos


func _physics_process(delta: float) -> void:
	super(delta)
	position.y -= velocidad_caida * delta
