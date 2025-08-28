extends PanelContainer

func add_part(tab, partbutton):
	var container = %part_tabs.find_child(tab)
	if not container: 
		push_warning("Tab '%s' does not exist" % tab)
	else:
		print(partbutton.stretch_mode)
		container.add_child(partbutton)
	
