extends Node2D

@onready var blockObject = preload("res://scenes/block.tscn") #refrence to bock 
# set No. of rows and columns 
var rows =8
var columns = 32
# size of a block 
var margin = 50
var colors=[
	Color(0.6196,0.7921,0.8392,1),
	Color(0.4549,0.5529,0.6824,1),
	Color(0.9686,0.8117,0.847,1),
	Color(0.9568,0.973,0.827,1),
	Color(0.9608,0.7961,0.7961,1),
	Color(1, 0.9176,0.9176,1),
	Color(0.6509,0.8392,0.8392,1),
	Color(0.5568, 0.4901,0.745,1)
]

func _ready() -> void:
	setUpLevel()

func setUpLevel():
	colors.shuffle()
	for r in rows:
		for c in columns:
			var newBlock = blockObject.instantiate()
			add_child(newBlock)
			newBlock.position = Vector2(margin + (34 *c),margin + (34*r))
			
			var sprite: Sprite2D = newBlock.get_node('Sprite2D')
			if r >= 0 and r<= 1:
				sprite.modulate =colors[0]
			if r >= 2 and r<= 3:
				sprite.modulate=colors[1]
			if r >= 4 and r<= 5:
				sprite.modulate=colors[2]
			if r >= 6 and r<= 7:
				sprite.modulate=colors[3]
				
				
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta: float)->void:
	pass


func _on_kill_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("Ball"):
		print("kill Zone entered")
		get_tree().change_scene_to_file("res://scenes/level.tscn")
