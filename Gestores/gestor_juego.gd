extends Node

@export var escena_powerup: PackedScene
@export var escenas_obstaculos: Array[PackedScene]
@export var puntos_spawn_ascenso: Node2D
@export var puntos_spawn_descenso: Node2D
@export var gestor_enemigos: Node2D
var altura: float = 0.0
var tiempo_ultimo_spawn: float = 0.0
var juego_activo: bool = false
const offset_y = -600


#region UI
@onready var agarro_paracaidas: Label = $"../UI/AgarroParacaidas"

@onready var barra_combustible: TextureProgressBar = $"../UI/ContenedorBarras/BarraCombustible"

@onready var barra_descenso: TextureProgressBar = $"../UI/ContenedorBarras/BarraDescenso"
@onready var barra_paracaidas: TextureProgressBar = $"../UI/BarraParacaidas"
@onready var barra_vida: TextureProgressBar = $"../UI/ContenedorBarras/BarraVida"

@onready var label_altura: Label = $"../UI/LabelAltura"
@onready var label_explicativo: Label = $"../UI/LabelExplicativo"
@onready var label_combustible: Label = $"../UI/LabelCombustible"
@onready var label_tiempo: Label = $"../UI/LabelTiempo"
@onready var label_velocidad: Label = $"../UI/LabelVelocidad"
@onready var game_over: Panel = $"../UI/GameOver"
@onready var panel_perder: ColorRect = $"../UI/PanelPerder"
@onready var pantalla_perder: Label = $"../UI/PanelPerder/PantallaPerder"

#endregion

#@onready var puntos_spawn: Node2D = $"../PuntosSpawn"
@onready var spawn_items: Timer = $SpawnItems
@onready var nave: Nave = $"../Nave"
@onready var paracaidas: Node2D = $"../Paracaidas"
@onready var power_ups: Node2D = $"../PowerUps"
@onready var perdio: bool = false

#Zonas
@onready var zona_aterrizaje: Area2D = $"../ZonaAterrizaje"
@onready var zona_llegada_espacio: Area2D = $"../ZonaLLegadaEspacio"


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ENTER") and perdio == true or event.is_action_pressed("ENTER") and nave.aterrizo == true:
		reiniciar_partida()

func _ready():
	nave.combustible_cambiado.connect(_on_combustible_cambiado)
	nave.velocidad_cambiada.connect(_on_velocidad_cambiada)
	nave.tiempo_actualizado.connect(_on_tiempo_actualizado)
	nave.ha_despegado.connect(_on_ha_despegado)
	nave.cambio_vida.connect(_on_cambio_vida.bind())
	barra_vida.max_value = nave.vida
	barra_vida.value = barra_vida.max_value
	barra_paracaidas.max_value = nave.paracaidas_a_agarrar
	nave.agarro_paracaida.connect(_on_agarro_paracaidas)
	nave.murio.connect(_on_nave_murio)
	nave.agarro_todos_paracaidas.connect(_on_nave_agarro_todos_paracaidas)
	barra_combustible.max_value = nave.combustible_maximo
	zona_aterrizaje.body_entered.connect(_on_zona_aterrizaje_body_entered)
	zona_llegada_espacio.body_entered.connect(_on_zona_llegada_espacio_body_entered)
	spawn_items.connect("timeout",_on_spawn_items_timeout)
	barra_descenso.max_value = abs(nave.global_position.y - zona_aterrizaje.global_position.y)
	gestor_enemigos.connect("enemigos_destruidos",_on_enemigos_destruidos)
	activar_power_ups()

func _process(delta: float) -> void:
	zona_aterrizaje.position.x = nave.position.x
	label_velocidad.text = "Velocidad: %.2f" % abs(nave.velocidad_actual)
	mover_zona_llegada_espacio(delta)
	if nave.estado == nave.Estados.DESCENDIENDO or nave.estado == nave.Estados.PARACAIDAS :
		mover_zona_aterrizaje(delta)

func generar_item_aleatorio():
	var obstaculo
	var punto
	if nave.estado == nave.Estados.ASCENDIENDO:
		obstaculo = escenas_obstaculos[0].instantiate()
		punto = puntos_spawn_ascenso.get_children().pick_random()
	elif nave.estado == nave.Estados.DESCENDIENDO or nave.estado == nave.Estados.PARACAIDAS:
		obstaculo = escenas_obstaculos[1].instantiate()
		punto = puntos_spawn_descenso.get_children().pick_random()
	
	obstaculo.position = punto.global_position
	nave.velocidad_cambiada.connect(obstaculo.set_velocidad_caida)
	add_child(obstaculo)

func mover_zona_llegada_espacio(delta: float) ->void:
	zona_llegada_espacio.position.y += -nave.velocidad_actual * delta
	altura = nave.global_position.y - zona_llegada_espacio.global_position.y
	if altura > 0:
		label_altura.text = "DISTANCIA ESPACIO: %.2f" % altura

func mover_zona_aterrizaje(delta: float) ->void:
	zona_aterrizaje.position.y += (-nave.velocidad_actual * 0.5) * delta
	var distancia = abs(nave.global_position.y - zona_aterrizaje.global_position.y)
	barra_descenso.value = barra_descenso.max_value - distancia

func activar_power_ups() -> void:
	if power_ups.get_children().size() > 0:
		for i in power_ups.get_children():
			nave.velocidad_cambiada.connect(i.set_velocidad_caida)

func activar_paracaidas() -> void:
	if paracaidas.get_children().size() > 0:
		for i in paracaidas.get_children():
			i.activo = true
			nave.velocidad_cambiada.connect(i.set_velocidad_caida)

func reiniciar_partida() -> void:
	if get_tree().current_scene:
		get_tree().reload_current_scene()

func activar_barra_descenso() -> void:
	barra_descenso.show()
	barra_paracaidas.show()

func _on_combustible_cambiado(nuevo_combustible: float):
	label_combustible.text = "Combustible: %.1f" % nuevo_combustible
	barra_combustible.value = nuevo_combustible

func _on_ha_despegado() -> void:
	label_explicativo.hide()
	spawn_items.start()
	juego_activo = true

func _on_velocidad_cambiada(nueva_velocidad: float):
	pass
	label_velocidad.text = "Velocidad: %.1f" % abs(nueva_velocidad)

func _on_tiempo_actualizado(tiempo_total: float):
	label_tiempo.text = "Tiempo: %.3f" % tiempo_total

func _on_zona_aterrizaje_body_entered(body: Node2D):
	if body is Nave:
		_on_juego_terminado()

func _on_zona_llegada_espacio_body_entered(_body: Node2D):
	nave.cambiar_estado_espacio()
	spawn_items.stop()

func _on_spawn_items_timeout() -> void:
	generar_item_aleatorio()

func _on_juego_terminado():
	if not juego_activo:
		return
	if nave.velocidad_actual > 500:
		nave.destruir_nave()
	else:
		print("Juego terminado! Tiempo final: ", nave.tiempo_acumulado)
		nave.aterrizar_nave()
		game_over.show()
	juego_activo = false

func _on_boss_destruido() -> void:
	
	pass

func _on_enemigos_destruidos() -> void:
	if gestor_enemigos.tiene_boss == false:
		nave.cambiar_estado_descenso()
		nave.frenar_en_seco()
		activar_paracaidas()
		activar_barra_descenso()
		spawn_items.start()

func _on_agarro_paracaidas() -> void:
	barra_paracaidas.value += 1

func _on_cambio_vida(nueva_vida: int) -> void:
	barra_vida.value = nueva_vida

func _on_nave_murio() -> void:
	panel_perder.show()
	pantalla_perder.show()
	perdio = true

func _on_nave_agarro_todos_paracaidas() -> void:
	agarro_paracaidas.show()
