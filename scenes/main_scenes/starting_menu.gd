extends Control
@onready var newgame = $MainControl/VBoxContainer/NewGame
@onready var loadgame = $MainControl/VBoxContainer/HBoxContainer/LoadGame
@onready var deletegame = $MainControl/VBoxContainer/HBoxContainer/DeleteGame
@onready var exitgame = $MainControl/VBoxContainer/ExitGame

@onready var char_name = $NewGameControl/VBoxContainer/HBoxContainer/CharName
@onready var entergame = $NewGameControl/VBoxContainer/EnterGame
@onready var goback = $NewGameControl/VBoxContainer/GoBack

# Called when the node enters the scene tree for the first time.
func _ready():
	newgame.grab_focus()
	$"../main_char/CanvasLayer/PlayerHUD".hide()
	
	if not FileAccess.file_exists("user://savegame.save"):
		loadgame.disabled = true
 
	newgame.pressed.connect(self._on_new_game)
	loadgame.pressed.connect(self._on_load_game)
	deletegame.pressed.connect(self._on_delete_game)
	exitgame.pressed.connect(self._on_exit_game)
	
	entergame.pressed.connect(self._on_enter_game)
	char_name.text_changed.connect(self._on_text_changed)
	goback.pressed.connect(self._on_go_back)

func _on_new_game():
	$MainControl.hide()
	$NewGameControl.show()
	char_name.grab_focus()
	
func _on_enter_game():
	var charname = char_name.get_text()
	if not charname.is_empty():
		GameState.is_initialized = false
		GameState.player_name = charname
		get_tree().change_scene_to_file("res://scenes/main_scenes/outside_tower.tscn")
	else:
		char_name.grab_focus()

func _on_text_changed(new_text):
	var valid_text = ""
	var regex = RegEx.new()
	regex.compile("[a-zA-Z ]*")  # Only allow letters and spaces
	
	var match = regex.search(new_text)
	if match:
		valid_text = match.get_string()
	else:
		valid_text = ""

	# Update the LineEdit's text if it doesn't match the valid pattern
	if valid_text != new_text:
		char_name.text = valid_text
		char_name.caret_column = valid_text.length()

func _on_load_game():
	GameState.load_data()
	
func _on_delete_game():
	DirAccess.remove_absolute("user://savegame.save")
	loadgame.disabled = true
	
func _on_go_back():
	$MainControl.show()
	$NewGameControl.hide()
	newgame.grab_focus()

func _on_exit_game():
	get_tree().quit()

