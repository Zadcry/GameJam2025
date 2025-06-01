extends Node2D

@onready var mi_boton1 = $TextureButton
@onready var mi_boton2 = $TextureButton2
@onready var mi_boton3 = $TextureButton3

# Variable to reference the player node
var player_node: Node = null

func _ready():
	self.visible = false  # Hide menu at start
	mi_boton1.visible = false
	mi_boton2.visible = false
	mi_boton3.visible = false
	# Connect the pressed signal of mi_boton2 (Resume) to close the menu
	mi_boton2.pressed.connect(_on_mi_boton2_pressed)

func show_pause_menu() -> void:
	get_tree().paused = true  # Pause the game
	self.visible = true  # Show menu
	var sprite = $AnimatedSprite2D
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
	sprite.frame = 23
	sprite.play("Cerrar")
	print("Reproduciendo animación Cerrar")
	# Wait for the animation to finish before hiding the menu and resuming
	await sprite.animation_finished
	self.visible = false
	get_tree().paused = false  # Resume the game
	# Notify the player that the game is unpaused and hide cursor
	if player_node:
		player_node.paused = false
		player_node.hide_cursor()
		print("Notificando al personaje: juego despausado, cursor oculto")

func _input(event):
	# Detect ui_accept action (e.g., left click or Enter)
	if event.is_action_pressed("ui_accept"):
		# Only execute if the pause menu is visible
		if self.visible:
			print("¡Acción ui_accept detectada! Reanudando juego...")
			exit_pause_menu()

func _on_mi_boton2_pressed():
	if mi_boton2.is_pressed():
		print("¡Botón Resume (TextureButton2) presionado!")
		exit_pause_menu()

func _on_AnimatedSprite2D_animation_finished():
	if $AnimatedSprite2D.animation == "Abrir":
		var last_frame = $AnimatedSprite2D.sprite_frames.get_frame_count("Abrir") - 1
		$AnimatedSprite2D.frame = last_frame
		$AnimatedSprite2D.stop()
