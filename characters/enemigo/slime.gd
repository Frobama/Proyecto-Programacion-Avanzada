extends Node2D


func play_walk():
	%SlimeBody.play("walk")


func play_hurt():
	%AnimationPlayer.play("hurt")
	%SlimeBody.play("walk")

func play_dead():
	%SlimeBody.play("dead")
