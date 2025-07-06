extends Control

var target_position: Vector2

func start_animation():
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_position, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.connect("finished", Callable(self, "queue_free"))
