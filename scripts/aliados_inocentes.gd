extends Area2D

@onready var sprite = $Sprite2D
var is_dead = false

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not is_dead:
			is_dead = true
			sprite.texture = preload("res://images/animal_muerto.png")

			var impacto = randi_range(5, 10)
			print("Impacto cordura (aliado):", impacto)

			# Suponiendo que el personaje principal es hijo directo del nodo raíz
			get_tree().root.get_node("nivel1/personaje_principal").reducir_cordura(impacto)
