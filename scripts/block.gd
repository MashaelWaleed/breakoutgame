extends RigidBody2D

var _destroyed: bool = false
var _row_idx: int = 0   # Level can set this via meta or property

func _ready() -> void:
	add_to_group("block")
	# pick up row index if Level stored it as metadata
	if has_meta("row_index"):
		_row_idx = int(get_meta("row_index"))

	# apply current theme and react to future changes
	if Engine.has_singleton("ThemeManager"):
		ThemeManager.theme_changed.connect(apply_theme)
		apply_theme(ThemeManager.current)

func apply_theme(theme) -> void:
	if theme == null:
		return

	if has_node("Sprite2D"):
		var spr := $Sprite2D as Sprite2D

		# textures > colors
		if theme.block_textures and theme.block_textures.size() > 0:
			var idx: int = _row_idx % theme.block_textures.size()
			spr.texture = theme.block_textures[idx]
			spr.modulate = Color.WHITE
		elif theme.block_colors and theme.block_colors.size() > 0:
			var idx2: int = _row_idx % theme.block_colors.size()
			spr.modulate = theme.block_colors[idx2]

	# particles (optional)
	if has_node("CPUParticles2D") and theme.particle_color:
		$CPUParticles2D.modulate = theme.particle_color

	# particles: tint if theme provides one
	if has_node("CPUParticles2D") and "particle_color" in theme and theme.particle_color:
		$CPUParticles2D.modulate = theme.particle_color

func hit() -> void:
	if _destroyed:
		return
	_destroyed = true

	GameManager.addPoints(1)

	# FX + hide + disable safely during physics step
	if has_node("CPUParticles2D"):
		$CPUParticles2D.emitting = true
	if has_node("Sprite2D"):
		$Sprite2D.visible = false
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)

	# remove self from group before counting the rest
	remove_from_group("block")
	var blocks_left: int = get_tree().get_nodes_in_group("block").size()

	if blocks_left == 0:
		# pause ball and go to next level
		var ball := get_tree().get_first_node_in_group("Ball")
		if ball:
			# if ball has is_active, this will work; otherwise it's harmless to skip
			ball.is_active = false
		await get_tree().create_timer(0.8).timeout
		GameManager.level += 1
		get_tree().reload_current_scene()
	else:
		await get_tree().create_timer(0.15).timeout
		queue_free()
