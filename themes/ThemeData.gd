extends Resource
class_name ThemeData

@export var name: String = "Classic"
@export var background: Texture2D
@export var block_colors: Array[Color] = []      # or…
@export var paddle_texture: Texture2D
@export var ball_texture: Texture2D
@export var particle_color: Color = Color.WHITE
@export var music: AudioStream
