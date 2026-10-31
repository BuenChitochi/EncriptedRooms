extends Area2D

@export var backtracker_scene: PackedScene
@export var backtracker_first_room := 200
@export_range(0.0, 1.0) var backtracker_chance := 0.2

@export var entity_scene: PackedScene
@export var guaranteed_room := 25
@export_range(0.0, 1.0) var chance_after := 0.3

@export_file("*.tscn") var next_room_path := "res://room.tscn"
@export var angulo_abierta := -90.0
@export var duracion := 0.4

@onready var spawn_point: Marker2D = $Marker2D
@onready var door_move: AnimatableBody2D = $doormove
@onready var colision_puerta: CollisionShape2D = $doormove/CollisionShape2D

var _used := false
var _tween: Tween

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_mover_puerta(angulo_abierta)
	if _used:
		return
	_used = true
	Roomconter.add_room()
	_spawn_room.call_deferred(spawn_point.global_position)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_mover_puerta(0.0)

func _mover_puerta(grados: float) -> void:
	colision_puerta.set_deferred("disabled", grados != 0.0)
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.tween_property(door_move, "rotation_degrees", grados, duracion)

func _should_spawn_entity() -> bool:
	var n: int = Roomconter.rooms
	if n == guaranteed_room:
		return true
	if n > guaranteed_room:
		return randf() <= chance_after
	return false

func _spawn_room(pos: Vector2) -> void:
	var scene: PackedScene = load(next_room_path)
	var new_room := scene.instantiate()
	new_room.position = pos
	var root := get_tree().current_scene
	root.add_child(new_room)
	root.move_child(new_room, 0)
	get_tree().call_group("oscuridad", "siguiente_habitacion")
	if entity_scene and _should_spawn_entity():
		var entity := entity_scene.instantiate()
		new_room.add_child(entity)
		entity.position = Vector2(100, 0)
		print("A-25 apareció en la habitación ", Roomconter.rooms)

	if backtracker_scene and Roomconter.rooms >= backtracker_first_room and randf() <= backtracker_chance:
		var b := backtracker_scene.instantiate()
		new_room.add_child(b)
		b.position = Vector2(350, 0)
