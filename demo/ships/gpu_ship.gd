extends Node2D

const ATLAS := preload("res://design/atlas_test.png")

var data: ShipData

func _draw() -> void:
	if data == null:
		return
	var xy0 := 32 * data.get_ship_rect().position
	data.for_each_part(func (part: ShipDataPart) -> void:
		#var size := 32 * part.rect.size
		#var rect := Rect2(32 * part.rect.position - xy0, size)
		#draw_texture_rect_region(ATLAS, rect, part.data.atlas_rect)
		var rect := part.get_rect()
		rect.position *= 32
		rect.position -= xy0
		rect.size *= 32
		draw_texture_rect(part.get_data().get_image().get_texture(), rect, false)
	)
