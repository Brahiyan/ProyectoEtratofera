extends Control

@onready var tiempo_label: RichTextLabel = $RichTextLabel

var tiempo: float = 0.0


func actualizar_tiempo(tiempo: float) -> void:
	var minutos: int = int(tiempo) / 60
	var segundos: int = int(tiempo) % 60
	var milisegundos: int = int((tiempo - int(tiempo)) * 100)
	
	tiempo_label.text = (
	"[center][wave amp=10 freq=2]" +
	"[color=#FF0015]%02d[/color]" % minutos +
	"[color=#FF0015]:[/color]" +
	"[color=#FF0015]%02d[/color]" % segundos +
	"[color=#FF0015]:[/color]" +
	"[color=#FF0015]%02d[/color]" % milisegundos +
	"[/wave][/center]"
)
