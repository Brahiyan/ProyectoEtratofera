extends Control

@onready var agradecimiento: Label = $Agradecimiento
@onready var tiempo: Label = $Tiempo
@onready var iniciales: Label = $Iniciales
@onready var linea: LineEdit = $linea

func recibir_tiempo(tiempo_recibido: float) -> void: 
	tiempo.text = tiempo.text + "%.4f" % tiempo_recibido
