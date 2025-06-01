extends Node2D

# Referencias a los TextureButtons y nodos visibles
@onready var retry_button = $retry
@onready var quit_button = $saliro
# Variable para almacenar la escena actual
var current_level_scene = ""

func _ready():
	# Ocultar el menú al inicio configurando la opacidad a 0
	modulate.a = 0.0
	retry_button.modulate.a = 0.0
	quit_button.modulate.a = 0.0
	# Conectar señales de los TextureButtons
	retry_button.pressed.connect(_on_retry_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

# Función para mostrar el menú de game over con efecto de disolver
func show_game_over():
	visible = true  # Hacer visible el Node2D
	get_tree().paused = true  # Pausar el juego
	
	# Crear un Tween para animar el efecto de disolver
	var tween = create_tween()
	
	# Animar la opacidad del Node2D (fondo del menú) de 0 a 1 en 0.5 segundos
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	
	# Animar los botones con un retraso para que aparezcan después del fondo
	tween.tween_property(retry_button, "modulate:a", 1.0, 0.5).set_delay(0.3)
	tween.tween_property(quit_button, "modulate:a", 1.0, 0.5).set_delay(0.2)

# Función para el botón de reintentar
func _on_retry_button_pressed():
	get_tree().paused = false  # Reanudar el juego
	# Cambiar a la escena del nivel actual
	if current_level_scene != "":
		get_tree().change_scene_to_file(current_level_scene)

# Función para el botón de salir
func _on_quit_button_pressed():
	get_tree().paused = false  # Reanudar antes de salir
	get_tree().change_scene_to_file("res://menu_inicial/menuI.tscn")  # Ajusta la ruta al menú principal

# Establecer la escena del nivel actual
func set_current_level(level_path: String):
	current_level_scene = level_path
