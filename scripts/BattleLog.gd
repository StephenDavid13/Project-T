extends RichTextLabel

# Updates the battle log with a single new message
func update_message(message: String):
	clear()  # Clear previous messages
	$"..".show()
	append_text("[color=white]%s[/color]\n" % [message])
	await get_tree().create_timer(2.0).timeout
	$"..".hide()
