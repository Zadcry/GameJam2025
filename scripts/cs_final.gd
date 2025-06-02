extends Control

# Array to store slide data (image paths and text)
var slides = [
	{"image": "res://sprites/cs2_1.png", "text": ""},
	{"image": "res://sprites/cs2_2.png", "text": ""},
	{"image": "res://sprites/cs2_3.png", "text": ""},
	{"image": "res://sprites/cs2_4.png", "text": ""},
	{"image": "res://sprites/cs2_5a.png", "text": "Si hubiera quitado más vidas ¿Me sentiría asi de mal?"},
	{"image": "res://sprites/cs2_5b.png", "text": "No era necesario pero lo disfruté. Muerte a todos. "},
]
var current_slide = 0
var is_animating = false
var typewriter_speed = 0.05  # Time per character in seconds

# Node references
@onready var slide_image = $TextureRect
@onready var slide_text = $Label
@onready var next_button = $Button
@onready var animation_player = $AnimationPlayer
@onready var musica : AudioStreamPlayer2D = $musica

func _ready():
	slide_text.hide()
	# Connect the button's pressed signal
	next_button.pressed.connect(_on_next_button_pressed)
	# Set up label background
	slide_text.add_theme_stylebox_override("normal", create_label_background())
	# Load the first slide
	update_slide()
	musica.play()

func create_label_background():
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0, 0, 0, 0.25)  # Black with 50% opacity
	stylebox.set_corner_radius_all(5)
	return stylebox

func update_slide():
	if current_slide >= slides.size():
		get_tree().change_scene_to_file("res://menu_inicial/menuI.tscn")
		return
	
	# Disable button during transition
	next_button.disabled = true
	next_button.hide()
	is_animating = true
	
	if current_slide == 0:
		slide_image.texture = load(slides[current_slide]["image"])
		slide_text.text = ""
		
		animation_player.play("start_fade_in")
		await animation_player.animation_finished
		
		start_typewriter_effect(slides[current_slide]["text"])
	elif current_slide == 4:		
		
		animation_player.play("fade_out")
		await animation_player.animation_finished
		
		slide_text.show()
		if GLOBAL.cordura > 35:
			# Load new slide content
			slide_image.texture = load(slides[current_slide]["image"])
			slide_text.text = ""
			
			# Start fade-in animation
			animation_player.play("fade_in")
			await animation_player.animation_finished
			
			start_typewriter_effect(slides[current_slide]["text"])
			current_slide+=1
		else: 
			current_slide+=1
			
			# Load new slide content
			slide_image.texture = load(slides[current_slide]["image"])
			slide_text.text = ""
			
			# Start fade-in animation
			animation_player.play("fade_in")
			await animation_player.animation_finished
			
			start_typewriter_effect(slides[current_slide]["text"])
		next_button.text = "Fin"
	else:
		# Start fade-out animation
		animation_player.play("fade_out")
		await animation_player.animation_finished
		
		# Load new slide content
		slide_image.texture = load(slides[current_slide]["image"])
		slide_text.text = ""
		
		# Start fade-in animation
		animation_player.play("fade_in")
		await animation_player.animation_finished
		
		start_typewriter_effect(slides[current_slide]["text"])

func start_typewriter_effect(full_text: String):
	var text_length = full_text.length()
	for i in range(text_length + 1):
		slide_text.text = full_text.substr(0, i)
		await get_tree().create_timer(typewriter_speed).timeout
	
	# Re-enable button after typewriter effect
	next_button.disabled = false
	next_button.show()
	is_animating = false

func _on_next_button_pressed():
	if not is_animating:
		current_slide += 1
		update_slide()

func _on_animation_player_animation_finished(_anim_name: String):
	# Signal connection is handled in update_slide
	pass
