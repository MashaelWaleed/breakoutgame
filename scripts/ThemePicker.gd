extends OptionButton

func _ready() -> void:
	clear()

	if Engine.has_singleton("ThemeManager") and ThemeManager.themes.size() > 0:
		# Fill items
		for i in range(ThemeManager.themes.size()):
			add_item(ThemeManager.themes[i].name, i) # id is an int

		# Select the currently active theme by index
		var current_name := ""
		if ThemeManager.current:
			current_name = ThemeManager.current.name
		for i in range(get_item_count()):
			if get_item_text(i) == current_name:
				select(i)  # <-- passes int index (OK)
				break

		# Keep picker in sync if theme changes elsewhere
		ThemeManager.theme_changed.connect(_on_theme_changed)

	# Godot 4 style signal connect (Callable)
	item_selected.connect(_on_item_selected)

func _on_item_selected(index: int) -> void:
	if not Engine.has_singleton("ThemeManager"):
		return
	var name := get_item_text(index)   # get text for selected index
	ThemeManager.set_theme_by_name(name)

func _on_theme_changed(theme) -> void:
	if theme == null:
		return
	for i in range(get_item_count()):
		if get_item_text(i) == theme.name:
			select(i)                  # pass int index
			return
