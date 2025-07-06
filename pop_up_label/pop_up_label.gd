extends Node2D

@export var text_speed: float = 50.0
@export var fade_time: float = 0.5

func start(text: String):
	$Label.text = text
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -30), fade_time)
	tween.tween_property(self, "modulate:a", 0.0, fade_time)
	tween.connect("finished", self.queue_free)
