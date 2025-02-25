extends Ship

@export var circle: CollisionShape2D
@export var HP_bar: ProgressBar
@export var shield_bar: ProgressBar
@export var energy_bar: ProgressBar

func set_circle_radius(new_radius: float)->void:
	circle.shape.radius = new_radius

var parts = [
	["1x2LightBlock",Vector2(0,0),1 ],
	["1x1LightBlock",Vector2(1,0),0 ],
	["2x2LightBlock",Vector2(1,-1),0]
]


func drawShip():
	for part in parts:
		var partData = globals.parts[part[0]]
		var newPart = Sprite2D.new()
		newPart.texture = load(partData["img"])
		newPart.scale = globals.partScale * partData["size"] / newPart.texture.get_size()
		#var offset = (newPart.scale/2)
		newPart.position = globals.partScale * (part[1] + partData["offset"])
		#newPart.rotate(PI/2 * part[2])
		add_child(newPart)


func _ready():
	drawShip()
	pass

func _process(_dt):
	queue_redraw()
	HP_bar.value = get_HP()
	shield_bar.value = get_shield()
	energy_bar.value = get_energy()
