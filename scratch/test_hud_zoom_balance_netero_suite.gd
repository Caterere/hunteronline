extends Node

## HUD scale, camera zoom, early damage curve, Netero→dirigível teleport wiring
var _ok := 0
var _fail := 0


func _ready() -> void:
	print("=== HUD / ZOOM / BALANCE / NETERO DIRIGÍVEL ===")
	_test_hud_scale()
	_test_zoom()
	_test_balance()
	await _test_netero_dirigivel()
	print("----------------------------------------------------------------")
	print("Resultado: %d/%d | falhas %d" % [_ok, _ok + _fail, _fail])
	await get_tree().process_frame
	get_tree().quit(0 if _fail == 0 else 1)


func _assert(c: bool, msg: String) -> void:
	if c:
		_ok += 1
		print("  ✅ ", msg)
	else:
		_fail += 1
		print("  ❌ ", msg)


func _test_hud_scale() -> void:
	var hud := FileAccess.get_file_as_string("res://ui/hud/PlayerHUD.gd")
	_assert("HUD_SCALE: float = 1.0" in hud, "PlayerHUD HUD_SCALE 1.0")
	var q := FileAccess.get_file_as_string("res://ui/hud/QuestHUD.gd")
	_assert("scale = Vector2(1.0, 1.0)" in q, "QuestHUD 1.0")
	var g := FileAccess.get_file_as_string("res://ui/hud/MissionGPSIndicator.gd")
	_assert("scale = Vector2(1.0, 1.0)" in g, "GPS 1.0")
	var n := FileAccess.get_file_as_string("res://ui/hud/NenQuickActionBar.gd")
	_assert("scale = Vector2(1.0, 1.0)" in n, "Nen bar 1.0 (alinhada)")
	var style := FileAccess.get_file_as_string("res://ui/theme/HunterUIStyle.gd")
	_assert("0.42" in style, "glass alpha mais transparente")


func _test_zoom() -> void:
	var src := FileAccess.get_file_as_string("res://entities/Player/Player.gd")
	_assert("definir_zoom_camera" in src, "Player.definir_zoom_camera")
	_assert("2.25" in src, "zoom default 2.25")
	var tscn := FileAccess.get_file_as_string("res://entities/Player/Player.tscn")
	_assert("Vector2(2.25, 2.25)" in tscn, "Player.tscn Camera2D zoom 2.25")


func _test_balance() -> void:
	# Flat damage baixo + força — early não melt
	var ce := FileAccess.get_file_as_string("res://autoload/CombatEngine.gd")
	_assert("var dano_base: float = 4.0" in ce, "CombatEngine dano_base 4")
	var cs := FileAccess.get_file_as_string("res://scripts/combat/CombatSystem.gd")
	_assert("ataque_dano_base: int = 4" in cs, "CombatSystem ataque_dano_base 4")
	# Lv1: flat 4 + forca 5 → ~9 vs defesa 0 (antes flat 10 meltava)
	var dmg := CombatEngine.calcular_dano({"forca": 5.0, "dano_base": 4.0}, {"defesa": 0.0})
	_assert(dmg >= 7 and dmg <= 12, "dano early flat+forca na faixa ~9 (got %d)" % dmg)
	var dmg_old_style := 10 + 5
	_assert(dmg < dmg_old_style, "novo escalonamento < antigo flat10+forca5")
	var forca := float(PlayerData.attributes.get("forca", 5))
	var cand := load("res://resource/status/CandidatoSabotador.tres")
	_assert(cand != null and int(cand.max_health) >= 110, "Candidato HP buffado (%d)" % int(cand.max_health))
	var macaco := load("res://resource/status/MacacoPantanal.tres")
	_assert(macaco != null and int(macaco.max_health) >= 140, "Macaco HP buffado (%d)" % int(macaco.max_health))
	var pig := load("res://resource/status/GreatStampPig.tres")
	_assert(pig != null and int(pig.max_health) >= 220, "Stamp HP buffado (%d)" % int(pig.max_health))
	var dm := FileAccess.get_file_as_string("res://autoload/DataManager.gd")
	_assert('"hp": 130' in dm, "slime early HP 130")
	_assert(forca <= 8.0, "player early forca ainda baixa (escala por flat)")


func _test_netero_dirigivel() -> void:
	_assert(ResourceLoader.exists("res://world/maps/dirigivel_hunter.tscn"), "cena dirigivel_hunter")
	_assert(ResourceLoader.exists("res://world/maps/DirigivelHunterMap.gd"), "script DirigivelHunterMap")
	var netero := FileAccess.get_file_as_string("res://entities/npc/netero/Netero.gd")
	_assert("_teleportar_para_dirigivel" in netero, "Netero teleporta ao deck")
	_assert("dialogo_concluido.connect" in netero, "teleporte após diálogo")
	_assert("dirigivel_hunter.tscn" in netero, "path do mapa do dirigível")
	var exame := FileAccess.get_file_as_string("res://world/maps/ExameMaratonaMap.gd")
	_assert("SpawnFromDirigivel" in exame, "spawn retorno Trick Tower")
	var st := FileAccess.get_file_as_string("res://autoload/SceneTransition.gd")
	_assert("dirigivel_hunter.tscn" in st, "banner SceneTransition")
	var gps := FileAccess.get_file_as_string("res://scripts/missions/MissionObjectiveResolver.gd")
	_assert("dirigivel_hunter.tscn" in gps, "GPS etapas 14–15 → dirigível")
	# Instantiar mapa smoke
	var packed: PackedScene = load("res://world/maps/dirigivel_hunter.tscn")
	_assert(packed != null, "PackedScene dirigível carrega")
	if packed != null:
		var map: Node = packed.instantiate()
		add_child(map)
		await get_tree().process_frame
		_assert(map.get_node_or_null("Netero") != null, "Netero plantado no deck")
		_assert(map.get_node_or_null("PortalTrickTower") != null, "portal Trick Tower")
		map.queue_free()
