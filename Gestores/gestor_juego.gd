extends Node

@export var escenas_powerup: Array[PackedScene]
@export var escenas_obstaculos: Array[PackedScene]
@export var puntos_spawn_ascenso: Node2D
@export var puntos_spawn_espacio: Node2D
@export var gestor_enemigos: Node2D
var altura: float = 0.0
var juego_activo: bool = false
var tiempo_partida: float = 0.0
var iniciales_persona

#region UI
@onready var barra_combustible: TextureProgressBar = $"../UI/ContenedorBarras/BarraCombustible"
@onready var barra_vida: TextureProgressBar = $"../UI/ContenedorBarras/BarraVida"
@onready var label_altura: Label = $"../UI/LabelAltura"
@onready var label_explicativo: Label = $"../UI/LabelExplicativo"
@onready var label_combustible: Label = $"../UI/LabelCombustible"
@onready var label_velocidad: Label = $"../UI/LabelVelocidad"
@onready var game_over: Control = $"../UI/GameOver"
@onready var panel_perder: ColorRect = $"../UI/PanelPerder"
@onready var pantalla_perder: Label = $"../UI/PanelPerder/PantallaPerder"
@onready var button_reiniciar: Button = $"../UI/PanelPerder/ButtonReiniciar"
@onready var button_menu: Button = $"../UI/PanelPerder/ButtonMenu"

#endregion
@onready var contador_tiempo: Control = $"../UI/ContadorTiempo"
@onready var jingle_menem_lo_hizo: AudioStreamPlayer = $JingleMenemLoHizo
@onready var nave: Nave = $"../Nave"
@onready var nombre_nivel: String = get_parent().name
@onready var obstaculos: Node2D = $"../Obstaculos"
@onready var perdio: bool = false
@onready var power_ups: Node2D = $"../PowerUps"
@onready var spawn_obstaculos: Timer = $SpawnObstaculos
@onready var spawn_power_ups: Timer = $SpawnPowerUps

#Zonas
@onready var zona_llegada_espacio: Area2D = $"../ZonaLLegadaEspacio"


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ENTER") and perdio == true or event.is_action_pressed("ENTER") and nave.aterrizo == true:
		pass
		#reiniciar_partida()

func _ready():
	nave.combustible_cambiado.connect(_on_combustible_cambiado)
	nave.velocidad_cambiada.connect(_on_velocidad_cambiada)
	nave.ha_despegado.connect(_on_ha_despegado)
	nave.cambio_vida.connect(_on_cambio_vida.bind())
	nave.murio.connect(_on_nave_murio)
	game_over.linea.text_submitted.connect(obtener_iniciales.bind())

	barra_vida.max_value = nave.vida
	barra_vida.value = barra_vida.max_value
	barra_combustible.max_value = nave.combustible_maximo
	spawn_obstaculos.connect("timeout",_on_spawn_obstaculos_timeout)
	spawn_power_ups.connect("timeout",_on_spawn_powerups_timeout)
	zona_llegada_espacio.body_entered.connect(_on_zona_llegada_espacio_body_entered)
	gestor_enemigos.connect("termino_etapa_espacio", _on_termino_etapa_espacio)
	inicializar_obstaculos_fijos()
	activar_power_ups()

func _process(delta: float) -> void:
	label_velocidad.text = "Velocidad: %.2f" % abs(nave.velocidad_actual)
	mover_zona_llegada_espacio(delta)
	if juego_activo:
		tiempo_partida += delta
		contador_tiempo.actualizar_tiempo(tiempo_partida)

func spawnear_obstaculo_aleatorio():
	var obstaculo
	var punto
	if nave.estado == nave.Estados.ASCENDIENDO:
		obstaculo = escenas_obstaculos.pick_random().instantiate()
		punto = puntos_spawn_ascenso.get_children().pick_random()
	obstaculo.position = punto.global_position
	nave.velocidad_cambiada.connect(obstaculo.set_velocidad_caida)
	add_child(obstaculo)

func spawnear_power_up_aleatorio() -> void:
	if nave.estado == nave.Estados.ESPACIO:
		var punto = puntos_spawn_espacio.get_children().pick_random()
		var instancia_power_up = escenas_powerup.pick_random().instantiate()
		nave.velocidad_cambiada.connect(instancia_power_up.set_velocidad_caida)
		instancia_power_up.position = punto.global_position
		power_ups.add_child(instancia_power_up)
		instancia_power_up.obtener_direccion(punto.global_position)
		instancia_power_up.desciende = false


func inicializar_obstaculos_fijos() -> void:
	if obstaculos.get_children().size() <= 0: return
	for i in obstaculos.get_children():
		nave.velocidad_cambiada.connect(i.set_velocidad_caida)

func mover_zona_llegada_espacio(delta: float) ->void:
	zona_llegada_espacio.position.y += -nave.velocidad_actual * delta
	altura = nave.global_position.y - zona_llegada_espacio.global_position.y
	if altura > 0:
		label_altura.text = "DISTANCIA ESPACIO: %.2f" % altura

func activar_power_ups() -> void:
	if power_ups.get_children().size() > 0:
		for i in power_ups.get_children():

			#i.conectar_señales(nave)

			nave.velocidad_cambiada.connect(i.set_velocidad_caida)

func reiniciar_partida() -> void:
	if get_tree().current_scene:
		get_tree().reload_current_scene()

func animacion_combustible_cambiado() -> void:
	var tween: Tween = create_tween()
	tween.set_loops(3)
	tween.tween_property(barra_combustible,"tint_progress",Color(Color.WHITE,0.0),0.2)
	tween.tween_property(barra_combustible,"tint_progress",Color(Color.WHITE,1.0),0.2)

func animacion_vida_cambiada() -> void:
	var tween: Tween = create_tween()
	tween.set_loops(3)
	tween.tween_property(barra_vida,"tint_progress",Color(Color.WHITE,0.0),0.2)
	tween.tween_property(barra_vida,"tint_progress",Color(Color.WHITE,1.0),0.2)

func obtener_iniciales(new_text: String) -> void:
	iniciales_persona = new_text

func terminar_juego():
	if not juego_activo:
		return
	else:
		nave.aterrizar_nave()
	game_over.recibir_tiempo(tiempo_partida)
	spawn_obstaculos.stop()
	spawn_power_ups.stop()
	jingle_menem_lo_hizo.play()
	juego_activo = false
	await game_over.linea.text_submitted
	Highscores.guardar_datos_partida(nombre_nivel,iniciales_persona,tiempo_partida)
	Highscores.guardar_json()

func _on_combustible_cambiado(nuevo_combustible: float, colisiono: bool):
	if colisiono:
		animacion_combustible_cambiado()
	barra_combustible.value = nuevo_combustible

func _on_ha_despegado() -> void:
	spawn_obstaculos.start()
	juego_activo = true

func _on_velocidad_cambiada(nueva_velocidad: float):
	label_velocidad.text = "Velocidad: %.1f" % abs(nueva_velocidad)

func _on_zona_llegada_espacio_body_entered(_body: Node2D):
	nave.cambiar_estado_espacio()
	spawn_power_ups.start()
	spawn_obstaculos.stop()

func _on_spawn_obstaculos_timeout() -> void:
	spawnear_obstaculo_aleatorio()

func _on_spawn_powerups_timeout() -> void:
	spawnear_power_up_aleatorio()

func _on_termino_etapa_espacio() -> void:
	terminar_juego()

func _on_cambio_vida(nueva_vida: int) -> void:
	animacion_vida_cambiada()
	barra_vida.value = nueva_vida

func _on_nave_murio() -> void:
	perdio = true
