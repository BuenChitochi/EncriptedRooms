extends Area2D

@export_range(0.0, 1.0) var hidden_alpha := 0.4
@export var fade_time := 0.2

@onready var sprite: Sprite2D = $Sprite2D

var _tween: Tween

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	body.set_hidden(true)
	_fade(hidden_alpha)

func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	body.set_hidden(false)
	_fade(1.0)

func _fade(alpha: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(sprite, "modulate:a", alpha, fade_time)
