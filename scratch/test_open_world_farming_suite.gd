extends Node

# ============================================================
# HUNTER ONLINE — Open World Farming (Padokia zones)
# godot --headless --path . res://scratch/test_open_world_farming_suite.tscn
# ============================================================

const FarmZoneCatalogScript = preload("res://resource/world/FarmZoneCatalog.gd")
const FarmZoneDirectorScript = preload("res://world/content/FarmZoneDirector.gd")
const ConsumableBuffCatalogScript = preload("res://resource/item/ConsumableBuffCatalog.gd")
const RegionContentConfigScript = preload("res://world/content/RegionContentConfig.gd")

var _pass := 0
var _fail := 0
var _failures: PackedStringArray = []


func assert_test(cond: bool, msg: String) -> void:
	if cond:
		_pass += 1
		print("  PASS: ", msg)
	else:
		_fail += 1
		_failures.append(msg)
		print("  FAIL: ", msg)


func _ready() -> void:
	print("\n=== test_open_world_farming_suite ===")
	_test_catalog()
	_test_buff_catalog_and_use()
	_test_region_content_ids()
	await _test_director_spawn_levels_and_hatsu()
	await _test_farm_zone_loot_path()
	await _test_maps_have_director()
	print("=== RESULT: %d pass, %d fail ===" % [_pass, _fail])
	if not _failures.is_empty():
		for f in _failures:
			print("   ❌ ", f)
	# Limpa filhos antes do quit para evitar crash de teardown em mapas densos
	for c in get_children():
		c.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout
	get_tree().quit(0 if _fail == 0 else 1)


func _test_catalog() -> void:
	print("-- catalog --")
	var zones: Array = FarmZoneCatalogScript.obter_todas()
	assert_test(zones.size() == 3, "3 farm zones Padokia")
	var e = FarmZoneCatalogScript.criar_zona_estrada()
	var f = FarmZoneCatalogScript.criar_zona_floresta()
	var r = FarmZoneCatalogScript.criar_zona_ruinas()
	assert_test(e.level_min == 1 and e.level_max == 30, "Estrada L1–30")
	assert_test(f.level_min == 25 and f.level_max == 50, "Floresta L25–50")
	assert_test(r.level_min == 45 and r.level_max == 70, "Ruínas L45–70")
	assert_test(not e.enemy_pool.is_empty() and not e.buff_drop_table.is_empty(), "Estrada pool+buffs")
	assert_test(not f.enemy_pool.is_empty() and not f.buff_drop_table.is_empty(), "Floresta pool+buffs")
	assert_test(not r.enemy_pool.is_empty() and not r.buff_drop_table.is_empty(), "Ruínas pool+buffs")
	assert_test(FarmZoneCatalogScript.obter_por_id(FarmZoneCatalogScript.ZONE_ESTRADA) != null, "lookup por id")
	assert_test(
		FarmZoneCatalogScript.obter_para_mapa("res://world/maps/estrada_padokia.tscn") != null,
		"lookup por mapa estrada"
	)
	# Pools reusam bestiário / história
	var ids_e: PackedStringArray = []
	for entry in e.enemy_pool:
		ids_e.append(str(entry.get("enemy_id", "")))
	assert_test("candidato_exame" in ids_e and "iniciado_nen_sombrio" in ids_e, "Estrada reusa história + hatsu elite")
	var ids_r: PackedStringArray = []
	for entry in r.enemy_pool:
		ids_r.append(str(entry.get("enemy_id", "")))
	assert_test("mafioso_yorknew" in ids_r and "membro_trupe" in ids_r, "Ruínas reusa fillers Yorknew/Trupe")


func _test_buff_catalog_and_use() -> void:
	print("-- buff consumable --")
	assert_test(ConsumableBuffCatalogScript.eh_buff_consumivel("tonico_forca"), "tonico_forca registrado")
	assert_test(ConsumableBuffCatalogScript.eh_buff_consumivel("oleo_ken"), "oleo_ken registrado")
	assert_test(ConsumableBuffCatalogScript.eh_buff_consumivel("ampola_aura"), "ampola_aura registrado")
	assert_test(ConsumableBuffCatalogScript.eh_buff_consumivel("elixir_cacador"), "elixir_cacador registrado")
	if DataManager != null:
		ConsumableBuffCatalogScript.registrar_em_data_manager()
		assert_test(DataManager.get_item(&"tonico_forca") != null, "DataManager tem tonico_forca")
	if PlayerData == null:
		assert_test(false, "PlayerData disponível")
		return
	PlayerData.adicionar_item(&"tonico_forca", 2)
	var before_qtd: int = PlayerData.obter_item_quantidade(&"tonico_forca")
	var forca_antes: float = float(PlayerData.obter_stat_calculado("forca"))
	var res: Dictionary = PlayerData.usar_item_consumivel(&"tonico_forca")
	assert_test(bool(res.get("ok", false)), "usar_item_consumivel ok")
	assert_test(PlayerData.obter_item_quantidade(&"tonico_forca") == before_qtd - 1, "consome 1 do inventário")
	var has_mod := false
	for m in PlayerData.active_modifiers:
		if m != null and str(m.source) == "farm_buff" and str(m.stat_name) == "forca":
			has_mod = true
			assert_test(float(m.duration) > 0.0, "modificador com duração > 0")
			break
	assert_test(has_mod, "StatModifier farm_buff aplicado")
	var forca_depois: float = float(PlayerData.obter_stat_calculado("forca"))
	assert_test(forca_depois >= forca_antes + 7.0, "força aumentou com tônico")
	# Tick de expiração: força duration baixo e processa
	for m2 in PlayerData.active_modifiers:
		if m2 != null and str(m2.source) == "farm_buff":
			m2.duration = 0.01
	PlayerData._tick_modificadores_temporarios(0.02)
	var still := false
	for m3 in PlayerData.active_modifiers:
		if m3 != null and str(m3.source) == "farm_buff":
			still = true
	assert_test(not still, "tick remove buff expirado")


func _test_region_content_ids() -> void:
	print("-- RegionContentConfig real ids --")
	var cfg = RegionContentConfigScript.create_default()
	var low = cfg.zone_profiles[RegionContentConfigScript.ZoneRisk.LOW_RISK]["allowed_pve"]
	var med = cfg.zone_profiles[RegionContentConfigScript.ZoneRisk.MEDIUM_RISK]["allowed_pve"]
	var high = cfg.zone_profiles[RegionContentConfigScript.ZoneRisk.HIGH_RISK]["allowed_pve"]
	assert_test("slime" in low and "ladrao_estrada" in low, "LOW_RISK ids reais")
	assert_test("fera_floresta" in med and "small_beast" not in med, "MEDIUM sem ids genéricos")
	assert_test("guardiao_elite" in high and "ruins_guardian" not in high, "HIGH sem ids genéricos")
	assert_test("forest_beast" not in med and "wolf" not in med, "sem placeholders antigos")


func _test_director_spawn_levels_and_hatsu() -> void:
	print("-- FarmZoneDirector spawn --")
	var host := Node2D.new()
	host.name = "FarmHost"
	add_child(host)
	var zone = FarmZoneCatalogScript.criar_zona_estrada()
	zone.max_alive = 5
	zone.respawn_delay = 99.0
	var director = FarmZoneDirectorScript.anexar_ao_mapa(host, zone)
	assert_test(director != null, "director anexado")
	await get_tree().process_frame
	await get_tree().process_frame
	var vivos: Array = director.obter_vivos()
	assert_test(vivos.size() > 0, "spawna população inicial (%d)" % vivos.size())
	assert_test(vivos.size() <= zone.max_alive, "respeita max_alive")
	var levels_ok := true
	var elite_hatsu := false
	for e in vivos:
		if e == null or not is_instance_valid(e):
			continue
		var es = e.get_node_or_null("EnemySystem")
		if es == null:
			levels_ok = false
			continue
		assert_test(str(es.farm_zone_id) == str(zone.zone_id), "farm_zone_id marcado")
		var lv: int = int(es.enemy_data.level) if es.enemy_data != null else -1
		if lv < zone.level_min or lv > zone.level_max:
			levels_ok = false
		if es.enemy_data != null and (es.enemy_data.is_elite or int(es.enemy_data.npc_tier) >= 2):
			if not str(es.enemy_data.hatsu_name).is_empty() or es.enemy_data.modular_hatsu != null:
				elite_hatsu = true
	assert_test(levels_ok, "níveis dentro da faixa da zona")
	# Força um elite com hatsu
	var forced = director._montar_enemy_data(&"iniciado_nen_sombrio", 20, true, true)
	assert_test(forced != null, "montar iniciado_nen_sombrio")
	if forced != null:
		assert_test(forced.level == 20, "escalonado para level 20")
		assert_test(forced.is_elite or int(forced.npc_tier) >= 2, "elite/tier2")
		assert_test(not forced.hatsu_name.is_empty() or forced.modular_hatsu != null, "elite com hatsu")
		elite_hatsu = elite_hatsu or (not forced.hatsu_name.is_empty())
	assert_test(elite_hatsu, "há caminho de elite com Hatsu")
	# Cap: não passa de max_alive
	for _i in range(10):
		director.spawn_um()
	assert_test(director.contar_vivos() <= zone.max_alive, "cap após spawns extras")
	director.queue_free()
	host.queue_free()
	await get_tree().process_frame


func _test_farm_zone_loot_path() -> void:
	print("-- farm buff loot path --")
	var src := FileAccess.get_file_as_string("res://scripts/systems/EnemySystem/EnemySystem.gd")
	assert_test("_gerar_buff_drop_farm_zone" in src, "EnemySystem tem drop de buff de zona")
	assert_test("farm_zone_id" in src, "EnemySystem carrega farm_zone_id")
	var anti := FarmZoneDirectorScript.fator_anti_farm_drop(100, 1)
	assert_test(anti <= 0.01, "anti-farm zera drop muito abaixo")
	var fair := FarmZoneDirectorScript.fator_anti_farm_drop(10, 8)
	assert_test(fair >= 0.99, "anti-farm 100% em faixa justa")


func _test_maps_have_director() -> void:
	print("-- maps smoke FarmZoneDirector --")
	var maps := [
		"res://world/maps/estrada_padokia.tscn",
		"res://world/maps/floresta_vestigios.tscn",
		"res://world/maps/dungeon_ruinas_zaban.tscn",
	]
	for path in maps:
		var scn: PackedScene = load(path) as PackedScene
		assert_test(scn != null, "load %s" % path.get_file())
		if scn == null:
			continue
		var node: Node = scn.instantiate()
		add_child(node)
		await get_tree().process_frame
		await get_tree().process_frame
		var director = node.get_node_or_null("FarmZoneDirector")
		assert_test(director != null, "FarmZoneDirector em %s" % path.get_file())
		if director != null and director.has_method("contar_vivos"):
			assert_test(director.contar_vivos() >= 0, "director vivo em %s" % path.get_file())
		node.queue_free()
		await get_tree().process_frame
