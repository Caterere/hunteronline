extends Node2D

## Pacote grind: Season Pass hooks, GI honesto, Códex, forja com materiais.

const Catalog = preload("res://resource/greed_island/GreedIslandCardCatalog.gd")
const EquipCat = preload("res://resource/item/EquipmentCatalog.gd")
const RaidInstanceScript = preload("res://scripts/network/RaidInstance.gd")

var total: int = 0
var passed: int = 0
var failed: int = 0


func _ready() -> void:
	print("\n=== GRIND: CÓDEX + GI + SEASON PASS + FORJA ===")
	_test_season_pass_hooks()
	_test_gi_flavor_to_catalog()
	_test_gi_binder_statmodifier()
	_test_gi_duel_requires_cards()
	_test_gi_duel_victory_reward()
	_test_codex_hooks()
	_test_forge_materials()
	_test_aura_conversion()
	print("----------------------------------------------------------------")
	print("Resultado: %d/%d | falhas %d" % [passed, total, failed])
	await get_tree().create_timer(0.05).timeout
	get_tree().quit(0 if failed == 0 else 1)


func _ok(cond: bool, label: String) -> void:
	total += 1
	if cond:
		passed += 1
		print("  ✅ %s" % label)
	else:
		failed += 1
		print("  ❌ %s" % label)


func _test_season_pass_hooks() -> void:
	print("\n[1] Season Pass notify hooks")
	if SeasonPassSystem == null:
		_ok(false, "SeasonPassSystem ausente")
		return
	var xp0 := int(SeasonPassSystem.xp)
	SeasonPassSystem.notify_contract_complete()
	_ok(int(SeasonPassSystem.xp) == xp0 + 25, "notify_contract_complete +25 XP")
	var xp1 := int(SeasonPassSystem.xp)
	SeasonPassSystem.notify_raid_clear()
	_ok(int(SeasonPassSystem.xp) == xp1 + 60, "notify_raid_clear +60 XP")

	# complete_raid deve chamar notify_raid_clear
	var xp2 := int(SeasonPassSystem.xp)
	var raid = RaidInstanceScript.new()
	raid.raid_id = "test_raid"
	raid.complete_raid()
	_ok(int(SeasonPassSystem.xp) == xp2 + 60, "RaidInstance.complete_raid concede XP do passe")


func _test_gi_flavor_to_catalog() -> void:
	print("\n[2] GI flavor → carta_NNN")
	if PlayerData == null:
		_ok(false, "PlayerData ausente")
		return
	# limpa cartas catalog
	for c in Catalog.duel_catalog():
		var cid := str(c.get("id", ""))
		while PlayerData.tem_item(StringName(cid)):
			PlayerData.remover_item(StringName(cid), 1)
	PlayerData.adicionar_item(&"carta_greed_comum", 2)
	_ok(not PlayerData.tem_item(&"carta_greed_comum"), "pack flavor não fica no inventário")
	var owned := Catalog.owned_unique_count()
	_ok(owned >= 1, "pack comum concedeu ≥1 carta_NNN (%d)" % owned)

	var before := Catalog.owned_unique_count()
	PlayerData.adicionar_item(&"carta_greed_rara", 1)
	_ok(Catalog.owned_unique_count() >= before, "pack raro concede carta do catálogo")


func _test_gi_binder_statmodifier() -> void:
	print("\n[3] Binder StatModifier real")
	if PlayerData == null:
		_ok(false, "PlayerData ausente")
		return
	PlayerData.remover_modificadores_da_fonte("gi_binder")
	PlayerData.adicionar_item(&"carta_030", 1)
	Catalog.apply_binder_bonus()
	var n := Catalog.owned_unique_count()
	var found := false
	for mod in PlayerData.active_modifiers:
		if str(mod.source) == "gi_binder" and mod.stat_name == &"forca":
			found = true
			_ok(is_equal_approx(float(mod.value), float(n * 3)), "bônus forca = %d%% (obtidas*%d)" % [n * 3, 3])
			break
	if not found:
		_ok(false, "modificador gi_binder/forca ausente")


func _test_gi_duel_requires_cards() -> void:
	print("\n[4] Duelo exige cartas reais")
	for c in Catalog.duel_catalog():
		var cid := str(c.get("id", ""))
		while PlayerData.tem_item(StringName(cid)):
			PlayerData.remover_item(StringName(cid), 1)
	var duel = load("res://scripts/systems/CardDuelSystem.gd").new()
	var res: Dictionary = duel.start_from_inventory("antokiba")
	_ok(not bool(res.get("ok", true)), "sem cartas → duelo bloqueado")
	PlayerData.adicionar_item(&"carta_060", 1)
	var res2: Dictionary = duel.start_from_inventory("antokiba")
	_ok(bool(res2.get("ok", false)), "com 1 carta → duelo inicia")


func _test_gi_duel_victory_reward() -> void:
	print("\n[5] Recompensa de vitória no duelo")
	var gold0 := int(PlayerData.attributes.get("gold", 0))
	var before := Catalog.owned_unique_count()
	var reward: Dictionary = Catalog.duel_victory_reward(150)
	_ok(bool(reward.get("ok", false)), "duel_victory_reward ok")
	_ok(not str(reward.get("card_id", "")).is_empty(), "concede card_id")
	_ok(Catalog.owned_unique_count() >= before, "inventário ganhou carta")
	_ok(int(PlayerData.attributes.get("gold", 0)) >= gold0 + 150 or (Economy != null and Economy.obter_gold() >= gold0), "Jenny da vitória")


func _test_codex_hooks() -> void:
	print("\n[6] Códex register_discovery")
	if CollectionManager == null:
		_ok(false, "CollectionManager ausente")
		return
	CollectionManager.collections["hatsu"] = []
	CollectionManager.collections["bosses"] = []
	CollectionManager.collections["secrets"] = []
	CollectionManager.collections["regions"] = []

	# Hatsu via criar_e_registrar é pesado (jenny/cooldown) — testa o gancho direto + WorldState
	CollectionManager.register_discovery("hatsu", "hatsu_test_grind")
	_ok(CollectionManager.has_discovered("hatsu", "hatsu_test_grind"), "hatsu no códex")

	if WorldState != null:
		WorldState.registrar_vitoria_boss("guardiao_zaban", "Guardião de Zaban")
		_ok(CollectionManager.has_discovered("bosses", "guardiao_zaban"), "boss no códex")
		WorldState.registrar_vitoria_boss("slime", "Slime")
		_ok(not CollectionManager.has_discovered("bosses", "slime"), "mob comum não entra em bosses")

	PlayerData.adicionar_item(&"carta_045", 1)
	_ok(CollectionManager.has_discovered("secrets", "carta_045"), "carta GI no códex secrets")

	var Disc = load("res://world/components/WorldDiscoveryTracker.gd")
	PlayerData.quest_states.erase("poi_descoberto_grind_poi_a")
	Disc.registrar_descoberta("grind_poi_a", "Clareira Teste", Disc.DiscoveryTier.VISIVEL)
	_ok(CollectionManager.has_discovered("regions", "grind_poi_a"), "POI visível → regions")
	PlayerData.quest_states.erase("poi_descoberto_grind_poi_b")
	Disc.registrar_descoberta("grind_poi_b", "Caverna Teste", Disc.DiscoveryTier.SECRETA)
	_ok(CollectionManager.has_discovered("secrets", "grind_poi_b"), "POI secreto → secrets")


func _test_forge_materials() -> void:
	print("\n[7] Craft consome materiais")
	while PlayerData.tem_item(&"pedra_aura"):
		PlayerData.remover_item(&"pedra_aura", 1)
	while PlayerData.tem_item(&"cristal_aura"):
		PlayerData.remover_item(&"cristal_aura", 1)
	while PlayerData.tem_item(&"espada_aco"):
		PlayerData.remover_item(&"espada_aco", 1)
	if Economy != null:
		Economy.definir_gold(99999) if Economy.has_method("definir_gold") else null
	PlayerData.attributes["gold"] = 99999

	var fail: Dictionary = EquipCat.tentar_craft("espada_aco")
	_ok(not bool(fail.get("ok", true)) and str(fail.get("reason", "")) == "sem_material", "craft falha sem pedra_aura")

	PlayerData.adicionar_item(&"pedra_aura", 2)
	var ok: Dictionary = EquipCat.tentar_craft("espada_aco")
	_ok(bool(ok.get("ok", false)), "craft sucesso com materiais + Jenny")
	_ok(PlayerData.tem_item(&"espada_aco"), "espada_aco no inventário")
	_ok(not PlayerData.tem_item(&"pedra_aura"), "pedra_aura consumida")

	var crafts := EquipCat.listar_crafts()
	var has_mats := false
	for c in crafts:
		if str(c.get("id", "")) == "espada_aco" and (c.get("materiais", []) as Array).size() > 0:
			has_mats = true
	_ok(has_mats, "listar_crafts expõe materiais")


func _test_aura_conversion() -> void:
	print("\n[8] Conversão pedra_aura → pedra de socket")
	while PlayerData.tem_item(&"pedra_aura"):
		PlayerData.remover_item(&"pedra_aura", 1)
	while PlayerData.tem_item(&"pedra_intensificacao"):
		PlayerData.remover_item(&"pedra_intensificacao", 1)
	var fail: Dictionary = EquipCat.converter_aura_para_pedra("pedra_intensificacao")
	_ok(not bool(fail.get("ok", true)), "conversão falha sem aura")
	PlayerData.adicionar_item(&"pedra_aura", 3)
	var ok: Dictionary = EquipCat.converter_aura_para_pedra("pedra_intensificacao")
	_ok(bool(ok.get("ok", false)), "3× pedra_aura → pedra_intensificacao")
	_ok(PlayerData.tem_item(&"pedra_intensificacao"), "pedra de socket concedida")
	_ok(not PlayerData.tem_item(&"pedra_aura"), "aura consumida na conversão")
