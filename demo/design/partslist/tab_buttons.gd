extends GridContainer

var tabs = {
	'Energy':0,
	'Armor':1,
	'Weapons':2,
	'Utility':3
}

func _ready():
	for button in get_children():
		print(button.name)
		var tab = button.name
		button.pressed.connect(change_tab.bind(tab))
	print("op")
		
func change_tab(tab):
	var tab_index = tabs.get(tab)
	print(tab_index)
	if tab_index == null:
		return
	%part_tabs.current_tab = tab_index
