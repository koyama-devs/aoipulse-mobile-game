extends Control
## AOIPulse — falling-blocks puzzle by Aoitex.
## Single Control node: menu, settings, gameplay, rendering, audio, haptics.

# ---------------------------------------------------------------------------
# Board
# ---------------------------------------------------------------------------
const COLS := 10
const ROWS := 20
const SAVE_PATH := "user://aoipulse.save"
const SETTINGS_PATH := "user://aoipulse_settings.cfg"

const PIECES := [
	[ # I
		[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)],
		[Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)],
		[Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)],
		[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)],
	],
	[ # O
		[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)],
		[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)],
		[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)],
		[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)],
	],
	[ # T
		[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
		[Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],
		[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],
		[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)],
	],
	[ # S
		[Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)],
		[Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)],
		[Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2)],
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)],
	],
	[ # Z
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)],
		[Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],
		[Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)],
		[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)],
	],
	[ # J
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
		[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(1, 2)],
		[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)],
		[Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)],
	],
	[ # L
		[Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
		[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)],
		[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2)],
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)],
	],
]

const COLORS := [
	Color(0.16, 0.83, 0.92),
	Color(0.96, 0.80, 0.20),
	Color(0.66, 0.35, 0.88),
	Color(0.32, 0.78, 0.40),
	Color(0.90, 0.28, 0.38),
	Color(0.27, 0.50, 0.90),
	Color(0.94, 0.58, 0.22),
]

const BG_COLOR := Color(0.06, 0.07, 0.12)
const PANEL_COLOR := Color(0.10, 0.12, 0.20)
const ACCENT := Color(0.29, 0.83, 0.92)
const GRID_LINE := Color(1, 1, 1, 0.05)
const GHOST_ALPHA := 0.22
const LINE_SCORES := [0, 100, 300, 500, 800]
const LOCK_DELAY := 0.5
const DAS := 0.16
const ARR := 0.045
const SWIPE_STEP := 34.0
const SOFT_STEP := 34.0
const TAP_MAX_DIST := 18.0

enum Screen { MENU, SETTINGS, HOWTO, PLAY, GAME_OVER }

# ---------------------------------------------------------------------------
# Runtime
# ---------------------------------------------------------------------------
var screen: Screen = Screen.MENU
var grid: Array = []
var bag: Array = []
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

# Settings
var sfx_on := true
var music_on := true
var haptic_on := true

# UI
var hud_root: Control
var score_label: Label
var high_label: Label
var level_label: Label
var lines_label: Label
var pause_btn: Button
var pad_root: Control
var menu_root: Control
var settings_root: Control
var howto_root: Control
var overlay: Control
var overlay_title: Label
var overlay_sub: Label
var menu_best_label: Label
var chk_sfx: CheckButton
var chk_music: CheckButton
var chk_haptic: CheckButton

# Audio
var sfx_players: Dictionary = {}
var music_player: AudioStreamPlayer

func _ready() -> void:
	randomize()
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
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in 8:
		menu_blocks.append({
			"pos": Vector2(rng.randf_range(0.05, 0.95), rng.randf_range(0.08, 0.92)),
			"type": rng.randi_range(0, 6),
			"speed": rng.randf_range(8.0, 22.0),
			"phase": rng.randf_range(0.0, TAU),
			"size": rng.randf_range(14.0, 28.0),
		})

# ---------------------------------------------------------------------------
# Screens
# ---------------------------------------------------------------------------
func _show_menu() -> void:
	screen = Screen.MENU
	paused = false
	hud_root.visible = false
	pad_root.visible = false
	pause_btn.visible = false
	settings_root.visible = false
	howto_root.visible = false
	overlay.visible = false
	menu_root.visible = true
	menu_best_label.text = "Best score  %d" % high_score
	_play_music(true)
	queue_redraw()

func _show_settings() -> void:
	screen = Screen.SETTINGS
	menu_root.visible = false
	howto_root.visible = false
	settings_root.visible = true
	chk_sfx.button_pressed = sfx_on
	chk_music.button_pressed = music_on
	chk_haptic.button_pressed = haptic_on
	queue_redraw()

func _show_howto() -> void:
	screen = Screen.HOWTO
	menu_root.visible = false
	settings_root.visible = false
	howto_root.visible = true
	queue_redraw()

func _start_play() -> void:
	screen = Screen.PLAY
	menu_root.visible = false
	settings_root.visible = false
	howto_root.visible = false
	hud_root.visible = true
	pad_root.visible = true
	pause_btn.visible = true
	overlay.visible = false
	_reset_game()
	_play_music(true)

func _show_game_over() -> void:
	screen = Screen.GAME_OVER
	pad_root.visible = false
	pause_btn.visible = false
	overlay_title.text = "GAME OVER"
	overlay_sub.text = "Score %d   •   Best %d\nTap to play again" % [score, high_score]
	overlay.visible = true
	_sfx("gameover")
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
	score = 0
	level = 1
	lines = 0
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
		if score > high_score:
			high_score = score
			_save_high_score(high_score)
		_refresh_labels()
		_show_game_over()

func _next_from_bag() -> int:
	if bag.is_empty():
		bag = [0, 1, 2, 3, 4, 5, 6]
		bag.shuffle()
	return bag.pop_back()

# ---------------------------------------------------------------------------
# Collision helpers
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# Actions
# ---------------------------------------------------------------------------
func _try_move(delta: Vector2i) -> bool:
	if screen != Screen.PLAY or paused or clearing:
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
	if screen != Screen.PLAY or paused or clearing:
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
	if screen != Screen.PLAY or paused or clearing:
		return
	var dropped := 0
	while _try_move(Vector2i(0, 1)):
		dropped += 1
	score += dropped * 2
	_sfx("hard")
	_lock_piece()

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
	# Flash first, then collapse after the animation finishes.
	clear_rows = full_rows
	pending_clear_count = full_rows.size()
	clear_flash = 0.32
	clearing = true
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
	# Remove from bottom to top so indices stay valid.
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
	_spawn_piece()
	_refresh_labels()
	queue_redraw()

func _show_toast(text: String, dur: float = 0.9) -> void:
	toast_text = text
	toast_timer = dur

func _hold_piece() -> void:
	if screen != Screen.PLAY or paused or clearing or hold_used:
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
			if score > high_score:
				high_score = score
				_save_high_score(high_score)
			_refresh_labels()
			_show_game_over()
			return
	hold_used = true
	queue_redraw()

func _update_fall_interval() -> void:
	fall_interval = max(0.05, pow(0.82, level - 1))

# ---------------------------------------------------------------------------
# Loop
# ---------------------------------------------------------------------------
func _process(delta: float) -> void:
	title_pulse += delta
	if toast_timer > 0.0:
		toast_timer = max(0.0, toast_timer - delta)
		queue_redraw()
	if clear_flash > 0.0:
		clear_flash = max(0.0, clear_flash - delta)
		queue_redraw()
		if clearing and clear_flash <= 0.0:
			_finish_clear()
	if screen == Screen.MENU or screen == Screen.SETTINGS or screen == Screen.HOWTO:
		for b in menu_blocks:
			b["phase"] = float(b["phase"]) + delta
			var p: Vector2 = b["pos"]
			p.y = fposmod(p.y + float(b["speed"]) * delta * 0.01, 1.0)
			b["pos"] = p
		queue_redraw()
		return
	if screen != Screen.PLAY or paused or clearing:
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
	if screen == Screen.MENU and e.pressed and (e.keycode == KEY_ENTER or e.keycode == KEY_SPACE):
		_sfx("ui")
		_start_play()
		return
	if screen == Screen.GAME_OVER and e.pressed and (e.keycode == KEY_ENTER or e.keycode == KEY_R or e.keycode == KEY_SPACE):
		_start_play()
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
		if screen != Screen.PLAY or paused:
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
			_start_play()
			return
		if not touching:
			return
		touching = false
		if not touch_moved and e.position.distance_to(touch_start) < TAP_MAX_DIST:
			if not paused:
				_rotate(1)
		soft_held = false

func _handle_drag(e: InputEventScreenDrag) -> void:
	if not touching or screen != Screen.PLAY or paused:
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

# ---------------------------------------------------------------------------
# Buttons
# ---------------------------------------------------------------------------
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
	if screen != Screen.PLAY:
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

func _on_play_pressed() -> void:
	_sfx("ui")
	_start_play()

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

func _on_sfx_toggled(on: bool) -> void:
	sfx_on = on
	_save_settings()

func _on_music_toggled(on: bool) -> void:
	music_on = on
	_apply_music_setting()
	_save_settings()

func _on_haptic_toggled(on: bool) -> void:
	haptic_on = on
	_save_settings()

# ---------------------------------------------------------------------------
# Audio / haptics
# ---------------------------------------------------------------------------
func _setup_audio() -> void:
	var names := ["move", "rotate", "soft", "lock", "hard", "clear", "tetris", "gameover", "ui"]
	for n in names:
		var p := AudioStreamPlayer.new()
		p.name = "Sfx_" + n
		p.bus = "Master"
		var path := "res://assets/audio/%s.wav" % n
		if ResourceLoader.exists(path):
			p.stream = load(path)
		add_child(p)
		sfx_players[n] = p
	music_player = AudioStreamPlayer.new()
	music_player.name = "Music"
	music_player.bus = "Master"
	music_player.volume_db = -10.0
	var mpath := "res://assets/audio/music.wav"
	if ResourceLoader.exists(mpath):
		var stream = load(mpath)
		if stream is AudioStreamWAV:
			var wav := stream as AudioStreamWAV
			wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
			wav.loop_begin = 0
			var bytes_per_sample := 2 if wav.format == AudioStreamWAV.FORMAT_16_BITS else 1
			var channels := 2 if wav.stereo else 1
			wav.loop_end = int(wav.data.size() / float(bytes_per_sample * channels))
			music_player.stream = wav
		else:
			music_player.stream = stream
	add_child(music_player)

func _sfx(name: String) -> void:
	if not sfx_on:
		return
	if sfx_players.has(name) and sfx_players[name].stream:
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
	draw_rect(Rect2(Vector2.ZERO, size), BG_COLOR, true)
	_draw_ambient(size)

	if screen == Screen.MENU or screen == Screen.SETTINGS or screen == Screen.HOWTO:
		_draw_menu_blocks(size)
		return

	var board_w := cell * COLS
	var board_h := cell * ROWS
	draw_rect(Rect2(board_origin - Vector2(6, 6), Vector2(board_w + 12, board_h + 12)), PANEL_COLOR, true)
	# Soft board frame accent.
	draw_rect(Rect2(board_origin - Vector2(6, 6), Vector2(board_w + 12, board_h + 12)), Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.18), false, 2.0)

	for x in range(COLS + 1):
		draw_line(board_origin + Vector2(x * cell, 0), board_origin + Vector2(x * cell, board_h), GRID_LINE, 1.0)
	for y in range(ROWS + 1):
		draw_line(board_origin + Vector2(0, y * cell), board_origin + Vector2(board_w, y * cell), GRID_LINE, 1.0)

	for y in ROWS:
		for x in COLS:
			var v: int = grid[y][x]
			if v != -1:
				_draw_cell(Vector2i(x, y), COLORS[v], 1.0)

	if clear_flash > 0.0:
		var a := clear_flash / 0.32
		draw_rect(Rect2(board_origin, Vector2(board_w, board_h)), Color(1, 1, 1, 0.22 * a), true)
		for ry in clear_rows:
			var yy := clampi(int(ry), 0, ROWS - 1)
			var r := Rect2(board_origin + Vector2(0, yy * cell), Vector2(board_w, cell))
			draw_rect(r, Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.55 * a), true)

	if screen == Screen.PLAY and not paused and not clearing:
		var gp := _ghost_pos()
		for c in _cells(cur_type, cur_rot, gp):
			if c.y >= 0:
				_draw_cell(c, COLORS[cur_type], GHOST_ALPHA)
		for c in _cells(cur_type, cur_rot, cur_pos):
			if c.y >= 0:
				_draw_cell(c, COLORS[cur_type], 1.0)

	_draw_side_previews()
	_draw_toast(size)

func _draw_toast(size: Vector2) -> void:
	if toast_timer <= 0.0 or toast_text.is_empty():
		return
	var a := clampf(toast_timer / 0.35, 0.0, 1.0)
	var font := ThemeDB.fallback_font
	var font_size := 28
	var tw := font.get_string_size(toast_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var pos := Vector2((size.x - tw) * 0.5, board_origin.y + cell * ROWS * 0.35)
	draw_string(font, pos + Vector2(2, 2), toast_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0, 0, 0, 0.45 * a))
	draw_string(font, pos, toast_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(1, 1, 1, a))

func _draw_ambient(size: Vector2) -> void:
	# Soft vignette / title glow for menu screens.
	var pulse := 0.5 + 0.5 * sin(title_pulse * 2.0)
	var glow := Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.05 + 0.04 * pulse)
	draw_circle(Vector2(size.x * 0.5, size.y * 0.22), 180.0 + 20.0 * pulse, glow)
	# Bottom ambient wash.
	draw_rect(Rect2(0, size.y * 0.72, size.x, size.y * 0.28), Color(0.08, 0.12, 0.22, 0.35), true)

func _draw_menu_blocks(size: Vector2) -> void:
	for b in menu_blocks:
		var p: Vector2 = Vector2(float(b["pos"].x) * size.x, float(b["pos"].y) * size.y)
		p.x += sin(float(b["phase"])) * 18.0
		var s: float = float(b["size"])
		var col: Color = COLORS[int(b["type"])]
		col.a = 0.18
		draw_rect(Rect2(p, Vector2(s, s)), col, true)
		var hi := col.lightened(0.3)
		hi.a = 0.12
		draw_rect(Rect2(p, Vector2(s, s * 0.3)), hi, true)

func _draw_cell(c: Vector2i, color: Color, alpha: float) -> void:
	var p := board_origin + Vector2(c.x * cell, c.y * cell)
	var inner := Rect2(p + Vector2(1, 1), Vector2(cell - 2, cell - 2))
	var col := color
	col.a = alpha
	draw_rect(inner, col, true)
	if alpha >= 1.0:
		var hi := color.lightened(0.25)
		hi.a = 0.5
		draw_rect(Rect2(p + Vector2(1, 1), Vector2(cell - 2, (cell - 2) * 0.28)), hi, true)

func _draw_side_previews() -> void:
	var box_cell := cell * 0.55
	var box_w := box_cell * 4
	# NEXT — top right
	var next_origin := Vector2(get_size().x - box_w - 16, 78)
	_draw_mini_box(next_origin, box_w, box_cell, next_type, "NEXT")
	# HOLD — below level/lines
	var hold_origin := Vector2(16, 98)
	_draw_mini_box(hold_origin, box_w, box_cell, hold_type, "HOLD")

func _draw_mini_box(origin: Vector2, box_w: float, box_cell: float, piece_type: int, caption: String) -> void:
	draw_rect(Rect2(origin - Vector2(6, 22), Vector2(box_w + 12, box_w + 34)), PANEL_COLOR, true)
	draw_string(ThemeDB.fallback_font, origin + Vector2(4, -6), caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.75, 0.8, 0.9))
	if piece_type < 0:
		return
	for c in PIECES[piece_type][0]:
		var p := origin + Vector2(c.x * box_cell, c.y * box_cell)
		draw_rect(Rect2(p + Vector2(1, 1), Vector2(box_cell - 2, box_cell - 2)), COLORS[piece_type], true)

# ---------------------------------------------------------------------------
# Layout / UI
# ---------------------------------------------------------------------------
func _recalc_layout() -> void:
	var size := get_size()
	hud_height = clamp(size.y * 0.12, 110.0, 180.0)
	pad_height = clamp(size.y * 0.22, 180.0, 320.0)
	var avail_h := size.y - hud_height - pad_height
	var avail_w := size.x * 0.92
	cell = floor(min(avail_w / COLS, avail_h / ROWS))
	cell = max(cell, 12.0)
	var board_w := cell * COLS
	var board_h := cell * ROWS
	board_origin = Vector2((size.x - board_w) * 0.5, hud_height + (avail_h - board_h) * 0.5)
	if pause_btn:
		pause_btn.position = Vector2(size.x - 72, 8)
	queue_redraw()

func _build_ui() -> void:
	_build_menu()
	_build_settings()
	_build_howto()
	_build_hud()
	_build_controls()
	_build_overlay()

func _build_menu() -> void:
	menu_root = Control.new()
	menu_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(menu_root)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left = -180
	box.offset_right = 180
	box.offset_top = -280
	box.offset_bottom = 280
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	menu_root.add_child(box)

	var title := _make_label("AOIPULSE", 56, ACCENT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	var by := _make_label("by Aoitex", 18, Color(0.7, 0.75, 0.85))
	by.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(by)

	menu_best_label = _make_label("Best score  0", 22, Color.WHITE)
	menu_best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(menu_best_label)

	var play_btn := _make_menu_button("PLAY", true)
	play_btn.pressed.connect(_on_play_pressed)
	box.add_child(play_btn)

	var set_btn := _make_menu_button("SETTINGS", false)
	set_btn.pressed.connect(_on_settings_pressed)
	box.add_child(set_btn)

	var howto_btn := _make_menu_button("HOW TO PLAY", false)
	howto_btn.pressed.connect(_on_howto_pressed)
	box.add_child(howto_btn)

	var tip := _make_label("Swipe to move · Tap to rotate\nHold button or C to hold piece", 16, Color(0.65, 0.7, 0.8))
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(tip)

func _build_settings() -> void:
	settings_root = Control.new()
	settings_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	settings_root.visible = false
	add_child(settings_root)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left = -200
	box.offset_right = 200
	box.offset_top = -240
	box.offset_bottom = 240
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	settings_root.add_child(box)

	var title := _make_label("SETTINGS", 40, ACCENT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	chk_sfx = CheckButton.new()
	chk_sfx.text = "Sound effects"
	chk_sfx.add_theme_font_size_override("font_size", 22)
	chk_sfx.toggled.connect(_on_sfx_toggled)
	box.add_child(chk_sfx)

	chk_music = CheckButton.new()
	chk_music.text = "Music"
	chk_music.add_theme_font_size_override("font_size", 22)
	chk_music.toggled.connect(_on_music_toggled)
	box.add_child(chk_music)

	chk_haptic = CheckButton.new()
	chk_haptic.text = "Vibration"
	chk_haptic.add_theme_font_size_override("font_size", 22)
	chk_haptic.toggled.connect(_on_haptic_toggled)
	box.add_child(chk_haptic)

	var back := _make_menu_button("BACK")
	back.pressed.connect(_on_back_menu)
	box.add_child(back)

func _build_howto() -> void:
	howto_root = Control.new()
	howto_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	howto_root.visible = false
	add_child(howto_root)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left = -260
	box.offset_right = 260
	box.offset_top = -320
	box.offset_bottom = 320
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 12)
	howto_root.add_child(box)

	var title := _make_label("HOW TO PLAY", 36, ACCENT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	var body := _make_label(
		"Goal\nClear full horizontal lines before the stack reaches the top.\n\nTouch\n• Swipe left/right — move\n• Swipe down — soft drop\n• Tap board — rotate\n• Buttons: ◀ H ⟳ ▼ ⤓ ▶\n\nTips\n• Ghost piece shows where you'll land\n• H / C holds a piece for later\n• Clear lines back-to-back for combos\n• Hard drop (⤓ / Space) for max points",
		18,
		Color(0.85, 0.88, 0.95)
	)
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(body)

	var back := _make_menu_button("BACK")
	back.pressed.connect(_on_back_menu)
	box.add_child(back)

func _build_hud() -> void:
	hud_root = Control.new()
	hud_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_root.visible = false
	add_child(hud_root)

	var hud := VBoxContainer.new()
	hud.position = Vector2(16, 8)
	hud.add_theme_constant_override("separation", 0)
	hud_root.add_child(hud)

	score_label = _make_label("Score 0", 30, Color.WHITE)
	high_label = _make_label("Best 0", 18, Color(0.7, 0.75, 0.85))
	hud.add_child(score_label)
	hud.add_child(high_label)

	var stat := HBoxContainer.new()
	stat.position = Vector2(16, 72)
	stat.add_theme_constant_override("separation", 18)
	hud_root.add_child(stat)
	level_label = _make_label("Lv 1", 18, Color(0.8, 0.85, 0.95))
	lines_label = _make_label("Lines 0", 18, Color(0.8, 0.85, 0.95))
	stat.add_child(level_label)
	stat.add_child(lines_label)

	pause_btn = Button.new()
	pause_btn.text = "II"
	pause_btn.custom_minimum_size = Vector2(56, 56)
	pause_btn.focus_mode = Control.FOCUS_NONE
	pause_btn.position = Vector2(get_size().x - 72, 8)
	pause_btn.pressed.connect(_toggle_pause)
	pause_btn.visible = false
	_apply_button_style(pause_btn, false)
	add_child(pause_btn)

func _build_controls() -> void:
	pad_root = HBoxContainer.new()
	pad_root.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	pad_root.offset_left = 12
	pad_root.offset_right = -12
	pad_root.offset_top = -150
	pad_root.offset_bottom = -24
	pad_root.alignment = BoxContainer.ALIGNMENT_CENTER
	pad_root.add_theme_constant_override("separation", 12)
	pad_root.visible = false
	add_child(pad_root)

	var left := _make_pad_button("◀")
	left.button_down.connect(_on_left_down)
	left.button_up.connect(_on_left_up)
	pad_root.add_child(left)

	var hold := _make_pad_button("H")
	hold.pressed.connect(_hold_piece)
	pad_root.add_child(hold)

	var rot := _make_pad_button("⟳")
	rot.pressed.connect(_on_rotate_btn)
	pad_root.add_child(rot)

	var down := _make_pad_button("▼")
	down.button_down.connect(_on_soft_down)
	down.button_up.connect(_on_soft_up)
	pad_root.add_child(down)

	var drop := _make_pad_button("⤓")
	drop.pressed.connect(_on_drop_btn)
	pad_root.add_child(drop)

	var right := _make_pad_button("▶")
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

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left = -200
	box.offset_right = 200
	box.offset_top = -80
	box.offset_bottom = 80
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	overlay.add_child(box)

	overlay_title = _make_label("PAUSED", 48, Color.WHITE)
	overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(overlay_title)

	overlay_sub = _make_label("", 22, Color(0.85, 0.88, 0.95))
	overlay_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(overlay_sub)

	var menu_from_pause := _make_menu_button("MAIN MENU")
	menu_from_pause.custom_minimum_size = Vector2(220, 52)
	menu_from_pause.pressed.connect(_on_pause_to_menu)
	box.add_child(menu_from_pause)

func _on_pause_to_menu() -> void:
	if screen == Screen.PLAY and paused:
		_sfx("ui")
		_show_menu()
	elif screen == Screen.GAME_OVER:
		_sfx("ui")
		_show_menu()

func _make_label(text: String, font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	return l

func _make_pad_button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(52, 88)
	b.add_theme_font_size_override("font_size", 28)
	b.focus_mode = Control.FOCUS_NONE
	_apply_button_style(b, false)
	return b

func _make_menu_button(text: String, primary: bool = true) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(260, 64)
	b.add_theme_font_size_override("font_size", 26)
	b.focus_mode = Control.FOCUS_NONE
	_apply_button_style(b, primary)
	return b

func _apply_button_style(b: Button, primary: bool) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.14, 0.18, 0.28, 0.95) if not primary else Color(0.12, 0.42, 0.52, 0.95)
	normal.set_corner_radius_all(14)
	normal.content_margin_left = 10
	normal.content_margin_right = 10
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
	normal.border_width_bottom = 3
	normal.border_color = Color(0.05, 0.07, 0.12, 0.8)
	var hover := normal.duplicate()
	hover.bg_color = normal.bg_color.lightened(0.12)
	var pressed := normal.duplicate()
	pressed.bg_color = normal.bg_color.darkened(0.12)
	pressed.border_width_bottom = 1
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_stylebox_override("focus", hover)
	b.add_theme_color_override("font_color", Color(0.92, 0.95, 1.0))
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", Color(0.85, 0.9, 1.0))

func _refresh_labels() -> void:
	if score_label:
		score_label.text = "Score %d" % score
	if high_label:
		high_label.text = "Best %d" % high_score
	if level_label:
		level_label.text = "Lv %d" % level
	if lines_label:
		lines_label.text = "Lines %d" % lines

# ---------------------------------------------------------------------------
# Persistence
# ---------------------------------------------------------------------------
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

func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "sfx", sfx_on)
	cfg.set_value("audio", "music", music_on)
	cfg.set_value("game", "haptic", haptic_on)
	cfg.save(SETTINGS_PATH)
