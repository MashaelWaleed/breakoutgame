extends Node2D

@onready var blockObject: PackedScene = preload("res://scenes/block.tscn")

# base grid (columns=32 is fine if your viewport is wide enough)
var rows := 8
var columns := 32
var margin := 50
var cell := 34

# Fallback palette (your current “classic” look) – used only if no theme is provided
var fallback_colors := [
	Color(0.6196,0.7921,0.8392,1),
	Color(0.4549,0.5529,0.6824,1),
	Color(0.9686,0.8117,0.847,1),
	Color(0.9568,0.973,0.827,1),
	Color(0.9608,0.7961,0.7961,1),
	Color(1, 0.9176,0.9176,1),
	Color(0.6509,0.8392,0.8392,1),
	Color(0.5568,0.4901,0.745,1)
]
# Optional if you didn't use `class_name ThemeData`:
# const ThemeData = preload("res://themes/ThemeData.gd")

func _ready() -> void:
	setUpLevel()
	apply_theme(_get_theme())
	$killZone.body_entered.connect(_on_kill_zone_body_entered)

	if Engine.has_singleton("ThemeManager") and not ThemeManager.themes_loaded.is_connected(_on_themes_loaded):
		ThemeManager.themes_loaded.connect(_on_themes_loaded)

	_ensure_theme_picker()   # builds it now (may be empty), will repopulate on themes_loaded



func _get_theme() -> ThemeData:
	if Engine.has_singleton("ThemeManager"):
		return ThemeManager.current as ThemeData
	return null

func setUpLevel() -> void:
	rows = 4 + GameManager.level
	if rows > 14: rows = 14

	var theme: ThemeData = _get_theme()
	var palette: Array = _get_palette(theme)
	palette.shuffle()

	for r in range(rows):
		for c in range(columns):
			if randi_range(0, 2) > 0:
				var new_block = blockObject.instantiate()
				add_child(new_block)
				new_block.position = Vector2(margin + (34 * c), margin + (34 * r))
				new_block.set_meta("row_index", r)
				_apply_block_look(new_block, r, theme)

func _apply_block_look(block: Node, row_idx: int, theme: ThemeData) -> void:
	var spr := block.get_node("Sprite2D") as Sprite2D
	if spr == null: return

	if theme and theme.block_textures.size() > 0:
		spr.texture = theme.block_textures[row_idx % theme.block_textures.size()]
		spr.modulate = Color.WHITE
	elif theme and theme.block_colors.size() > 0:
		spr.modulate = theme.block_colors[row_idx % theme.block_colors.size()]
	else:
		spr.modulate = fallback_colors[row_idx % fallback_colors.size()]

func _get_palette(theme: ThemeData) -> Array:
	if theme and theme.block_colors.size() > 0:
		return theme.block_colors.duplicate()
	return fallback_colors.duplicate()

func apply_theme(theme: ThemeData) -> void:
	if has_node("TextureRect") and theme and theme.background:
		$TextureRect.texture = theme.background
	if has_node("Music") and theme and theme.music:
		$Music.stream = theme.music
		if not $Music.playing: $Music.play()

	# re-skin existing blocks
	for b in get_children():
		if b.has_meta("row_index"):
			_apply_block_look(b, int(b.get_meta("row_index")), theme)

func _on_kill_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("Ball"):
		print("kill Zone entered")
		body.call_deferred("gameOver")

func _process(_delta: float) -> void:
	pass
func _ensure_theme_picker() -> void:
	var layer := get_node_or_null("CanvasLayer") as CanvasLayer
	if layer == null:
		layer = CanvasLayer.new()
		layer.name = "CanvasLayer"
		layer.layer = 100
		add_child(layer)

	var picker := layer.get_node_or_null("ThemePicker") as OptionButton
	if picker == null:
		picker = OptionButton.new()
		picker.name = "ThemePicker"
		picker.size = Vector2(220, 32)
		picker.position = Vector2(16, 16)
		layer.add_child(picker)

	_populate_picker(picker)

	if not picker.item_selected.is_connected(_on_theme_item_selected):
		picker.item_selected.connect(_on_theme_item_selected)

	if Engine.has_singleton("ThemeManager") and not ThemeManager.theme_changed.is_connected(_on_theme_changed):
		ThemeManager.theme_changed.connect(_on_theme_changed)


func _on_theme_item_selected(index: int) -> void:
	var picker := get_node("CanvasLayer/ThemePicker") as OptionButton
	var name: String = picker.get_item_text(index)
	if Engine.has_singleton("ThemeManager") and ThemeManager.themes.size() > 0:
		ThemeManager.set_theme_by_name(name)


func _on_theme_changed(theme) -> void:
	var picker := get_node_or_null("CanvasLayer/ThemePicker") as OptionButton
	if picker == null or theme == null:
		return
	for i in range(picker.get_item_count()):
		if picker.get_item_text(i) == theme.name:
			picker.select(i)
			return

			
func _on_themes_loaded(count: int) -> void:
	print("[Level] themes_loaded count=", count)
	_ensure_theme_picker()  # repopulate now that themes exist
	
func _populate_picker(picker: OptionButton) -> void:
	picker.clear()
	if Engine.has_singleton("ThemeManager") and ThemeManager.themes.size() > 0:
		for i in range(ThemeManager.themes.size()):
			picker.add_item(ThemeManager.themes[i].name, i)
		if ThemeManager.current != null:
			var current_name: String = String(ThemeManager.current.name)
			for i in range(picker.get_item_count()):
				if picker.get_item_text(i) == current_name:
					picker.select(i)
					break
		picker.disabled = false
	else:
		picker.add_item("Classic (fallback)", 0)
		picker.select(0)
		picker.disabled = false
		print("[ThemePicker] No .tres themes found in res://themes. Showing fallback item.")
