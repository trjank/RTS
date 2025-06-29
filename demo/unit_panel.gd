extends Control
var shipManager = ShipManager.new()
#@onready var shipimgbox = %ship_img
@onready var shipimg = ImageTexture.create_from_image(Image.load_from_file("user://ship2.png"))

# Called when the node enters the scene tree for the first time.
func _ready():
	#shipimg.set_size_override( shipimg.get_size() * 10)
	#shipimgbox.texture = shipimg
	#shipimgbox.size = shipimgbox.size * 10 
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
