extends Control

# Array to store slide data (image paths and text)
var slides = [
	{"image": "res://sprites/cs1_1.png", "text": "Enhorabuena"},
	{"image": "res://sprites/cs1_2.png", "text": "Ha sido seleccionado para participar en la guerra"},
	{"image": "res://sprites/cs1_3.png", "text": "Reportese inmediatamente en la zona de conflicto"}
]
var current_slide = 0

# Node references
@onready var slide_image = $TextureRect
@onready var slide_text = $Label
@onready var next_button = $Button

func _ready():
	# Connect the button's pressed signal
	next_button.pressed.connect(_on_next_button_pressed)
	# Load the first slide
	update_slide()

func update_slide():
	# Check if there are slides to display
	if current_slide < slides.size():
		# Load the slide image
		slide_image.texture = load(slides[current_slide]["image"])
		# Update the text
		slide_text.text = slides[current_slide]["text"]
	else:
		# End of cutscene, hide or transition to another scene
		queue_free()

func _on_next_button_pressed():
	# Move to the next slide
	current_slide += 1
	update_slide()
