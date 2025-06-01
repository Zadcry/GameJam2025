extends Node2D

# Referencias a los nodos de los botones
@onready var click_button = $click
@onready var jugar_button = $Jugar
@onready var opciones_button = $Opciones
@onready var salir_button = $Salir

# Variable para controlar el parpadeo
var blink_timer = 0.0
var blink_speed = 5.0
var menu_shown = false
var opciones_scene_instance = null

const OPCIONES_SCENE_PATH = "res://menu_opciones/menuop.tscn"

func _ready():
	if jugar_button: jugar_button.hide()
	if opciones_button: opciones_button.hide()
	if salir_button: salir_button.hide()
	print("MainMenu _ready: Node references: click_button=", click_button, " jugar_button=", jugar_button, " opciones_button=", opciones_button, " salir_button=", salir_button)
	if click_button: print("click_button rect: ", click_button.get_global_rect())
	if jugar_button: print("jugar_button rect: ", jugar_button.get_global_rect())
	if opciones_button: print("opciones_button rect: ", opciones_button.get_global_rect())
	if salir_button: print("salir_button rect: ", salir_button.get_global_rect())
	print("MainMenu _ready: Scene path exists: ", ResourceLoader.exists(OPCIONES_SCENE_PATH))

func _process(_delta):
	if not menu_shown:
		blink_timer += _delta * blink_speed
		var alpha = (sin(blink_timer) + 1) / 2
		if click_button: click_button.modulate.a = alpha

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var click_position = get_global_mouse_position()
		print("MainMenu _input: Click detected at position: ", click_position, " menu_shown: ", menu_shown)
		
		if not menu_shown and click_button and click_button.get_global_rect().has_point(click_position):
			print("MainMenu _input: Click button clicked")
			click_button.hide()
			animate_button_appearance(jugar_button, 0.0)
			animate_button_appearance(opciones_button, 0.2)
			animate_button_appearance(salir_button, 0.4)
			menu_shown = true
		elif menu_shown and jugar_button and jugar_button.get_global_rect().has_point(click_position) and !jugar_button.disabled:
			print("MainMenu _input: Jugar button clicked")
			get_tree().change_scene_to_file("res://escenas_niveles/tutorial.tscn")
		elif menu_shown and opciones_button and opciones_button.get_global_rect().has_point(click_position) and !opciones_button.disabled:
			print("MainMenu _input: Opciones button clicked")
			_show_opciones_scene()
		elif menu_shown and salir_button and salir_button.get_global_rect().has_point(click_position) and !salir_button.disabled:
			print("MainMenu _input: Salir button clicked")
			get_tree().quit()

func animate_button_appearance(button, delay):
	if not button:
		print("MainMenu animate_button_appearance: Error: Button is null")
		return
	var tween = create_tween()
	button.show()
	var original_position = button.position
	button.position.y = 800
	tween.tween_property(button, "position", original_position, 0.5).set_delay(delay).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(button, "scale", Vector2(1.2, 1.2), 0.3).set_delay(delay)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	print("MainMenu animate_button_appearance: Animation started for ", button.name)

func _show_opciones_scene():
	if opciones_scene_instance != null:
		print("MainMenu _show_opciones_scene: Options scene already instantiated")
		return
	
	if not ResourceLoader.exists(OPCIONES_SCENE_PATH):
		print("MainMenu _show_opciones_scene: Error: Options scene does not exist at ", OPCIONES_SCENE_PATH)
		return
	
	var opciones_scene = load(OPCIONES_SCENE_PATH)
	opciones_scene_instance = opciones_scene.instantiate()
	if opciones_scene_instance == null:
		print("MainMenu _show_opciones_scene: Error: Failed to instantiate options scene")
		return
	
	add_child(opciones_scene_instance)
	opciones_scene_instance.z_index = 50
	opciones_scene_instance.position = Vector2.ZERO
	
	if opciones_scene_instance.has_signal("closed"):
		opciones_scene_instance.connect("closed", _on_opciones_scene_closed)
	else:
		print("MainMenu _show_opciones_scene: Warning: Options scene does not have 'closed' signal")

	# 🔒 Deshabilitar botones mientras opciones está abierto
	if jugar_button: jugar_button.disabled = true
	if opciones_button: opciones_button.disabled = true
	if salir_button: salir_button.disabled = true
	print("MainMenu _show_opciones_scene: Options scene instantiated and buttons disabled")

func _on_opciones_scene_closed():
	if opciones_scene_instance != null:
		opciones_scene_instance.queue_free()
		opciones_scene_instance = null

	# ✅ Volver a habilitar botones
	if jugar_button: jugar_button.disabled = false
	if opciones_button: opciones_button.disabled = false
	if salir_button: salir_button.disabled = false

	print("MainMenu _on_opciones_scene_closed: Options scene closed and buttons re-enabled")
