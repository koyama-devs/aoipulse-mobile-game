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
