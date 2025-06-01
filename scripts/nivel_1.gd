extends Node2D

@onready var personaje : CharacterBody2D = $PersonajePrincipal
@onready var aliados : Node = $Aliados
@onready var enemigos : Node = $Enemigos
@onready var enterTxt : CanvasLayer = $Enter
@onready var misionTxt : CanvasLayer = $Mision
@onready var menu_pausa = preload("res://menu_pausa/Menu_P.tscn").instantiate()
@onready var game_over_menu = preload("res://game_over/gameo.tscn").instantiate()

const enemy_grown_speed : float = 0.015
const enemy_move_speed : float = 15
const MAX_POSITION_Y = 325.0
const MAX_SCALE = 2.0
const MAX_COLLIDER_EXTENTS = Vector2(64, 64)
const MAX_COLLIDER_RADIUS = 64.0
var position_reached: bool = false
const reached_anim = preload("res://sprites/enemigoDisparando.tres")

var tiempo_acumulado = 0.0
var intervalo = 2.0
var aliadosMuertos = 0
var enemigosMuertos = 0
var levelBeaten = false
var paused = false

func _ready():
	enterTxt.visible=false
	misionTxt.visible=true
	# Agregar el menú de pausa como hijo
	add_child(menu_pausa)
	menu_pausa.process_mode = Node.PROCESS_MODE_ALWAYS
	menu_pausa.visible = false  # Ocultar al inicio
	# Agregar el menú de game over como hijo
	add_child(game_over_menu)
	game_over_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	game_over_menu.visible = false  # Ocultar al inicio
	game_over_menu.set_current_level(get_tree().current_scene.scene_file_path)  # Establecer el nivel actual
	# Asegurar que los menús estén en la capa superior
	menu_pausa.z_index = 100
	game_over_menu.z_index = 100
	# Inicialmente ocultar el cursor del sistema durante el juego
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER and levelBeaten:
		get_tree().change_scene_to_file("res://escenas_niveles/nivel2.tscn")
		return

func _process(delta: float) -> void:
	checkGameOver(delta)
	# Gestionar la visibilidad del cursor del sistema
	if paused or game_over_menu.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE  # Mostrar el cursor del sistema para clic
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN  # Ocultar el cursor durante el juego
	
	if paused:
		return
	
	for enemigo in enemigos.get_children():
		if enemigo is Area2D and !enemigo.is_dead:
			acercar_personaje(enemigo, delta)
		elif enemigo.is_dead:
			enemigosMuertos+=1
	if enemigosMuertos >= 2:
		levelBeaten = true
		enterTxt.visible = true
	else:
		enemigosMuertos = 0

	# Manejar la pausa
	if Input.is_action_just_pressed("ui_cancel"):
		if not paused and not game_over_menu.visible:
			paused = true
			get_tree().paused = true
			menu_pausa.visible = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE  # Asegurar cursor visible en pausa

func acercar_personaje(personaje: Area2D, delta):
	if position_reached and !personaje.is_dead:
		personaje.is_shooting = true
		buscarAliadosVivos(delta)
	elif personaje.is_dead:
		personaje.is_shooting = false
	
	# Movimiento hacia abajo con límite
	if personaje.position.y < MAX_POSITION_Y:
		personaje.position.y += enemy_move_speed * delta
	else:
		personaje.position.y = MAX_POSITION_Y
		position_reached = true

	# Crecimiento visual con límite
	if (personaje.scale.x < MAX_SCALE - 0.01 or personaje.scale.y < MAX_SCALE - 0.01) and position_reached == false:
		var nueva_escala = personaje.scale + Vector2.ONE * enemy_grown_speed * delta
		nueva_escala.x = min(nueva_escala.x, MAX_SCALE)
		nueva_escala.y = min(nueva_escala.y, MAX_SCALE)
		personaje.scale = nueva_escala

func buscarAliadosVivos(delta):
	tiempo_acumulado += delta
	if tiempo_acumulado >= intervalo:
		tiempo_acumulado -= intervalo
		var alive_allies = 0
		for aliado in aliados.get_children():
			if aliado.is_dead == false:
				if randf() < 0.2:
					aliado.is_dead = true

func checkGameOver(delta):
	for aliado in aliados.get_children():
		if aliado.is_dead:
			aliadosMuertos+=1
	if aliadosMuertos == 2 and !levelBeaten:
		print("todos los aliados muertos")
		misionTxt.visible=false
		enterTxt.visible=false
		game_over_menu.show_game_over()
		return
	else:
		aliadosMuertos = 0


func unpause():
	paused = false
	get_tree().paused = false
	menu_pausa.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN  # Ocultar cursor al reanudar
