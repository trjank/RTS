extends OptionButton

const NEW_FLEET_OPTION := 0
const RENAME_FLEET_OPTION := 1
const DELETE_FLEET_OPTION := 2
const NO_OPTION := 3
const NO_NAME := "*Unnamed"
var fleets = [1]

@export var rename_fleet_popup: AcceptDialog
@export var delete_fleet_popup: AcceptDialog



func set_fleets(new_fleets):
	fleets = new_fleets
	for fleet in fleets:
		var fleet_name = fleet["name"]
		add_item(fleet_name, true)
	


# func update_actions():
# 	var disable_actions := selected == NO_OPTION or selected == STARTER_FLEET
# 	set_item_disabled(RENAME_FLEET_OPTION, disable_actions)
# 	set_item_disabled(DELETE_FLEET_OPTION, disable_actions)

# # func _on_item_selected(option: int)->void:
# # 	match option:
# # 		RENAME_FLEET_OPTION:
# # 			# Open a popup window with a textbox
# # 			select(previous_option)
# # 			option_to_rename = selected
# # 			rename_fleet_popup.show()
# # 		DELETE_FLEET_OPTION:
# # 			# Open a popup confirmation window
# # 			select(previous_option)
# # 			option_to_delete = selected
# # 			delete_fleet_popup.show()
# # 		NEW_FLEET_OPTION:
# # 			add_item(NO_NAME, 0)
# # 			select(item_count - 1)
# # 			option_to_rename = selected
# # 			rename_fleet_popup.show()
# # 		_:
# # 			print("changing fleet...")
# # 			var fleet_index = selected - 4
			 


# 	update_actions()
# 	previous_option = selected

# func _on_delete_fleet_popup_confirmed()->void:
# 	remove_item(option_to_delete)
# 	select(NO_OPTION)
# 	update_actions()
# 	# TODO: delete specific fleet folder

# func _on_rename_fleet_popup_valid_rename(new_name: String)->void:
# 	set_item_text(option_to_rename, new_name)
# 	select(option_to_rename)
# 	update_actions()
# 	# TODO: rename specific fleet folder
