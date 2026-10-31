extends Label

func _ready() -> void:
	text = "A-000"
	Roomconter.room_change.connect(func(n): text = "A-%03d" % n)
