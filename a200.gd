extends CharacterBody2D

@export var wait_time := 4.0
@export var speed := 9000.0
@export var damage := 50
@export var damage_cooldown := 1.5
@export var stop_at_x := -3000.0
@export var despawn_distance := 2500.0

var _wait_left := 0.0
var _can_damage := true
var _leaving := false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_area: Area2D = $Area2D
@onready var spawn_sound: AudioStreamPlayer2D = $SpawnSound
@onready var ambient_sound: AudioStreamPlayer2D = $AmbientSound

func _ready() -> void:
	_wait_left = wait_time
	sprite.play("A-200animation")
	spawn_sound.play()
	ambient_sound.play()

func _physics_process(delta: float) -> void:
	if _leaving:
		return

	if _wait_left > 0.0:
		_wait_left -= delta
		return

	_check_damage()

	velocity = Vector2.LEFT * speed
	sprite.flip_h = true
	move_and_slide()

	if global_position.x < stop_at_x:
		_fade_out()
		return

	var player := get_tree().get_first_node_in_group("player")
	if player and global_position.distance_to(player.global_position) > despawn_distance:
		queue_free()

func _check_damage() -> void:
	if not _can_damage:
		return
	for body in damage_area.get_overlapping_bodies():
		if not body.is_in_group("player"):
			continue
		if body.get("is_hiding"):
			continue
		if body.has_method("take_damage"):
			_can_damage = false
			body.take_damage(damage)
			_reset_damage()
			return

func _reset_damage() -> void:
	await get_tree().create_timer(damage_cooldown).timeout
	_can_damage = true

func _fade_out() -> void:
	_leaving = true
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(ambient_sound, "volume_db", -40.0, 0.5)
	tween.tween_callback(queue_free)
