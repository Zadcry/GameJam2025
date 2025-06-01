extends Node

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

func _ready():
	_load_config()
	_apply_settings()

func cambiar_modo():
	indice_actual = (indice_actual + 1) % opciones.size()
	if opciones[indice_actual] == "Completa":
		ultima_resolucion_ventana = indice_resolucion
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		indice_resolucion = 4
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(resoluciones[indice_resolucion])
		ultima_resolucion_ventana = indice_resolucion
	_save_config()

func cambiar_resolucion(direccion:int):
	if opciones[indice_actual] == "Ventana":
		if direccion < 0 and indice_resolucion > 0:
			indice_resolucion -= 1
		elif direccion > 0 and indice_resolucion < resoluciones.size() - 1:
			indice_resolucion += 1
		DisplayServer.window_set_size(resoluciones[indice_resolucion])
		ultima_resolucion_ventana = indice_resolucion
		_save_config()

func _apply_settings():
	if opciones[indice_actual] == "Completa":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		indice_resolucion = 4
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(resoluciones[indice_resolucion])

func _save_config():
	var config = ConfigFile.new()
	config.set_value("pantalla", "modo", indice_actual)
	config.set_value("pantalla", "resolucion", indice_resolucion)
	config.set_value("pantalla", "ultima_ventana", ultima_resolucion_ventana)
	config.save(CONFIG_PATH)

func _load_config():
	var config = ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		indice_actual = config.get_value("pantalla", "modo", 0)
		indice_resolucion = config.get_value("pantalla", "resolucion", 4)
		ultima_resolucion_ventana = config.get_value("pantalla", "ultima_ventana", indice_resolucion)
