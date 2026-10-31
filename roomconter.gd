extends Node

signal room_change(total: int)

var rooms := 0

func add_room() -> void:
	rooms += 1
	room_change.emit(rooms)
