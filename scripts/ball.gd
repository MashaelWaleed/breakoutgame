extends CharacterBody2D

@export var base_speed: float = 250.0
var is_active: bool = true
var direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	add_to_group("Ball")

	var s: float = base_speed + (10.0 * float(GameManager.level))
	velocity = Vector2(-s, s)

	# Apply theme now and on future changes
	if Engine.has_singleton("ThemeManager"):
		ThemeManager.theme_changed.connect(apply_theme)
		apply_theme(ThemeManager.current)

func apply_theme(theme) -> void:
	if theme == null:
		return
	if has_node("Sprite2D"):
		var spr := $Sprite2D as Sprite2D
		if "ball_texture" in theme and theme.ball_texture:
			spr.texture = theme.ball_texture
			spr.modulate = Color.WHITE
		elif "block_colors" in theme and theme.block_colors and theme.block_colors.size() > 0:
			spr.modulate = theme.block_colors[0]

	# Optional: tint extras if you have them
	if has_node("Trail2D") and theme and "block_colors" in theme and theme.block_colors and theme.block_colors.size() > 0:
		$Trail2D.default_color = theme.block_colors[0]
	if has_node("CPUParticles2D") and theme and "particle_color" in theme and theme.particle_color:
		$CPUParticles2D.modulate = theme.particle_color

func _physics_process(delta: float) -> void:
	if is_active:
		var collision := move_and_collide(velocity * delta)
		if collision:
			velocity = velocity.bounce(collision.get_normal())
			if collision.get_collider().has_method("hit"):
				collision.get_collider().hit()

		# Prevent near-horizontal/vertical stalls
		if velocity.y > 0.0 and velocity.y < 100.0:
			velocity.y = -200.0
		if velocity.x == 0.0:
			velocity.x = -200.0

func gameOver() -> void:
	GameManager.score = 0
	GameManager.level = 1
	get_tree().reload_current_scene()

func _on_kill_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("Ball"):
		print("kill Zone entered")
		gameOver()
