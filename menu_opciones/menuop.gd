extends Node2D

signal closed # Signal to notify the parent scene when exiting

var opciones = ["Completa", "Ventana"]
var indice_actual = 0

var resoluciones = [
	Vector2i(800, 600),
	Vector2i(1024, 768),
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080)
]
var indice_resolucion = 4
var ultima_resolucion_ventana = indice_resolucion
var dragging_musica := false

const CONFIG_PATH := "user://config.cfg"

@onready var modo_label = $Label
@onready var resolucion_label = $Label2
@onready var flecha_izq = $Label3
@onready var flecha_der = $Label4
@onready var opciones_visual = $Opciones2
@onready var boton_salir = $Salir
@onready var progres_bar_musica = $musica

func _ready():
	_load_config()
	_aplicar_fuente()
	_aplicar_configuracion()
	_actualizar_label_resolucion()
	_actualizar_visibilidad_flechas()
	_actualizar_barras_volumen()
	_animate_entrance()

func _animate_entrance():
	var tween = create_tween().set_parallel(true)
	var screen_height = get_viewport_rect().size.y
	
	var nodes = [modo_label, resolucion_label, flecha_izq, flecha_der, opciones_visual, boton_salir, progres_bar_musica]
	
	for node in nodes:
		if node:
			var original_pos = node.position
			node.position.y += screen_height
			tween.tween_property(node, "position:y", original_pos.y, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _animate_exit():
	var tween = create_tween().set_parallel(true)
	var screen_height = get_viewport_rect().size.y
	
	var nodes = [modo_label, resolucion_label, flecha_izq, flecha_der, opciones_visual, boton_salir, progres_bar_musica]
	
	for node in nodes:
		if node:
			tween.tween_property(node, "position:y", node.position.y - screen_height, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	tween.tween_callback(_on_exit_animation_finished)

func _on_exit_animation_finished():
	emit_signal("closed")

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var click_position = event.position
		
		if modo_label and modo_label.get_global_rect().has_point(click_position) and event.button_index == MOUSE_BUTTON_LEFT:
			if opciones[indice_actual] == "Ventana":
				ultima_resolucion_ventana = indice_resolucion

			indice_actual = (indice_actual + 1) % opciones.size()
			modo_label.text = opciones[indice_actual]

			match opciones[indice_actual]:
				"Completa":
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
					resolucion_label.modulate.a = 0.5
					indice_resolucion = ultima_resolucion_ventana
				"Ventana":
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
					indice_resolucion = ultima_resolucion_ventana
					DisplayServer.window_set_size(resoluciones[indice_resolucion])
					resolucion_label.modulate.a = 1.0

			_actualizar_label_resolucion()
			_actualizar_visibilidad_flechas()
			_save_config()

		if opciones[indice_actual] == "Ventana":
			if flecha_izq and flecha_izq.get_global_rect().has_point(click_position) and event.button_index == MOUSE_BUTTON_LEFT:
				if indice_resolucion > 0:
					indice_resolucion -= 1
					DisplayServer.window_set_size(resoluciones[indice_resolucion])
					_actualizar_label_resolucion()
					_actualizar_visibilidad_flechas()
					_save_config()
			if flecha_der and flecha_der.get_global_rect().has_point(click_position) and event.button_index == MOUSE_BUTTON_LEFT:
				if indice_resolucion < resoluciones.size() - 1:
					indice_resolucion += 1
					DisplayServer.window_set_size(resoluciones[indice_resolucion])
					_actualizar_label_resolucion()
					_actualizar_visibilidad_flechas()
					_save_config()

		if boton_salir and boton_salir.get_global_rect().has_point(click_position) and event.button_index == MOUSE_BUTTON_LEFT:
			_animate_exit()
		
		# Manejo de arrastre en barra de volumen de música
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if progres_bar_musica.get_global_rect().has_point(click_position):
					dragging_musica = true
					_set_volume_from_mouse(progres_bar_musica, click_position.x)
				else:
					dragging_musica = false
			else:
				dragging_musica = false

	elif event is InputEventMouseMotion:
		if dragging_musica:
			if progres_bar_musica.get_global_rect().has_point(event.position):
				_set_volume_from_mouse(progres_bar_musica, event.position.x)
			else:
				dragging_musica = false

func _actualizar_label_resolucion():
	var res = resoluciones[indice_resolucion]
	resolucion_label.text = "%dx%d" % [res.x, res.y]

func _actualizar_visibilidad_flechas():
	var arrows_visible = opciones[indice_actual] == "Ventana"
	flecha_izq.visible = arrows_visible
	flecha_der.visible = arrows_visible

	flecha_izq.text = "<"
	flecha_der.text = ">"

	if arrows_visible:
		flecha_izq.modulate.a = 0.3 if indice_resolucion <= 0 else 1.0
		flecha_der.modulate.a = 0.3 if indice_resolucion >= resoluciones.size() - 1 else 1.0

func _aplicar_configuracion():
	modo_label.text = opciones[indice_actual]

	match opciones[indice_actual]:
		"Completa":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			resolucion_label.modulate.a = 0.5
		"Ventana":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(resoluciones[indice_resolucion])
			resolucion_label.modulate.a = 1.0

func _aplicar_fuente():
	var fuente_archivo : FontFile = load("res://Fuente/Perfect DOS VGA 437.ttf")
	var label_settings = LabelSettings.new()
	label_settings.font = fuente_archivo
	label_settings.font_size = 48

	for label in [modo_label, resolucion_label, flecha_izq, flecha_der]:
		if label:
			label.label_settings = label_settings.duplicate()
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _set_volume_from_mouse(bar: TextureProgressBar, mouse_x: float) -> void:
	var rect: Rect2 = bar.get_global_rect()
	var relative_x: float = clamp(mouse_x - rect.position.x, 0.0, rect.size.x)
	var value: float = relative_x / rect.size.x
	bar.value = value * bar.max_value
	_update_audio_volume(bar)

func _update_audio_volume(bar: TextureProgressBar):
	var volume := bar.value / bar.max_value
	if bar == progres_bar_musica:
		print("Master Volume set to: ", volume)
		AudioManager.set_master_volume(volume)

func _actualizar_barras_volumen():
	progres_bar_musica.value = AudioManager.get_master_volume() * progres_bar_musica.max_value

func _save_config():
	var config = ConfigFile.new()
	config.set_value("pantalla", "modo", indice_actual)
	config.set_value("pantalla", "resolucion", indice_resolucion)
	config.set_value("pantalla", "ultima_ventana", ultima_resolucion_ventana)
	config.save(CONFIG_PATH)

func _load_config():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	if err == OK:
		indice_actual = int(config.get_value("pantalla", "modo", 0))
		indice_resolucion = int(config.get_value("pantalla", "resolucion", 4))
		ultima_resolucion_ventana = int(config.get_value("pantalla", "ultima_ventana", indice_resolucion))
	else:
		indice_actual = 0
		indice_resolucion = 4
		ultima_resolucion_ventana = indice_resolucion
