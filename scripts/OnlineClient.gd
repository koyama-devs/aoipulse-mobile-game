extends Node
## HTTP client for AOIPulse online rooms + leaderboards.

signal request_ok(kind: String, data: Dictionary)
signal request_fail(kind: String, message: String)

const DEFAULT_URL := "https://aoipulse-server.onrender.com"
const CONFIG_PATH := "user://online_config.cfg"
const PROFILE_PATH := "user://profile.cfg"

var base_url: String = DEFAULT_URL
var player_id: String = ""
var player_name: String = ""
var player_xp: int = 0
var room_code: String = ""
var http: HTTPRequest

const NAME_CHARS := "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"

func _ready() -> void:
	http = HTTPRequest.new()
	http.timeout = 12.0
	add_child(http)
	http.request_completed.connect(_on_request_completed)
	_load_config()
	_load_profile()

func generate_default_name() -> String:
	# Short default so first launch needs no Settings visit.
	var s := "Player"
	for i in 4:
		s += NAME_CHARS[randi() % NAME_CHARS.length()]
	return s

func ensure_display_name() -> String:
	var n := player_name.strip_edges()
	if n.is_empty() or n == "プレイヤー" or n.begins_with("ゲスト"):
		player_name = generate_default_name()
		_save_profile()
	return player_name

func _shipped_base_url() -> String:
	# Packaged default so installs work without Settings setup.
	if FileAccess.file_exists("res://online_config.json"):
		var f := FileAccess.open("res://online_config.json", FileAccess.READ)
		if f:
			var parsed = JSON.parse_string(f.get_as_text())
			f.close()
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("base_url"):
				var u := String(parsed["base_url"]).rstrip("/")
				if not u.is_empty():
					return u
	return DEFAULT_URL

func _is_local_dev_url(url: String) -> bool:
	var u := url.to_lower()
	return u.contains("127.0.0.1") or u.contains("localhost") or u.contains("10.0.2.2")

func _load_config() -> void:
	var shipped := _shipped_base_url()
	base_url = shipped
	var cfg := ConfigFile.new()
	if cfg.load(CONFIG_PATH) != OK:
		return
	var saved := String(cfg.get_value("online", "base_url", "")).rstrip("/")
	# Keep a user override only when it is a real remote server.
	# Old local/dev URLs are ignored so fresh APKs use the shipped Render host.
	if saved != "" and not _is_local_dev_url(saved):
		base_url = saved
	elif _is_local_dev_url(saved):
		# Migrate leftover localhost from earlier builds.
		save_base_url(shipped)
func save_base_url(url: String) -> void:
	base_url = url.rstrip("/")
	var cfg := ConfigFile.new()
	cfg.set_value("online", "base_url", base_url)
	cfg.save(CONFIG_PATH)

func _load_profile() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PROFILE_PATH) != OK:
		player_name = generate_default_name()
		_save_profile()
		return
	player_id = String(cfg.get_value("profile", "player_id", ""))
	player_name = String(cfg.get_value("profile", "player_name", "")).strip_edges()
	player_xp = int(cfg.get_value("profile", "xp", 0))
	ensure_display_name()

func _save_profile() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("profile", "player_id", player_id)
	cfg.set_value("profile", "player_name", player_name)
	cfg.set_value("profile", "xp", player_xp)
	cfg.save(PROFILE_PATH)

var _pending_kind: String = ""

func _request(kind: String, method: int, path: String, body: Dictionary = {}) -> void:
	_pending_kind = kind
	var url := "%s%s" % [base_url, path]
	var headers := PackedStringArray(["Content-Type: application/json"])
	var payload := ""
	if method != HTTPClient.METHOD_GET:
		payload = JSON.stringify(body)
	var err := http.request(url, headers, method, payload)
	if err != OK:
		request_fail.emit(kind, "Could not start request (%d)" % err)

func register_player(display_name: String) -> void:
	player_name = display_name.strip_edges().substr(0, 16)
	if player_name.is_empty():
		player_name = ensure_display_name()
	_request("register", HTTPClient.METHOD_POST, "/api/player/register", {
		"name": player_name,
		"playerId": player_id,
	})

func create_room(mode: String) -> void:
	_request("create_room", HTTPClient.METHOD_POST, "/api/rooms", {
		"playerId": player_id,
		"mode": mode,
	})

func join_room(code: String) -> void:
	_request("join_room", HTTPClient.METHOD_POST, "/api/rooms/%s/join" % code.to_upper(), {
		"playerId": player_id,
	})

func set_ready(ready: bool) -> void:
	_request("ready", HTTPClient.METHOD_POST, "/api/rooms/%s/ready" % room_code, {
		"playerId": player_id,
		"ready": ready,
	})

func start_room() -> void:
	_request("start_room", HTTPClient.METHOD_POST, "/api/rooms/%s/start" % room_code, {
		"playerId": player_id,
	})

func poll_room() -> void:
	if room_code.is_empty():
		return
	_request("poll_room", HTTPClient.METHOD_GET, "/api/rooms/%s" % room_code)

func finish_room(score: int, lines: int, time_ms: int, stage: int = 1) -> void:
	_request("finish_room", HTTPClient.METHOD_POST, "/api/rooms/%s/finish" % room_code, {
		"playerId": player_id,
		"score": score,
		"lines": lines,
		"timeMs": time_ms,
		"stage": stage,
	})

func fetch_leaderboard(board: String) -> void:
	_request("leaderboard", HTTPClient.METHOD_GET, "/api/leaderboard/%s" % board)

func fetch_daily() -> void:
	_request("daily", HTTPClient.METHOD_GET, "/api/daily")

func submit_daily(score: int, lines: int, time_ms: int, seed: int) -> void:
	_request("daily_submit", HTTPClient.METHOD_POST, "/api/daily/submit", {
		"playerId": player_id,
		"score": score,
		"lines": lines,
		"timeMs": time_ms,
		"seed": seed,
	})

func health() -> void:
	_request("health", HTTPClient.METHOD_GET, "/api/health")

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var kind := _pending_kind
	_pending_kind = ""
	if result != HTTPRequest.RESULT_SUCCESS:
		request_fail.emit(kind, "Network error")
		return
	var text := body.get_string_from_utf8()
	var parsed = JSON.parse_string(text)
	if response_code >= 400:
		var msg := "HTTP %d" % response_code
		if typeof(parsed) == TYPE_DICTIONARY and parsed.has("error"):
			msg = String(parsed["error"])
		request_fail.emit(kind, msg)
		return
	if typeof(parsed) != TYPE_DICTIONARY:
		request_fail.emit(kind, "Bad server response")
		return
	var data: Dictionary = parsed
	match kind:
		"register":
			if data.has("player"):
				var p: Dictionary = data["player"]
				player_id = String(p.get("id", ""))
				player_name = String(p.get("name", player_name))
				player_xp = int(p.get("xp", player_xp))
				_save_profile()
		"create_room", "join_room", "ready", "start_room", "poll_room", "finish_room":
			if data.has("room"):
				var room: Dictionary = data["room"]
				room_code = String(room.get("code", room_code))
			if data.has("player"):
				var p2: Dictionary = data["player"]
				player_xp = int(p2.get("xp", player_xp))
				_save_profile()
		"daily_submit":
			if data.has("player"):
				var p3: Dictionary = data["player"]
				player_xp = int(p3.get("xp", player_xp))
				_save_profile()
	request_ok.emit(kind, data)
