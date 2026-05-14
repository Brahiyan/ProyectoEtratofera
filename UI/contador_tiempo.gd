extends Control

@onready var tiempo_label: RichTextLabel = $Panel/RichTextLabel

var tiempo: float = 0.0


func actualizar_tiempo(tiempo: float) -> void:
	var minutos: int = int(tiempo) / 60
	var segundos: int = int(tiempo) % 60
	var milisegundos: int = int((tiempo - int(tiempo)) * 100)
	
	tiempo_label.text = (
	"[center][wave amp=10 freq=2]" +
	"[color=#00FFAA]%02d[/color]" % minutos +
	"[color=#00FFAA]:[/color]" +
	"[color=#00FFAA]%02d[/color]" % segundos +
	"[color=#00FFAA]:[/color]" +
	"[color=#00FFAA]%02d[/color]" % milisegundos +
	"[/wave][/center]"
)
