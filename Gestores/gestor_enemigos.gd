extends Node2D


#Tiene un bool que dice si el boss fue destruido.

# la cantidad de enemigos que va a spawnear la etapa espacio
@export var cantidad_enemigos: int = 10

@export var escena_boss: PackedScene
@export var escenas_enemigos: Array[PackedScene]
@onready var puntos_spawn: Node2D = $PuntosSpawn
@export var tiempo_de_spawn: float = 5.0 # El tiempo que tarda en spawnear un nuevo enemigo
@export var nave_ref: Node2D
@export var tiene_boss: bool = false
@onready var timer_spawn: Timer = $TimerSpawn

var gestor_activo: bool = false:
	set(new_value):
		gestor_activo = new_value
		if  new_value == false:
			timer_spawn.stop()
		elif new_value == true:
			timer_spawn.start()

var enemigos_spawneados: int = 0:
	set(nuevo_valor):
		enemigos_spawneados = nuevo_valor
		if enemigos_spawneados >= cantidad_enemigos :
			timer_spawn.stop()
			frenar_spawn_enemigos_normales = true

var frenar_spawn_enemigos_normales: bool = false
var se_destruyeron_enemigos: bool = false

var se_destruyo_boss: bool = false:
	set(nuevo_valor):
		se_destruyo_boss = nuevo_valor
		if se_destruyo_boss == true and se_destruyeron_enemigos == true:
			termino_etapa_espacio.emit()

var cantidad_enemigos_destruidos: int

signal boss_destruido
signal enemigos_destruidos
signal termino_etapa_espacio

func _ready() -> void:
	nave_ref.connect("en_espacio",activar_gestor)
	timer_spawn.wait_time = tiempo_de_spawn
	timer_spawn.connect("timeout",spawnear_enemigo)

func activar_gestor() -> void:
	gestor_activo = true
	timer_spawn.start()

func seleccionar_enemigo_aleatorio() -> Node2D:
	if escenas_enemigos.size() >0:
		return escenas_enemigos.pick_random().instantiate()
	else: return null

func set_enemigos_destruidos(valor: int = 1) -> void:
	cantidad_enemigos_destruidos += valor
	if cantidad_enemigos_destruidos >= cantidad_enemigos:
		enemigos_destruidos.emit()
		se_destruyeron_enemigos = true

func spawnear_enemigo() -> void:
	if frenar_spawn_enemigos_normales == true: return
	enemigos_spawneados += 1
	
	var instancia_enemigo = seleccionar_enemigo_aleatorio()
	instancia_enemigo.nave_ref = self.nave_ref
	var punto = puntos_spawn.get_children().pick_random()
	if puntos_spawn:
		instancia_enemigo.connect("enemigo_muerto",set_enemigos_destruidos)
		add_child(instancia_enemigo)
		instancia_enemigo.global_position = punto.global_position
