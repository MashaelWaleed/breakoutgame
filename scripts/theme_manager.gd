extends Node
signal theme_changed(theme)           # type it if you want: (theme: ThemeData)
signal themes_loaded(count: int)

var themes: Array = []
var current = null

func _enter_tree() -> void:
	_load_themes()                    # runs before your Level scene _ready()

func _ready() -> void:
	_restore_theme()                  # will emit theme_changed inside set_theme_by_name
	emit_signal("themes_loaded", themes.size())

func _load_themes() -> void:
	themes.clear()
	var da := DirAccess.open("res://themes")
	if da:
		for f in da.get_files():
			if f.ends_with(".tres"):
				var t = load("res://themes/%s" % f)
				if t:
					themes.append(t)
	print("[ThemeManager] Loaded ", themes.size(), " theme(s).")

func set_theme_by_name(name: String) -> void:
	if themes.size() == 0:
		return
	if name == "":
		current = themes[0]
	else:
		current = themes[0]
		for t in themes:
			if t.name == name:
				current = t
				break
	emit_signal("theme_changed", current)
	var cfg := ConfigFile.new()
	cfg.set_value("ui", "theme", current.name)
	cfg.save("user://settings.cfg")

func _restore_theme() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load("user://settings.cfg")
	var saved := ""
	if err == OK:
		saved = str(cfg.get_value("ui","theme",""))
	set_theme_by_name(saved)
