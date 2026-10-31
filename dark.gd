extends CanvasModulate

@export var color_inicial := Color(1, 1, 1)
@export var color_final := Color(0.04,0.04,0.08)
@export var habitaciones_hasta_oscuro := 140
@export var duracion := 0.1

var _habitaciones := 0

func _ready() -> void:
	add_to_group("oscuridad")
	color = color_inicial

func siguiente_habitacion() -> void:
	_habitaciones = mini(_habitaciones + 1, habitaciones_hasta_oscuro)
	var t := float(_habitaciones) / habitaciones_hasta_oscuro
	var objetivo := color_inicial.lerp(color_final, t)
	create_tween().tween_property(self, "color", objetivo, duracion)
