extends ProgressBar

func _ready() -> void:
	await get_tree().process_frame
	var player := get_tree().get_first_node_in_group("player")
	max_value = player.max_health
	value = player.current_health
	player.health_changed.connect(func(v): value = v)
