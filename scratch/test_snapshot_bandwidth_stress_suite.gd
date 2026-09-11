extends Node2D

# ============================================================
# HUNTER ONLINE — SNAPSHOT BANDWIDTH STRESS REPORT
# ============================================================
# Gera relatório JSON com tamanhos full/AoI/delta e estimativa KB/s
# sob N peers + muitos inimigos (sem sockets reais).
# ============================================================

const ServerWorldCoordinatorScript = preload("res://scripts/network/ServerWorldCoordinator.gd")
const REPORT_PATH := "user://snapshot_bandwidth_stress_report.json"
const ARTIFACT_COPY := "/opt/cursor/artifacts/snapshot_bandwidth_stress_report.json"

var peer_counts: Array[int] = [2, 4, 8, 16]
var enemy_count: int = 80
var aoi_radius: float = 400.0
var send_hz: float = 10.0


func _ready() -> void:
	print("\n=== SNAPSHOT BANDWIDTH STRESS REPORT ===")
	var rows: Array = []
	for n in peer_counts:
		var row := _measure_scenario(int(n))
		rows.append(row)
		print("peers=%d full=%dB aoi=%dB aoi_c=%dB est=%.1fKB/s naive=%.1fKB/s save=%.1fx" % [
			row["peers"], row["full_bytes"], row["aoi_bytes"], row["aoi_comp_bytes"],
			row["est_kbps"], row["naive_kbps"], row["saving_factor"]
		])

	var report := {
		"generated_ms": Time.get_ticks_msec(),
		"enemy_count": enemy_count,
		"aoi_radius": aoi_radius,
		"send_hz": send_hz,
		"tick_rate": 20,
		"rows": rows
	}
	_write_report(report)
	print("Report written to %s" % REPORT_PATH)
	get_tree().quit(0)


func _measure_scenario(peers: int) -> Dictionary:
	var coord = ServerWorldCoordinatorScript.new(20)
	coord.interest_radius_default = aoi_radius
	coord.use_snapshot_delta = true
	coord.start_coordinator()

	for i in range(peers):
		var angle := TAU * float(i) / float(max(1, peers))
		var dist := 50.0 if i == 0 else 1100.0
		coord.register_player(i + 1, {
			"name": "P%d" % (i + 1),
			"attributes": {"vida": 100, "vida_max": 100}
		}, Vector2(cos(angle), sin(angle)) * dist)

	for e in range(enemy_count):
		var near: bool = e < int(enemy_count / 2)
		var pos := Vector2(float(e % 10) * 30.0, float(int(e / 10)) * 30.0)
		if not near:
			pos += Vector2(2500, 2500)
		coord.spawn_enemy(&"lobo_nen", "E%d" % e, pos, 70, 10, 5)

	var full_raw := var_to_bytes(coord.build_world_snapshot())
	var aoi := coord.build_interest_snapshot(1, aoi_radius, true)
	var aoi_raw := var_to_bytes(aoi)
	var aoi_comp := aoi_raw.compress(FileAccess.COMPRESSION_DEFLATE)
	var delta := coord.build_interest_snapshot(1, aoi_radius, false)
	var delta_raw := var_to_bytes(delta)

	var est_bps: int = aoi_comp.size() * peers * int(send_hz)
	var naive_bps: int = full_raw.size() * peers * 20
	var saving: float = float(naive_bps) / max(1.0, float(est_bps))

	coord.stop_coordinator()
	return {
		"peers": peers,
		"full_bytes": full_raw.size(),
		"aoi_bytes": aoi_raw.size(),
		"aoi_comp_bytes": aoi_comp.size(),
		"delta_empty_bytes": delta_raw.size(),
		"aoi_enemies": (aoi.get("enemies", []) as Array).size(),
		"aoi_players": (aoi.get("players", []) as Array).size(),
		"est_bytes_per_sec": est_bps,
		"naive_bytes_per_sec": naive_bps,
		"est_kbps": float(est_bps) / 1024.0,
		"naive_kbps": float(naive_bps) / 1024.0,
		"saving_factor": saving
	}


func _write_report(report: Dictionary) -> void:
	var text := JSON.stringify(report, "\t")
	var fa := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if fa:
		fa.store_string(text)
		fa.close()
	# Cópia para artefato do agent (best-effort)
	var fa2 := FileAccess.open(ARTIFACT_COPY, FileAccess.WRITE)
	if fa2:
		fa2.store_string(text)
		fa2.close()
