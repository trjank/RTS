extends Node

# 32 x 32 images
const CENTER = Vector2i(16, 16)
const TARGET := preload("res://images/cursor_target.png")
const DEFAULT := preload("res://images/cursor_default.png")

func begin_targeting():
	Input.set_custom_mouse_cursor(TARGET, Input.CURSOR_ARROW, CENTER)

func reset():
	Input.set_custom_mouse_cursor(DEFAULT, Input.CURSOR_ARROW, Vector2i(0, 0))

func _ready():
	reset()

var fcmd = false

func _unhandled_input(_event):
	if not Input.is_action_just_pressed("fcmd"): return
	fcmd = not fcmd
	begin_targeting() if fcmd else reset()
