extends SceneTree

var _ok := 0
var _fail := 0


func _initialize() -> void:
	print("🚀 SUÍTE ELITE + LOOT IDENTITY PACK")
	_check_kit_files()
	_check_equipment_fields()
	_check_loot_tables()
	_check_rarity_weight()
	_check_unique_and_sets()
	_check_elite_specs()
	_check_wiring()
	_check_tooltip()
	print("============================================================")
	print("✅ PASSED: %d | ❌ FAILED: %d" % [_ok, _fail])
	quit(0 if _fail == 0 else 1)


func _assert(c: bool, msg: String) -> void:
	if c:
		_ok += 1
		print("  ✓ ", msg)
	else:
		_fail += 1
		print("  ✗ ", msg)


func _read(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	return f.get_as_text() if f else ""


func _check_kit_files() -> void:
	print("-- Kits --")
	_assert(ResourceLoader.exists("res://scripts/systems/loot/LootIdentityKit.gd"), "LootIdentityKit existe")
	_assert(ResourceLoader.exists("res://scripts/systems/loot/EliteIdentityKit.gd"), "EliteIdentityKit existe")
	var loot := _read("res://scripts/systems/loot/LootIdentityKit.gd")
	var elite := _read("res://scripts/systems/loot/EliteIdentityKit.gd")
	_assert("class_name LootIdentityKit" in loot, "Loot class_name")
	_assert("class_name EliteIdentityKit" in elite, "Elite class_name")
	_assert("static func tabela_efetiva" in loot, "tabela_efetiva")
	_assert("static func jenny_multiplier" in loot, "jenny_multiplier")
	_assert("static func peso_raridade" in loot, "peso_raridade")
	_assert("static func registrar_itens_identidade" in loot, "registrar_itens_identidade")
	_assert("static func densify_saga" in elite, "elite densify_saga")
	_assert("static func criar_enemy_data" in elite, "criar_enemy_data")


func _check_equipment_fields() -> void:
	print("-- EquipmentData identity fields --")
	var src := _read("res://resource/item/EquipmentData.gd")
	_assert("efeito_unico_id" in src, "efeito_unico_id")
	_assert("efeito_unico_desc" in src, "efeito_unico_desc")
	_assert("set_id" in src, "set_id")
	_assert("set_peca_id" in src, "set_peca_id")


func _check_loot_tables() -> void:
	print("-- Loot tables --")
	var ids := [
		"candidato_exame", "lutador_arena", "mordomo_zoldyck", "mafioso_yorknew",
		"membro_trupe", "formiga_soldado", "formiga_lider", "guarda_real",
		"boss_meruem", "guarda_black_whale", "nen_beast_principe", "monstro_greed",
		"bomber_greed", "boss_razor", "criatura_pantanal", "boss_hisoka",
	]
	for eid in ids:
		var tabela: Array = LootIdentityKit.tabela_padrao_para(eid)
		_assert(tabela.size() >= 3, "tabela densa %s (%d)" % [eid, tabela.size()])
		for row in tabela:
			if typeof(row) != TYPE_DICTIONARY:
				continue
			_assert(float(row.get("chance", 0.0)) > 0.0, "%s chance>0" % eid)
			_assert(not String(row.get("item_id", "")).is_empty(), "%s item_id" % eid)

	var ed := EnemyData.new()
	ed.enemy_id = &"candidato_exame"
	ed.is_elite = true
	var elite_table: Array = LootIdentityKit.tabela_efetiva(ed)
	var normal: Array = LootIdentityKit.tabela_padrao_para("candidato_exame")
	_assert(elite_table.size() == normal.size(), "elite table same size")
	if not elite_table.is_empty() and not normal.is_empty():
		_assert(float(elite_table[0].get("chance", 0.0)) > float(normal[0].get("chance", 0.0)), "elite chance boost")
	var boosted: Array = LootIdentityKit.tabela_elite_de("formiga_soldado")
	_assert(boosted.size() >= 3, "tabela_elite_de formiga")


func _check_rarity_weight() -> void:
	print("-- Rarity weight --")
	_assert(is_equal_approx(LootIdentityKit.peso_raridade("Comum"), 1.0), "comum=1")
	_assert(LootIdentityKit.peso_raridade("Raro") > LootIdentityKit.peso_raridade("Comum"), "raro>comum")
	_assert(LootIdentityKit.peso_raridade("Épico") > LootIdentityKit.peso_raridade("Raro"), "epico>raro")
	_assert(LootIdentityKit.peso_raridade("Lendário") > LootIdentityKit.peso_raridade("Épico"), "lendario>epico")
	var boss := EnemyData.new()
	boss.is_boss = true
	var elite := EnemyData.new()
	elite.is_elite = true
	_assert(LootIdentityKit.jenny_multiplier(boss) > LootIdentityKit.jenny_multiplier(elite), "boss jenny > elite")
	_assert(LootIdentityKit.jenny_multiplier(elite) > 1.0, "elite jenny > 1")


func _check_unique_and_sets() -> void:
	print("-- Uniques / sets --")
	var effects: Dictionary = LootIdentityKit.catalogo_efeitos_unicos()
	_assert(effects.has("laminas_exame"), "unique laminas")
	_assert(effects.has("garras_quirmera"), "unique garras")
	_assert(effects.has("manto_palacio"), "unique manto")
	_assert(effects.has("escudo_torneio"), "unique escudo")
	var sets: Dictionary = LootIdentityKit.catalogo_sets()
	_assert(sets.has(LootIdentityKit.SET_CACADOR), "set cacador")
	_assert(sets.has(LootIdentityKit.SET_FORMIGA), "set formiga")
	_assert(sets.has(LootIdentityKit.SET_PALACIO), "set palacio")
	var bonus: Dictionary = LootIdentityKit.bonus_set_para_pecas(["set_cacador_botas", "set_cacador_peito"])
	_assert(int(bonus.get("bonus_forca", 0)) >= 4, "set 2/2 forca")
	_assert((bonus.get("sets_ativos", []) as Array).has(LootIdentityKit.SET_CACADOR), "set ativo")

	# Stub de registro (autoload pode não resolver como identifier no -s)
	var dm := _StubDataManager.new()
	LootIdentityKit.registrar_itens_identidade(dm)
	_assert(dm.items_registry.has(&"unique_laminas_exame"), "unique registrado")
	_assert(dm.items_registry.has(&"set_formiga_garras"), "set piece registrado")
	var u = dm.items_registry[&"unique_laminas_exame"]
	_assert(u is EquipmentData and not String(u.efeito_unico_id).is_empty(), "unique id preenchido")
	_assert(not String(u.trade_off_descricao).is_empty(), "trade_off unique")
	var s = dm.items_registry[&"set_cacador_peito"]
	_assert(s is EquipmentData and String(s.set_id) == LootIdentityKit.SET_CACADOR, "set_id peito")


func _check_elite_specs() -> void:
	print("-- Elite specs --")
	var total := 0
	for saga_id in range(1, 10):
		var list: Array = EliteIdentityKit.listar_elites(saga_id)
		_assert(list.size() >= 1, "saga %d tem elite(s)" % saga_id)
		total += list.size()
		for spec in list:
			var path := String(spec.get("base_tres", ""))
			_assert(ResourceLoader.exists(path), "base tres %s" % path.get_file())
			var data := EliteIdentityKit.criar_enemy_data(spec as Dictionary)
			_assert(data != null and data.is_elite, "elite data %s" % spec.get("id", "?"))
			_assert(data.max_health > 0 and data.strength > 0, "stats elite %s" % data.enemy_id)
			_assert(not data.drop_table.is_empty(), "drop elite %s" % data.enemy_id)
			_assert(not String(data.hatsu_name).is_empty(), "hatsu elite %s" % data.enemy_id)
	_assert(total >= 10, "pelo menos 10 elites nomeados (%d)" % total)

	var mapa := Node2D.new()
	mapa.name = "EliteTestMap"
	root.add_child(mapa)
	var spawned := EliteIdentityKit.densify_saga(mapa, 1, Vector2(100, 100))
	_assert(spawned >= 1, "spawn exame elites (%d)" % spawned)
	_assert(mapa.get_node_or_null("Elite_elite_hisoka_sombra") != null, "hisoka node")
	mapa.queue_free()


func _check_wiring() -> void:
	print("-- Wiring --")
	var enemy := _read("res://scripts/systems/EnemySystem/EnemySystem.gd")
	_assert("LootIdentityKit.tabela_efetiva" in enemy, "EnemySystem tabela_efetiva")
	_assert("LootIdentityKit.jenny_multiplier" in enemy, "EnemySystem jenny")
	_assert("LootIdentityKit.peso_raridade" in enemy, "EnemySystem peso_raridade")
	var dm := _read("res://autoload/DataManager.gd")
	_assert("LootIdentityKit.registrar_itens_identidade" in dm, "DataManager register")
	var saga := _read("res://world/components/SagaDistrictKit.gd")
	_assert("EliteIdentityKit.densify_saga" in saga, "SagaDistrictKit elite densify")
	var hubs := {
		1: "res://world/maps/ExameMaratonaMap.gd",
		2: "res://world/maps/MontanhaKukurooMap.gd",
		3: "res://world/maps/ArenaCelestialMap.gd",
		4: "res://world/maps/YorknewCityMap.gd",
		5: "res://world/maps/GreedIslandMap.gd",
		6: "res://world/maps/NGLFormigasMap.gd",
		7: "res://world/maps/AssociacaoHunterMap.gd",
		8: "res://world/maps/ContinenteNegroMap.gd",
		9: "res://world/maps/BlackWhale1Map.gd",
	}
	for arco in hubs.keys():
		var src := _read(String(hubs[arco]))
		_assert(("SagaDistrictKit.densify_saga(self, %d)" % int(arco)) in src, "hub saga %d densify" % int(arco))


func _check_tooltip() -> void:
	print("-- Tooltip rarity / unique --")
	var tip := _read("res://ui/common/ItemLoreTooltip.gd")
	_assert("épico" in tip or "epico" in tip, "tooltip epico")
	_assert("lendario" in tip or "lendário" in tip, "tooltip lendario")
	_assert("incomum" in tip, "tooltip incomum")
	_assert("efeito_unico_id" in tip, "tooltip unique")
	_assert("set_id" in tip, "tooltip set")


class _StubDataManager extends Node:
	var items_registry: Dictionary = {}
	var equipment_registry: Dictionary = {}

	func obter_item(id: Variant) -> Variant:
		return items_registry.get(id, null)
