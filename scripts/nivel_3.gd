extends Node2D

@onready var personaje : CharacterBody2D = $PersonajePrincipal
@onready var aliados : Node = $Aliados
@onready var enemigos : Node = $Enemigos
@onready var enterTxt : CanvasLayer = $Enter
@onready var misionTxt : CanvasLayer = $Mision
@onready var rifles : AudioStreamPlayer2D = $Rifles
@onready var sandstorm : AudioStreamPlayer2D = $SandStorm
@onready var menu_pausa = preload("res://menu_pausa/Menu_P.tscn").instantiate()
@onready var game_over_menu = preload("res://game_over/gameo.tscn").instantiate()

const enemy_grown_speed : float = 0.015
const enemy_move_speed : float = 15
const MAX_POSITION_Y = 325.0
const MAX_SCALE = 2.0
const MAX_COLLIDER_EXTENTS = Vector2(64, 64)
const MAX_COLLIDER_RADIUS = 64.0
const reached_anim = preload("res://sprites/enemigoDisparando.tres")

var tiempo_acumulado = 0.0
var intervalo = 2.0
var aliadosMuertos = 0
var enemigosMuertos = 0
var levelBeaten = false
var game_over = false
var enemy_states: Dictionary = {}

var tiempoAcomuladoEnemigos = 0.0
var intervaloEnemigos = 1.0

func _ready():
	enterTxt.visible=false
	misionTxt.visible=true
	sandstorm.play()
	add_child(menu_pausa)
	menu_pausa.process_mode = Node.PROCESS_MODE_ALWAYS
	menu_pausa.visible = false
	add_child(game_over_menu)
	game_over_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	game_over_menu.visible = false
	game_over_menu.set_current_level(get_tree().current_scene.scene_file_path)
	menu_pausa.z_index = 100
	game_over_menu.z_index = 100
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	# Initialize enemy states
	for enemigo in enemigos.get_children():
		enemy_states[enemigo] = {"position_reached": false}

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER and levelBeaten:
		get_tree().change_scene_to_file("res://escenas_niveles/nivel2.tscn")
		return

func _process(delta: float) -> void:
	checkGameOver(delta)
	enemyShootingSFX(delta)
	
	if game_over or get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	
	for enemigo in enemigos.get_children():
		if enemigo is Area2D and !enemigo.is_dead:
			acercar_personaje(enemigo, delta)
		elif enemigo.is_dead:
			enemigosMuertos += 1
	if enemigosMuertos >= 6:
		levelBeaten = true
		enterTxt.visible = true
	else:
		enemigosMuertos = 0

	if Input.is_action_just_pressed("ui_cancel"):
		if not get_tree().paused and not game_over:
			get_tree().paused = true
			menu_pausa.visible = true
			if menu_pausa.has_method("show_pause_menu"):
				menu_pausa.show_pause_menu()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func acercar_personaje(personaje: Area2D, delta):
	if personaje.is_dead:
		personaje.is_shooting = false
		return

	# Initialize state if not present
	if not enemy_states.has(personaje):
		enemy_states[personaje] = {"position_reached": false}

	# Debug print to track enemy state
	#print("Enemy: ", personaje.name, " Pos: ", personaje.position.y, " Reached: ", enemy_states[personaje]["position_reached"], " Scale: ", personaje.scale)

	# Movement
	if personaje.position.y < MAX_POSITION_Y:
		personaje.position.y += enemy_move_speed * delta
		enemy_states[personaje]["position_reached"] = false
	else:
		personaje.position.y = MAX_POSITION_Y
		enemy_states[personaje]["position_reached"] = true

	# Growth
	if not enemy_states[personaje]["position_reached"] and (personaje.scale.x < MAX_SCALE - 0.01 or personaje.scale.y < MAX_SCALE - 0.01):
		var nueva_escala = personaje.scale + Vector2.ONE * enemy_grown_speed * delta
		nueva_escala.x = min(nueva_escala.x, MAX_SCALE)
		nueva_escala.y = min(nueva_escala.y, MAX_SCALE)
		personaje.scale = nueva_escala

	# Collider growth
	var collider = personaje.get_node_or_null("CollisionShape2D")
	if collider and collider.shape and not enemy_states[personaje]["position_reached"]:
		var shape = collider.shape
		if shape is RectangleShape2D:
			if shape.extents.x < MAX_COLLIDER_EXTENTS.x - 0.1 or shape.extents.y < MAX_COLLIDER_EXTENTS.y - 0.1:
				var new_extents = shape.extents + Vector2.ONE * enemy_grown_speed * delta
				new_extents.x = min(new_extents.x, MAX_COLLIDER_EXTENTS.x)
				new_extents.y = min(new_extents.y, MAX_COLLIDER_EXTENTS.y)
				shape.extents = new_extents
			else:
				shape.extents = MAX_COLLIDER_EXTENTS
		elif shape is CircleShape2D:
			if shape.radius < MAX_COLLIDER_RADIUS - 0.1:
				var new_radius = shape.radius + enemy_grown_speed * delta * 10
				shape.radius = min(new_radius, MAX_COLLIDER_RADIUS)
			else:
				shape.radius = MAX_COLLIDER_RADIUS

	# Shooting
	if enemy_states[personaje]["position_reached"] and not personaje.is_dead:
		personaje.is_shooting = true
		buscarAliadosVivos(delta)

func buscarAliadosVivos(delta):
	tiempo_acumulado += delta
	if tiempo_acumulado >= intervalo:
		tiempo_acumulado -= intervalo
		for aliado in aliados.get_children():
			if not aliado.is_dead:
				if randf() < 0.2:
					aliado.is_dead = true

func checkGameOver(delta):
	for aliado in aliados.get_children():
		if aliado.is_dead:
			aliadosMuertos += 1
	if aliadosMuertos == 3 and !levelBeaten:
		print("todos los aliados muertos")
		misionTxt.visible=false
		enterTxt.visible=false
		game_over = true
		game_over_menu.show_game_over()
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if personaje:
			personaje.set_game_over(true)
		return
	else:
		aliadosMuertos = 0

func resume_enemies():
	for enemigo in enemigos.get_children():
		if enemigo is Area2D and not enemigo.is_dead:
			if not enemy_states.has(enemigo):
				enemy_states[enemigo] = {"position_reached": false}
			enemy_states[enemigo]["position_reached"] = enemigo.position.y >= MAX_POSITION_Y
			if enemy_states[enemigo]["position_reached"]:
				enemigo.is_shooting = true
			else:
				enemigo.is_shooting = false
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

func enemyShootingSFX(delta):
	tiempoAcomuladoEnemigos += delta
	if tiempoAcomuladoEnemigos >= intervaloEnemigos:
		tiempoAcomuladoEnemigos -= intervaloEnemigos
		for enemigo in enemigos.get_children():
			if enemigo.is_shooting:
				enemigo.shooting_sfx.play()
