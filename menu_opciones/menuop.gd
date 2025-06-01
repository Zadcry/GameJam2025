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

const CONFIG_PATH := "user://config.cfg"

@onready var modo_label = $Label
@onready var resolucion_label = $Label2
@onready var flecha_izq = $Label3
@onready var flecha_der = $Label4
@onready var opciones_visual = $Opciones
@onready var boton_salir = $Salir
@onready var progres_bar_sfx = $sfx
@onready var progres_bar_musica = $musica

func _ready():
	# Debug: Verify node references
	print("OptionsMenu _ready: Nodes: modo_label=", modo_label, " resolucion_label=", resolucion_label, " flecha_izq=", flecha_izq, " flecha_der=", flecha_der, " boton_salir=", boton_salir)
	if modo_label: print("modo_label rect: ", modo_label.get_global_rect())
	if flecha_izq: print("flecha_izq rect: ", flecha_izq.get_global_rect())
	if flecha_der: print("flecha_der rect: ", flecha_der.get_global_rect())
	if boton_salir: print("boton_salir rect: ", boton_salir.get_global_rect())
	
	_load_config()
	_aplicar_fuente()
	_aplicar_configuracion()
	_actualizar_label_resolucion()
	_actualizar_visibilidad_flechas()
	_animate_entrance()
	print("OptionsMenu _ready: Completed")

func _animate_entrance():
	var tween = create_tween().set_parallel(true)
	var screen_height = get_viewport_rect().size.y
	
	var nodes = [modo_label, resolucion_label, flecha_izq, flecha_der, opciones_visual, boton_salir, progres_bar_sfx, progres_bar_musica]
	
	for node in nodes:
		if node:
			var original_pos = node.position
			node.position.y += screen_height
			tween.tween_property(node, "position:y", original_pos.y, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	print("OptionsMenu _animate_entrance: Started")

func _animate_exit():
	var tween = create_tween().set_parallel(true)
	var screen_height = get_viewport_rect().size.y
	
	var nodes = [modo_label, resolucion_label, flecha_izq, flecha_der, opciones_visual, boton_salir, progres_bar_sfx, progres_bar_musica]
	
	for node in nodes:
		if node:
			# Slide upward off-screen (top-down exit)
			tween.tween_property(node, "position:y", node.position.y - screen_height, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	tween.tween_callback(_on_exit_animation_finished)
	print("OptionsMenu _animate_exit: Started downward animation")

func _on_exit_animation_finished():
	emit_signal("closed")
	print("OptionsMenu _on_exit_animation_finished: Emitted 'closed' signal")

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var click_position = event.position
		print("OptionsMenu _input: Click at: ", click_position)
		
		if modo_label and modo_label.get_global_rect().has_point(click_position) and event.button_index == MOUSE_BUTTON_LEFT:
			print("OptionsMenu _input: Modo label clicked, current mode: ", opciones[indice_actual])
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
			print("OptionsMenu _input: New mode: ", opciones[indice_actual])

		if opciones[indice_actual] == "Ventana":
			if flecha_izq and flecha_izq.get_global_rect().has_point(click_position) and event.button_index == MOUSE_BUTTON_LEFT:
				if indice_resolucion > 0:
					indice_resolucion -= 1
					DisplayServer.window_set_size(resoluciones[indice_resolucion])
					_actualizar_label_resolucion()
					_actualizar_visibilidad_flechas()
					_save_config()
					print("OptionsMenu _input: Resolution decreased to: ", resoluciones[indice_resolucion])
			if flecha_der and flecha_der.get_global_rect().has_point(click_position) and event.button_index == MOUSE_BUTTON_LEFT:
				if indice_resolucion < resoluciones.size() - 1:
					indice_resolucion += 1
					DisplayServer.window_set_size(resoluciones[indice_resolucion])
					_actualizar_label_resolucion()
					_actualizar_visibilidad_flechas()
					_save_config()
					print("OptionsMenu _input: Resolution increased to: ", resoluciones[indice_resolucion])

		if boton_salir and boton_salir.get_global_rect().has_point(click_position) and event.button_index == MOUSE_BUTTON_LEFT:
			print("OptionsMenu _input: Salir button clicked")
			_animate_exit()

func _actualizar_label_resolucion():
	var res = resoluciones[indice_resolucion]
	resolucion_label.text = "%dx%d" % [res.x, res.y]

func _actualizar_visibilidad_flechas():
	# Validate indice_actual to prevent out-of-bounds access
	if indice_actual < 0 or indice_actual >= opciones.size():
		print("OptionsMenu _actualizar_visibilidad_flechas: Error: indice_actual out of bounds: ", indice_actual)
		indice_actual = clamp(indice_actual, 0, opciones.size() - 1)
	
	# Debug print to check the value being compared
	print("OptionsMenu _actualizar_visibilidad_flechas: opciones[indice_actual]: ", opciones[indice_actual], " | Comparing with 'Ventana'")
	var arrows_visible = opciones[indice_actual] == "Ventana"
	print("OptionsMenu _actualizar_visibilidad_flechas: arrows_visible: ", arrows_visible)
	
	flecha_izq.visible = arrows_visible
	flecha_der.visible = arrows_visible

	flecha_izq.text = "<"
	flecha_der.text = ">"

	if arrows_visible:
		flecha_izq.modulate.a = 0.3 if indice_resolucion <= 0 else 1.0
		flecha_der.modulate.a = 0.3 if indice_resolucion >= resoluciones.size() - 1 else 1.0

func _aplicar_configuracion():
	# Validate indice_actual
	if indice_actual < 0 or indice_actual >= opciones.size():
		print("OptionsMenu _aplicar_configuracion: Error: Invalid indice_actual: ", indice_actual)
		indice_actual = 0
	
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
		print("OptionsMenu _load_config: Failed to load config file: ", err)
		indice_actual = 0 # Default to "Completa" if config fails
		indice_resolucion = 4
		ultima_resolucion_ventana = indice_resolucion
		

	
