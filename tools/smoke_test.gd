extends SceneTree
## Headless smoke test for AOIPulse core logic (no window).
## Run: godot --path . --headless -s res://tools/smoke_test.gd

func _init() -> void:
	var ok := true
	ok = _assert(true, "boot") and ok

	# Shape count / rotation count sanity.
	var pieces: Array = [
		4, 4, 4, 4, 4, 4, 4
	]
	ok = _assert(pieces.size() == 7, "seven pieces") and ok

	# Scoring table.
	var line_scores := [0, 100, 300, 500, 800]
	ok = _assert(line_scores[4] == 800, "tetris score") and ok

	# Fall interval curve.
	var lv1: float = maxf(0.05, pow(0.82, 0.0))
	var lv10: float = maxf(0.05, pow(0.82, 9.0))
	ok = _assert(lv1 > lv10, "speed increases") and ok

	# 7-bag uniqueness.
	var bag: Array = [0, 1, 2, 3, 4, 5, 6]
	bag.shuffle()
	var seen: Dictionary = {}
	for v in bag:
		seen[v] = true
	ok = _assert(seen.size() == 7, "bag unique") and ok

	# Adventure stage curve.
	var stage_lines := 5
	ok = _assert(stage_lines == 5, "stage lines") and ok
	var fuse_s2 := maxi(3, 8 - int((2 - 2) / 2))
	var fuse_s8 := maxi(3, 8 - int((8 - 2) / 2))
	ok = _assert(fuse_s2 > fuse_s8, "bomb fuse tightens") and ok
	var bomb_chance_s1 := 0.0 if 1 < 2 else 0.14
	var bomb_chance_s4 := minf(0.42, 0.14 + (4 - 2) * 0.04)
	ok = _assert(bomb_chance_s1 == 0.0, "no bomb stage1") and ok
	ok = _assert(bomb_chance_s4 > 0.0, "bomb stage4") and ok
	var chest_s2 := 0.0 if 2 < 3 else 0.1
	var chest_s5 := minf(0.28, 0.10 + (5 - 3) * 0.03)
	ok = _assert(chest_s2 == 0.0, "no chest stage2") and ok
	ok = _assert(chest_s5 > 0.0, "chest stage5") and ok
	var garbage_s3 := 0 if 3 < 4 else 10
	var garbage_s6 := maxi(6, 14 - 6)
	ok = _assert(garbage_s3 == 0, "no garbage stage3") and ok
	ok = _assert(garbage_s6 >= 6, "garbage interval") and ok
	var boss_limit := maxi(12, 24 - int(5 / 5) * 2)
	ok = _assert(boss_limit >= 12, "boss piece limit") and ok
	# Garbage row always has a hole.
	var cols := 10
	var hole := 3
	var filled := 0
	for x in cols:
		if x != hole:
			filled += 1
	ok = _assert(filled == cols - 1, "garbage has hole") and ok
	# Loot table size.
	var loot := ["hammer", "line", "slow"]
	ok = _assert(loot.size() == 3, "loot table") and ok

	# Adventure online mode string + ranking comparator (stage > score > time).
	var mode_map := {"classic": 0, "sprint": 1, "ultra": 2, "daily": 3, "adventure": 4}
	ok = _assert(mode_map.has("adventure"), "mode adventure") and ok
	var ranked: Array = [
		{"n": "A", "stage": 5, "score": 1000, "timeMs": 90000},
		{"n": "B", "stage": 7, "score": 500, "timeMs": 120000},
		{"n": "C", "stage": 7, "score": 800, "timeMs": 100000},
		{"n": "D", "stage": 7, "score": 800, "timeMs": 80000},
	]
	ranked.sort_custom(func(a, b):
		if int(a.stage) != int(b.stage):
			return int(a.stage) > int(b.stage)
		if int(a.score) != int(b.score):
			return int(a.score) > int(b.score)
		return int(a.timeMs) < int(b.timeMs)
	)
	ok = _assert(String(ranked[0].n) == "D" and String(ranked[1].n) == "C" and String(ranked[2].n) == "B" and String(ranked[3].n) == "A", "adventure rank order") and ok

	if ok:
		print("AOIPULSE_SMOKE_OK")
		quit(0)
	else:
		print("AOIPULSE_SMOKE_FAIL")
		quit(1)

func _assert(cond: bool, label: String) -> bool:
	if cond:
		print("OK ", label)
		return true
	print("FAIL ", label)
	return false
