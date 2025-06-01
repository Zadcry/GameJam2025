extends Node2D

@onready var mi_boton1 = $TextureButton
@onready var mi_boton2 = $TextureButton2
@onready var mi_boton3 = $TextureButton3

# Variable to reference the player node
var player_node: Node = null

func _ready():
	self.visible = false  # Hide menu at start
	# Centrar el menú en la pantalla
	var viewport_size = get_viewport_rect().size
	self.position = viewport_size / 2
	# Asegurar que los botones estén inicialmente ocultos
	mi_boton1.visible = false
	mi_boton2.visible = false
	mi_boton3.visible = false
	# Connect the pressed signal of mi_boton2 (Resume) to close the menu
	if mi_boton2:
		mi_boton2.pressed.connect(_on_mi_boton2_pressed)
	# Connect the pressed signal of mi_boton3 to change scene
	if mi_boton3:
		mi_boton3.pressed.connect(_on_mi_boton3_pressed)

func show_pause_menu() -> void:
	get_tree().paused = true  # Pause the game
	self.visible = true  # Show menu
	var sprite = $AnimatedSprite2D
	if sprite:
		sprite.frame = 0
		sprite.play("Abrir")
		print("Reproduciendo animación Abrir")
		await get_tree().create_timer(2.25).timeout
		mi_boton1.visible = true
		mi_boton2.visible = true
		mi_boton3.visible = true

func exit_pause_menu() -> void:
	# Hide buttons immediately
	mi_boton1.visible = false
	mi_boton2.visible = false
	mi_boton3.visible = false
	var sprite = $AnimatedSprite2D
	if sprite:
		sprite.frame = 23
		sprite.play("Cerrar")
		print("Reproduciendo animación Cerrar")
		# Wait for the animation to finish before hiding the menu and resuming
		await sprite.animation_finished
	# Hide menu and resume game
	self.visible = false
	get_tree().paused = false
	# Notify the player that the game is unpaused and hide cursor
	if player_node:
		player_node.paused = false
		player_node.hide_cursor()
		print("Notificando al personaje: juego despausado, cursor oculto")
	# Call resume_enemies on the main scene
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_method("resume_enemies"):
		main_scene.resume_enemies()
		print("Called resume_enemies on main scene")

func _input(event):
	# Detect ui_accept action (e.g., left click or Enter)
	if event.is_action_pressed("ui_accept"):
		# Only execute if the pause menu is visible
		if self.visible:
			print("¡Acción ui_accept detectada! Reanudando juego...")
			exit_pause_menu()

func _on_mi_boton2_pressed():
	print("¡Botón Resume (TextureButton2) presionado!")
	exit_pause_menu()

func _on_mi_boton3_pressed():
	print("¡Botón 3 (TextureButton3) presionado! Cambiando a escena...")
	# Hide buttons and play closing animation
	mi_boton1.visible = false
	mi_boton2.visible = false
	mi_boton3.visible = false
	var sprite = $AnimatedSprite2D
	if sprite:
		sprite.frame = 23
		sprite.play("Cerrar")
		print("Reproduciendo animación Cerrar")
		# Wait for the animation to finish before changing scene
		await sprite.animation_finished
	self.visible = false
	get_tree().paused = false  # Unpause the game before changing scene
	# Change to the desired scene
	get_tree().change_scene_to_file("res://menu_inicial/menuI.tscn")

func _on_AnimatedSprite2D_animation_finished():
	var sprite = $AnimatedSprite2D
	if sprite and sprite.animation == "Abrir":
		var last_frame = sprite.sprite_frames.get_frame_count("Abrir") - 1
		sprite.frame = last_frame
		sprite.stop()
