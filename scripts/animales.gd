extends Area2D

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

var is_dead : bool = false

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if is_dead and GLOBAL.scoped:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		GLOBAL.scoped = false
		get_tree().change_scene_to_file("res://cutscenes/cs_despuesTutorial.tscn")

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and GLOBAL.scoped:
		if not is_dead:
			is_dead = true
			sprite.play()
