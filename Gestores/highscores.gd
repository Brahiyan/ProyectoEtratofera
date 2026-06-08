extends Node

const RUTA_GUARDADO := "user://datos_partida.json"
var datos_partida: Dictionary = {"nombre": "", "tiempo":0.0}
var diccionario_niveles: Dictionary



func _ready() -> void:
	cargar_json()
	obtener_top_5("NivelUruguay")
	

func guardar_datos_partida(nivel: String, nombre: String, tiempo: float)-> void:
	var nuevo_dict = datos_partida.duplicate()
	
	nuevo_dict["nombre"] = nombre
	nuevo_dict["tiempo"] = tiempo
	
	var nueva_partida := {"nombre": nombre,"tiempo": tiempo}
	
	if not diccionario_niveles.has(nivel):
		diccionario_niveles[nivel] = []

	diccionario_niveles[nivel].append(nueva_partida)

func guardar_json() -> void:

	var archivo = FileAccess.open(RUTA_GUARDADO,FileAccess.WRITE)

	if archivo == null:
		print("No se pudo abrir el archivo")
		return

	var json_string = JSON.stringify(diccionario_niveles, "\t")
	archivo.store_string(json_string)
	archivo.close()

func cargar_json() -> void:

	if not FileAccess.file_exists(RUTA_GUARDADO):
		return

	var archivo = FileAccess.open(RUTA_GUARDADO,FileAccess.READ)
	if archivo == null:
		return

	var contenido = archivo.get_as_text()
	archivo.close()
	var json = JSON.new()
	var error = json.parse(contenido)

	if error != OK:
		print("Error al parsear JSON")
		return
	diccionario_niveles = json.data

func obtener_top_5(nivel: String) -> Array:

	if not diccionario_niveles.has(nivel):
		return []

	var valores = diccionario_niveles[nivel].duplicate()

	valores.sort_custom(
		func(a, b):
			return a["tiempo"] < b["tiempo"]
	)
	#print(valores)

	return valores.slice(0, min(5, valores.size()))


func formatear_highscores(highscores: Array) -> String:
	var texto := ""

	for i in range(highscores.size()):
		var score = highscores[i]

		texto += "%d. %s - %s\n" % [
			i + 1,
			score["nombre"],
			convertir_tiempo(score["tiempo"])
		]

	return texto

func convertir_tiempo(tiempo: float) -> String:
	var minutos: int = int(tiempo) / 60
	var segundos: int = int(tiempo) % 60
	var milisegundos: int = int((tiempo - int(tiempo)) * 100)
	
	return "%02d:%02d.%02d" % [minutos, segundos, milisegundos]
