extends Node2D

# Referencias a los nodos de los botones
@onready var click_button = $click
@onready var jugar_button = $Jugar
@onready var opciones_button = $Opciones
@onready var salir_button = $Salir

# Variable para controlar el parpadeo
var blink_timer = 0.0
var blink_speed = 5.0 # Velocidad del parpadeo más rápida
var menu_shown = false # Para evitar repetición de la animación

func _ready():
	# Inicialmente ocultar los botones de Jugar, Opciones y Salir
	jugar_button.hide()
	opciones_button.hide()
	salir_button.hide()

func _process(delta):
	# Actualizar el temporizador para el parpadeo solo si el menú no se ha mostrado
	if not menu_shown:
		blink_timer += delta * blink_speed
		# Usar una función seno para hacer que el botón parpadee (cambia la transparencia)
		var alpha = (sin(blink_timer) + 1) / 2 # Valor entre 0 y 1
		click_button.modulate.a = alpha # Aplicar la transparencia

func _input(event):
	# Detectar clic izquierdo del ratón
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Obtener la posición del clic
		var click_position = get_global_mouse_position()
		# Comprobar si el clic está dentro del área del botón click
		if not menu_shown and click_button.get_global_rect().has_point(click_position):
			# Ocultar el botón Click
			click_button.hide()
			# Iniciar animaciones para mostrar los botones
			animate_button_appearance(jugar_button, 0.0)
			animate_button_appearance(opciones_button, 0.2)
			animate_button_appearance(salir_button, 0.4)
			menu_shown = true
		# Comprobar si el clic está dentro del área del botón salir
		elif menu_shown and salir_button.get_global_rect().has_point(click_position):
			# Cerrar el juego
			get_tree().quit()

# Animación para que los botones aparezcan sin cambiar su posición original
func animate_button_appearance(button, delay):
	var tween = create_tween()
	button.show()
	# Restaurar la posición original después de la animación
	var original_position = button.position
	# Posición inicial fuera de la pantalla (abajo)
	button.position.y = 800
	# Animar de vuelta a la posición original
	tween.tween_property(button, "position", original_position, 0.5).set_delay(delay).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	# Escalar desde pequeño a normal con efecto de rebote
	tween.parallel().tween_property(button, "scale", Vector2(1.2, 1.2), 0.3).set_delay(delay)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

# Cuando se presiona el botón Jugar
func _on_jugar_button_pressed():
	# Cambiar a la escena Nivel 1
	get_tree().change_scene_to_file("res://Nivel1.tscn")
