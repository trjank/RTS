extends TextureButton

func _on_pressed():
	var x := FileDialog.new()
	x.use_native_dialog = true
	x.show()
	return
