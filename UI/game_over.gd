extends Control

@onready var agradecimiento: Label = $Agradecimiento
@onready var tiempo: Label = $Tiempo
@onready var iniciales: Label = $Iniciales
@onready var linea: LineEdit = $linea

func recibir_tiempo(tiempo_recibido: float) -> void: 
	var texto_tiempo = Highscores.convertir_tiempo(tiempo_recibido)
	tiempo.text = tiempo.text + " " + texto_tiempo
	#tiempo.text = tiempo.text + "%.4f" % tiempo_recibido
