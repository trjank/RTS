extends PanelContainer

func add_part(tab, partbutton):
	var container = %part_tabs.find_child(tab)
	if not container: 
		push_warning("Tab '%s' does not exist" % tab)
	else:
		#muting sneaky print statements
		#print(partbutton.stretch_mode)
		#print(partbutton)
		container.add_child(partbutton)
	
