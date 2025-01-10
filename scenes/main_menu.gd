extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_host_lobby_button_pressed() -> void:
	print("Host Lobby Clicked!")



func _on_join_lobby_button_pressed() -> void:
	print("Join Lobby Clicked!")



func _on_play_solo_button_pressed() -> void:
	print("Play Solo Clicked!")
	



func _on_settings_button_pressed() -> void:
	print("Settings Clicked!")
	



func _on_credits_pressed() -> void:
	print("Credits Clicked!")
	



func _on_quit_button_pressed() -> void:
	print("Quit Clicked Clicked!")
