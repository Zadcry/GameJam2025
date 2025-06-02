extends CharacterBody2D

@onready var camera := $MainCamera
@onready var cursor_follower := $CursorFollower
@onready var flash_rect : ColorRect = $PantallaFlash
@onready var menu_p = preload("res://menu_pausa/Menu_P.tscn").instantiate()
@onready var disparo : AudioStreamPlayer = $Disparo
@onready var latido : AudioStreamPlayer2D = $Latido
@onready var respiracion : AudioStreamPlayer2D = $Respiracion
@onready var filtro : ColorRect = $Filtro
@onready var voz_inocentes : AudioStreamPlayer2D = $VozInocentes
@onready var pause_label : Label = $Label

const CURSOR_NORMAL = preload("res://images/puntero.png")
const CURSOR_ZOOMED = preload("res://images/ScopeReescalada.png")
const FLASH_DURATION := 3.1

var cordura : float
var zoomed := false
var paused := false
var game_over = false
var state := true
var shake_strenght : float
var time := 0.0
var amplitude : float = 0.0
var frequency : float = 0.0
var flash_timer = 0.0
var flashing : bool = false
var zoom_normal : Vector2 = Vector2(1, 1)
var zoom_in : Vector2 = Vector2(2.5, 2.5)
var ya_sono : bool = false
var ya_sono_respiracion : bool = false
var voces = []
var voces_activadas : bool = false
var ultima_voz_index := -1
var inocentes_reproducida : bool = false
var pause_label_timer : float = 0.0
const PAUSE_LABEL_DURATION := 2.0

func _ready():
	voces = [
		$Voces/dispara,
		$Voces/no_lo_hagas,
		$Voces/que_haces,
		$Voces/hazlo,
		$Voces/acabalo,
		$Voces/confia,
		$Voces/ya_detente,
		$Voces/no_eres_capaz
	]
	add_child(menu_p)
	menu_p.process_mode = Node.PROCESS_MODE_ALWAYS
	menu_p.visible = false
	# Pasar referencia de este nodo al menú de pausa
	menu_p.player_node = self
	# Centrar el menú de pausa en la pantalla
	var viewport_size = get_viewport_rect().size
	menu_p.position = viewport_size / 2
	# Configurar el label de pausa
	pause_label.visible = false
	pause_label.text = "No puedes pausar en este estado"
	var font = load("res://Fuente/Perfect DOS VGA 437.ttf")
	pause_label.set("theme_override_fonts/font", font)
	pause_label.set("theme_override_font_sizes/font_size", 16)
	pause_label.position = viewport_size / 2 - Vector2(100, 20)
	# Inicializar resto de componentes
	randomize()
	camera.zoom = zoom_normal
	camera.position = Vector2.ZERO
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	cordura = GLOBAL.cordura
	flash_rect.visible = false

func _process(delta):
	if paused or game_over:
		return
	
	time += delta
	if zoomed:
		follow_cursor()

	var mouse_pos = get_viewport().get_mouse_position()
	var world_mouse_pos = screen_to_world(mouse_pos)
	
	if GLOBAL.cordura < 90 and GLOBAL.cordura > 80:
		chequear_voz_inocentes()
	
	if flashing:
		flash_timer += delta
		var t = flash_timer / FLASH_DURATION
		flash_rect.modulate.a = lerpf(1.0, 0.0, t)
		if t >= 1.0:
			flashing = false
			flash_rect.visible = false

	# Gestionar movimiento del cursor según cordura
	if GLOBAL.cordura > 95.0 and GLOBAL.cordura <= 100.0:
		filtro.modulate = Color(1,1,1,0)
		if not ya_sono_respiracion:
			respiracion.play()
			ya_sono_respiracion = true
		amplitude = 2.5
		frequency = 1.5
		var offset_x = sin(time * frequency) * amplitude
		var offset_y = cos(time * frequency * 1.3) * amplitude * 0.7
		var offset = Vector2(offset_x, offset_y)
		cursor_follower.global_position = world_mouse_pos + offset
	elif GLOBAL.cordura > 85.0 and GLOBAL.cordura <= 95:
		filtro.modulate = Color(1,1,1,0.05)
		amplitude = 3.5
		frequency = 2.5
		var offset_x = sin(time * frequency) * amplitude
		var offset_y = cos(time * frequency * 1.3) * amplitude * 0.7
		var offset = Vector2(offset_x, offset_y)
		cursor_follower.global_position = world_mouse_pos + offset
	elif GLOBAL.cordura > 70 and GLOBAL.cordura <= 85:
		filtro.modulate = Color(1,1,1,0.1)
		if respiracion.playing:
			respiracion.stop()
		if not ya_sono:
			latido.play()
			ya_sono = true
		var shake_strength = 0.4
		var offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		cursor_follower.global_position = world_mouse_pos + offset
	elif GLOBAL.cordura > 60 and GLOBAL.cordura <= 70:
		filtro.modulate = Color(1,1,1,0.15)
		var shake_strength = 0.8
		var offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		cursor_follower.global_position = world_mouse_pos + offset
	elif GLOBAL.cordura > 45 and GLOBAL.cordura <= 60:
		filtro.modulate = Color(1,1,1,0.2)
		if latido.playing:
			latido.stop()
		cursor_follower.global_position = world_mouse_pos
	elif GLOBAL.cordura > 35  and GLOBAL.cordura <= 45:
		filtro.modulate = Color(1,1,1,0.25)
		if GLOBAL.scoped and not voces_activadas:
			activar_voces()
			voces_activadas = true
		cursor_follower.global_position = world_mouse_pos
	elif GLOBAL.cordura > 20  and GLOBAL.cordura <= 35:
		filtro.modulate = Color(1,1,1,0.3)
		cursor_follower.global_position = world_mouse_pos
	elif GLOBAL.cordura > 10  and GLOBAL.cordura <= 20:
		filtro.modulate = Color(1,1,1,0.4)
		cursor_follower.global_position = world_mouse_pos
	elif GLOBAL.cordura > 1  and GLOBAL.cordura <= 10:
		filtro.modulate = Color(1,1,1,0.5)
		cursor_follower.global_position = world_mouse_pos
	elif GLOBAL.cordura <= 1:
		filtro.modulate = Color(1,1,1,0.7)
		cursor_follower.global_position = world_mouse_pos
	else:
		cursor_follower.global_position = world_mouse_pos

	# Actualizar temporizador del label de pausa (en caso de que se use en otro contexto)
	if pause_label.visible:
		pause_label_timer += delta
		if pause_label_timer >= PAUSE_LABEL_DURATION:
			pause_label.visible = false
			pause_label_timer = 0.0

	# Manejar zoom
	if Input.is_action_just_pressed("toggle_zoom") and !paused and !game_over:
		zoomed = !zoomed
		GLOBAL.scoped = zoomed
		if zoomed:
			camera.zoom = zoom_in
			cursor_follower.texture = CURSOR_ZOOMED
			cursor_follower.scale = Vector2(0.81, 0.81)
			# Deshabilitar ui_cancel globalmente
			GLOBAL.disable_ui_cancel()
		else:
			camera.zoom = zoom_normal
			camera.position = Vector2.ZERO
			cursor_follower.texture = CURSOR_NORMAL
			cursor_follower.scale = Vector2(0.5, 0.5)
			# Rehabilitar ui_cancel globalmente
			GLOBAL.enable_ui_cancel()

	# Manejar pausa
	if Input.is_action_just_pressed("ui_cancel") and !game_over and !zoomed:
		if !paused:
			paused = true
			get_tree().paused = true
			menu_p.visible = true
			# Llamar a la función para mostrar el menú si existe
			if menu_p.has_method("show_pause_menu"):
				menu_p.show_pause_menu()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			paused = false
			get_tree().paused = false
			menu_p.visible = false
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
			# Rehabilitar ui_cancel al despausar
			GLOBAL.enable_ui_cancel()

func _unhandled_input(event):
	# No procesar inputs si está pausado o en game over
	if paused or game_over:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and GLOBAL.scoped:
		disparo.play()
		iniciar_flash()

func disable_ui_cancel():
	# Deshabilitar la acción ui_cancel eliminando sus eventos
	GLOBAL.ui_cancel_events = InputMap.action_get_events("ui_cancel").duplicate()
	InputMap.action_erase_events("ui_cancel")

func enable_ui_cancel():
	# Restaurar los eventos de ui_cancel
	InputMap.action_erase_events("ui_cancel")
	for event in GLOBAL.ui_cancel_events:
		InputMap.action_add_event("ui_cancel", event)

func follow_cursor():
	var mouse_pos = get_viewport().get_mouse_position()
	var world_mouse_pos = screen_to_world(mouse_pos)
	var cam_offset = (world_mouse_pos - global_position).clamp(-Vector2(300, 200), Vector2(300, 200))
	var target_position = global_position + cam_offset
	var lerp_speed = 0.4 if not zoomed else 0.05
	camera.global_position = camera.global_position.lerp(target_position, lerp_speed)

func screen_to_world(screen_pos: Vector2) -> Vector2:
	return camera.get_canvas_transform().affine_inverse() * screen_pos

func reducir_cordura(valor: int) -> void:
	GLOBAL.cordura = max(GLOBAL.cordura - valor, 0)
	print("Cordura actual:", GLOBAL.cordura)

func iniciar_flash():
	flash_rect.visible = true
	flash_rect.modulate.a = 1.0
	flashing = true
	flash_timer = 0.0

func set_game_over(value: bool):
	game_over = value
	if game_over and zoomed:
		# Desactivar la mira y volver a la vista general
		zoomed = false
		GLOBAL.scoped = false
		camera.zoom = zoom_normal
		camera.position = Vector2.ZERO
		cursor_follower.texture = CURSOR_NORMAL
		cursor_follower.scale = Vector2(0.5, 0.5)
		# Rehabilitar ui_cancel al entrar en game over
		GLOBAL.enable_ui_cancel()

func hide_cursor():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

func activar_voces():
	reproducir_voz_random()
	
func reproducir_voz_random():
	var nueva_index := randi() % voces.size()
	while nueva_index == ultima_voz_index and voces.size() > 1:
		nueva_index = randi() % voces.size()
	ultima_voz_index = nueva_index
	var voz = voces[nueva_index]
	if not voz.playing:
		voz.play()
	await get_tree().create_timer(randf_range(1.0, 4.0)).timeout
	if cordura <= 45 and GLOBAL.scoped:
		reproducir_voz_random()

func chequear_voz_inocentes():
	if not inocentes_reproducida and GLOBAL.cordura < 90 and GLOBAL.cordura > 80:
		inocentes_reproducida = true
		esperar_y_reproducir()

func esperar_y_reproducir() -> void:
	await get_tree().create_timer(2.0).timeout
	voz_inocentes.play()
