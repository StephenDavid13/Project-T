extends RichTextLabel

# Updates the battle log with a single new message
func update_message(message: String):
	clear()  # Clear previous messages
	append_text("[color=white]%s[/color]\n" % [message])
