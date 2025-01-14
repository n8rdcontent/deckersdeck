extends Node2D
@onready var ButtonSound = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_host_lobby_button_pressed() -> void:
	print("Host Lobby Clicked!")
	ButtonSound.play()



func _on_join_lobby_button_pressed() -> void:
	print("Join Lobby Clicked!")
	ButtonSound.play()



func _on_play_solo_button_pressed() -> void:
	print("Play Solo Clicked!")
	get_tree().change_scene_to_file("res://scenes/SoloGame.tscn")
	
func _on_credits_pressed() -> void:
	print("Credits Clicked!")
	ButtonSound.play()



func _on_quit_button_pressed() -> void:
	print("Quit Clicked Clicked!")
	get_tree().quit()


func _on_tutorial_button_pressed() -> void:
	ButtonSound.play()
	print("Credits Clicked!")
