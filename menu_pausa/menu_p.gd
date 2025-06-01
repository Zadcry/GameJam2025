extends Node2D

@onready var mi_boton1 = $TextureButton
@onready var mi_boton2 = $TextureButton2
@onready var mi_boton3 = $TextureButton3
@onready var sprite = $AnimatedSprite2D
@onready var opciones_layer = $OpcionesLayer  # Nuevo: capa para el menú de opciones

var player_node: Node = null
var opciones_scene_instance = null

const OPCIONES_SCENE_PATH = "res://menu_opciones/menuop.tscn"

func _ready():
	self.visible = false
	position = get_viewport_rect().size / 2

	mi_boton1.visible = false
	mi_boton2.visible = false
	mi_boton3.visible = false

	if mi_boton1:
		mi_boton1.pressed.connect(_on_mi_boton1_pressed)
	if mi_boton2:
		mi_boton2.pressed.connect(_on_mi_boton2_pressed)
	if mi_boton3:
		mi_boton3.pressed.connect(_on_mi_boton3_pressed)

func show_pause_menu() -> void:
	self.visible = true
	if sprite:
		sprite.frame = 0
		sprite.play("Abrir")
		await get_tree().create_timer(2.25).timeout
	mi_boton1.visible = true
	mi_boton2.visible = true
	mi_boton3.visible = true
	get_tree().paused = true

func exit_pause_menu() -> void:
	mi_boton1.visible = false
	mi_boton2.visible = false
	mi_boton3.visible = false

	if sprite:
		sprite.frame = 23
		sprite.play("Cerrar")
		await sprite.animation_finished

	self.visible = false
	get_tree().paused = false

	if player_node:
		player_node.paused = false
		player_node.hide_cursor()

	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_method("resume_enemies"):
		main_scene.resume_enemies()

func _input(event):
	if event.is_action_pressed("ui_accept") and self.visible:
		exit_pause_menu()

func _on_mi_boton1_pressed():
	_show_opciones_scene()

func _on_mi_boton2_pressed():
	exit_pause_menu()

func _on_mi_boton3_pressed():
	mi_boton1.visible = false
	mi_boton2.visible = false
	mi_boton3.visible = false
	if sprite:
		sprite.frame = 23
		sprite.play("Cerrar")
		await sprite.animation_finished

	self.visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu_inicial/menuI.tscn")

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

	# Añadir a capa especial para que quede delante
	opciones_layer.add_child(opciones_scene_instance)
	opciones_scene_instance.z_index = 1000

	# Reducir escala (por ejemplo 75%)
	opciones_scene_instance.scale = Vector2(0.75, 0.75)

	var viewport_size = get_viewport_rect().size

	if opciones_scene_instance is Control:
		# Centrar usando anclas y márgenes
		opciones_scene_instance.set_anchors_and_margins_preset(Control.PRESET_CENTER)
		# Posición base centrada
		var base_pos = opciones_scene_instance.rect_position
		# Mover hacia la izquierda 100 px (ajusta el valor a tu gusto)
		opciones_scene_instance.rect_position = base_pos + Vector2(-100, 0)
	else:
		# Centrar y luego mover a la izquierda
		opciones_scene_instance.position = viewport_size / 2 + Vector2(-500, -200)

	if opciones_scene_instance.has_signal("closed"):
		opciones_scene_instance.connect("closed", _on_opciones_scene_closed)
	else:
		print("MainMenu _show_opciones_scene: Warning: Options scene does not have 'closed' signal")

	mi_boton1.disabled = true
	mi_boton2.disabled = true
	mi_boton3.disabled = true

	print("MainMenu _show_opciones_scene: Options scene instantiated and buttons disabled")


func _on_opciones_scene_closed():
	if opciones_scene_instance:
		opciones_scene_instance.queue_free()
		opciones_scene_instance = null

	mi_boton1.disabled = false
	mi_boton2.disabled = false
	mi_boton3.disabled = false

func _on_AnimatedSprite2D_animation_finished():
	if sprite and sprite.animation == "Abrir":
		sprite.frame = sprite.sprite_frames.get_frame_count("Abrir") - 1
		sprite.stop()
