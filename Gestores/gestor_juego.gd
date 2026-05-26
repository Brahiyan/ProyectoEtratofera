extends Node


#Arreglar bug de menu de pausa.

@export var escenas_powerup: Array[PackedScene]
@export var escenas_obstaculos: Array[PackedScene]
@export var puntos_spawn_ascenso: Node2D
@export var puntos_spawn_espacio: Node2D
@export var gestor_enemigos: Node2D
var altura: float = 0.0
var tiempo_ultimo_spawn: float = 0.0
var juego_activo: bool = false
const offset_y = -600
var tiempo_partida: float = 0.0

#region UI
#@onready var agarro_paracaidas: Label = $"../UI/AgarroParacaidas"
@onready var barra_combustible: TextureProgressBar = $"../UI/ContenedorBarras/BarraCombustible"

@onready var barra_descenso: TextureProgressBar = $"../UI/ContenedorBarras/BarraDescenso"
#@onready var barra_paracaidas: TextureProgressBar = $"../UI/BarraParacaidas"
@onready var barra_vida: TextureProgressBar = $"../UI/ContenedorBarras/BarraVida"

@onready var jingle_menem_lo_hizo: AudioStreamPlayer = $JingleMenemLoHizo
@onready var label_altura: Label = $"../UI/LabelAltura"
@onready var label_explicativo: Label = $"../UI/LabelExplicativo"
@onready var label_combustible: Label = $"../UI/LabelCombustible"
@onready var label_velocidad: Label = $"../UI/LabelVelocidad"
@onready var game_over: ColorRect = $"../UI/GameOver"
@onready var panel_perder: ColorRect = $"../UI/PanelPerder"
@onready var pantalla_perder: Label = $"../UI/PanelPerder/PantallaPerder"

#endregion

#@onready var puntos_spawn: Node2D = $"../PuntosSpawn"
@onready var contador_tiempo: Control = $"../UI/ContadorTiempo"
@onready var nave: Nave = $"../Nave"
@onready var obstaculos: Node2D = $"../Obstaculos"
@onready var perdio: bool = false
@onready var power_ups: Node2D = $"../PowerUps"
@onready var spawn_obstaculos: Timer = $SpawnObstaculos
@onready var spawn_power_ups: Timer = $SpawnPowerUps
#@onready var paracaidas: Node2D = $"../Paracaidas"

#Zonas
@onready var zona_llegada_espacio: Area2D = $"../ZonaLLegadaEspacio"


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ENTER") and perdio == true or event.is_action_pressed("ENTER") and nave.aterrizo == true:
		reiniciar_partida()

func _ready():
	nave.combustible_cambiado.connect(_on_combustible_cambiado)
	nave.velocidad_cambiada.connect(_on_velocidad_cambiada)
	nave.ha_despegado.connect(_on_ha_despegado)
	nave.cambio_vida.connect(_on_cambio_vida.bind())

	nave.murio.connect(_on_nave_murio)
	barra_vida.max_value = nave.vida
	barra_vida.value = barra_vida.max_value
	#barra_paracaidas.max_value = nave.paracaidas_a_agarrar
	barra_combustible.max_value = nave.combustible_maximo
	spawn_obstaculos.connect("timeout",_on_spawn_obstaculos_timeout)
	spawn_power_ups.connect("timeout",_on_spawn_powerups_timeout)
	zona_llegada_espacio.body_entered.connect(_on_zona_llegada_espacio_body_entered)
	#gestor_enemigos.connect("enemigos_destruidos",_on_enemigos_destruidos)
	gestor_enemigos.connect("termino_etapa_espacio", _on_termino_etapa_espacio)
	inicializar_obstaculos_fijos()
	activar_power_ups()

func _process(delta: float) -> void:
	label_velocidad.text = "Velocidad: %.2f" % abs(nave.velocidad_actual)
	mover_zona_llegada_espacio(delta)
	#if nave.estado == nave.Estados.DESCENDIENDO or nave.estado == nave.Estados.PARACAIDAS :
		#mover_zona_aterrizaje(delta)
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


func _on_combustible_cambiado(nuevo_combustible: float):
	label_combustible.text = "Combustible: %.1f" % nuevo_combustible
	barra_combustible.value = nuevo_combustible

func _on_ha_despegado() -> void:
	label_explicativo.hide()
	spawn_obstaculos.start()
	juego_activo = true

func _on_velocidad_cambiada(nueva_velocidad: float):
	pass

	label_velocidad.text = "Velocidad: %.1f" % abs(nueva_velocidad)

func _on_zona_llegada_espacio_body_entered(_body: Node2D):
	nave.cambiar_estado_espacio()
	spawn_power_ups.start()
	spawn_obstaculos.stop()

func _on_spawn_obstaculos_timeout() -> void:
	spawnear_obstaculo_aleatorio()

func _on_spawn_powerups_timeout() -> void:
	spawnear_power_up_aleatorio()

func _on_juego_terminado():
	if not juego_activo:
		return
	if nave.velocidad_actual > 500: #cambiar por variable luego
		nave.destruir_nave()
	else:
		#print("Juego terminado! Tiempo final: ", nave.tiempo_acumulado)
		nave.aterrizar_nave()
		game_over.show()
	jingle_menem_lo_hizo.play()
	juego_activo = false

#func _on_boss_destruido() -> void:
	#nave.cambiar_estado_descenso()
	#nave.frenar_en_seco()
	#activar_paracaidas()
	#activar_barra_descenso()
	#spawn_items.start()

func _on_termino_etapa_espacio() -> void:
	_on_juego_terminado()
	#if nave.estado != nave.Estados.ESPACIO:return
	#nave.cambiar_estado_descenso()
	#nave.frenar_en_seco()
	#activar_paracaidas()
	#activar_barra_descenso()
	#spawn_items.start()

func _on_cambio_vida(nueva_vida: int) -> void:
	barra_vida.value = nueva_vida

func _on_nave_murio() -> void:
	panel_perder.show()
	pantalla_perder.show()
	perdio = true

#func _on_nave_agarro_todos_paracaidas() -> void:
	#agarro_paracaidas.show()
#func _on_perdio_paracaidas() -> void:
	#agarro_paracaidas.hide()
#func _on_agarro_paracaidas() -> void:
	#barra_paracaidas.value += 1

#func activar_barra_descenso() -> void:
	#barra_descenso.show()
	#barra_paracaidas.show()

#func activar_paracaidas() -> void:
	#if paracaidas.get_children().size() > 0:
		#for i in paracaidas.get_children():
			#i.activo = true
			#if not nave.velocidad_cambiada.is_connected(i.set_velocidad_caida):
				#nave.velocidad_cambiada.connect(i.set_velocidad_caida)
