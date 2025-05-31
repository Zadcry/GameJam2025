extends Area2D

@onready var sprite = $Sprite

var impacto_cordura : int = randi_range(1, 3)
const ALIVE_TEXTURE = preload("res://images/perro_vivo.png")
const DEAD_TEXTURE = preload("res://images/animal_muerto.png")

var is_dead = false

func _ready():
	sprite.texture = ALIVE_TEXTURE

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not is_dead:
			is_dead = true
			sprite.modulate = Color.RED
			print("¡Objetivo clickeado!")
