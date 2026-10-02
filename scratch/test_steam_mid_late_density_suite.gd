extends Node

const CheckpointCutsceneLibraryScript = preload("res://scripts/cutscenes/CheckpointCutsceneLibrary.gd")

# ============================================================
# HUNTER ONLINE — Steam Mid/Late Density Suite
# ============================================================
# Kukuroo → Arena → Yorknew → GI → NGL → Assoc → CN → Black Whale
# Exclui: playtest humano G5 · sprites PixelLab novos
# ============================================================

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 STEAM MID/LATE DENSITY SUITE")
	print("================================================================================")
	await get_tree().process_frame
	_test_economy_catalog()
	_test_powerscale_align()
	_test_companion_and_checkpoint_scripts()
	await _test_map_density("Kukuroo", "res://world/maps/MontanhaKukurooMap.gd", {
		"always": ["BauKukuPortao", "CompanionChatter", "HatsuMomentKukuroo", "CkptKukuAlameda", "ZetsuAlamedaMike"],
		"nen_on": ["GyoPistaPortaoAura", "KoPedraAlameda", "BauKukuMansao"],
	})
	await _test_map_density("Arena", "res://world/maps/ArenaCelestialMap.gd", {
		"always": ["BauArenaDojo", "TrainingWingRespiro", "CompanionChatter", "HatsuMomentArena", "ZetsuBarreiraHisoka200"],
		"nen_on": ["GyoRingue100", "KoPoste200Andar", "CkptArenaWing"],
	})
	await _test_map_density("Yorknew", "res://world/maps/YorknewCityMap.gd", {
		"always": ["BauYorkAvenida", "CrowdYork_A", "CompanionChatter", "ZetsuBecoRuasNorte"],
		"nen_on": ["GyoPistaLeilaoAura", "KoCaixoteLeilao", "HatsuMomentYorknew", "CkptYorkAvenida"],
	})
	await _test_map_density("Greed", "res://world/maps/GreedIslandMap.gd", {
		"always": ["BauGreedAntokiba", "CompanionChatter", "ZetsuColinasAntokiba"],
		"nen_on": ["GyoDesfiladeiroBiscuit", "HatsuMomentGreed", "CkptGreedBiscuit"],
	})
	await _test_map_density("NGL", "res://world/maps/NGLFormigasMap.gd", {
		"always": ["BauNGLFronteira", "CompanionChatter"],
		"nen_on": ["GyoFabricaD2", "HatsuMomentNGL", "CkptNGLPalacio"],
	})
	await _test_map_density("BlackWhale", "res://world/maps/BlackWhale1Map.gd", {
		"always": ["BauBWConves", "CompanionChatter", "ZetsuCorredorConves3"],
		"nen_on": ["GyoPrimeiroAssassinato", "KoPortaCegada", "HatsuMomentBW", "GyoConves1"],
	})
	_test_tower_training_button()
	print("\n================================================================================")
	print("🏆 RESULTADO: %d / %d" % [_passed, _total])
	if not _failures.is_empty():
		for f in _failures:
			print("   ❌ ", f)
	print("================================================================================\n")
	get_tree().quit(0 if _passed == _total else 1)


func _ok(cond: bool, label: String) -> void:
	_total += 1
	if cond:
		_passed += 1
		print("  ✅ ", label)
	else:
		_failures.append(label)
		print("  ❌ ", label)


func _test_economy_catalog() -> void:
	print("\n[1] Economy mid/late (30–50 IDs, sem poção clássica)...")
	var n: int = Economy.ITEM_CATALOGO.size()
	_ok(n >= 30, "ITEM_CATALOGO >=30 (got %d)" % n)
	_ok(n <= 80, "ITEM_CATALOGO não explodiu (<=80, got %d)" % n)
	_ok(Economy.ITEM_CATALOGO.has("pedra_aura"), "pedra_aura presente")
	_ok(Economy.ITEM_CATALOGO.has("food_cha_erva"), "food_cha_erva presente")
	_ok(Economy.ITEM_CATALOGO.has("ticket_leilao"), "ticket_leilao mid")
	_ok(Economy.ITEM_CATALOGO.has("fragmento_sucessao"), "fragmento_sucessao late")
	_ok(not Economy.ITEM_CATALOGO.has("pocao_vida"), "sem pocao_vida clássica")
	_ok(not Economy.ITEM_CATALOGO.has("pocao_aura"), "sem pocao_aura clássica")


func _test_powerscale_align() -> void:
	print("\n[2] PowerScale ↔ ProgressionConfig cap 1000...")
	_ok(ProgressionConfig.MAX_LEVEL == 1000, "MAX_LEVEL 1000")
	_ok(PowerScale.obter_tier_por_nivel(50) == PowerScale.Tier.HUMANO, "lv50 HUMANO")
	_ok(PowerScale.obter_tier_por_nivel(150) == PowerScale.Tier.HUNTER_INICIANTE, "lv150 INICIANTE")
	_ok(PowerScale.obter_tier_por_nivel(950) == PowerScale.Tier.ENDGAME, "lv950 ENDGAME")
	var src := FileAccess.get_file_as_string("res://autoload/PowerScale.gd")
	_ok("901–1000" in src or "901-1000" in src or "lv 901" in src.to_lower() or "901–1000" in src, "comentários alinhados a 1000")


func _test_companion_and_checkpoint_scripts() -> void:
	print("\n[3] CompanionChatter + CheckpointCutsceneLibrary...")
	_ok(ResourceLoader.exists("res://scripts/story/CompanionChatter.gd"), "CompanionChatter.gd")
	_ok(ResourceLoader.exists("res://scripts/cutscenes/CheckpointCutsceneLibrary.gd"), "CheckpointCutsceneLibrary.gd")
	_ok(ResourceLoader.exists("res://world/components/exploration/MidLateDensityKit.gd"), "MidLateDensityKit.gd")
	var passos = CheckpointCutsceneLibraryScript.obter_passos(&"yorknew_avenida")
	_ok(passos.size() >= 5, "checkpoint yorknew tem passos")
	var passos_bw = CheckpointCutsceneLibraryScript.obter_passos(&"black_whale_conves")
	_ok(passos_bw.size() >= 5, "checkpoint black whale tem passos")


func _test_map_density(label: String, script_path: String, expect: Dictionary) -> void:
	print("\n[%s] densificação..." % label)
	var MapScript = load(script_path)
	_ok(MapScript != null, "%s carrega" % label)
	if MapScript == null:
		return

	PlayerData.despertou_nen = false
	var mapa_off = MapScript.new()
	mapa_off.name = "%sOff" % label
	add_child(mapa_off)
	await get_tree().process_frame
	await get_tree().process_frame
	for n in expect.get("always", []):
		_ok(mapa_off.get_node_or_null(str(n)) != null, "%s always: %s" % [label, n])
	mapa_off.queue_free()
	await get_tree().process_frame

	PlayerData.despertou_nen = true
	var mapa_on = MapScript.new()
	mapa_on.name = "%sOn" % label
	add_child(mapa_on)
	await get_tree().process_frame
	await get_tree().process_frame
	for n in expect.get("nen_on", []):
		_ok(mapa_on.get_node_or_null(str(n)) != null, "%s nen_on: %s" % [label, n])
	mapa_on.queue_free()
	await get_tree().process_frame


func _test_tower_training_button() -> void:
	print("\n[Tower] Training Wing respiro...")
	var src := FileAccess.get_file_as_string("res://ui/Arena/HeavensArenaTowerUI.gd")
	_ok("_on_training_wing_pressed" in src, "botão Training Wing na tower UI")
	var arena := FileAccess.get_file_as_string("res://world/maps/ArenaCelestialMap.gd")
	_ok("TrainingWingRespiro" in arena, "nó TrainingWingRespiro no mapa")
