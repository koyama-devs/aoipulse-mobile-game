extends Control
## AOIPulse — modes, juice, online rooms & leaderboards.

const COLS := 10
const ROWS := 20
## Max pad slots (includes adventure item + online attack).
const PAD_COUNT := 8
const ATTACK_TYPES := ["garbage", "banana", "bomb"]
const ATTACK_LABELS := {"garbage": "ゴミ", "banana": "バナナ", "bomb": "ボム"}
const ATTACK_COOLDOWN := 6.0
## Menu pages keep their content this narrow and centred, so buttons do not
## stretch edge to edge behind a couple of short kanji.
const CONTENT_MAX_W := 380.0
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
	# Aoitex house colours: deep navy, bright teal, punchy coral.
	{"name": "Aoitex", "jp": "アオイテックス",
	 "bg": Color(0.02, 0.045, 0.09), "bg2": Color(0.07, 0.13, 0.24), "panel": Color(0.06, 0.11, 0.20),
	 "accent": Color(0.28, 0.86, 0.96), "accent2": Color(1.0, 0.48, 0.32),
	 "colors": [Color(0.22, 0.88, 0.96), Color(1.0, 0.82, 0.28), Color(1.0, 0.42, 0.38), Color(0.36, 0.90, 0.62), Color(0.72, 0.48, 0.96), Color(0.34, 0.58, 0.98), Color(1.0, 0.58, 0.22)]},
	{"name": "Neon", "jp": "ネオン",
	 "bg": Color(0.04, 0.05, 0.09), "bg2": Color(0.07, 0.10, 0.18), "panel": Color(0.09, 0.12, 0.20),
	 "accent": Color(0.25, 0.88, 0.95), "accent2": Color(0.35, 0.55, 1.0),
	 "colors": [Color(0.18, 0.88, 0.95), Color(0.98, 0.82, 0.22), Color(0.72, 0.40, 0.95), Color(0.35, 0.85, 0.48), Color(0.95, 0.30, 0.42), Color(0.30, 0.55, 0.95), Color(0.98, 0.60, 0.22)]},
	{"name": "Sunset", "jp": "サンセット",
	 "bg": Color(0.10, 0.04, 0.06), "bg2": Color(0.18, 0.08, 0.08), "panel": Color(0.20, 0.09, 0.10),
	 "accent": Color(1.0, 0.58, 0.28), "accent2": Color(0.95, 0.30, 0.45),
	 "colors": [Color(1.0, 0.48, 0.38), Color(1.0, 0.78, 0.28), Color(0.98, 0.38, 0.58), Color(0.98, 0.62, 0.22), Color(0.88, 0.22, 0.32), Color(0.72, 0.38, 0.58), Color(1.0, 0.52, 0.18)]},
	{"name": "Forest", "jp": "フォレスト",
	 "bg": Color(0.03, 0.07, 0.05), "bg2": Color(0.06, 0.14, 0.09), "panel": Color(0.08, 0.15, 0.11),
	 "accent": Color(0.42, 0.92, 0.58), "accent2": Color(0.25, 0.70, 0.75),
	 "colors": [Color(0.38, 0.88, 0.72), Color(0.88, 0.88, 0.38), Color(0.48, 0.75, 0.42), Color(0.32, 0.80, 0.45), Color(0.75, 0.42, 0.38), Color(0.42, 0.65, 0.88), Color(0.88, 0.68, 0.32)]},
]

const FONT_PATH := "res://assets/fonts/NotoSansJP-Game.otf"

const LINE_SCORES := [0, 100, 300, 500, 800]
const LOCK_DELAY := 0.5
const DAS := 0.16
const ARR := 0.045
const SWIPE_STEP := 34.0
const SOFT_STEP := 34.0
const TAP_MAX_DIST := 18.0
const SPRINT_LINES := 40
const ULTRA_SECONDS := 120.0
const STAGE_LINES := 5
const META_NONE := 0
const META_BOMB := 1
const META_CHEST := 2
const META_GARBAGE := 3
const ITEM_NONE := ""
const ITEM_HAMMER := "hammer"
const ITEM_LINE := "line"
const ITEM_SLOW := "slow"

enum Screen { MENU, MODE, SETTINGS, HOWTO, ONLINE, ROOM, LEADERBOARD, PLAY, GAME_OVER }
enum Mode { CLASSIC, SPRINT, ULTRA, DAILY, ADVENTURE, NO_ROTATE }

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
var high_norotate := 0
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
# Preview boxes are laid out in _recalc_layout so they never collide with HUD text.
var preview_cell := 14.0
var preview_w := 56.0
var hold_origin := Vector2.ZERO
var next_origin := Vector2.ZERO
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
var toast_punch := 0.0
var menu_blocks: Array = []
var shake_time := 0.0
var shake_mag := 0.0
var particles: Array = []
var panel_fade := 1.0
var score_pop := 0.0
var last_shown_score := 0
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
var last_online_create_mode := ""
var online_reregister_tries := 0
var room_status := "lobby"
var forfeit_armed := false
var last_started_seed := 0

# Adventure mode state
var meta: Array = []
var bomb_timer: Array = []
var stage := 1
var stage_line_count := 0
var pieces_placed := 0
var boss_piece_limit := 0
var held_item := ITEM_NONE
var slow_left := 0
var shield_charges := 0
var garbage_warn := 0
var bombs_defused := 0
var chests_opened := 0
var highest_stage := 1
var stage_banner := ""
var stage_banner_timer := 0.0
var event_warn := ""
var event_warn_timer := 0.0
var attack_charges := 0
var attack_cooldown := 0.0
var attack_type_idx := 0
var last_event_id := 0
var pending_bananas := 0
var play_poll := 0.0

var sfx_on := true
var music_on := true
var haptic_on := true

var hud_root: Control
var hud_col: VBoxContainer
var score_label: Label
var high_label: Label
var level_label: Label
var lines_label: Label
var timer_label: Label
var adventure_label: Label
var pause_btn: Button
var item_btn: Button
var attack_btn: Button
var rot_btn: Button
var pad_root: Control
var pad_buttons: Array[Button] = []
var screen_margins: Array[MarginContainer] = []
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
var brand_cool: Label
var brand_warm: Label
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
var save_status_label: Label

var sfx_players: Dictionary = {}
var music_player: AudioStreamPlayer
var online: Node
var ui_font: Font

func _theme() -> Dictionary:
	return THEMES[clampi(theme_idx, 0, THEMES.size() - 1)]

func _mode_label(m: Mode) -> String:
	match m:
		Mode.CLASSIC:
			return "クラシック"
		Mode.SPRINT:
			return "スプリント"
		Mode.ULTRA:
			return "ウルトラ"
		Mode.ADVENTURE:
			return "アドベンチャー"
		Mode.NO_ROTATE:
			return "回転なし"
		_:
			return "デイリー"

func _is_no_rotate() -> bool:
	return mode == Mode.NO_ROTATE

func _current_high_score() -> int:
	return high_norotate if _is_no_rotate() else high_score

func _is_adventure() -> bool:
	return mode == Mode.ADVENTURE

func _pvp_attacks_enabled() -> bool:
	return online_match and mode == Mode.ADVENTURE

func _current_attack_type() -> String:
	return ATTACK_TYPES[clampi(attack_type_idx, 0, ATTACK_TYPES.size() - 1)]

func _attack_type_label(t: String) -> String:
	return String(ATTACK_LABELS.get(t, t))

func _gain_attack_charge(reason: String = "") -> void:
	if not _pvp_attacks_enabled():
		return
	if attack_charges >= 3:
		return
	attack_charges += 1
	_show_toast("攻撃チャージ +1" + (("（%s）" % reason) if reason != "" else ""), 0.85)
	_refresh_attack_btn()
	_refresh_labels()

func _cycle_attack_type() -> void:
	attack_type_idx = (attack_type_idx + 1) % ATTACK_TYPES.size()
	_show_toast("攻撃：%s" % _attack_type_label(_current_attack_type()), 0.55)
	_refresh_attack_btn()

func _on_attack_btn() -> void:
	if not _pvp_attacks_enabled() or screen != Screen.PLAY or paused or forfeit_armed or countdown > 0.0:
		return
	if attack_charges <= 0:
		_cycle_attack_type()
		_show_toast("チャージがありません（タップで種類切替）", 0.7)
		return
	if attack_cooldown > 0.0:
		_show_toast("クールダウン中…", 0.55)
		return
	if online == null or online.player_id == "":
		return
	var t := _current_attack_type()
	attack_charges = maxi(0, attack_charges - 1)
	attack_cooldown = ATTACK_COOLDOWN
	_refresh_attack_btn()
	_refresh_labels()
	_show_toast("%sを送信！" % _attack_type_label(t), 0.7)
	_sfx("ui")
	online.send_attack(t)

func _ingest_attack_events(data: Dictionary) -> void:
	var events = data.get("events", [])
	if typeof(events) != TYPE_ARRAY:
		return
	for e in events:
		if typeof(e) != TYPE_DICTIONARY:
			continue
		var eid := int(e.get("id", 0))
		if eid <= last_event_id:
			continue
		last_event_id = maxi(last_event_id, eid)
		var from_id := String(e.get("fromId", ""))
		if from_id == "" or (online and from_id == online.player_id):
			continue
		if screen != Screen.PLAY:
			continue
		_apply_incoming_attack(String(e.get("type", "")), String(e.get("fromName", "?")))

func _apply_incoming_attack(type: String, from_name: String) -> void:
	match type:
		"garbage":
			if shield_charges > 0:
				shield_charges -= 1
				_show_toast("%sのゴミを盾で防いだ！" % from_name, 1.0)
				_sfx("loot" if ResourceLoader.exists("res://assets/audio/loot.wav") else "ui")
			else:
				_add_garbage_row(1)
				_show_toast("%sからゴミ！" % from_name, 1.0)
				_sfx("warn" if ResourceLoader.exists("res://assets/audio/warn.wav") else "ui")
				_haptic(45)
		"banana":
			if clearing or countdown > 0.0 or paused:
				pending_bananas += 1
				_show_toast("%sからバナナ！（まもなく）" % from_name, 0.9)
			else:
				_apply_banana_effect()
				_show_toast("%sからバナナ！" % from_name, 1.0)
		"bomb":
			_plant_incoming_bomb()
			_show_toast("%sからボム設置！" % from_name, 1.0)
			_sfx("bomb" if ResourceLoader.exists("res://assets/audio/bomb.wav") else "warn")
			_haptic(40)
		_:
			return
	_refresh_labels()
	queue_redraw()

func _apply_banana_effect() -> void:
	# Randomize active piece rotation to a valid orientation.
	var start := cur_rot
	var order: Array = [0, 1, 2, 3]
	order.shuffle()
	for r in order:
		var rr := int(r)
		if rr == start:
			continue
		if _is_valid(cur_type, rr, cur_pos):
			cur_rot = rr
			_sfx("rotate")
			return
	# Kick left/right if pure rotate fails.
	for r in order:
		var rr := int(r)
		for dx in [0, -1, 1, -2, 2]:
			var np := cur_pos + Vector2i(dx, 0)
			if _is_valid(cur_type, rr, np):
				cur_rot = rr
				cur_pos = np
				_sfx("rotate")
				return

func _plant_incoming_bomb() -> void:
	var cells: Array = []
	for y in ROWS:
		for x in COLS:
			if grid[y][x] != -1 and int(meta[y][x]) == META_NONE:
				cells.append(Vector2i(x, y))
	if cells.is_empty():
		_add_garbage_row(1)
		# Plant on a garbage cell in the new bottom row if possible.
		var y := ROWS - 1
		for x in COLS:
			if grid[y][x] != -1:
				meta[y][x] = META_BOMB
				bomb_timer[y][x] = 5
				return
		return
	var pick: Vector2i = cells[rng.randi_range(0, cells.size() - 1)]
	meta[pick.y][pick.x] = META_BOMB
	bomb_timer[pick.y][pick.x] = 5

func _font() -> Font:
	return ui_font if ui_font != null else ThemeDB.fallback_font

func _colors() -> Array:
	return _theme()["colors"]

func _accent() -> Color:
	return _theme()["accent"]

func _accent2() -> Color:
	return _theme()["accent2"]

func _ready() -> void:
	if ResourceLoader.exists(FONT_PATH):
		ui_font = load(FONT_PATH)
	online = get_node_or_null("/root/Online")
	if online:
		online.request_ok.connect(_on_online_ok)
		online.request_fail.connect(_on_online_fail)
	rng.randomize()
	_load_settings()
	high_score = _load_high_score()
	high_norotate = _load_norotate_high()
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
			"pos": Vector2(rng.randf_range(0.06, 0.94), rng.randf_range(0.05, 0.95)),
			"type": rng.randi_range(0, 6),
			"rot": rng.randi_range(0, 3),
			"speed": rng.randf_range(5.0, 16.0),
			"phase": rng.randf_range(0.0, TAU),
			"size": rng.randf_range(14.0, 22.0),
			"drift": rng.randf_range(14.0, 36.0),
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

func _fade_in_panel() -> void:
	panel_fade = 0.0

func _show_menu() -> void:
	screen = Screen.MENU
	paused = false
	online_match = false
	_hide_all_panels()
	_fade_in_panel()
	menu_root.visible = true
	menu_best_label.text = "最高スコア  %d" % high_score
	var xp := 0
	var pname := "プレイヤー"
	if online:
		xp = online.player_xp
		pname = online.player_name
	theme_idx = mini(THEMES.size() - 1, int(xp / 500))
	menu_xp_label.text = "%s  ／  XP %d  ／  テーマ：%s" % [pname, xp, _theme()["jp"]]
	_restyle_buttons()
	_play_music(true)
	queue_redraw()

func _show_mode() -> void:
	screen = Screen.MODE
	_hide_all_panels()
	_fade_in_panel()
	mode_root.visible = true
	queue_redraw()

func _show_settings() -> void:
	screen = Screen.SETTINGS
	_hide_all_panels()
	_fade_in_panel()
	settings_root.visible = true
	chk_sfx.button_pressed = sfx_on
	chk_music.button_pressed = music_on
	chk_haptic.button_pressed = haptic_on
	if online:
		name_edit.text = online.ensure_display_name()
		server_edit.text = online.base_url
	queue_redraw()

func _show_howto() -> void:
	screen = Screen.HOWTO
	_hide_all_panels()
	_fade_in_panel()
	howto_root.visible = true
	queue_redraw()

func _show_online() -> void:
	screen = Screen.ONLINE
	_hide_all_panels()
	_fade_in_panel()
	online_root.visible = true
	online_reregister_tries = 0
	# Wake Render free tier + refresh player id (DB may have been wiped).
	status_msg = "サーバーに接続中…（初回は数十秒かかることがあります）"
	_refresh_status()
	if online:
		online.register_player(online.ensure_display_name())
	queue_redraw()

func _show_room() -> void:
	screen = Screen.ROOM
	paused = false
	forfeit_armed = false
	_hide_all_panels()
	_fade_in_panel()
	room_root.visible = true
	room_poll = 0.0
	_refresh_room_ui()
	queue_redraw()

func _show_leaderboard() -> void:
	screen = Screen.LEADERBOARD
	_hide_all_panels()
	_fade_in_panel()
	lb_root.visible = true
	lb_label.text = "読み込み中..."
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
			status_msg = "本日のお題を取得中..."
			if online.player_id == "":
				online.register_player(online.player_name)
			online.fetch_daily()
			return
		var day := Time.get_datetime_string_from_system(true).substr(0, 10)
		match_seed = _hash_seed(day)
	_begin_play()

func _begin_play() -> void:
	screen = Screen.PLAY
	paused = false
	forfeit_armed = false
	_hide_all_panels()
	hud_root.visible = true
	pad_root.visible = true
	pause_btn.visible = true
	if online_match:
		pause_btn.text = "×"
		pause_btn.set_meta("primary", false)
		_apply_button_style(pause_btn, false)
	else:
		pause_btn.text = "II"
	countdown = 3.0 if online_match else 0.0
	_reset_game()
	_refresh_item_btn()
	_refresh_attack_btn()
	if item_btn:
		item_btn.visible = _is_adventure()
	if attack_btn:
		attack_btn.visible = _pvp_attacks_enabled()
	_refresh_rotate_btn()
	_play_music(true)

func _show_game_over(victory: bool = false) -> void:
	screen = Screen.GAME_OVER
	pad_root.visible = false
	pause_btn.visible = false
	var title := "ゲームオーバー"
	if victory:
		title = "クリア！"
	elif mode == Mode.ULTRA:
		title = "タイムアップ"
	overlay_title.text = title
	var time_txt := _fmt_time(int(elapsed * 1000.0))
	var best := _current_high_score()
	overlay_sub.text = "スコア %d　／　ライン %d　／　タイム %s\n最高スコア %d\n\n画面をタップしてもどる" % [score, lines, time_txt, best]
	if mode == Mode.ADVENTURE:
		overlay_sub.text = "スコア %d　／　到達ステージ %d\nボム解除 %d　／　宝箱 %d\n最高スコア %d\n\n画面をタップしてもどる" % [score, highest_stage, bombs_defused, chests_opened, high_score]
	elif _is_no_rotate():
		overlay_sub.text = "回転なし　／　スコア %d　／　ライン %d\n最高スコア %d\n\n画面をタップしてもどる" % [score, lines, best]
	if online_match:
		overlay_sub.text += "\n結果を送信中..."
	elif mode == Mode.DAILY and online and online.player_id != "":
		overlay_sub.text += "\nデイリースコアを送信中..."
		online.submit_daily(score, lines, int(elapsed * 1000.0), match_seed)
	overlay.visible = true
	_sfx("gameover")
	_commit_run_high_score()
	if online_match and online:
		var st := highest_stage if mode == Mode.ADVENTURE else 1
		online.finish_room(score, lines, int(elapsed * 1000.0), st)
	_refresh_labels()
	queue_redraw()

# ---------------------------------------------------------------------------
# Game lifecycle
# ---------------------------------------------------------------------------
func _reset_game() -> void:
	grid.clear()
	meta.clear()
	bomb_timer.clear()
	for y in ROWS:
		var row: Array = []
		var mrow: Array = []
		var brow: Array = []
		for x in COLS:
			row.append(-1)
			mrow.append(META_NONE)
			brow.append(0)
		grid.append(row)
		meta.append(mrow)
		bomb_timer.append(brow)
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
	last_shown_score = 0
	score_pop = 0.0
	left_held = false
	right_held = false
	soft_held = false
	stage = 1
	stage_line_count = 0
	pieces_placed = 0
	boss_piece_limit = 0
	held_item = ITEM_NONE
	slow_left = 0
	shield_charges = 0
	garbage_warn = 0
	bombs_defused = 0
	chests_opened = 0
	highest_stage = 1
	stage_banner = ""
	stage_banner_timer = 0.0
	event_warn = ""
	event_warn_timer = 0.0
	attack_charges = 0
	attack_cooldown = 0.0
	attack_type_idx = 0
	last_event_id = 0
	pending_bananas = 0
	play_poll = 0.0
	_update_fall_interval()
	next_type = _next_from_bag()
	_spawn_piece()
	if _is_adventure():
		_begin_stage(1, true)
	_refresh_labels()
	_refresh_item_btn()
	_refresh_attack_btn()
	pause_btn.text = "II"
	pause_btn.modulate = Color.WHITE
	_apply_button_style(pause_btn, false)
	queue_redraw()

func _empty_meta_row() -> Array:
	var empty: Array = []
	for x in COLS:
		empty.append(META_NONE)
	return empty

func _empty_bomb_row() -> Array:
	var empty: Array = []
	for x in COLS:
		empty.append(0)
	return empty

func _begin_stage(s: int, intro: bool = false) -> void:
	stage = s
	highest_stage = maxi(highest_stage, stage)
	stage_line_count = 0
	pieces_placed = 0
	boss_piece_limit = 0
	var is_boss := stage % 5 == 0
	if is_boss:
		boss_piece_limit = maxi(12, 24 - int(stage / 5) * 2)
	else:
		boss_piece_limit = 0
	if stage >= 4 and garbage_warn == 0:
		garbage_warn = _adventure_garbage_interval()
	var tip := ""
	match stage:
		1:
			tip = "まずはラインを消そう！"
		2:
			tip = "ボム付きブロックが出現！"
		3:
			tip = "宝箱からアイテムを入手！"
		4:
			tip = "おじゃまラインに注意！"
		_:
			tip = "難易度アップ！" if not is_boss else "ボス戦：限られた手数でクリア"
	stage_banner = "ステージ %d\n%s" % [stage, tip]
	stage_banner_timer = 2.2 if intro else 1.8
	_sfx("stage" if ResourceLoader.exists("res://assets/audio/stage.wav") else "ui")
	_refresh_labels()

func _adventure_bomb_chance() -> float:
	if stage < 2:
		return 0.0
	return minf(0.42, 0.14 + (stage - 2) * 0.04)

func _adventure_chest_chance() -> float:
	if stage < 3:
		return 0.0
	return minf(0.28, 0.10 + (stage - 3) * 0.03)

func _adventure_bomb_fuse() -> int:
	return maxi(3, 8 - int((stage - 2) / 2))

func _adventure_garbage_interval() -> int:
	if stage < 4:
		return 0
	return maxi(6, 14 - stage)

func _spawn_piece() -> void:
	cur_type = next_type
	next_type = _next_from_bag()
	cur_rot = 0
	cur_pos = Vector2i(3, 0)
	lock_timer = 0.0
	hold_used = false
	if not _is_valid(cur_type, cur_rot, cur_pos):
		_end_run(false)
		return
	if pending_bananas > 0:
		pending_bananas -= 1
		_apply_banana_effect()

func _end_run(victory: bool) -> void:
	if screen == Screen.GAME_OVER:
		return
	_commit_run_high_score()
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
	if _is_no_rotate():
		_show_toast("このモードでは回転できません", 0.7)
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
	var locked_cells: Array = []
	for c in _cells(cur_type, cur_rot, cur_pos):
		if c.y >= 0 and c.y < ROWS and c.x >= 0 and c.x < COLS:
			grid[c.y][c.x] = cur_type
			meta[c.y][c.x] = META_NONE
			bomb_timer[c.y][c.x] = 0
			locked_cells.append(c)
	_sfx("lock")
	pieces_placed += 1
	if _is_adventure():
		_adventure_on_lock(locked_cells)
	var full_rows := _find_full_rows()
	if full_rows.is_empty():
		combo = 0
		if _is_adventure():
			_adventure_after_lock_no_clear()
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

func _adventure_on_lock(locked_cells: Array) -> void:
	if locked_cells.is_empty():
		return
	# Attach bomb / chest to one random locked cell.
	var roll_bomb := rng.randf() < _adventure_bomb_chance()
	var roll_chest := (not roll_bomb) and rng.randf() < _adventure_chest_chance()
	if roll_bomb or roll_chest:
		var pick: Vector2i = locked_cells[rng.randi_range(0, locked_cells.size() - 1)]
		if roll_bomb:
			meta[pick.y][pick.x] = META_BOMB
			bomb_timer[pick.y][pick.x] = _adventure_bomb_fuse()
			_show_toast("ボム出現！　カウント %d" % bomb_timer[pick.y][pick.x], 0.9)
			_sfx("warn" if ResourceLoader.exists("res://assets/audio/warn.wav") else "ui")
		else:
			meta[pick.y][pick.x] = META_CHEST
			_show_toast("宝箱を埋めた！", 0.8)
	# Tick existing bombs (not including the one just placed this lock — fuse starts next lock).
	_tick_bombs(locked_cells)

func _tick_bombs(just_placed: Array) -> void:
	var placed := {}
	for c in just_placed:
		placed["%d,%d" % [c.x, c.y]] = true
	var explode: Array = []
	for y in ROWS:
		for x in COLS:
			if int(meta[y][x]) != META_BOMB:
				continue
			var key := "%d,%d" % [x, y]
			if placed.has(key):
				continue
			bomb_timer[y][x] = int(bomb_timer[y][x]) - 1
			if int(bomb_timer[y][x]) <= 0:
				explode.append(Vector2i(x, y))
	for p in explode:
		_explode_bomb(p)

func _explode_bomb(p: Vector2i) -> void:
	if p.y < 0 or p.y >= ROWS or p.x < 0 or p.x >= COLS:
		return
	meta[p.y][p.x] = META_NONE
	bomb_timer[p.y][p.x] = 0
	_sfx("bomb" if ResourceLoader.exists("res://assets/audio/bomb.wav") else "gameover")
	_haptic(70)
	_shake(0.22, 8.0)
	_show_toast("ボム爆発！　おじゃま発生", 1.0)
	_add_garbage_row(1)

func _add_garbage_row(count: int = 1) -> void:
	for _i in count:
		# Top-out if top row occupied.
		for x in COLS:
			if grid[0][x] != -1:
				_end_run(false)
				return
		grid.remove_at(0)
		meta.remove_at(0)
		bomb_timer.remove_at(0)
		var grow: Array = []
		var mrow: Array = []
		var brow: Array = []
		var hole := rng.randi_range(0, COLS - 1)
		for x in COLS:
			if x == hole:
				grow.append(-1)
				mrow.append(META_NONE)
			else:
				grow.append(0)
				mrow.append(META_GARBAGE)
			brow.append(0)
		grid.append(grow)
		meta.append(mrow)
		bomb_timer.append(brow)

func _adventure_after_lock_no_clear() -> void:
	_adventure_check_boss_fail()
	_adventure_tick_garbage_schedule()

func _adventure_check_boss_fail() -> void:
	if boss_piece_limit > 0 and pieces_placed >= boss_piece_limit and stage_line_count < STAGE_LINES:
		_show_toast("ボス戦失敗…", 1.0)
		_end_run(false)

func _adventure_tick_garbage_schedule() -> void:
	var interval := _adventure_garbage_interval()
	if interval <= 0:
		return
	if garbage_warn > 0:
		garbage_warn -= 1
		if garbage_warn == 0:
			if shield_charges > 0:
				shield_charges -= 1
				_show_toast("シールドでおじゃまを防いだ！", 0.9)
				_sfx("loot" if ResourceLoader.exists("res://assets/audio/loot.wav") else "ui")
			else:
				_add_garbage_row(1)
				_show_toast("おじゃまライン上昇！", 0.9)
				_sfx("warn" if ResourceLoader.exists("res://assets/audio/warn.wav") else "ui")
				_haptic(50)
			# Schedule next warning cycle.
			garbage_warn = -1
		elif garbage_warn == 1:
			event_warn = "次の配置でおじゃま上昇！"
			event_warn_timer = 1.4
			_sfx("warn" if ResourceLoader.exists("res://assets/audio/warn.wav") else "ui")
	elif garbage_warn < 0:
		# Idle between cycles.
		garbage_warn = interval
	else:
		garbage_warn = interval

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
	var bombs_in_clear := 0
	var chests_in_clear := 0
	for y in rows:
		for x in COLS:
			if int(meta[y][x]) == META_BOMB:
				bombs_in_clear += 1
			elif int(meta[y][x]) == META_CHEST:
				chests_in_clear += 1
	for y in rows:
		grid.remove_at(y)
		meta.remove_at(y)
		bomb_timer.remove_at(y)
		var empty: Array = []
		for x in COLS:
			empty.append(-1)
		grid.insert(0, empty)
		meta.insert(0, _empty_meta_row())
		bomb_timer.insert(0, _empty_bomb_row())
	var cleared: int = pending_clear_count
	combo += 1
	var base: int = int(LINE_SCORES[cleared]) * level
	var bonus: int = int(base * 0.5 * maxi(0, combo - 1))
	score += base + bonus
	lines += cleared
	if not _is_adventure():
		level = 1 + int(lines / 10.0)
	else:
		level = stage
		if bombs_in_clear > 0:
			bombs_defused += bombs_in_clear
			var bscore := bombs_in_clear * 250 * stage
			score += bscore
			_show_toast("ボム解除！　+%d" % bscore, 1.0)
			_sfx("loot" if ResourceLoader.exists("res://assets/audio/loot.wav") else "clear")
		if chests_in_clear > 0:
			for _c in chests_in_clear:
				_grant_chest_loot()
		stage_line_count += cleared
		_adventure_progress_stage()
		if _pvp_attacks_enabled() and cleared >= 2:
			_gain_attack_charge("%dライン" % cleared)
	_update_fall_interval()
	if bombs_in_clear == 0 and chests_in_clear == 0:
		if combo > 1:
			_show_toast("コンボ %d連鎖！　+%d" % [combo, base + bonus], 1.1)
		elif cleared >= 4:
			_show_toast("4ライン消し！　+%d" % (base + bonus), 1.0)
		elif cleared == 3:
			_show_toast("3ライン消し　+%d" % (base + bonus), 0.85)
		elif cleared == 2:
			_show_toast("2ライン消し　+%d" % (base + bonus), 0.75)
	pending_clear_count = 0
	clear_rows.clear()
	clearing = false
	if slow_left > 0:
		slow_left -= 1
	_refresh_labels()
	if mode == Mode.SPRINT and lines >= SPRINT_LINES:
		_end_run(true)
		return
	if _is_adventure():
		_adventure_tick_garbage_schedule()
	_spawn_piece()
	queue_redraw()

func _adventure_progress_stage() -> void:
	while stage_line_count >= STAGE_LINES:
		stage_line_count -= STAGE_LINES
		var clear_bonus := 400 * stage
		if stage % 5 == 0:
			clear_bonus *= 2
			_show_toast("ボス撃破！　+%d" % clear_bonus, 1.2)
		else:
			_show_toast("ステージクリア！　+%d" % clear_bonus, 1.0)
		score += clear_bonus
		_sfx("stage" if ResourceLoader.exists("res://assets/audio/stage.wav") else "tetris")
		_haptic(60)
		_begin_stage(stage + 1, false)

func _grant_chest_loot() -> void:
	chests_opened += 1
	var roll := rng.randi_range(0, 2)
	var item := ITEM_HAMMER
	if roll == 1:
		item = ITEM_LINE
	elif roll == 2:
		item = ITEM_SLOW
	# If inventory full, convert to score; shield is passive charge from chest sometimes.
	if held_item != ITEM_NONE:
		score += 150 * stage
		_show_toast("宝箱ボーナス　+%d" % (150 * stage), 0.85)
	else:
		held_item = item
		_show_toast("%s入手：%s" % [_item_label(item), _item_hint(item)], 1.35)
	if rng.randf() < 0.35:
		shield_charges = mini(2, shield_charges + 1)
		_show_toast("盾を入手！　おじゃまを1回自動で防ぐ", 1.0)
	if _pvp_attacks_enabled() and rng.randf() < 0.35:
		_gain_attack_charge("宝箱")
	_sfx("loot" if ResourceLoader.exists("res://assets/audio/loot.wav") else "ui")
	_refresh_item_btn()

func _item_label(item: String) -> String:
	match item:
		ITEM_HAMMER:
			return "ハンマー"
		ITEM_LINE:
			return "ライン"
		ITEM_SLOW:
			return "スロー"
		_:
			return "なし"

func _item_hint(item: String) -> String:
	match item:
		ITEM_HAMMER:
			return "一番上のブロック1つを壊す"
		ITEM_LINE:
			return "一番下の埋まっている行を消す"
		ITEM_SLOW:
			return "しばらく落下を遅くする"
		_:
			return ""

func _item_btn_caption(item: String) -> String:
	match item:
		ITEM_HAMMER:
			return "ハンマー"
		ITEM_LINE:
			return "ライン"
		ITEM_SLOW:
			return "スロー"
		_:
			return "道具\nなし"

func _use_held_item() -> void:
	if not _is_adventure() or screen != Screen.PLAY or paused or clearing or countdown > 0.0:
		return
	if held_item == ITEM_NONE:
		_show_toast("アイテムを持っていません", 0.7)
		return
	var used := held_item
	held_item = ITEM_NONE
	_refresh_item_btn()
	match used:
		ITEM_HAMMER:
			_item_hammer()
		ITEM_LINE:
			_item_clear_lowest()
		ITEM_SLOW:
			slow_left = 8
			_show_toast("スロー発動！　8手減速", 1.0)
			_sfx("loot" if ResourceLoader.exists("res://assets/audio/loot.wav") else "ui")
	_refresh_labels()
	queue_redraw()

func _item_hammer() -> void:
	for y in ROWS:
		for x in COLS:
			if grid[y][x] != -1:
				grid[y][x] = -1
				meta[y][x] = META_NONE
				bomb_timer[y][x] = 0
				_show_toast("ハンマーで1マス破壊！", 0.85)
				_sfx("hard")
				_haptic(30)
				return
	_show_toast("壊せるマスがありません", 0.7)

func _item_clear_lowest() -> void:
	for y in range(ROWS - 1, -1, -1):
		var any := false
		for x in COLS:
			if grid[y][x] != -1:
				any = true
				break
		if not any:
			continue
		for x in COLS:
			grid[y][x] = -1
			meta[y][x] = META_NONE
			bomb_timer[y][x] = 0
		# Collapse this empty row upward? Simpler: remove and insert top.
		grid.remove_at(y)
		meta.remove_at(y)
		bomb_timer.remove_at(y)
		var empty: Array = []
		for x in COLS:
			empty.append(-1)
		grid.insert(0, empty)
		meta.insert(0, _empty_meta_row())
		bomb_timer.insert(0, _empty_bomb_row())
		score += 100 * stage
		_show_toast("ライン消去！", 0.85)
		_sfx("clear")
		_haptic(40)
		return
	_show_toast("消せるラインがありません", 0.7)

func _show_toast(text: String, dur: float = 0.9) -> void:
	toast_text = text
	toast_punch = 0.28
	toast_timer = dur

func _update_fall_interval() -> void:
	var lv := level
	if _is_adventure():
		lv = stage
	fall_interval = maxf(0.05, pow(0.82, lv - 1))
	if slow_left > 0:
		fall_interval *= 1.7

func _shake(t: float, mag: float) -> void:
	shake_time = t
	shake_mag = mag

func _spawn_clear_particles(rows: Array) -> void:
	var n := rows.size()
	var burst := 1 if n <= 1 else (2 if n <= 3 else 3)
	var speed_boost := 1.0 + (n - 1) * 0.22
	for y in rows:
		for x in COLS:
			var cidx: int = int(grid[y][x]) if grid[y][x] != -1 else rng.randi_range(0, 6)
			var base_col: Color = _colors()[cidx]
			for _k in burst:
				var col := base_col.lightened(rng.randf_range(0.0, 0.25))
				particles.append({
					"pos": board_origin + Vector2((x + 0.5) * cell, (y + 0.5) * cell),
					"vel": Vector2(rng.randf_range(-140, 140) * speed_boost, rng.randf_range(-280, -60) * speed_boost),
					"life": rng.randf_range(0.32, 0.75 + n * 0.06),
					"color": col,
					"size": rng.randf_range(3.0, 6.5 + n * 0.8),
				})
	# Extra teal/coral sparks on Tetris / big clears.
	if n >= 3:
		var ac := _accent() if n < 4 else _accent2()
		for i in (10 if n >= 4 else 6):
			particles.append({
				"pos": board_origin + Vector2(cell * COLS * 0.5, cell * float(rows[0])),
				"vel": Vector2(rng.randf_range(-220, 220), rng.randf_range(-320, -80)),
				"life": rng.randf_range(0.4, 0.85),
				"color": Color(ac.r, ac.g, ac.b, 1.0),
				"size": rng.randf_range(4.0, 9.0),
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
	if paused and pause_btn and pause_btn.visible:
		pause_btn.modulate = Color.WHITE.lerp(Color(1.6, 1.7, 1.9), 0.5 + 0.5 * sin(title_pulse * 5.0))
	if screen == Screen.MENU:
		var bp := 1.0 + 0.035 * sin(title_pulse * 2.4)
		if brand_cool:
			brand_cool.scale = Vector2(bp, bp)
			brand_cool.pivot_offset = brand_cool.size * 0.5
		if brand_warm:
			brand_warm.scale = Vector2(bp, bp)
			brand_warm.pivot_offset = brand_warm.size * 0.5
	elif brand_cool:
		brand_cool.scale = Vector2.ONE
		if brand_warm:
			brand_warm.scale = Vector2.ONE
	if panel_fade < 1.0:
		panel_fade = minf(1.0, panel_fade + delta * 4.5)
		_apply_panel_fade()
	if toast_timer > 0.0:
		toast_timer = maxf(0.0, toast_timer - delta)
	if toast_punch > 0.0:
		toast_punch = maxf(0.0, toast_punch - delta)
	if stage_banner_timer > 0.0:
		stage_banner_timer = maxf(0.0, stage_banner_timer - delta)
	if event_warn_timer > 0.0:
		event_warn_timer = maxf(0.0, event_warn_timer - delta)
	if shake_time > 0.0:
		shake_time = maxf(0.0, shake_time - delta)
	if score_pop > 0.0:
		score_pop = maxf(0.0, score_pop - delta)
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
	if attack_cooldown > 0.0:
		attack_cooldown = maxf(0.0, attack_cooldown - delta)
		if attack_cooldown <= 0.0:
			_refresh_attack_btn()
	if screen == Screen.ROOM and online:
		room_poll -= delta
		if room_poll <= 0.0:
			room_poll = 1.2
			online.poll_room(last_event_id)
	if screen == Screen.PLAY and online_match and online and not paused:
		play_poll -= delta
		if play_poll <= 0.0:
			play_poll = 0.8
			online.poll_room(last_event_id)
	if screen == Screen.MENU or screen == Screen.MODE or screen == Screen.SETTINGS or screen == Screen.HOWTO or screen == Screen.ONLINE or screen == Screen.ROOM or screen == Screen.LEADERBOARD:
		for b in menu_blocks:
			b["phase"] = float(b["phase"]) + delta
			var p2: Vector2 = b["pos"]
			p2.y = fposmod(p2.y + float(b["speed"]) * delta * 0.008, 1.0)
			b["pos"] = p2
		queue_redraw()
		return
	if screen != Screen.PLAY or paused or forfeit_armed:
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

func _apply_panel_fade() -> void:
	var a := panel_fade
	for n in [menu_root, mode_root, settings_root, howto_root, online_root, room_root, lb_root]:
		if n and n.visible:
			n.modulate = Color(1, 1, 1, a)

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
		# Cancel online forfeit confirm.
		if screen == Screen.PLAY and online_match and forfeit_armed:
			if pause_btn and pause_btn.visible and pause_btn.get_global_rect().has_point(e.position):
				return
			forfeit_armed = false
			overlay.visible = false
			queue_redraw()
			return
		# Tap anywhere (except the pause button itself) to resume.
		if screen == Screen.PLAY and paused:
			if pause_btn and pause_btn.visible and pause_btn.get_global_rect().has_point(e.position):
				return
			_toggle_pause()
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
	if screen != Screen.PLAY:
		return
	# Online: no pause — × confirms forfeit back to room.
	if online_match:
		if forfeit_armed:
			_forfeit_online()
			return
		forfeit_armed = true
		overlay.visible = true
		overlay_title.text = "対戦をやめる？"
		overlay_sub.text = "もう一度 × で棄権してルームへ戻ります\n（現在のスコアで終了扱い）\n画面をタップでキャンセル"
		queue_redraw()
		return
	paused = not paused
	pause_btn.text = "▶" if paused else "II"
	pause_btn.set_meta("primary", paused)
	_apply_button_style(pause_btn, paused)
	if not paused:
		pause_btn.modulate = Color.WHITE
	overlay.visible = paused
	if paused:
		overlay_title.text = "一時停止"
		overlay_sub.text = "画面をタップして再開\n（右上の ▶ ボタンでもOK）"
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
			online_reregister_tries = 0
			status_msg = "%s としてログインしました" % online.player_name
			_refresh_status()
			if menu_xp_label:
				menu_xp_label.text = "%s  ／  XP %d  ／  テーマ：%s" % [online.player_name, online.player_xp, _theme()["jp"]]
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
			elif screen == Screen.ONLINE:
				status_msg = "部屋をつくる、またはコードを入力して参加します。"
				_refresh_status()
		"create_room", "join_room":
			last_started_seed = 0
			_apply_room_payload(data)
			_show_room()
		"ready", "start_room", "poll_room", "finish_room", "send_attack":
			_apply_room_payload(data)
			_ingest_attack_events(data)
			if kind == "start_room" or (kind == "poll_room" and screen == Screen.ROOM):
				_try_enter_online_match(data, kind == "start_room")
			if kind == "finish_room":
				_refresh_room_ui()
				if screen == Screen.GAME_OVER:
					if mode == Mode.ADVENTURE:
						overlay_sub.text = "ステージ %d　／　スコア %d を送信しました。\n画面をタップして順位を見る。" % [highest_stage, score]
					else:
						overlay_sub.text = "スコア %d を送信しました。\n画面をタップして順位を見る。" % score
			if kind == "send_attack":
				_refresh_attack_btn()
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
				overlay_sub.text += "\nデイリー順位を更新しました。"
		"health":
			status_msg = "サーバーに接続できました"
			_refresh_status()
	queue_redraw()

func _on_online_fail(kind: String, message: String) -> void:
	# Stale player ids after Render redeploy → re-register once and retry.
	var unknown := message.to_lower().contains("unknown player")
	if unknown and online and online_reregister_tries < 1 and (kind == "create_room" or kind == "join_room" or kind == "ready" or kind == "start_room" or kind == "finish_room"):
		online_reregister_tries += 1
		online.clear_player_id()
		status_msg = "プレイヤーを再登録しています…"
		_refresh_status()
		if kind == "create_room" and pending_create_mode == "":
			pending_create_mode = last_online_create_mode if last_online_create_mode != "" else "sprint"
		online.register_player(online.ensure_display_name())
		queue_redraw()
		return
	status_msg = message
	_refresh_status()
	if kind == "send_attack":
		# Refund charge if server rejected the throw.
		attack_charges = mini(3, attack_charges + 1)
		attack_cooldown = 0.0
		_show_toast(message, 0.85)
		_refresh_attack_btn()
		_refresh_labels()
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
	room_status = String(room.get("status", room_status))
	mode = _mode_from_str(String(room.get("mode", "sprint")))
	_refresh_room_ui()

func _local_player_finished(room: Dictionary) -> bool:
	if online == null:
		return false
	for p in room.get("players", []):
		if String(p.get("id", "")) == online.player_id:
			return bool(p.get("finished", false))
	return false

func _try_enter_online_match(data: Dictionary, force_start: bool) -> void:
	# Enter play only for a fresh match we haven't finished — never restart after game-over return.
	if screen != Screen.ROOM:
		return
	var room: Dictionary = data.get("room", {})
	if String(room.get("status", "")) != "playing":
		return
	if _local_player_finished(room):
		return
	var seed := int(room.get("seed", 0))
	# Poll after returning mid-match must not relaunch the same seed.
	if not force_start and seed != 0 and seed == last_started_seed:
		return
	match_seed = seed
	last_started_seed = seed
	online_match = true
	mode = _mode_from_str(String(room.get("mode", "sprint")))
	last_event_id = 0
	_begin_play()

func _forfeit_online() -> void:
	if not online_match or online == null or screen != Screen.PLAY:
		return
	forfeit_armed = false
	overlay.visible = false
	var st := highest_stage if mode == Mode.ADVENTURE else 1
	online.finish_room(score, lines, int(elapsed * 1000.0), st)
	online_match = true # keep flag so game-over path still treats as online
	_show_toast("棄権しました", 0.9)
	_show_room()

func _mode_from_str(s: String) -> Mode:
	match s:
		"classic":
			return Mode.CLASSIC
		"ultra":
			return Mode.ULTRA
		"daily":
			return Mode.DAILY
		"adventure":
			return Mode.ADVENTURE
		"norotate":
			return Mode.NO_ROTATE
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
		Mode.ADVENTURE:
			return "adventure"
		Mode.NO_ROTATE:
			return "norotate"
		_:
			return "sprint"

func _refresh_status() -> void:
	if status_label:
		status_label.text = status_msg
	if save_status_label:
		save_status_label.text = status_msg

func _refresh_room_ui() -> void:
	if room_info_label == null:
		return
	var code: String = online.room_code if online else "----"
	var role := ""
	match room_status:
		"playing":
			role = "試合進行中。終了した人は結果待ちです。ホストは全員終了後に次の試合を開始できます。"
		"finished":
			role = "試合終了。ホストが「ゲーム開始」で再戦できます。" if is_host else "試合終了。ホストの再戦開始を待っています。"
		_:
			role = "あなたはホストです。全員そろったら「ゲーム開始」を押してください。" if is_host else "ホストが開始するまでお待ちください。"
	room_info_label.text = "部屋コード：%s　／　モード：%s\n状態：%s\n%s" % [code, _mode_label(mode), room_status, role]
	var lines_txt := "参加者（%d人）\n" % room_players.size()
	for p in room_players:
		var state := "準備OK" if bool(p.get("ready", false)) else "準備中"
		if bool(p.get("finished", false)):
			state = "終了"
		elif room_status == "playing":
			state = "プレイ中"
		lines_txt += "・%s … %s\n" % [String(p.get("name", "?")), state]
	if not room_ranking.is_empty():
		lines_txt += "\n順位\n"
		for e in room_ranking:
			if mode == Mode.SPRINT:
				lines_txt += "%d位　%s　%s\n" % [int(e.get("rank", 0)), String(e.get("name", "?")), _fmt_time(int(e.get("timeMs", 0)))]
			elif mode == Mode.ADVENTURE:
				lines_txt += "%d位　%s　ステージ%d　%d点\n" % [
					int(e.get("rank", 0)),
					String(e.get("name", "?")),
					int(e.get("stage", 1)),
					int(e.get("score", 0)),
				]
			else:
				lines_txt += "%d位　%s　%d点\n" % [int(e.get("rank", 0)), String(e.get("name", "?")), int(e.get("score", 0))]
	room_list_label.text = lines_txt

func _board_label(board: String) -> String:
	match board:
		"sprint":
			return "スプリント（最速タイム）"
		"ultra":
			return "ウルトラ（2分間スコア）"
		"classic":
			return "クラシック"
		"adventure":
			return "アドベンチャー（到達ステージ）"
		"norotate":
			return "回転なし（スコア）"
		_:
			return "デイリーチャレンジ"

func _refresh_lb_ui(board: String, day: String) -> void:
	var t := "%s\n" % _board_label(board)
	if day != "":
		t += "%s\n" % day
	t += "\n"
	if leaderboard_entries.is_empty():
		t += "まだ記録がありません。\n最初の1位をねらいましょう！"
	else:
		var i := 1
		for e in leaderboard_entries:
			if board == "sprint":
				t += "%d位　%s　%s\n" % [i, String(e.get("name", "?")), _fmt_time(int(e.get("timeMs", 0)))]
			elif board == "adventure":
				t += "%d位　%s　ステージ%d　%d点\n" % [i, String(e.get("name", "?")), int(e.get("stage", 1)), int(e.get("score", 0))]
			else:
				t += "%d位　%s　%d点\n" % [i, String(e.get("name", "?")), int(e.get("score", 0))]
			i += 1
	lb_label.text = t

# ---------------------------------------------------------------------------
# Audio
# ---------------------------------------------------------------------------
func _setup_audio() -> void:
	var names := ["move", "rotate", "soft", "lock", "hard", "clear", "tetris", "gameover", "ui", "bomb", "loot", "warn", "stage"]
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
	_draw_background(size, th)
	_draw_ambient(size)
	if screen != Screen.PLAY and screen != Screen.GAME_OVER:
		_draw_menu_blocks(size)
		_draw_menu_brand_glow(size)
		return
	var offset := Vector2.ZERO
	if shake_time > 0.0:
		offset = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)) * shake_mag
	var origin := board_origin + offset
	var board_w := cell * COLS
	var board_h := cell * ROWS
	_draw_board_frame(origin, board_w, board_h, th)
	for y in ROWS:
		for x in COLS:
			var v: int = grid[y][x]
			if v != -1:
				var col: Color = _colors()[clampi(v, 0, 6)]
				if meta.size() > y and int(meta[y][x]) == META_GARBAGE:
					col = Color(0.45, 0.48, 0.55)
				_draw_cell_at(origin, Vector2i(x, y), col, 1.0)
				_draw_meta_overlay(origin, Vector2i(x, y))
	if clear_flash > 0.0:
		var a := clear_flash / 0.32
		var big := clear_rows.size() >= 4
		var dim := Color(0.02, 0.04, 0.08, 0.22 * a)
		draw_rect(Rect2(origin, Vector2(board_w, board_h)), dim, true)
		draw_rect(Rect2(origin, Vector2(board_w, board_h)), Color(1, 1, 1, (0.10 if big else 0.06) * a), true)
		for ry in clear_rows:
			var yy := clampi(int(ry), 0, ROWS - 1)
			var flash_col: Color = th["accent2"] if big else th["accent"]
			var flash := Color(flash_col.r, flash_col.g, flash_col.b, (0.78 if big else 0.62) * a)
			draw_rect(Rect2(origin + Vector2(0, yy * cell), Vector2(board_w, cell)), flash, true)
			draw_rect(Rect2(origin + Vector2(0, yy * cell), Vector2(board_w, cell)), Color(1, 1, 1, 0.4 * a), false, 2.2)
	if screen == Screen.PLAY and not paused and not clearing and countdown <= 0.0:
		var gp := _ghost_pos()
		for c in _cells(cur_type, cur_rot, gp):
			if c.y >= 0:
				_draw_ghost_cell(origin, c, _colors()[cur_type])
		for c in _cells(cur_type, cur_rot, cur_pos):
			if c.y >= 0:
				_draw_cell_at(origin, c, _colors()[cur_type], 1.0)
	_draw_side_previews()
	for p in particles:
		var col: Color = p["color"]
		col.a = clampf(float(p["life"]) * 2.0, 0.0, 1.0)
		draw_circle(p["pos"] + offset, float(p["size"]), col)
		var glow := col
		glow.a *= 0.25
		draw_circle(p["pos"] + offset, float(p["size"]) * 2.2, glow)
	_draw_toast(size)
	_draw_stage_banner(size)
	_draw_item_btn_glyph()
	if countdown > 0.0:
		_draw_countdown(size)

func _draw_meta_overlay(origin: Vector2, c: Vector2i) -> void:
	if meta.is_empty() or c.y < 0 or c.y >= meta.size():
		return
	var m: int = int(meta[c.y][c.x])
	if m == META_NONE or m == META_GARBAGE:
		return
	var p := origin + Vector2(c.x * cell, c.y * cell)
	var font := _font()
	if m == META_BOMB:
		_draw_bomb_icon(p, cell, c)
	elif m == META_CHEST:
		_draw_chest_icon(p, cell)

func _draw_bomb_icon(p: Vector2, sz: float, c: Vector2i) -> void:
	var pulse := 0.5 + 0.5 * sin(title_pulse * 8.0)
	var cd := 0
	if bomb_timer.size() > c.y:
		cd = int(bomb_timer[c.y][c.x])
	var urgent := cd <= 2
	var center := p + Vector2(sz * 0.48, sz * 0.58)
	var r := sz * 0.28
	# Soft glow so the bomb reads even on dark cells.
	var glow := Color(1.0, 0.25, 0.12, 0.22 + 0.28 * pulse) if urgent else Color(0.15, 0.15, 0.18, 0.35)
	draw_circle(center, r * 1.35, glow)
	# Body.
	draw_circle(center, r, Color(0.10, 0.10, 0.12, 0.96))
	draw_circle(center + Vector2(-r * 0.28, -r * 0.30), r * 0.32, Color(0.42, 0.44, 0.48, 0.55))
	# Cap / collar.
	var cap := Rect2(center.x - r * 0.38, center.y - r * 0.95, r * 0.76, r * 0.32)
	draw_rect(cap, Color(0.55, 0.58, 0.62, 0.95), true)
	# Fuse.
	var fuse_base := Vector2(center.x, cap.position.y)
	var fuse_tip := fuse_base + Vector2(sz * 0.06, -sz * 0.18)
	draw_line(fuse_base, fuse_tip, Color(0.55, 0.32, 0.14, 0.95), maxf(1.5, sz * 0.05))
	# Spark at the tip — blinks faster when the fuse is short.
	var spark_pulse := 0.5 + 0.5 * sin(title_pulse * (14.0 if urgent else 7.0))
	var spark_col := Color(1.0, 0.55 + 0.35 * spark_pulse, 0.12, 0.85 + 0.15 * spark_pulse)
	draw_circle(fuse_tip, maxf(1.8, sz * 0.07), spark_col)
	draw_circle(fuse_tip, maxf(0.8, sz * 0.035), Color(1, 1, 0.85, 0.95))
	# Countdown badge — orange when urgent, teal otherwise.
	var badge_col := _accent2() if urgent else _accent()
	var font := _font()
	var fs := int(clampf(sz * 0.38, 9.0, 16.0))
	var t := str(cd)
	var tw := font.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var badge := Rect2(p.x + sz - tw - 6.0, p.y + 2.0, tw + 5.0, fs + 4.0)
	draw_rect(badge, Color(0.05, 0.06, 0.09, 0.82), true)
	draw_rect(badge, Color(badge_col.r, badge_col.g, badge_col.b, 0.9), false, 1.2)
	draw_string(font, Vector2(badge.position.x + 2.5, badge.position.y + fs + 1.0), t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE)

func _draw_chest_icon(p: Vector2, sz: float) -> void:
	var body := Rect2(p + Vector2(sz * 0.18, sz * 0.32), Vector2(sz * 0.64, sz * 0.48))
	draw_rect(body, Color(0.78, 0.48, 0.16, 0.95), true)
	draw_rect(Rect2(body.position, Vector2(body.size.x, body.size.y * 0.38)), Color(0.92, 0.62, 0.22, 0.95), true)
	draw_rect(body, Color(1.0, 0.85, 0.35, 0.9), false, 1.4)
	# Lock plate.
	var lock_c := body.position + Vector2(body.size.x * 0.5, body.size.y * 0.55)
	draw_circle(lock_c, sz * 0.08, Color(0.95, 0.82, 0.25, 0.95))
	draw_circle(lock_c, sz * 0.035, Color(0.35, 0.22, 0.08, 0.95))
	# Small 宝 mark so chests are not mistaken for normal blocks.
	if sz >= 18.0:
		var font := _font()
		var fs := int(clampf(sz * 0.32, 9.0, 14.0))
		var mark := "宝"
		var tw := font.get_string_size(mark, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		draw_string(font, p + Vector2((sz - tw) * 0.5, sz * 0.28), mark, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(1, 0.95, 0.7, 0.95))

func _draw_item_btn_glyph() -> void:
	if item_btn == null or not item_btn.visible or held_item == ITEM_NONE:
		return
	var r := item_btn.get_global_rect()
	var c := r.get_center() + Vector2(0, -r.size.y * 0.18)
	var s := minf(r.size.x, r.size.y) * 0.22
	match held_item:
		ITEM_HAMMER:
			# Simple hammer: handle + head.
			draw_line(c + Vector2(-s * 0.2, s * 0.55), c + Vector2(s * 0.15, -s * 0.35), Color(0.55, 0.35, 0.18), maxf(2.0, s * 0.28))
			draw_rect(Rect2(c + Vector2(-s * 0.55, -s * 0.55), Vector2(s * 0.9, s * 0.38)), Color(0.75, 0.78, 0.82), true)
		ITEM_LINE:
			draw_rect(Rect2(c + Vector2(-s * 0.7, -s * 0.12), Vector2(s * 1.4, s * 0.28)), Color(0.95, 0.55, 0.25), true)
			draw_line(c + Vector2(-s * 0.5, s * 0.35), c + Vector2(s * 0.5, -s * 0.45), Color(1, 1, 1, 0.9), 2.0)
		ITEM_SLOW:
			draw_circle(c, s * 0.55, Color(0.25, 0.55, 0.85, 0.35))
			draw_arc(c, s * 0.55, -PI * 0.5, PI * 0.9, 16, Color(0.45, 0.85, 1.0), maxf(2.0, s * 0.18))
			draw_line(c, c + Vector2(0, s * 0.35), Color(1, 1, 1, 0.95), 2.0)

func _draw_stage_banner(size: Vector2) -> void:
	var font := _font()
	if stage_banner_timer > 0.0 and stage_banner != "":
		var a := clampf(stage_banner_timer / 0.45, 0.0, 1.0)
		var lines_txt := stage_banner.split("\n")
		var y0 := size.y * 0.36
		draw_rect(Rect2(24, y0 - 36, size.x - 48, 28.0 + lines_txt.size() * 34.0), Color(0.04, 0.06, 0.1, 0.78 * a), true)
		var yi := 0
		for line in lines_txt:
			var fs := 28 if yi == 0 else 18
			var tw := font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
			draw_string(font, Vector2((size.x - tw) * 0.5, y0 + yi * 34), line, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(1, 1, 1, a))
			yi += 1
		return
	if event_warn_timer > 0.0 and event_warn != "":
		var a2 := clampf(event_warn_timer / 0.4, 0.0, 1.0)
		var tw2 := font.get_string_size(event_warn, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x
		var pos2 := Vector2((size.x - tw2) * 0.5, maxf(24.0, board_origin.y - 10.0))
		draw_string(font, pos2, event_warn, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(1.0, 0.55, 0.35, a2))

func _draw_background(size: Vector2, th: Dictionary) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), th["bg"], true)
	for i in 14:
		var t := float(i) / 13.0
		var c: Color = th["bg"].lerp(th["bg2"], t)
		c.a = 0.62
		var y := size.y * t
		draw_rect(Rect2(0, y, size.x, size.y / 13.0 + 2.0), c, true)
	var cool: Color = th["accent"]
	var warm: Color = th["accent2"]
	var band := size.y * 0.38
	for i in 16:
		var t := float(i) / 15.0
		var fade := (1.0 - t) * (1.0 - t)
		draw_rect(Rect2(0, band * t, size.x, band / 15.0 + 2.0), Color(cool.r, cool.g, cool.b, 0.07 * fade), true)
		draw_rect(Rect2(0, size.y - band * t - band / 15.0 - 2.0, size.x, band / 15.0 + 2.0), Color(warm.r, warm.g, warm.b, 0.065 * fade), true)
	# Soft vignette bands.
	draw_rect(Rect2(0, 0, size.x, 28), Color(0, 0, 0, 0.38), true)
	draw_rect(Rect2(0, size.y - 40, size.x, 40), Color(0, 0, 0, 0.42), true)
	draw_rect(Rect2(0, 0, 18, size.y), Color(0, 0, 0, 0.22), true)
	draw_rect(Rect2(size.x - 18, 0, 18, size.y), Color(0, 0, 0, 0.22), true)

func _draw_board_frame(origin: Vector2, board_w: float, board_h: float, th: Dictionary) -> void:
	var pad := 12.0
	var outer := Rect2(origin - Vector2(pad, pad), Vector2(board_w + pad * 2, board_h + pad * 2))
	var ac: Color = th["accent"]
	var ac2: Color = th["accent2"]
	# Layered outer glow.
	draw_rect(outer.grow(10), Color(ac.r, ac.g, ac.b, 0.07), true)
	draw_rect(outer.grow(5), Color(ac.r, ac.g, ac.b, 0.14), true)
	# Frame shell with depth.
	draw_rect(outer, th["panel"], true)
	draw_rect(outer, Color(ac.r, ac.g, ac.b, 0.55), false, 2.4)
	draw_rect(outer.grow(-3), Color(ac2.r, ac2.g, ac2.b, 0.22), false, 1.2)
	# Inner well — near black for stack readability (TETR.IO-style).
	draw_rect(Rect2(origin, Vector2(board_w, board_h)), Color(0.015, 0.02, 0.035, 0.94), true)
	# Very light scan bands.
	for i in 5:
		var sy := origin.y + board_h * (0.12 + i * 0.18)
		draw_rect(Rect2(origin.x, sy, board_w, 1.0), Color(1, 1, 1, 0.025), true)
	# Grid ~4%.
	for x in range(COLS + 1):
		draw_line(origin + Vector2(x * cell, 0), origin + Vector2(x * cell, board_h), Color(1, 1, 1, 0.045), 1.0)
	for y in range(ROWS + 1):
		draw_line(origin + Vector2(0, y * cell), origin + Vector2(board_w, y * cell), Color(1, 1, 1, 0.045), 1.0)
	# Danger zone — clearer coral wash + line.
	draw_rect(Rect2(origin, Vector2(board_w, cell * 2)), Color(ac2.r, ac2.g, ac2.b, 0.08), true)
	draw_line(origin + Vector2(0, cell * 2), origin + Vector2(board_w, cell * 2), Color(ac2.r, ac2.g, ac2.b, 0.55), 2.0)
	# Corner brackets.
	var brk := minf(30.0, board_w * 0.14)
	var warm := Color(ac2.r, ac2.g, ac2.b, 0.9)
	for corner in [Vector2(outer.position.x, outer.position.y), Vector2(outer.end.x, outer.position.y), Vector2(outer.position.x, outer.end.y), Vector2(outer.end.x, outer.end.y)]:
		var sx := 1.0 if corner.x == outer.position.x else -1.0
		var sy := 1.0 if corner.y == outer.position.y else -1.0
		draw_line(corner, corner + Vector2(brk * sx, 0), warm, 3.0)
		draw_line(corner, corner + Vector2(0, brk * sy), warm, 3.0)

func _draw_toast(size: Vector2) -> void:
	if toast_timer <= 0.0 or toast_text.is_empty():
		return
	var a := clampf(toast_timer / 0.35, 0.0, 1.0)
	var punch := 1.0 + toast_punch * 1.35
	var font := _font()
	var fs := int(26.0 * punch)
	var tw := font.get_string_size(toast_text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var pos := Vector2((size.x - tw) * 0.5, board_origin.y + cell * ROWS * 0.32)
	var pill := Rect2(pos - Vector2(20, 30), Vector2(tw + 40, 48))
	var bg := Color(0.04, 0.06, 0.11, 0.82 * a)
	draw_rect(pill, bg, true)
	draw_rect(pill, Color(_accent2().r, _accent2().g, _accent2().b, 0.72 * a), false, 2.0)
	draw_string(font, pos + Vector2(2, 2), toast_text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0, 0, 0, 0.45 * a))
	draw_string(font, pos, toast_text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(1, 1, 1, a))

func _draw_countdown(size: Vector2) -> void:
	var n := str(maxi(1, int(ceil(countdown))))
	var frac := countdown - floorf(countdown)
	var scale := 1.0 + (1.0 - frac) * 0.25
	var fs := int(78.0 * scale)
	var font := _font()
	var tw := font.get_string_size(n, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var pos := Vector2((size.x - tw) * 0.5, size.y * 0.42)
	var ac := _accent()
	var ac2 := _accent2()
	draw_circle(Vector2(size.x * 0.5, size.y * 0.40), 70.0 + 10.0 * (1.0 - frac), Color(ac.r, ac.g, ac.b, 0.12))
	draw_arc(Vector2(size.x * 0.5, size.y * 0.40), 76.0 + 10.0 * (1.0 - frac), 0.0, TAU * (1.0 - frac), 48, Color(ac2.r, ac2.g, ac2.b, 0.75), 3.0)
	draw_string(font, pos + Vector2(2, 2), n, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0, 0, 0, 0.45))
	draw_string(font, pos, n, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE)

func _draw_ambient(size: Vector2) -> void:
	var pulse := 0.5 + 0.5 * sin(title_pulse * 1.6)
	var ac := _accent()
	var ac2: Color = _theme()["accent2"]
	draw_circle(Vector2(size.x * 0.18, size.y * 0.16), 160.0 + 22.0 * pulse, Color(ac.r, ac.g, ac.b, 0.08 + 0.04 * pulse))
	draw_circle(Vector2(size.x * 0.86, size.y * 0.26), 130.0 + 16.0 * (1.0 - pulse), Color(ac2.r, ac2.g, ac2.b, 0.07 + 0.04 * pulse))
	draw_circle(Vector2(size.x * 0.5, size.y * 0.82), 180.0, Color(ac.r, ac.g, ac.b, 0.045))

func _draw_menu_brand_glow(size: Vector2) -> void:
	if screen != Screen.MENU:
		return
	var pulse := 0.5 + 0.5 * sin(title_pulse * 2.2)
	var ac := _accent()
	var ac2 := _accent2()
	var center := Vector2(size.x * 0.5, 108.0)
	# Expanding pulse rings (Effect-inspired, low alpha).
	for i in 3:
		var phase := fposmod(title_pulse * 0.55 + float(i) * 0.33, 1.0)
		var rr := 42.0 + phase * 95.0
		var aa := (1.0 - phase) * (0.16 if i == 0 else 0.10)
		draw_arc(center, rr, 0.0, TAU, 64, Color(ac.r, ac.g, ac.b, aa), 2.0)
	draw_circle(center, 96.0 + 14.0 * pulse, Color(ac.r, ac.g, ac.b, 0.10 + 0.06 * pulse))
	draw_circle(center + Vector2(58, 4), 62.0 + 10.0 * (1.0 - pulse), Color(ac2.r, ac2.g, ac2.b, 0.09 + 0.05 * pulse))

func _draw_menu_blocks(size: Vector2) -> void:
	var side := maxf(22.0, (size.x - CONTENT_MAX_W) * 0.5)
	for b in menu_blocks:
		var s: float = float(b["size"])
		var nx := float(b["pos"].x)
		var span := side - 10.0 - s * 4.0
		var x: float
		if span > 20.0:
			if nx < 0.5:
				x = 6.0 + nx * 2.0 * span
			else:
				x = size.x - side + 4.0 + (nx - 0.5) * 2.0 * span
		else:
			x = nx * size.x
		var base := Vector2(x, float(b["pos"].y) * size.y)
		base.x += sin(float(b["phase"])) * float(b["drift"]) * (0.35 if span > 20.0 else 1.0)
		var t: int = int(b["type"])
		var rot: int = int(b["rot"])
		var col: Color = _colors()[t]
		col.a = 0.22
		for c in PIECES[t][rot]:
			var p := base + Vector2(c.x * s, c.y * s)
			var cell_r := Rect2(p, Vector2(s - 1.5, s - 1.5))
			# Soft trail / glow.
			draw_rect(cell_r.grow(3.0), Color(col.r, col.g, col.b, 0.06), true)
			draw_rect(cell_r, col, true)
			var hi := col.lightened(0.35)
			hi.a = 0.35
			draw_rect(Rect2(cell_r.position, Vector2(cell_r.size.x, cell_r.size.y * 0.32)), hi, true)
			var shade := col.darkened(0.3)
			shade.a = 0.3
			draw_rect(Rect2(cell_r.position + Vector2(0, cell_r.size.y * 0.7), Vector2(cell_r.size.x, cell_r.size.y * 0.3)), shade, true)
			draw_rect(cell_r, Color(1, 1, 1, 0.12), false, 1.0)

func _draw_cell_at(origin: Vector2, c: Vector2i, color: Color, alpha: float) -> void:
	var p := origin + Vector2(c.x * cell, c.y * cell)
	var inset := 1.8
	var r := Rect2(p + Vector2(inset, inset), Vector2(cell - inset * 2, cell - inset * 2))
	var col := color
	col.a = alpha
	if alpha >= 0.9:
		draw_rect(Rect2(r.position + Vector2(1.8, 2.4), r.size), Color(0, 0, 0, 0.35), true)
	draw_rect(r, col, true)
	if alpha >= 0.85:
		var hi := color.lightened(0.36)
		hi.a = 0.62 * alpha
		draw_rect(Rect2(r.position, Vector2(r.size.x, r.size.y * 0.30)), hi, true)
		var edge := color.lightened(0.18)
		edge.a = 0.42 * alpha
		draw_rect(Rect2(r.position, Vector2(r.size.x * 0.14, r.size.y)), edge, true)
		var shade := color.darkened(0.32)
		shade.a = 0.42 * alpha
		draw_rect(Rect2(r.position + Vector2(0, r.size.y * 0.68), Vector2(r.size.x, r.size.y * 0.32)), shade, true)
		draw_rect(Rect2(r.position + Vector2(r.size.x * 0.16, r.size.y * 0.10), Vector2(r.size.x * 0.28, r.size.y * 0.09)), Color(1, 1, 1, 0.28 * alpha), true)
		# Bright rim.
		var rim := color.lightened(0.45)
		rim.a = 0.55 * alpha
		draw_rect(r, rim, false, 1.2)

func _draw_ghost_cell(origin: Vector2, c: Vector2i, color: Color) -> void:
	var p := origin + Vector2(c.x * cell, c.y * cell)
	var r := Rect2(p + Vector2(2.5, 2.5), Vector2(cell - 5.0, cell - 5.0))
	draw_rect(r, Color(color.r, color.g, color.b, 0.10), true)
	var outline := color.lightened(0.15)
	outline.a = 0.62
	draw_rect(r, outline, false, 2.0)
	# Corner ticks for a clearer landing guide.
	var tick := minf(5.0, cell * 0.18)
	var oc := Color(color.r, color.g, color.b, 0.75)
	draw_line(r.position, r.position + Vector2(tick, 0), oc, 1.5)
	draw_line(r.position, r.position + Vector2(0, tick), oc, 1.5)
	draw_line(r.end, r.end - Vector2(tick, 0), oc, 1.5)
	draw_line(r.end, r.end - Vector2(0, tick), oc, 1.5)

func _draw_side_previews() -> void:
	_draw_mini_box(hold_origin, preview_w, preview_cell, hold_type, "ホールド")
	_draw_mini_box(next_origin, preview_w, preview_cell, next_type, "つぎ")

func _draw_mini_box(origin: Vector2, box_w: float, box_cell: float, piece_type: int, caption: String) -> void:
	var panel := Rect2(origin - Vector2(8, 24), Vector2(box_w + 16, box_w + 36))
	# Glass panel — UI retreats, board leads.
	draw_rect(panel, Color(0.05, 0.08, 0.14, 0.72), true)
	draw_rect(panel, Color(_accent().r, _accent().g, _accent().b, 0.35), false, 1.6)
	var cap_size := int(clampf(box_w * 0.22, 9.0, 13.0))
	draw_string(_font(), origin + Vector2(2, -8), caption, HORIZONTAL_ALIGNMENT_LEFT, box_w + 12.0, cap_size, Color(0.72, 0.82, 0.92, 0.9))
	if piece_type < 0:
		return
	var min_x := 99
	var max_x := -99
	var min_y := 99
	var max_y := -99
	for c in PIECES[piece_type][0]:
		min_x = mini(min_x, c.x)
		max_x = maxi(max_x, c.x)
		min_y = mini(min_y, c.y)
		max_y = maxi(max_y, c.y)
	var pw := (max_x - min_x + 1) * box_cell
	var ph := (max_y - min_y + 1) * box_cell
	var ox := origin.x + (box_w - pw) * 0.5 - min_x * box_cell
	var oy := origin.y + (box_w - ph) * 0.5 - min_y * box_cell + 4.0
	for c in PIECES[piece_type][0]:
		var p := Vector2(ox + c.x * box_cell, oy + c.y * box_cell)
		var col: Color = _colors()[piece_type]
		var cr := Rect2(p + Vector2(1, 1), Vector2(box_cell - 2, box_cell - 2))
		draw_rect(cr, col, true)
		var hi := col.lightened(0.3)
		hi.a = 0.5
		draw_rect(Rect2(cr.position, Vector2(cr.size.x, cr.size.y * 0.3)), hi, true)
		draw_rect(cr, Color(1, 1, 1, 0.2), false, 1.0)

# ---------------------------------------------------------------------------
# UI builders
# ---------------------------------------------------------------------------
func _recalc_layout() -> void:
	var size := get_size()
	# Taller HUD band so score/hold/next/pause never collide.
	hud_height = clampf(size.y * 0.17, 150.0, 220.0)

	# Keep touch pads roughly square: their height follows the width each one
	# gets, instead of stretching to fill a percentage of the screen.
	var pad_gap := 8.0
	var visible_pads := 0
	for b in pad_buttons:
		if b.visible:
			visible_pads += 1
	var pad_n := maxi(visible_pads, 6)
	var pad_btn_w := (size.x - 20.0 - pad_gap * (pad_n - 1)) / float(pad_n)
	var pad_btn_h := clampf(pad_btn_w * 0.85, 52.0, 88.0)
	pad_height = pad_btn_h + 44.0
	if pad_root:
		pad_root.offset_top = -(pad_btn_h + 22.0)
		pad_root.offset_bottom = -22.0
		var glyph_size := int(clampf(pad_btn_h * 0.34, 17.0, 28.0))
		for b in pad_buttons:
			b.custom_minimum_size = Vector2(44, pad_btn_h)
			var fs := glyph_size
			if b == item_btn or b == attack_btn:
				fs = int(glyph_size * 0.55)
			b.add_theme_font_size_override("font_size", fs)

	var avail_h := size.y - hud_height - pad_height
	var avail_w := size.x * 0.92
	cell = floorf(minf(avail_w / COLS, avail_h / ROWS))
	cell = maxf(cell, 12.0)
	var board_w := cell * COLS
	var board_h := cell * ROWS
	board_origin = Vector2((size.x - board_w) * 0.5, hud_height + (avail_h - board_h) * 0.5)

	var btn_size := 46.0
	var btn_top := 8.0
	if pause_btn:
		pause_btn.position = Vector2(size.x - btn_size - 12.0, btn_top)
		pause_btn.custom_minimum_size = Vector2(btn_size, btn_size)

	# Both preview panels sit on one right-hand row, under the pause button.
	# A panel is 16px wider and 36px taller than its inner box (see _draw_mini_box).
	var boxes_top := btn_top + btn_size + 10.0
	var box_w := cell * 4.0 * 0.44
	box_w = minf(box_w, hud_height - boxes_top - 42.0)
	box_w = minf(box_w, (size.x - 250.0) * 0.5)
	box_w = maxf(box_w, 32.0)
	preview_w = box_w
	preview_cell = box_w * 0.25
	var box_y := boxes_top + 24.0
	next_origin = Vector2(size.x - 14.0 - box_w, box_y)
	hold_origin = Vector2(next_origin.x - box_w - 24.0, box_y)

	# The text column gets whatever width is left of the preview panels.
	if hud_col:
		var col_w := maxf(140.0, hold_origin.x - 8.0 - 14.0 - 10.0)
		hud_col.custom_minimum_size = Vector2(col_w, 0)
		hud_col.size = Vector2(col_w, 0)
		if adventure_label:
			adventure_label.custom_minimum_size = Vector2(col_w, 0)

	var side := maxf(22.0, (size.x - CONTENT_MAX_W) * 0.5)
	for m in screen_margins:
		m.add_theme_constant_override("margin_left", int(side))
		m.add_theme_constant_override("margin_right", int(side))
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
	var margin := _screen_margin()
	menu_root.add_child(margin)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	margin.add_child(col)
	col.add_child(_spacer(36))
	# Two-tone wordmark: teal AOI + coral PULSE — hero of the first viewport.
	var brand := HBoxContainer.new()
	brand.alignment = BoxContainer.ALIGNMENT_CENTER
	brand.add_theme_constant_override("separation", 2)
	brand_cool = _brand_part("AOI", _accent())
	brand_warm = _brand_part("PULSE", _accent2())
	brand.add_child(brand_cool)
	brand.add_child(brand_warm)
	col.add_child(brand)
	col.add_child(_sub("リズムで消す", 16))
	col.add_child(_spacer(22))
	var scroll := _scroll()
	col.add_child(scroll)
	var list := _list()
	scroll.add_child(list)
	_menu_item(list, "ひとりで遊ぶ", "モードを選んですぐプレイできます", true, _on_play_menu, true)
	_menu_item(list, "オンライン対戦", "友だちと同じ条件でスコアを競います", true, _on_online_pressed)
	_menu_item(list, "ランキング", "みんなの記録を見る", false, _on_lb_pressed)
	_menu_item(list, "設定", "名前・サーバー・音・振動", false, _on_settings_pressed)
	_menu_item(list, "遊び方", "操作方法とルールの説明", false, _on_howto_pressed)
	# Quiet footer stats — not competing with brand/CTA.
	list.add_child(_spacer(8))
	menu_best_label = _make_label("最高スコア  0", 15, Color(0.62, 0.70, 0.82))
	list.add_child(menu_best_label)
	menu_xp_label = _sub("プレイヤー ／ XP 0", 12)
	list.add_child(menu_xp_label)

func _build_mode() -> void:
	var parts := _screen_root("モードを選ぶ", "遊びたいルールを選んでください")
	mode_root = parts[0]
	var col: VBoxContainer = parts[1]
	var list: VBoxContainer = parts[2]
	_menu_item(list, "クラシック", "時間制限なし。レベルが上がるほど速くなります", true, func(): _start_local(Mode.CLASSIC))
	_menu_item(list, "アドベンチャー", "ステージ制。ボム・宝箱・おじゃまの挑戦", true, func(): _start_local(Mode.ADVENTURE), true)
	_menu_item(list, "回転なし", "出てきた向きのまま置く。回転ボタンは使えません", true, func(): _start_local(Mode.NO_ROTATE), true)
	_menu_item(list, "スプリント（40ライン）", "40ライン消すまでの最速タイムをねらいます", true, func(): _start_local(Mode.SPRINT))
	_menu_item(list, "ウルトラ（2分）", "2分間でどれだけスコアを稼げるか挑戦します", true, func(): _start_local(Mode.ULTRA))
	_menu_item(list, "デイリーチャレンジ", "毎日変わる共通のお題。全員が同じブロック順です", true, func(): _start_local(Mode.DAILY))
	_screen_back(col, list, _on_back_menu)

func _build_settings() -> void:
	var parts := _screen_root("設定", "名前やサウンドを変更できます")
	settings_root = parts[0]
	var col: VBoxContainer = parts[1]
	var list: VBoxContainer = parts[2]
	_section(list, "プレイヤー")
	list.add_child(_body("ランキングや対戦で表示される名前です。", 16))
	name_edit = _input_field("表示名（例：ヒロ）")
	if online:
		name_edit.text = online.ensure_display_name()
	list.add_child(name_edit)
	_section(list, "オンライン")
	list.add_child(_body("ひとりで遊ぶだけなら変更しなくて大丈夫です。", 16))
	server_edit = _input_field("サーバーURL")
	list.add_child(server_edit)
	list.add_child(_btn("サーバー接続を確認", false, func(): if online: online.health()))
	_section(list, "サウンド・操作")
	chk_sfx = _check("効果音", func(v): sfx_on = v; _save_settings())
	list.add_child(chk_sfx)
	chk_music = _check("BGM（音楽）", func(v): music_on = v; _apply_music_setting(); _save_settings())
	list.add_child(chk_music)
	chk_haptic = _check("振動（バイブ）", func(v): haptic_on = v; _save_settings())
	list.add_child(chk_haptic)
	save_status_label = _body("", 16)
	save_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	list.add_child(save_status_label)
	col.add_child(_spacer(10))
	col.add_child(_btn("保存する", true, _on_save_profile))
	_screen_back(col, list, _on_back_menu)

func _build_howto() -> void:
	var parts := _screen_root("遊び方", "はじめての方はここを読んでください")
	howto_root = parts[0]
	var col: VBoxContainer = parts[1]
	var list: VBoxContainer = parts[2]
	_section(list, "ゲームの目的")
	list.add_child(_body("落ちてくるブロックを積み、横1列をすき間なくそろえるとその列が消えて得点になります。ブロックが画面の上まで積み上がるとゲームオーバーです。", 19))
	_section(list, "スマホでの操作")
	list.add_child(_body("・左右にスワイプ　…　横に動かす\n・画面をタップ　…　回転する\n・下にスワイプ　…　少し速く落とす\n・画面下のボタンでも同じ操作ができます", 19))
	_section(list, "下のボタンの意味")
	list.add_child(_body("◀ ▶ 　横に動かす\n⟳ 　　回転する\n▼ 　　少し速く落とす\n⤓ 　　一気に下まで落とす\nH 　　ブロックを1つ預ける（ホールド）", 19))
	_section(list, "高得点のコツ")
	list.add_child(_body("・1度に多くのラインを消すほど高得点です（4ライン同時が最高）\n・続けて消すとコンボボーナスが入ります\n・うすい影は落下する位置の目安です", 19))
	_section(list, "モードの違い")
	list.add_child(_body("クラシック　…　時間制限なし。長く生き残る\nアドベンチャー　…　ステージ制。ボム・宝箱・おじゃま\n回転なし　…　出てきた向きのまま置く（回転不可）\nスプリント　…　40ライン消すまでのタイムを競う\nウルトラ　…　2分間でスコアを稼ぐ\nデイリー　…　毎日共通のお題で全員と勝負", 19))
	_section(list, "アドベンチャーのコツ")
	list.add_child(_body("入手：宝箱のラインを消すと道具が1つ入ります（すでに持っているとスコアに変わります）。\n使い方：下の「道具」ボタンをタップ。\n\n・ハンマー　…　いちばん上にあるブロックを1マス壊す\n・ライン消去　…　いちばん下の埋まっている行を消す\n・スロー　…　しばらく落下を遅くする\n・盾　…　自動でおじゃま1回を防ぐ（ボタン不要）\n\n・ボムはカウントがゼロになる前にそのラインを消す\n・5ステージごとに手数制限のボス戦", 18))
	_section(list, "オンライン対戦のやり方")
	list.add_child(_body("1. ホストが「部屋をつくる」を押すと4文字のコードが出ます（スプリント／ウルトラ／アドベンチャー／回転なし）\n2. 友だちにコードを伝えます\n3. 友だちは「部屋に入る」でコードを入力します\n4. 全員が「準備OK」を押したらホストが開始します\n5. アドベンチャーは到達ステージ→スコア、回転なしはスコアで順位が決まります", 19))
	_section(list, "アドベンチャーオンラインの攻撃")
	list.add_child(_body("2ライン以上消す、または宝箱で攻撃チャージを貯めます（最大3）。\n下の「攻撃」ボタンで相手に送れます。チャージがないときはタップで種類切替。\n・ゴミ　…　おじゃま1段（盾で防げる）\n・バナナ　…　落ちているブロックの向きを乱す\n・ボム　…　盤面にボムを1つ置く\nクールダウン約6秒。順位はこれまでどおり到達ステージ優先です。", 18))
	_screen_back(col, list, _on_back_menu)

func _build_online() -> void:
	var parts := _screen_root("オンライン対戦", "同じ部屋の全員が同じ条件で対戦します")
	online_root = parts[0]
	var col: VBoxContainer = parts[1]
	var list: VBoxContainer = parts[2]
	status_label = _body("", 16)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	list.add_child(status_label)
	_section(list, "部屋をつくる（ホストになる）")
	_menu_item(list, "スプリントの部屋をつくる", "40ラインの最速タイムを競います", true, func(): _online_create("sprint"))
	_menu_item(list, "ウルトラの部屋をつくる", "2分間のスコアを競います", true, func(): _online_create("ultra"))
	_menu_item(list, "アドベンチャーの部屋をつくる", "同じ種でステージ競争＋ゴミ／バナナ／ボム攻撃", true, func(): _online_create("adventure"), true)
	_menu_item(list, "回転なしの部屋をつくる", "同じ種・回転なしでスコアを競います", true, func(): _online_create("norotate"), true)
	_section(list, "部屋に入る（参加する）")
	list.add_child(_body("ホストから聞いた4文字のコードを入力してください。", 16))
	join_edit = _input_field("部屋コード（例：ABCD）")
	join_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	list.add_child(join_edit)
	list.add_child(_btn("この部屋に入る", true, _online_join))
	list.add_child(_spacer(4))
	list.add_child(_btn("サーバー接続を確認", false, func(): if online: online.health()))
	_screen_back(col, list, _on_back_menu)

func _build_room() -> void:
	var parts := _screen_root("待機ルーム", "全員の準備ができたらホストが開始します")
	room_root = parts[0]
	var col: VBoxContainer = parts[1]
	var list: VBoxContainer = parts[2]
	room_info_label = _body("", 15)
	room_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	list.add_child(room_info_label)
	list.add_child(_spacer(4))
	room_list_label = _body("", 15)
	list.add_child(room_list_label)
	col.add_child(_btn("準備OK", true, func(): if online: online.set_ready(true)))
	col.add_child(_btn("ゲーム開始／再戦（ホスト）", true, _on_host_start_match))
	col.add_child(_btn("部屋を出る", false, _on_back_menu))

func _build_leaderboard() -> void:
	var parts := _screen_root("ランキング", "種目を選んで順位を確認できます")
	lb_root = parts[0]
	var col: VBoxContainer = parts[1]
	var list: VBoxContainer = parts[2]
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 8)
	list.add_child(row)
	row.add_child(_tab_btn("デイリー", func(): if online: online.fetch_leaderboard("daily")))
	row.add_child(_tab_btn("スプリント", func(): if online: online.fetch_leaderboard("sprint")))
	row.add_child(_tab_btn("ウルトラ", func(): if online: online.fetch_leaderboard("ultra")))
	row.add_child(_tab_btn("冒険", func(): if online: online.fetch_leaderboard("adventure")))
	row.add_child(_tab_btn("無回転", func(): if online: online.fetch_leaderboard("norotate")))
	lb_label = _body("", 15)
	list.add_child(lb_label)
	_screen_back(col, list, _on_back_menu)

func _build_hud() -> void:
	hud_root = Control.new()
	hud_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_root.visible = false
	add_child(hud_root)
	# Single left column — avoids absolute-positioned rows overlapping.
	var hud := VBoxContainer.new()
	hud.position = Vector2(14, 8)
	hud.custom_minimum_size = Vector2(200, 0)
	hud.add_theme_constant_override("separation", 1)
	hud_root.add_child(hud)
	hud_col = hud
	score_label = _make_label("スコア 0", 30, _accent2())
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	score_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.65))
	score_label.add_theme_constant_override("shadow_offset_x", 0)
	score_label.add_theme_constant_override("shadow_offset_y", 3)
	high_label = _make_label("最高 0", 13, Color(0.58, 0.66, 0.78))
	high_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	timer_label = _make_label("", 13, Color(0.78, 0.86, 0.96))
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	hud.add_child(score_label)
	hud.add_child(high_label)
	hud.add_child(timer_label)
	var stat := HBoxContainer.new()
	stat.add_theme_constant_override("separation", 14)
	hud.add_child(stat)
	level_label = _make_label("レベル 1", 13, Color(0.70, 0.78, 0.90))
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	lines_label = _make_label("ライン 0", 13, Color(0.70, 0.78, 0.90))
	lines_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	stat.add_child(level_label)
	stat.add_child(lines_label)
	adventure_label = _make_label("", 13, Color(0.95, 0.85, 0.45))
	adventure_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	adventure_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	adventure_label.custom_minimum_size = Vector2(200, 0)
	hud.add_child(adventure_label)
	pause_btn = Button.new()
	pause_btn.text = "II"
	pause_btn.custom_minimum_size = Vector2(46, 46)
	pause_btn.focus_mode = Control.FOCUS_NONE
	pause_btn.pressed.connect(_toggle_pause)
	pause_btn.visible = false
	_apply_button_style(pause_btn, false)
	add_child(pause_btn)

func _build_controls() -> void:
	pad_root = HBoxContainer.new()
	pad_root.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	pad_root.offset_left = 10
	pad_root.offset_right = -10
	pad_root.offset_top = -110
	pad_root.offset_bottom = -22
	pad_root.alignment = BoxContainer.ALIGNMENT_CENTER
	pad_root.add_theme_constant_override("separation", 10)
	pad_root.visible = false
	add_child(pad_root)
	var left := _pad("◀")
	left.button_down.connect(_on_left_down)
	left.button_up.connect(_on_left_up)
	pad_root.add_child(left)
	var hold := _pad("H")
	hold.pressed.connect(_hold_piece)
	pad_root.add_child(hold)
	rot_btn = _pad("⟳")
	rot_btn.pressed.connect(_on_rotate_btn)
	pad_root.add_child(rot_btn)
	var down := _pad("▼")
	down.button_down.connect(_on_soft_down)
	down.button_up.connect(_on_soft_up)
	pad_root.add_child(down)
	var drop := _pad("⤓")
	drop.pressed.connect(_on_drop_btn)
	pad_root.add_child(drop)
	item_btn = _pad("道具")
	item_btn.add_theme_font_size_override("font_size", 16)
	item_btn.pressed.connect(_use_held_item)
	item_btn.visible = false
	pad_root.add_child(item_btn)
	attack_btn = _pad("攻撃")
	attack_btn.add_theme_font_size_override("font_size", 13)
	attack_btn.pressed.connect(_on_attack_btn)
	attack_btn.visible = false
	pad_root.add_child(attack_btn)
	var right := _pad("▶")
	right.button_down.connect(_on_right_down)
	right.button_up.connect(_on_right_up)
	pad_root.add_child(right)

func _refresh_item_btn() -> void:
	if item_btn == null:
		return
	item_btn.text = _item_btn_caption(held_item)
	var fs := 14 if held_item != ITEM_NONE else 16
	item_btn.add_theme_font_size_override("font_size", fs)
	# Highlight when an item is ready to use.
	item_btn.set_meta("primary", held_item != ITEM_NONE)
	item_btn.set_meta("warm", held_item != ITEM_NONE)
	_apply_button_style(item_btn, held_item != ITEM_NONE)

func _refresh_attack_btn() -> void:
	if attack_btn == null:
		return
	var t := _attack_type_label(_current_attack_type())
	var ready := attack_charges > 0 and attack_cooldown <= 0.0
	if attack_cooldown > 0.0:
		attack_btn.text = "攻撃×%d\n%s\nCD" % [attack_charges, t]
	else:
		attack_btn.text = "攻撃×%d\n%s" % [attack_charges, t]
	attack_btn.add_theme_font_size_override("font_size", 12)
	attack_btn.set_meta("primary", ready)
	attack_btn.set_meta("warm", ready)
	_apply_button_style(attack_btn, ready)

func _build_overlay() -> void:
	overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.visible = false
	add_child(overlay)
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.03, 0.06, 0.72)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(dim)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -240
	panel.offset_right = 240
	panel.offset_top = -150
	panel.offset_bottom = 150
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.10, 0.16, 0.96)
	sb.set_corner_radius_all(18)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = Color(_accent().r, _accent().g, _accent().b, 0.45)
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 24
	sb.content_margin_bottom = 24
	panel.add_theme_stylebox_override("panel", sb)
	overlay.add_child(panel)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	overlay_title = _title("一時停止", 40)
	box.add_child(overlay_title)
	overlay_sub = _sub("", 17)
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
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

func _brand_part(text: String, color: Color) -> Label:
	var l := _make_label(text, 64, color)
	l.add_theme_color_override("font_shadow_color", Color(color.r, color.g, color.b, 0.35))
	l.add_theme_constant_override("shadow_offset_x", 0)
	l.add_theme_constant_override("shadow_offset_y", 4)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.55))
	l.add_theme_constant_override("outline_size", 4)
	return l

func _make_label(text: String, font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

func _screen_margin() -> MarginContainer:
	var m := MarginContainer.new()
	m.set_anchors_preset(Control.PRESET_FULL_RECT)
	m.add_theme_constant_override("margin_left", 22)
	m.add_theme_constant_override("margin_right", 22)
	m.add_theme_constant_override("margin_top", 26)
	m.add_theme_constant_override("margin_bottom", 22)
	screen_margins.append(m)
	return m

func _scroll() -> ScrollContainer:
	var s := ScrollContainer.new()
	s.size_flags_vertical = Control.SIZE_EXPAND_FILL
	s.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	return s

func _list() -> VBoxContainer:
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Fill the scroll viewport so short pages sit centred instead of hugging
	# the top; taller pages overflow and scroll as usual.
	v.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 12)
	return v

func _spacer(h: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c

## Builds a full-screen page: [root, outer column, scrollable list].
func _screen_root(title_text: String, subtitle: String) -> Array:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.visible = false
	add_child(root)
	var margin := _screen_margin()
	root.add_child(margin)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	margin.add_child(col)
	col.add_child(_title(title_text, 32))
	if subtitle != "":
		col.add_child(_sub(subtitle, 16))
	col.add_child(_spacer(6))
	var scroll := _scroll()
	col.add_child(scroll)
	var list := _list()
	scroll.add_child(list)
	return [root, col, list]

## Closes a page built by _screen_root. The trailing padding keeps the last
## scrolled line from being clipped flush against the footer button.
func _screen_back(col: VBoxContainer, list: VBoxContainer, cb: Callable) -> void:
	list.add_child(_spacer(12))
	col.add_child(_spacer(10))
	col.add_child(_btn("もどる", false, cb))

## A primary action with a one-line explanation underneath.
func _menu_item(parent: VBoxContainer, title: String, desc: String, primary: bool, cb: Callable, warm: bool = false) -> void:
	var group := VBoxContainer.new()
	group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	group.add_theme_constant_override("separation", 3)
	group.add_child(_btn(title, primary, cb, warm))
	if desc != "":
		var l := _make_label(desc, 15, Color(0.62, 0.68, 0.80))
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		group.add_child(l)
	parent.add_child(group)

func _section(parent: VBoxContainer, text: String) -> void:
	parent.add_child(_spacer(6))
	var l := _make_label(text, 16, _accent())
	parent.add_child(l)
	var rule := ColorRect.new()
	rule.custom_minimum_size = Vector2(0, 1)
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rule.color = Color(_accent2().r, _accent2().g, _accent2().b, 0.35)
	parent.add_child(rule)

func _body(text: String, size: int = 18) -> Label:
	var l := _make_label(text, size, Color(0.82, 0.86, 0.94))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

func _input_field(placeholder: String) -> LineEdit:
	var e := LineEdit.new()
	e.placeholder_text = placeholder
	e.custom_minimum_size = Vector2(0, 50)
	e.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	e.add_theme_font_size_override("font_size", 17)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.10, 0.16, 0.95)
	sb.set_corner_radius_all(12)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = Color(_accent().r, _accent().g, _accent().b, 0.30)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	e.add_theme_stylebox_override("normal", sb)
	var focus := sb.duplicate() as StyleBoxFlat
	focus.border_color = Color(_accent().r, _accent().g, _accent().b, 0.70)
	e.add_theme_stylebox_override("focus", focus)
	return e

func _check(text: String, cb: Callable) -> CheckButton:
	var c := CheckButton.new()
	c.text = text
	c.add_theme_font_size_override("font_size", 18)
	c.focus_mode = Control.FOCUS_NONE
	c.toggled.connect(cb)
	return c

func _tab_btn(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 46)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_size_override("font_size", 15)
	b.focus_mode = Control.FOCUS_NONE
	_apply_button_style(b, false)
	b.pressed.connect(cb)
	return b

func _btn(text: String, primary: bool, cb: Callable, warm: bool = false) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 58)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_size_override("font_size", 19)
	b.focus_mode = Control.FOCUS_NONE
	b.set_meta("primary", primary)
	b.set_meta("warm", warm)
	_apply_button_style(b, primary)
	b.pressed.connect(cb)
	return b

func _pad(text: String) -> Button:
	var b := Button.new()
	b.text = text
	# Height is set by _recalc_layout so the pads stay close to square.
	b.custom_minimum_size = Vector2(48, 72)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_size_override("font_size", 28)
	b.focus_mode = Control.FOCUS_NONE
	b.set_meta("pad", true)
	_apply_button_style(b, false)
	pad_buttons.append(b)
	return b

func _restyle_buttons() -> void:
	# Re-apply theme accent colors after theme unlock.
	_restyle_tree(self)
	if brand_cool:
		brand_cool.add_theme_color_override("font_color", _accent())
	if brand_warm:
		brand_warm.add_theme_color_override("font_color", _accent2())
	if score_label:
		score_label.add_theme_color_override("font_color", _accent2())

func _restyle_tree(n: Node) -> void:
	if n is Button:
		var b := n as Button
		var primary := bool(b.get_meta("primary", false))
		_apply_button_style(b, primary)
	for c in n.get_children():
		_restyle_tree(c)

func _apply_button_style(b: Button, primary: bool) -> void:
	var warm := bool(b.get_meta("warm", false))
	var pad_glass := bool(b.get_meta("pad", false))
	# One accent family per button — never mix teal fill with coral border.
	var ac: Color = _accent2() if warm else _accent()
	var normal := StyleBoxFlat.new()
	if primary:
		var mix := 0.82 if warm else 0.58
		normal.bg_color = Color(
			lerpf(0.07, ac.r, mix),
			lerpf(0.10, ac.g, mix),
			lerpf(0.16, ac.b, mix),
			0.97
		)
		normal.border_color = Color(ac.r, ac.g, ac.b, 0.42).lightened(0.08)
	elif pad_glass:
		normal.bg_color = Color(0.06, 0.10, 0.18, 0.78)
		normal.border_color = Color(ac.r, ac.g, ac.b, 0.28)
	else:
		normal.bg_color = Color(0.09, 0.12, 0.20, 0.92)
		normal.border_color = Color(1, 1, 1, 0.10)
	normal.set_corner_radius_all(16 if not pad_glass else 14)
	normal.content_margin_left = 12
	normal.content_margin_right = 12
	normal.content_margin_top = 10
	normal.content_margin_bottom = 10
	normal.border_width_left = 1
	normal.border_width_top = 1
	normal.border_width_right = 1
	normal.border_width_bottom = 2
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = normal.bg_color.lightened(0.10)
	hover.border_color = Color(ac.r, ac.g, ac.b, 0.50)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = normal.bg_color.darkened(0.14)
	pressed.border_width_bottom = 1
	pressed.content_margin_top = 12
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_stylebox_override("focus", hover)
	b.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0))
	b.add_theme_color_override("font_pressed_color", Color(0.88, 0.92, 1.0))
	b.add_theme_color_override("font_hover_color", Color.WHITE)

func _refresh_labels() -> void:
	if score != last_shown_score:
		if score > last_shown_score:
			score_pop = 0.25
		last_shown_score = score
	if score_label:
		score_label.text = "スコア %d" % score
		if score_pop > 0.0:
			score_label.add_theme_font_size_override("font_size", int(30 + score_pop * 16))
		else:
			score_label.add_theme_font_size_override("font_size", 30)
	if high_label:
		high_label.text = "最高 %d" % _current_high_score()
	if level_label:
		if _is_adventure():
			level_label.text = "ステージ %d" % stage
		else:
			level_label.text = "レベル %d" % level
	if lines_label:
		if mode == Mode.SPRINT:
			lines_label.text = "ライン %d/%d" % [lines, SPRINT_LINES]
		elif _is_adventure():
			var left := STAGE_LINES - stage_line_count
			if boss_piece_limit > 0:
				lines_label.text = "目標 %d　手数 %d/%d" % [left, pieces_placed, boss_piece_limit]
			else:
				lines_label.text = "目標まで %d" % left
		else:
			lines_label.text = "ライン %d" % lines
	if timer_label:
		if mode == Mode.ULTRA:
			timer_label.text = "のこり %s" % _fmt_time(int(maxf(0.0, ULTRA_SECONDS - elapsed) * 1000.0))
		elif mode == Mode.SPRINT or online_match:
			timer_label.text = "タイム %s" % _fmt_time(int(elapsed * 1000.0))
		else:
			timer_label.text = _mode_label(mode)
	if adventure_label:
		if _is_adventure():
			var sh := "　盾×%d" % shield_charges if shield_charges > 0 else ""
			var atk := ""
			if _pvp_attacks_enabled():
				atk = "\n攻撃チャージ×%d　／　%s" % [attack_charges, _attack_type_label(_current_attack_type())]
			if held_item != ITEM_NONE:
				adventure_label.text = "道具：%s（タップで使用）%s\n%s%s" % [_item_label(held_item), sh, _item_hint(held_item), atk]
			else:
				adventure_label.text = "道具：なし%s\n宝箱ラインを消して入手%s" % [sh, atk]
			adventure_label.visible = true
		else:
			adventure_label.text = ""
			adventure_label.visible = false
	if item_btn:
		item_btn.visible = _is_adventure() and screen == Screen.PLAY
	if attack_btn:
		attack_btn.visible = _pvp_attacks_enabled() and screen == Screen.PLAY
		if attack_btn.visible:
			_refresh_attack_btn()
	_refresh_rotate_btn()

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
		var n := name_edit.text.strip_edges() if name_edit else ""
		if n.is_empty():
			n = online.ensure_display_name()
			name_edit.text = n
		online.register_player(n)
	_save_settings()
	status_msg = "保存しました"
	_refresh_status()

func _on_host_start_match() -> void:
	_sfx("ui")
	if online == null:
		return
	if not is_host:
		status_msg = "ホストだけが開始できます"
		_refresh_status()
		return
	if room_status == "playing":
		status_msg = "試合進行中です。全員が終了してから再戦できます"
		_refresh_status()
		return
	online.start_room()

func _online_create(m: String) -> void:
	_sfx("ui")
	if online == null:
		status_msg = "オンライン機能を読み込めませんでした"
		_refresh_status()
		return
	# Always re-register first: Render free DB can wipe player ids on redeploy.
	last_online_create_mode = m
	pending_create_mode = m
	online_reregister_tries = 0
	status_msg = "接続中…（初回はサーバー起動に数十秒かかることがあります）"
	_refresh_status()
	var n := name_edit.text.strip_edges() if name_edit else ""
	online.register_player(n if n != "" else online.ensure_display_name())

func _online_join() -> void:
	_sfx("ui")
	if online == null:
		return
	var code := join_edit.text.strip_edges().to_upper()
	if code.is_empty():
		status_msg = "部屋コードを入力してください"
		_refresh_status()
		return
	pending_join_code = code
	status_msg = "接続中…（初回はサーバー起動に数十秒かかることがあります）"
	_refresh_status()
	online.register_player(online.ensure_display_name())

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

func _load_norotate_high() -> int:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return 0
	return int(cfg.get_value("scores", "norotate", 0))

func _save_norotate_high(value: int) -> void:
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_PATH)
	cfg.set_value("scores", "norotate", value)
	# Keep audio/theme keys if already present.
	cfg.set_value("audio", "sfx", sfx_on)
	cfg.set_value("audio", "music", music_on)
	cfg.set_value("game", "haptic", haptic_on)
	cfg.set_value("game", "theme", theme_idx)
	cfg.save(SETTINGS_PATH)

func _commit_run_high_score() -> void:
	if _is_no_rotate():
		if score > high_norotate:
			high_norotate = score
			_save_norotate_high(high_norotate)
	elif score > high_score:
		high_score = score
		_save_high_score(high_score)

func _refresh_rotate_btn() -> void:
	if rot_btn == null:
		return
	var playing := screen == Screen.PLAY
	if _is_no_rotate() and playing:
		# Keep the slot so pad layout stays stable; grey it out.
		rot_btn.visible = true
		rot_btn.disabled = false
		rot_btn.modulate = Color(0.55, 0.58, 0.65, 0.75)
		rot_btn.set_meta("primary", false)
		rot_btn.set_meta("warm", false)
		_apply_button_style(rot_btn, false)
	else:
		rot_btn.visible = playing
		rot_btn.modulate = Color.WHITE

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
	cfg.load(SETTINGS_PATH)
	cfg.set_value("audio", "sfx", sfx_on)
	cfg.set_value("audio", "music", music_on)
	cfg.set_value("game", "haptic", haptic_on)
	cfg.set_value("game", "theme", theme_idx)
	cfg.set_value("scores", "norotate", high_norotate)
	cfg.save(SETTINGS_PATH)
