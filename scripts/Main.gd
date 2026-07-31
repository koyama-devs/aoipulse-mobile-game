extends Control
## AOIPulse — modes, juice, online rooms & leaderboards.

const COLS := 10
const ROWS := 20
const SAVE_PATH := "user://aoipulse.save"
const SETTINGS_PATH := "user://aoipulse_settings.cfg"
const PROFILE_PATH := "user://profile.cfg"

const PIECES := [
	[[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)], [Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)], [Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)], [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)]],
	[[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)], [Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)], [Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)], [Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)]],
	[[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], [Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)], [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)], [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]],
	[[Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)], [Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)], [Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2)], [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]],
	[[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)], [Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)], [Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)], [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)]],
	[[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], [Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(1, 2)], [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)], [Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]],
	[[Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)], [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2)], [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)]],
]

const THEMES := [
	{"name": "Neon", "bg": Color(0.06, 0.07, 0.12), "panel": Color(0.10, 0.12, 0.20), "accent": Color(0.29, 0.83, 0.92),
	 "colors": [Color(0.16, 0.83, 0.92), Color(0.96, 0.80, 0.20), Color(0.66, 0.35, 0.88), Color(0.32, 0.78, 0.40), Color(0.90, 0.28, 0.38), Color(0.27, 0.50, 0.90), Color(0.94, 0.58, 0.22)]},
	{"name": "Sunset", "bg": Color(0.12, 0.06, 0.08), "panel": Color(0.22, 0.10, 0.12), "accent": Color(1.0, 0.55, 0.25),
	 "colors": [Color(1.0, 0.45, 0.35), Color(1.0, 0.75, 0.25), Color(0.95, 0.35, 0.55), Color(0.95, 0.6, 0.2), Color(0.85, 0.2, 0.3), Color(0.7, 0.35, 0.55), Color(1.0, 0.5, 0.15)]},
	{"name": "Forest", "bg": Color(0.05, 0.09, 0.06), "panel": Color(0.09, 0.16, 0.11), "accent": Color(0.45, 0.9, 0.55),
	 "colors": [Color(0.35, 0.85, 0.7), Color(0.85, 0.85, 0.35), Color(0.45, 0.7, 0.4), Color(0.3, 0.75, 0.4), Color(0.7, 0.4, 0.35), Color(0.4, 0.6, 0.85), Color(0.85, 0.65, 0.3)]},
]

const LINE_SCORES := [0, 100, 300, 500, 800]
const LOCK_DELAY := 0.5
const DAS := 0.16
const ARR := 0.045
const SWIPE_STEP := 34.0
const SOFT_STEP := 34.0
const TAP_MAX_DIST := 18.0
const SPRINT_LINES := 40
const ULTRA_SECONDS := 120.0

enum Screen { MENU, MODE, SETTINGS, HOWTO, ONLINE, ROOM, LEADERBOARD, PLAY, GAME_OVER }
enum Mode { CLASSIC, SPRINT, ULTRA, DAILY }

var screen: Screen = Screen.MENU
var mode: Mode = Mode.CLASSIC
var grid: Array = []
var bag: Array = []
var rng := RandomNumberGenerator.new()
var match_seed: int = 0
var cur_type := 0
var cur_rot := 0
var cur_pos := Vector2i.ZERO
var next_type := 0
var score := 0
var level := 1
var lines := 0
var high_score := 0
var paused := false
var fall_timer := 0.0
var fall_interval := 1.0
var lock_timer := 0.0
var left_held := false
var right_held := false
var soft_held := false
var move_timer := 0.0
var soft_timer := 0.0
var cell := 32.0
var board_origin := Vector2.ZERO
var hud_height := 150.0
var pad_height := 250.0
var touching := false
var touch_start := Vector2.ZERO
var touch_moved := false
var swipe_acc := Vector2.ZERO
var clear_flash := 0.0
var clear_rows: Array = []
var pending_clear_count := 0
var clearing := false
var hold_type := -1
var hold_used := false
var combo := 0
var toast_text := ""
var toast_timer := 0.0
var title_pulse := 0.0
var menu_blocks: Array = []
var shake_time := 0.0
var shake_mag := 0.0
var particles: Array = []
var elapsed := 0.0
var countdown := 0.0
var online_match := false
var theme_idx := 0
var room_poll := 0.0
var leaderboard_entries: Array = []
var room_ranking: Array = []
var room_players: Array = []
var is_host := false
var status_msg := ""
var pending_create_mode := ""
var pending_join_code := ""
var pending_daily := false

var sfx_on := true
var music_on := true
var haptic_on := true

var hud_root: Control
var score_label: Label
var high_label: Label
var level_label: Label
var lines_label: Label
var timer_label: Label
var pause_btn: Button
var pad_root: Control
var menu_root: Control
var mode_root: Control
var settings_root: Control
var howto_root: Control
var online_root: Control
var room_root: Control
var lb_root: Control
var overlay: Control
var overlay_title: Label
var overlay_sub: Label
var menu_best_label: Label
var menu_xp_label: Label
var chk_sfx: CheckButton
var chk_music: CheckButton
var chk_haptic: CheckButton
var name_edit: LineEdit
var join_edit: LineEdit
var server_edit: LineEdit
var room_info_label: Label
var room_list_label: Label
var lb_label: Label
var status_label: Label

var sfx_players: Dictionary = {}
var music_player: AudioStreamPlayer
var online: Node

func _theme() -> Dictionary:
	return THEMES[clampi(theme_idx, 0, THEMES.size() - 1)]

func _colors() -> Array:
	return _theme()["colors"]

func _accent() -> Color:
	return _theme()["accent"]

func _ready() -> void:
	online = get_node_or_null("/root/Online")
	if online:
		online.request_ok.connect(_on_online_ok)
		online.request_fail.connect(_on_online_fail)
	rng.randomize()
	_load_settings()
	high_score = _load_high_score()
	_setup_audio()
	_init_menu_blocks()
	_build_ui()
	get_viewport().size_changed.connect(_recalc_layout)
	_recalc_layout()
	_show_menu()
	set_process(true)
	set_process_input(true)

func _init_menu_blocks() -> void:
	menu_blocks.clear()
	for i in 10:
		menu_blocks.append({
			"pos": Vector2(rng.randf_range(0.05, 0.95), rng.randf_range(0.05, 0.95)),
			"type": rng.randi_range(0, 6),
			"speed": rng.randf_range(8.0, 26.0),
			"phase": rng.randf_range(0.0, TAU),
			"size": rng.randf_range(14.0, 30.0),
		})

# ---------------------------------------------------------------------------
# Screens
# ---------------------------------------------------------------------------
func _hide_all_panels() -> void:
	for n in [menu_root, mode_root, settings_root, howto_root, online_root, room_root, lb_root, hud_root, pad_root, overlay]:
		if n:
			n.visible = false
	if pause_btn:
		pause_btn.visible = false

func _show_menu() -> void:
	screen = Screen.MENU
	paused = false
	online_match = false
	_hide_all_panels()
	menu_root.visible = true
	menu_best_label.text = "Best  %d" % high_score
	var xp := 0
	var pname := "Player"
	if online:
		xp = online.player_xp
		pname = online.player_name
	menu_xp_label.text = "%s  ·  XP %d  ·  Theme %s" % [pname, xp, _theme()["name"]]
	theme_idx = mini(2, int(xp / 500))
	_play_music(true)
	queue_redraw()

func _show_mode() -> void:
	screen = Screen.MODE
	_hide_all_panels()
	mode_root.visible = true
	queue_redraw()

func _show_settings() -> void:
	screen = Screen.SETTINGS
	_hide_all_panels()
	settings_root.visible = true
	chk_sfx.button_pressed = sfx_on
	chk_music.button_pressed = music_on
	chk_haptic.button_pressed = haptic_on
	if online:
		name_edit.text = online.player_name
		server_edit.text = online.base_url
	queue_redraw()

func _show_howto() -> void:
	screen = Screen.HOWTO
	_hide_all_panels()
	howto_root.visible = true
	queue_redraw()

func _show_online() -> void:
	screen = Screen.ONLINE
	_hide_all_panels()
	online_root.visible = true
	status_msg = "Create a room or join with a code."
	_refresh_status()
	if online and online.player_id == "":
		online.register_player(name_edit.text if name_edit else "Player")
	queue_redraw()

func _show_room() -> void:
	screen = Screen.ROOM
	_hide_all_panels()
	room_root.visible = true
	room_poll = 0.0
	_refresh_room_ui()
	queue_redraw()

func _show_leaderboard() -> void:
	screen = Screen.LEADERBOARD
	_hide_all_panels()
	lb_root.visible = true
	lb_label.text = "Loading..."
	if online:
		if online.player_id == "":
			online.register_player(online.player_name)
		online.fetch_leaderboard("daily")
	queue_redraw()

func _start_local(m: Mode) -> void:
	mode = m
	online_match = false
	match_seed = 0
	if m == Mode.DAILY:
		if online:
			pending_daily = true
			status_msg = "Loading daily seed..."
			if online.player_id == "":
				online.register_player(online.player_name)
			online.fetch_daily()
			return
		var day := Time.get_datetime_string_from_system(true).substr(0, 10)
		match_seed = _hash_seed(day)
	_begin_play()

func _begin_play() -> void:
	screen = Screen.PLAY
	_hide_all_panels()
	hud_root.visible = true
	pad_root.visible = true
	pause_btn.visible = true
	countdown = 3.0 if online_match else 0.0
	_reset_game()
	_play_music(true)

func _show_game_over(victory: bool = false) -> void:
	screen = Screen.GAME_OVER
	pad_root.visible = false
	pause_btn.visible = false
	var title := "GAME OVER"
	if victory:
		title = "CLEAR!"
	elif mode == Mode.ULTRA:
		title = "TIME UP"
	overlay_title.text = title
	var time_txt := _fmt_time(int(elapsed * 1000.0))
	overlay_sub.text = "Score %d   ·   Lines %d   ·   %s\nBest %d" % [score, lines, time_txt, high_score]
	if online_match:
		overlay_sub.text += "\nSubmitting result..."
	elif mode == Mode.DAILY and online and online.player_id != "":
		overlay_sub.text += "\nSubmitting daily score..."
		online.submit_daily(score, lines, int(elapsed * 1000.0), match_seed)
	overlay.visible = true
	_sfx("gameover")
	if score > high_score:
		high_score = score
		_save_high_score(high_score)
	if online_match and online:
		online.finish_room(score, lines, int(elapsed * 1000.0))
	_refresh_labels()
	queue_redraw()

# ---------------------------------------------------------------------------
# Game lifecycle
# ---------------------------------------------------------------------------
func _reset_game() -> void:
	grid.clear()
	for y in ROWS:
		var row: Array = []
		for x in COLS:
			row.append(-1)
		grid.append(row)
	bag.clear()
	if match_seed != 0:
		rng.seed = match_seed
	else:
		rng.randomize()
	score = 0
	level = 1
	lines = 0
	elapsed = 0.0
	paused = false
	fall_timer = 0.0
	lock_timer = 0.0
	clear_flash = 0.0
	clear_rows.clear()
	pending_clear_count = 0
	clearing = false
	hold_type = -1
	hold_used = false
	combo = 0
	toast_text = ""
	toast_timer = 0.0
	particles.clear()
	shake_time = 0.0
	left_held = false
	right_held = false
	soft_held = false
	_update_fall_interval()
	next_type = _next_from_bag()
	_spawn_piece()
	_refresh_labels()
	pause_btn.text = "II"
	queue_redraw()

func _spawn_piece() -> void:
	cur_type = next_type
	next_type = _next_from_bag()
	cur_rot = 0
	cur_pos = Vector2i(3, 0)
	lock_timer = 0.0
	hold_used = false
	if not _is_valid(cur_type, cur_rot, cur_pos):
		_end_run(false)

func _end_run(victory: bool) -> void:
	if screen == Screen.GAME_OVER:
		return
	if score > high_score:
		high_score = score
		_save_high_score(high_score)
	_show_game_over(victory)

func _next_from_bag() -> int:
	if bag.is_empty():
		bag = [0, 1, 2, 3, 4, 5, 6]
		# Fisher-Yates with seeded rng
		for i in range(bag.size() - 1, 0, -1):
			var j := rng.randi_range(0, i)
			var tmp = bag[i]
			bag[i] = bag[j]
			bag[j] = tmp
	return int(bag.pop_back())

func _hash_seed(s: String) -> int:
	var h := 2166136261
	for i in s.length():
		h = int(h) ^ s.unicode_at(i)
		h = int(h * 16777619) & 0x7fffffff
	return h

func _cells(type: int, rot: int, pos: Vector2i) -> Array:
	var out: Array = []
	for c in PIECES[type][rot]:
		out.append(Vector2i(c.x + pos.x, c.y + pos.y))
	return out

func _is_valid(type: int, rot: int, pos: Vector2i) -> bool:
	for c in _cells(type, rot, pos):
		if c.x < 0 or c.x >= COLS or c.y < 0 or c.y >= ROWS:
			return false
		if grid[c.y][c.x] != -1:
			return false
	return true

func _ghost_pos() -> Vector2i:
	var p := cur_pos
	while _is_valid(cur_type, cur_rot, p + Vector2i(0, 1)):
		p += Vector2i(0, 1)
	return p

func _playfield_rect() -> Rect2:
	return Rect2(board_origin, Vector2(cell * COLS, cell * ROWS)).grow(cell * 0.5)

func _try_move(delta: Vector2i) -> bool:
	if screen != Screen.PLAY or paused or clearing or countdown > 0.0:
		return false
	if _is_valid(cur_type, cur_rot, cur_pos + delta):
		cur_pos += delta
		if delta.y == 0:
			lock_timer = 0.0
			_sfx("move")
		queue_redraw()
		return true
	return false

func _rotate(dir: int) -> void:
	if screen != Screen.PLAY or paused or clearing or countdown > 0.0:
		return
	var nr := (cur_rot + dir + 4) % 4
	for kick in [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(-2, 0), Vector2i(2, 0), Vector2i(0, -1)]:
		if _is_valid(cur_type, nr, cur_pos + kick):
			cur_rot = nr
			cur_pos += kick
			lock_timer = 0.0
			_sfx("rotate")
			queue_redraw()
			return

func _soft_drop() -> void:
	if _try_move(Vector2i(0, 1)):
		score += 1
		_sfx("soft")
		_refresh_labels()

func _hard_drop() -> void:
	if screen != Screen.PLAY or paused or clearing or countdown > 0.0:
		return
	var dropped := 0
	while _try_move(Vector2i(0, 1)):
		dropped += 1
	score += dropped * 2
	_sfx("hard")
	_shake(0.12, 4.0)
	_lock_piece()

func _hold_piece() -> void:
	if screen != Screen.PLAY or paused or clearing or hold_used or countdown > 0.0:
		return
	_sfx("ui")
	if hold_type < 0:
		hold_type = cur_type
		_spawn_piece()
	else:
		var swap := hold_type
		hold_type = cur_type
		cur_type = swap
		cur_rot = 0
		cur_pos = Vector2i(3, 0)
		lock_timer = 0.0
		if not _is_valid(cur_type, cur_rot, cur_pos):
			_end_run(false)
			return
	hold_used = true
	queue_redraw()

func _lock_piece() -> void:
	for c in _cells(cur_type, cur_rot, cur_pos):
		if c.y >= 0 and c.y < ROWS and c.x >= 0 and c.x < COLS:
			grid[c.y][c.x] = cur_type
	_sfx("lock")
	var full_rows := _find_full_rows()
	if full_rows.is_empty():
		combo = 0
		_spawn_piece()
		_refresh_labels()
		queue_redraw()
		return
	clear_rows = full_rows
	pending_clear_count = full_rows.size()
	clear_flash = 0.32
	clearing = true
	_spawn_clear_particles(full_rows)
	_shake(0.18, 6.0 + pending_clear_count * 2.0)
	if pending_clear_count >= 4:
		_sfx("tetris")
		_haptic(80)
	else:
		_sfx("clear")
		_haptic(40)
	queue_redraw()

func _find_full_rows() -> Array:
	var full_rows: Array = []
	for y in ROWS:
		var full := true
		for x in COLS:
			if grid[y][x] == -1:
				full = false
				break
		if full:
			full_rows.append(y)
	return full_rows

func _finish_clear() -> void:
	var rows := clear_rows.duplicate()
	rows.sort()
	rows.reverse()
	for y in rows:
		grid.remove_at(y)
		var empty: Array = []
		for x in COLS:
			empty.append(-1)
		grid.insert(0, empty)
	var cleared: int = pending_clear_count
	combo += 1
	var base: int = int(LINE_SCORES[cleared]) * level
	var bonus: int = int(base * 0.5 * maxi(0, combo - 1))
	score += base + bonus
	lines += cleared
	level = 1 + int(lines / 10.0)
	_update_fall_interval()
	if combo > 1:
		_show_toast("COMBO x%d  +%d" % [combo, base + bonus], 1.1)
	elif cleared >= 4:
		_show_toast("QUAD CLEAR  +%d" % (base + bonus), 1.0)
	elif cleared == 3:
		_show_toast("TRIPLE  +%d" % (base + bonus), 0.85)
	elif cleared == 2:
		_show_toast("DOUBLE  +%d" % (base + bonus), 0.75)
	pending_clear_count = 0
	clear_rows.clear()
	clearing = false
	_refresh_labels()
	if mode == Mode.SPRINT and lines >= SPRINT_LINES:
		_end_run(true)
		return
	_spawn_piece()
	queue_redraw()

func _show_toast(text: String, dur: float = 0.9) -> void:
	toast_text = text
	toast_timer = dur

func _update_fall_interval() -> void:
	fall_interval = maxf(0.05, pow(0.82, level - 1))

func _shake(t: float, mag: float) -> void:
	shake_time = t
	shake_mag = mag

func _spawn_clear_particles(rows: Array) -> void:
	for y in rows:
		for x in COLS:
			var cidx: int = int(grid[y][x]) if grid[y][x] != -1 else rng.randi_range(0, 6)
			particles.append({
				"pos": board_origin + Vector2((x + 0.5) * cell, (y + 0.5) * cell),
				"vel": Vector2(rng.randf_range(-120, 120), rng.randf_range(-220, -40)),
				"life": rng.randf_range(0.35, 0.7),
				"color": _colors()[cidx],
				"size": rng.randf_range(3.0, 7.0),
			})

func _fmt_time(ms: int) -> String:
	var s := ms / 1000
	var m := int(s / 60)
	var r := int(s % 60)
	var frac := int((ms % 1000) / 10)
	return "%d:%02d.%02d" % [m, r, frac]

# ---------------------------------------------------------------------------
# Loop
# ---------------------------------------------------------------------------
func _process(delta: float) -> void:
	title_pulse += delta
	if toast_timer > 0.0:
		toast_timer = maxf(0.0, toast_timer - delta)
	if shake_time > 0.0:
		shake_time = maxf(0.0, shake_time - delta)
	if not particles.is_empty():
		var alive: Array = []
		for p in particles:
			p["life"] = float(p["life"]) - delta
			p["vel"].y += 520.0 * delta
			p["pos"] = p["pos"] + p["vel"] * delta
			if float(p["life"]) > 0.0:
				alive.append(p)
		particles = alive
		queue_redraw()
	if clear_flash > 0.0:
		clear_flash = maxf(0.0, clear_flash - delta)
		if clearing and clear_flash <= 0.0:
			_finish_clear()
	if screen == Screen.ROOM and online:
		room_poll -= delta
		if room_poll <= 0.0:
			room_poll = 1.2
			online.poll_room()
	if screen == Screen.MENU or screen == Screen.MODE or screen == Screen.SETTINGS or screen == Screen.HOWTO or screen == Screen.ONLINE or screen == Screen.ROOM or screen == Screen.LEADERBOARD:
		for b in menu_blocks:
			b["phase"] = float(b["phase"]) + delta
			var p2: Vector2 = b["pos"]
			p2.y = fposmod(p2.y + float(b["speed"]) * delta * 0.01, 1.0)
			b["pos"] = p2
		queue_redraw()
		return
	if screen != Screen.PLAY or paused:
		queue_redraw()
		return
	if countdown > 0.0:
		countdown = maxf(0.0, countdown - delta)
		queue_redraw()
		return
	elapsed += delta
	if mode == Mode.ULTRA and elapsed >= ULTRA_SECONDS:
		_end_run(false)
		return
	if left_held or right_held:
		move_timer -= delta
		if move_timer <= 0.0:
			_try_move(Vector2i(-1 if left_held else 1, 0))
			move_timer = ARR
	if soft_held:
		soft_timer -= delta
		if soft_timer <= 0.0:
			_soft_drop()
			soft_timer = ARR
	if clearing:
		queue_redraw()
		return
	fall_timer += delta
	if fall_timer >= fall_interval:
		fall_timer = 0.0
		if not _try_move(Vector2i(0, 1)):
			lock_timer += fall_interval
	if not _is_valid(cur_type, cur_rot, cur_pos + Vector2i(0, 1)):
		lock_timer += delta
		if lock_timer >= LOCK_DELAY:
			_lock_piece()
	else:
		lock_timer = 0.0
	_refresh_labels()
	queue_redraw()

# ---------------------------------------------------------------------------
# Input
# ---------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		_handle_key(event)
	elif event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)

func _handle_key(e: InputEventKey) -> void:
	if e.echo:
		return
	if screen == Screen.GAME_OVER and e.pressed and (e.keycode == KEY_ENTER or e.keycode == KEY_R or e.keycode == KEY_SPACE):
		if online_match:
			_show_room()
		else:
			_show_mode()
		return
	if screen != Screen.PLAY:
		return
	if e.pressed:
		match e.keycode:
			KEY_LEFT, KEY_A:
				left_held = true
				move_timer = DAS
				_try_move(Vector2i(-1, 0))
			KEY_RIGHT, KEY_D:
				right_held = true
				move_timer = DAS
				_try_move(Vector2i(1, 0))
			KEY_DOWN, KEY_S:
				soft_held = true
				soft_timer = DAS
				_soft_drop()
			KEY_UP, KEY_X, KEY_W:
				_rotate(1)
			KEY_Z:
				_rotate(-1)
			KEY_SPACE:
				_hard_drop()
			KEY_C, KEY_SHIFT:
				_hold_piece()
			KEY_P, KEY_ESCAPE:
				_toggle_pause()
	else:
		match e.keycode:
			KEY_LEFT, KEY_A:
				left_held = false
			KEY_RIGHT, KEY_D:
				right_held = false
			KEY_DOWN, KEY_S:
				soft_held = false

func _handle_touch(e: InputEventScreenTouch) -> void:
	if e.pressed:
		if screen == Screen.GAME_OVER:
			return
		if screen != Screen.PLAY or paused or countdown > 0.0:
			return
		if not _playfield_rect().has_point(e.position):
			touching = false
			return
		touching = true
		touch_start = e.position
		touch_moved = false
		swipe_acc = Vector2.ZERO
	else:
		if screen == Screen.GAME_OVER:
			if online_match:
				_show_room()
			else:
				_show_mode()
			return
		if not touching:
			return
		touching = false
		if not touch_moved and e.position.distance_to(touch_start) < TAP_MAX_DIST and not paused:
			_rotate(1)
		soft_held = false

func _handle_drag(e: InputEventScreenDrag) -> void:
	if not touching or screen != Screen.PLAY or paused or countdown > 0.0:
		return
	swipe_acc += e.relative
	if e.position.distance_to(touch_start) > TAP_MAX_DIST:
		touch_moved = true
	while swipe_acc.x >= SWIPE_STEP:
		_try_move(Vector2i(1, 0))
		swipe_acc.x -= SWIPE_STEP
	while swipe_acc.x <= -SWIPE_STEP:
		_try_move(Vector2i(-1, 0))
		swipe_acc.x += SWIPE_STEP
	while swipe_acc.y >= SOFT_STEP:
		_soft_drop()
		swipe_acc.y -= SOFT_STEP

func _on_left_down() -> void:
	left_held = true
	move_timer = DAS
	_try_move(Vector2i(-1, 0))
func _on_left_up() -> void:
	left_held = false
func _on_right_down() -> void:
	right_held = true
	move_timer = DAS
	_try_move(Vector2i(1, 0))
func _on_right_up() -> void:
	right_held = false
func _on_soft_down() -> void:
	soft_held = true
	soft_timer = DAS
	_soft_drop()
func _on_soft_up() -> void:
	soft_held = false
func _on_rotate_btn() -> void:
	_rotate(1)
func _on_drop_btn() -> void:
	_hard_drop()

func _toggle_pause() -> void:
	if screen != Screen.PLAY or online_match:
		# No pause mid online race — keep fair.
		if screen == Screen.PLAY and online_match:
			_show_toast("No pause in online race", 0.8)
		return
	paused = not paused
	pause_btn.text = "▶" if paused else "II"
	overlay.visible = paused
	if paused:
		overlay_title.text = "PAUSED"
		overlay_sub.text = "Tap II to resume"
		if music_player:
			music_player.stream_paused = true
	else:
		overlay.visible = false
		if music_player and music_on:
			music_player.stream_paused = false
	queue_redraw()

# ---------------------------------------------------------------------------
# Online handlers
# ---------------------------------------------------------------------------
func _on_online_ok(kind: String, data: Dictionary) -> void:
	status_msg = ""
	match kind:
		"register":
			status_msg = "Signed in as %s" % online.player_name
			_refresh_status()
			if menu_xp_label:
				menu_xp_label.text = "%s  ·  XP %d  ·  Theme %s" % [online.player_name, online.player_xp, _theme()["name"]]
			if pending_create_mode != "":
				var m := pending_create_mode
				pending_create_mode = ""
				online.create_room(m)
			elif pending_join_code != "":
				var c := pending_join_code
				pending_join_code = ""
				online.join_room(c)
			elif pending_daily:
				online.fetch_daily()
		"create_room", "join_room":
			_apply_room_payload(data)
			_show_room()
		"ready", "start_room", "poll_room", "finish_room":
			_apply_room_payload(data)
			if kind == "start_room" or (kind == "poll_room" and screen == Screen.ROOM):
				var room: Dictionary = data.get("room", {})
				if String(room.get("status", "")) == "playing" and screen == Screen.ROOM:
					match_seed = int(room.get("seed", 0))
					online_match = true
					mode = _mode_from_str(String(room.get("mode", "sprint")))
					_begin_play()
			if kind == "finish_room":
				_refresh_room_ui()
				if screen == Screen.GAME_OVER:
					overlay_sub.text = "Score %d submitted.\nTap for room ranking." % score
		"leaderboard":
			leaderboard_entries = data.get("entries", [])
			_refresh_lb_ui(String(data.get("board", "daily")), String(data.get("day", "")))
		"daily":
			match_seed = int(data.get("seed", match_seed))
			if pending_daily or (mode == Mode.DAILY and screen != Screen.PLAY and screen != Screen.GAME_OVER):
				pending_daily = false
				_begin_play()
		"daily_submit":
			leaderboard_entries = data.get("entries", [])
			if screen == Screen.GAME_OVER:
				overlay_sub.text += "\nDaily rank updated."
		"health":
			status_msg = "Server online"
			_refresh_status()
	queue_redraw()

func _on_online_fail(kind: String, message: String) -> void:
	status_msg = message
	_refresh_status()
	if screen == Screen.GAME_OVER:
		overlay_sub.text += "\n(%s)" % message
	queue_redraw()

func _apply_room_payload(data: Dictionary) -> void:
	if not data.has("room"):
		return
	var room: Dictionary = data["room"]
	online.room_code = String(room.get("code", online.room_code))
	is_host = String(room.get("hostId", "")) == online.player_id
	room_players = room.get("players", [])
	room_ranking = data.get("ranking", [])
	mode = _mode_from_str(String(room.get("mode", "sprint")))
	_refresh_room_ui()

func _mode_from_str(s: String) -> Mode:
	match s:
		"classic":
			return Mode.CLASSIC
		"ultra":
			return Mode.ULTRA
		"daily":
			return Mode.DAILY
		_:
			return Mode.SPRINT

func _mode_str(m: Mode) -> String:
	match m:
		Mode.CLASSIC:
			return "classic"
		Mode.ULTRA:
			return "ultra"
		Mode.DAILY:
			return "daily"
		_:
			return "sprint"

func _refresh_status() -> void:
	if status_label:
		status_label.text = status_msg

func _refresh_room_ui() -> void:
	if room_info_label == null:
		return
	room_info_label.text = "Room %s  ·  %s\n%s" % [online.room_code if online else "----", _mode_str(mode).capitalize(), "Host controls Start" if is_host else "Waiting for host"]
	var lines_txt := ""
	for p in room_players:
		var mark := "●" if bool(p.get("ready", false)) else "○"
		var fin := " DONE" if bool(p.get("finished", false)) else ""
		lines_txt += "%s %s%s\n" % [mark, String(p.get("name", "?")), fin]
	if not room_ranking.is_empty():
		lines_txt += "\nRanking\n"
		for e in room_ranking:
			if mode == Mode.SPRINT:
				lines_txt += "#%d  %s  %s\n" % [int(e.get("rank", 0)), String(e.get("name", "?")), _fmt_time(int(e.get("timeMs", 0)))]
			else:
				lines_txt += "#%d  %s  %d\n" % [int(e.get("rank", 0)), String(e.get("name", "?")), int(e.get("score", 0))]
	room_list_label.text = lines_txt

func _refresh_lb_ui(board: String, day: String) -> void:
	var t := "Leaderboard · %s" % board.capitalize()
	if day != "":
		t += " · %s" % day
	t += "\n\n"
	if leaderboard_entries.is_empty():
		t += "No scores yet. Be the first!"
	else:
		var i := 1
		for e in leaderboard_entries:
			if board == "sprint":
				t += "#%d  %s  %s\n" % [i, String(e.get("name", "?")), _fmt_time(int(e.get("timeMs", 0)))]
			else:
				t += "#%d  %s  %d\n" % [i, String(e.get("name", "?")), int(e.get("score", 0))]
			i += 1
	lb_label.text = t

# ---------------------------------------------------------------------------
# Audio
# ---------------------------------------------------------------------------
func _setup_audio() -> void:
	var names := ["move", "rotate", "soft", "lock", "hard", "clear", "tetris", "gameover", "ui"]
	for n in names:
		var p := AudioStreamPlayer.new()
		p.name = "Sfx_" + n
		var path := "res://assets/audio/%s.wav" % n
		if ResourceLoader.exists(path):
			p.stream = load(path)
		add_child(p)
		sfx_players[n] = p
	music_player = AudioStreamPlayer.new()
	music_player.volume_db = -10.0
	var mpath := "res://assets/audio/music.wav"
	if ResourceLoader.exists(mpath):
		var stream = load(mpath)
		if stream is AudioStreamWAV:
			var wav := stream as AudioStreamWAV
			wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
			wav.loop_begin = 0
			var bps := 2 if wav.format == AudioStreamWAV.FORMAT_16_BITS else 1
			var ch := 2 if wav.stereo else 1
			wav.loop_end = int(wav.data.size() / float(bps * ch))
			music_player.stream = wav
		else:
			music_player.stream = stream
	add_child(music_player)

func _sfx(name: String) -> void:
	if sfx_on and sfx_players.has(name) and sfx_players[name].stream:
		sfx_players[name].play()

func _play_music(force_restart: bool = false) -> void:
	if music_player == null or music_player.stream == null:
		return
	if music_on:
		if force_restart or not music_player.playing:
			music_player.play()
		music_player.stream_paused = false
	else:
		music_player.stop()

func _apply_music_setting() -> void:
	if music_on:
		_play_music(false)
	elif music_player:
		music_player.stop()

func _haptic(ms: int) -> void:
	if haptic_on:
		Input.vibrate_handheld(ms)

# ---------------------------------------------------------------------------
# Draw
# ---------------------------------------------------------------------------
func _draw() -> void:
	var size := get_size()
	var th := _theme()
	draw_rect(Rect2(Vector2.ZERO, size), th["bg"], true)
	_draw_ambient(size)
	if screen != Screen.PLAY and screen != Screen.GAME_OVER:
		_draw_menu_blocks(size)
		return
	var offset := Vector2.ZERO
	if shake_time > 0.0:
		offset = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)) * shake_mag
	var origin := board_origin + offset
	var board_w := cell * COLS
	var board_h := cell * ROWS
	draw_rect(Rect2(origin - Vector2(6, 6), Vector2(board_w + 12, board_h + 12)), th["panel"], true)
	draw_rect(Rect2(origin - Vector2(6, 6), Vector2(board_w + 12, board_h + 12)), Color(th["accent"].r, th["accent"].g, th["accent"].b, 0.25), false, 2.0)
	for x in range(COLS + 1):
		draw_line(origin + Vector2(x * cell, 0), origin + Vector2(x * cell, board_h), Color(1, 1, 1, 0.05), 1.0)
	for y in range(ROWS + 1):
		draw_line(origin + Vector2(0, y * cell), origin + Vector2(board_w, y * cell), Color(1, 1, 1, 0.05), 1.0)
	for y in ROWS:
		for x in COLS:
			var v: int = grid[y][x]
			if v != -1:
				_draw_cell_at(origin, Vector2i(x, y), _colors()[v], 1.0)
	if clear_flash > 0.0:
		var a := clear_flash / 0.32
		draw_rect(Rect2(origin, Vector2(board_w, board_h)), Color(1, 1, 1, 0.18 * a), true)
		for ry in clear_rows:
			var yy := clampi(int(ry), 0, ROWS - 1)
			draw_rect(Rect2(origin + Vector2(0, yy * cell), Vector2(board_w, cell)), Color(th["accent"].r, th["accent"].g, th["accent"].b, 0.55 * a), true)
	if screen == Screen.PLAY and not paused and not clearing and countdown <= 0.0:
		var gp := _ghost_pos()
		for c in _cells(cur_type, cur_rot, gp):
			if c.y >= 0:
				_draw_cell_at(origin, c, _colors()[cur_type], 0.22)
		for c in _cells(cur_type, cur_rot, cur_pos):
			if c.y >= 0:
				_draw_cell_at(origin, c, _colors()[cur_type], 1.0)
	_draw_side_previews()
	for p in particles:
		var col: Color = p["color"]
		col.a = clampf(float(p["life"]) * 2.0, 0.0, 1.0)
		draw_circle(p["pos"] + offset, float(p["size"]), col)
	_draw_toast(size)
	if countdown > 0.0:
		var n := str(maxi(1, int(ceil(countdown))))
		draw_string(ThemeDB.fallback_font, Vector2(size.x * 0.5 - 20, size.y * 0.45), n, HORIZONTAL_ALIGNMENT_LEFT, -1, 72, Color.WHITE)

func _draw_toast(size: Vector2) -> void:
	if toast_timer <= 0.0 or toast_text.is_empty():
		return
	var a := clampf(toast_timer / 0.35, 0.0, 1.0)
	var font := ThemeDB.fallback_font
	var tw := font.get_string_size(toast_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 28).x
	var pos := Vector2((size.x - tw) * 0.5, board_origin.y + cell * ROWS * 0.35)
	draw_string(font, pos + Vector2(2, 2), toast_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color(0, 0, 0, 0.45 * a))
	draw_string(font, pos, toast_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color(1, 1, 1, a))

func _draw_ambient(size: Vector2) -> void:
	var pulse := 0.5 + 0.5 * sin(title_pulse * 2.0)
	var ac := _accent()
	draw_circle(Vector2(size.x * 0.5, size.y * 0.2), 180.0 + 20.0 * pulse, Color(ac.r, ac.g, ac.b, 0.05 + 0.04 * pulse))

func _draw_menu_blocks(size: Vector2) -> void:
	for b in menu_blocks:
		var p: Vector2 = Vector2(float(b["pos"].x) * size.x, float(b["pos"].y) * size.y)
		p.x += sin(float(b["phase"])) * 18.0
		var s: float = float(b["size"])
		var col: Color = _colors()[int(b["type"])]
		col.a = 0.16
		draw_rect(Rect2(p, Vector2(s, s)), col, true)

func _draw_cell_at(origin: Vector2, c: Vector2i, color: Color, alpha: float) -> void:
	var p := origin + Vector2(c.x * cell, c.y * cell)
	var col := color
	col.a = alpha
	draw_rect(Rect2(p + Vector2(1, 1), Vector2(cell - 2, cell - 2)), col, true)
	if alpha >= 1.0:
		var hi := color.lightened(0.25)
		hi.a = 0.5
		draw_rect(Rect2(p + Vector2(1, 1), Vector2(cell - 2, (cell - 2) * 0.28)), hi, true)

func _draw_side_previews() -> void:
	var box_cell := cell * 0.55
	var box_w := box_cell * 4
	_draw_mini_box(Vector2(get_size().x - box_w - 16, 78), box_w, box_cell, next_type, "NEXT")
	_draw_mini_box(Vector2(16, 98), box_w, box_cell, hold_type, "HOLD")

func _draw_mini_box(origin: Vector2, box_w: float, box_cell: float, piece_type: int, caption: String) -> void:
	draw_rect(Rect2(origin - Vector2(6, 22), Vector2(box_w + 12, box_w + 34)), _theme()["panel"], true)
	draw_string(ThemeDB.fallback_font, origin + Vector2(4, -6), caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.75, 0.8, 0.9))
	if piece_type < 0:
		return
	for c in PIECES[piece_type][0]:
		var p := origin + Vector2(c.x * box_cell, c.y * box_cell)
		draw_rect(Rect2(p + Vector2(1, 1), Vector2(box_cell - 2, box_cell - 2)), _colors()[piece_type], true)

# ---------------------------------------------------------------------------
# UI builders
# ---------------------------------------------------------------------------
func _recalc_layout() -> void:
	var size := get_size()
	hud_height = clampf(size.y * 0.12, 110.0, 180.0)
	pad_height = clampf(size.y * 0.22, 180.0, 320.0)
	var avail_h := size.y - hud_height - pad_height
	var avail_w := size.x * 0.92
	cell = floorf(minf(avail_w / COLS, avail_h / ROWS))
	cell = maxf(cell, 12.0)
	var board_w := cell * COLS
	var board_h := cell * ROWS
	board_origin = Vector2((size.x - board_w) * 0.5, hud_height + (avail_h - board_h) * 0.5)
	if pause_btn:
		pause_btn.position = Vector2(size.x - 72, 8)
	queue_redraw()

func _build_ui() -> void:
	_build_menu()
	_build_mode()
	_build_settings()
	_build_howto()
	_build_online()
	_build_room()
	_build_leaderboard()
	_build_hud()
	_build_controls()
	_build_overlay()

func _build_menu() -> void:
	menu_root = Control.new()
	menu_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(menu_root)
	var box := _center_box(-200, 200, -320, 320, 14)
	menu_root.add_child(box)
	box.add_child(_title("AOIPULSE", 56))
	box.add_child(_sub("by Aoitex", 18))
	menu_best_label = _sub("Best  0", 22)
	menu_best_label.add_theme_color_override("font_color", Color.WHITE)
	box.add_child(menu_best_label)
	menu_xp_label = _sub("Player · XP 0", 16)
	box.add_child(menu_xp_label)
	box.add_child(_btn("PLAY", true, _on_play_menu))
	box.add_child(_btn("ONLINE RACE", true, _on_online_pressed))
	box.add_child(_btn("LEADERBOARD", false, _on_lb_pressed))
	box.add_child(_btn("SETTINGS", false, _on_settings_pressed))
	box.add_child(_btn("HOW TO PLAY", false, _on_howto_pressed))

func _build_mode() -> void:
	mode_root = Control.new()
	mode_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	mode_root.visible = false
	add_child(mode_root)
	var box := _center_box(-220, 220, -300, 300, 12)
	mode_root.add_child(box)
	box.add_child(_title("SELECT MODE", 36))
	box.add_child(_btn("CLASSIC", true, func(): _start_local(Mode.CLASSIC)))
	box.add_child(_btn("SPRINT 40L", true, func(): _start_local(Mode.SPRINT)))
	box.add_child(_btn("ULTRA 2:00", true, func(): _start_local(Mode.ULTRA)))
	box.add_child(_btn("DAILY CHALLENGE", true, func(): _start_local(Mode.DAILY)))
	box.add_child(_btn("BACK", false, _on_back_menu))

func _build_settings() -> void:
	settings_root = Control.new()
	settings_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	settings_root.visible = false
	add_child(settings_root)
	var box := _center_box(-240, 240, -360, 360, 12)
	settings_root.add_child(box)
	box.add_child(_title("SETTINGS", 36))
	name_edit = LineEdit.new()
	name_edit.placeholder_text = "Display name"
	name_edit.custom_minimum_size = Vector2(280, 44)
	box.add_child(name_edit)
	server_edit = LineEdit.new()
	server_edit.placeholder_text = "Server URL"
	server_edit.custom_minimum_size = Vector2(280, 44)
	box.add_child(server_edit)
	chk_sfx = CheckButton.new()
	chk_sfx.text = "Sound effects"
	chk_sfx.toggled.connect(func(v): sfx_on = v; _save_settings())
	box.add_child(chk_sfx)
	chk_music = CheckButton.new()
	chk_music.text = "Music"
	chk_music.toggled.connect(func(v): music_on = v; _apply_music_setting(); _save_settings())
	box.add_child(chk_music)
	chk_haptic = CheckButton.new()
	chk_haptic.text = "Vibration"
	chk_haptic.toggled.connect(func(v): haptic_on = v; _save_settings())
	box.add_child(chk_haptic)
	box.add_child(_btn("SAVE PROFILE", true, _on_save_profile))
	box.add_child(_btn("BACK", false, _on_back_menu))

func _build_howto() -> void:
	howto_root = Control.new()
	howto_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	howto_root.visible = false
	add_child(howto_root)
	var box := _center_box(-270, 270, -340, 340, 10)
	howto_root.add_child(box)
	box.add_child(_title("HOW TO PLAY", 34))
	var body := _sub("Modes\nClassic · Sprint 40 lines · Ultra 2 min · Daily shared seed\n\nOnline Race\nCreate/join a room (max 8). Same seed, live ranking.\n\nTouch\nSwipe move · Tap rotate · H hold · ⤓ hard drop\n\nCombos & themes unlock with XP.", 17)
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(body)
	box.add_child(_btn("BACK", false, _on_back_menu))

func _build_online() -> void:
	online_root = Control.new()
	online_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	online_root.visible = false
	add_child(online_root)
	var box := _center_box(-250, 250, -340, 340, 12)
	online_root.add_child(box)
	box.add_child(_title("ONLINE RACE", 36))
	status_label = _sub("...", 16)
	box.add_child(status_label)
	join_edit = LineEdit.new()
	join_edit.placeholder_text = "Room code"
	join_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	join_edit.custom_minimum_size = Vector2(260, 48)
	box.add_child(join_edit)
	box.add_child(_btn("CREATE SPRINT ROOM", true, func(): _online_create("sprint")))
	box.add_child(_btn("CREATE ULTRA ROOM", true, func(): _online_create("ultra")))
	box.add_child(_btn("JOIN ROOM", true, _online_join))
	box.add_child(_btn("PING SERVER", false, func(): if online: online.health()))
	box.add_child(_btn("BACK", false, _on_back_menu))

func _build_room() -> void:
	room_root = Control.new()
	room_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	room_root.visible = false
	add_child(room_root)
	var box := _center_box(-270, 270, -360, 360, 10)
	room_root.add_child(box)
	box.add_child(_title("ROOM", 34))
	room_info_label = _sub("", 18)
	room_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(room_info_label)
	room_list_label = _sub("", 17)
	room_list_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	room_list_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(room_list_label)
	box.add_child(_btn("READY TOGGLE", true, func(): if online: online.set_ready(true)))
	box.add_child(_btn("START MATCH", true, func(): if online: online.start_room()))
	box.add_child(_btn("LEAVE", false, _on_back_menu))

func _build_leaderboard() -> void:
	lb_root = Control.new()
	lb_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	lb_root.visible = false
	add_child(lb_root)
	var box := _center_box(-270, 270, -360, 360, 10)
	lb_root.add_child(box)
	box.add_child(_title("RANKINGS", 34))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	box.add_child(row)
	row.add_child(_btn("DAILY", false, func(): if online: online.fetch_leaderboard("daily")))
	row.add_child(_btn("SPRINT", false, func(): if online: online.fetch_leaderboard("sprint")))
	row.add_child(_btn("ULTRA", false, func(): if online: online.fetch_leaderboard("ultra")))
	lb_label = _sub("...", 17)
	lb_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	lb_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(lb_label)
	box.add_child(_btn("BACK", false, _on_back_menu))

func _build_hud() -> void:
	hud_root = Control.new()
	hud_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_root.visible = false
	add_child(hud_root)
	var hud := VBoxContainer.new()
	hud.position = Vector2(16, 8)
	hud_root.add_child(hud)
	score_label = _make_label("Score 0", 28, Color.WHITE)
	high_label = _make_label("Best 0", 16, Color(0.7, 0.75, 0.85))
	timer_label = _make_label("", 16, Color(0.85, 0.9, 1.0))
	hud.add_child(score_label)
	hud.add_child(high_label)
	hud.add_child(timer_label)
	var stat := HBoxContainer.new()
	stat.position = Vector2(16, 86)
	stat.add_theme_constant_override("separation", 16)
	hud_root.add_child(stat)
	level_label = _make_label("Lv 1", 17, Color(0.8, 0.85, 0.95))
	lines_label = _make_label("Lines 0", 17, Color(0.8, 0.85, 0.95))
	stat.add_child(level_label)
	stat.add_child(lines_label)
	pause_btn = Button.new()
	pause_btn.text = "II"
	pause_btn.custom_minimum_size = Vector2(56, 56)
	pause_btn.focus_mode = Control.FOCUS_NONE
	pause_btn.pressed.connect(_toggle_pause)
	pause_btn.visible = false
	_apply_button_style(pause_btn, false)
	add_child(pause_btn)

func _build_controls() -> void:
	pad_root = HBoxContainer.new()
	pad_root.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	pad_root.offset_left = 8
	pad_root.offset_right = -8
	pad_root.offset_top = -150
	pad_root.offset_bottom = -20
	pad_root.alignment = BoxContainer.ALIGNMENT_CENTER
	pad_root.add_theme_constant_override("separation", 8)
	pad_root.visible = false
	add_child(pad_root)
	var left := _pad("◀")
	left.button_down.connect(_on_left_down)
	left.button_up.connect(_on_left_up)
	pad_root.add_child(left)
	var hold := _pad("H")
	hold.pressed.connect(_hold_piece)
	pad_root.add_child(hold)
	var rot := _pad("⟳")
	rot.pressed.connect(_on_rotate_btn)
	pad_root.add_child(rot)
	var down := _pad("▼")
	down.button_down.connect(_on_soft_down)
	down.button_up.connect(_on_soft_up)
	pad_root.add_child(down)
	var drop := _pad("⤓")
	drop.pressed.connect(_on_drop_btn)
	pad_root.add_child(drop)
	var right := _pad("▶")
	right.button_down.connect(_on_right_down)
	right.button_up.connect(_on_right_up)
	pad_root.add_child(right)

func _build_overlay() -> void:
	overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.visible = false
	add_child(overlay)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(dim)
	var box := _center_box(-220, 220, -120, 120, 14)
	overlay.add_child(box)
	overlay_title = _title("PAUSED", 44)
	box.add_child(overlay_title)
	overlay_sub = _sub("", 20)
	overlay_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(overlay_sub)

func _center_box(l: float, r: float, t: float, b: float, sep: int) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left = l
	box.offset_right = r
	box.offset_top = t
	box.offset_bottom = b
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", sep)
	return box

func _title(text: String, size: int) -> Label:
	return _make_label(text, size, _accent())

func _sub(text: String, size: int) -> Label:
	var l := _make_label(text, size, Color(0.7, 0.75, 0.85))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

func _make_label(text: String, font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

func _btn(text: String, primary: bool, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(260, 56)
	b.add_theme_font_size_override("font_size", 22)
	b.focus_mode = Control.FOCUS_NONE
	_apply_button_style(b, primary)
	b.pressed.connect(cb)
	return b

func _pad(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(52, 88)
	b.add_theme_font_size_override("font_size", 28)
	b.focus_mode = Control.FOCUS_NONE
	_apply_button_style(b, false)
	return b

func _apply_button_style(b: Button, primary: bool) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.12, 0.42, 0.52, 0.95) if primary else Color(0.14, 0.18, 0.28, 0.95)
	normal.set_corner_radius_all(14)
	normal.content_margin_left = 10
	normal.content_margin_right = 10
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
	normal.border_width_bottom = 3
	normal.border_color = Color(0.05, 0.07, 0.12, 0.8)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = normal.bg_color.lightened(0.12)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = normal.bg_color.darkened(0.12)
	pressed.border_width_bottom = 1
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_color_override("font_color", Color(0.92, 0.95, 1.0))

func _refresh_labels() -> void:
	if score_label:
		score_label.text = "Score %d" % score
	if high_label:
		high_label.text = "Best %d" % high_score
	if level_label:
		level_label.text = "Lv %d" % level
	if lines_label:
		if mode == Mode.SPRINT:
			lines_label.text = "Lines %d/%d" % [lines, SPRINT_LINES]
		else:
			lines_label.text = "Lines %d" % lines
	if timer_label:
		if mode == Mode.ULTRA:
			timer_label.text = "Time %s" % _fmt_time(int(maxf(0.0, ULTRA_SECONDS - elapsed) * 1000.0))
		elif mode == Mode.SPRINT or online_match:
			timer_label.text = "Time %s" % _fmt_time(int(elapsed * 1000.0))
		elif mode == Mode.DAILY:
			timer_label.text = "Daily"
		else:
			timer_label.text = _mode_str(mode).capitalize()

# ---------------------------------------------------------------------------
# Button callbacks / persistence
# ---------------------------------------------------------------------------
func _on_play_menu() -> void:
	_sfx("ui")
	_show_mode()

func _on_online_pressed() -> void:
	_sfx("ui")
	_show_online()

func _on_lb_pressed() -> void:
	_sfx("ui")
	_show_leaderboard()

func _on_settings_pressed() -> void:
	_sfx("ui")
	_show_settings()

func _on_howto_pressed() -> void:
	_sfx("ui")
	_show_howto()

func _on_back_menu() -> void:
	_sfx("ui")
	_save_settings()
	_apply_music_setting()
	_show_menu()

func _on_save_profile() -> void:
	_sfx("ui")
	if online:
		online.save_base_url(server_edit.text.strip_edges())
		online.register_player(name_edit.text)
	_save_settings()
	status_msg = "Profile saved"
	_refresh_status()

func _online_create(m: String) -> void:
	_sfx("ui")
	if online == null:
		status_msg = "Online module missing"
		_refresh_status()
		return
	if online.player_id == "":
		pending_create_mode = m
		status_msg = "Registering..."
		_refresh_status()
		online.register_player(name_edit.text if name_edit else online.player_name)
		return
	online.create_room(m)

func _online_join() -> void:
	_sfx("ui")
	if online == null:
		return
	var code := join_edit.text.strip_edges().to_upper()
	if code.is_empty():
		status_msg = "Enter a room code"
		_refresh_status()
		return
	if online.player_id == "":
		pending_join_code = code
		online.register_player(online.player_name)
		return
	online.join_room(code)

func _load_high_score() -> int:
	if not FileAccess.file_exists(SAVE_PATH):
		return 0
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return 0
	var v := f.get_32()
	f.close()
	return v

func _save_high_score(value: int) -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_32(value)
	f.close()

func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return
	sfx_on = bool(cfg.get_value("audio", "sfx", true))
	music_on = bool(cfg.get_value("audio", "music", true))
	haptic_on = bool(cfg.get_value("game", "haptic", true))
	theme_idx = int(cfg.get_value("game", "theme", 0))

func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "sfx", sfx_on)
	cfg.set_value("audio", "music", music_on)
	cfg.set_value("game", "haptic", haptic_on)
	cfg.set_value("game", "theme", theme_idx)
	cfg.save(SETTINGS_PATH)
