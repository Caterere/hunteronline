extends Node2D

## Smoke de integração: grind + enemy Nen + FX procedural no mesmo boot.

const KitEnemy = preload("res://scripts/systems/EnemySystem/EnemyNenKit.gd")
const KitFx = preload("res://entities/effects/HatsuProceduralFxKit.gd")
const Catalog = preload("res://resource/greed_island/GreedIslandCardCatalog.gd")
const EquipCat = preload("res://resource/item/EquipmentCatalog.gd")
const RaidInstanceScript = preload("res://scripts/network/RaidInstance.gd")

var total: int = 0
var passed: int = 0
var failed: int = 0


func _ready() -> void:
	print("\n=== PACKAGE INTEGRATION SMOKE ===")
	_test_autoload_hooks()
	_test_gi_and_forge()
	_test_enemy_and_fx()
	_test_hatsu_damage_tags()
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


func _test_autoload_hooks() -> void:
	print("\n[1] Autoloads / SeasonPass / Códex")
	_ok(SeasonPassSystem != null, "SeasonPassSystem")
	_ok(CollectionManager != null, "CollectionManager")
	_ok(DataManager != null, "DataManager")
	_ok(PlayerData != null, "PlayerData")
	if SeasonPassSystem != null:
		var xp0 := int(SeasonPassSystem.xp)
		SeasonPassSystem.notify_contract_complete()
		_ok(int(SeasonPassSystem.xp) == xp0 + 25, "contract XP")
		var raid = RaidInstanceScript.new()
		raid.raid_id = "smoke"
		var xp1 := int(SeasonPassSystem.xp)
		raid.complete_raid()
		_ok(int(SeasonPassSystem.xp) == xp1 + 60, "raid clear XP")
	CollectionManager.register_discovery("secrets", "smoke_secret_fx")
	_ok(CollectionManager.has_discovered("secrets", "smoke_secret_fx"), "codex discovery")


func _test_gi_and_forge() -> void:
	print("\n[2] GI + forja")
	for c in Catalog.duel_catalog():
		var cid := str(c.get("id", ""))
		while PlayerData.tem_item(StringName(cid)):
			PlayerData.remover_item(StringName(cid), 1)
	PlayerData.adicionar_item(&"carta_greed_comum", 1)
	_ok(Catalog.owned_unique_count() >= 1, "flavor → carta real")
	Catalog.apply_binder_bonus()
	var has_mod := false
	for mod in PlayerData.active_modifiers:
		if str(mod.source) == "gi_binder":
			has_mod = true
			break
	_ok(has_mod, "binder StatModifier")

	while PlayerData.tem_item(&"pedra_aura"):
		PlayerData.remover_item(&"pedra_aura", 1)
	PlayerData.attributes["gold"] = 99999
	var fail := EquipCat.tentar_craft("espada_aco")
	_ok(not bool(fail.get("ok", true)), "craft bloqueia sem material")
	PlayerData.adicionar_item(&"pedra_aura", 2)
	var ok := EquipCat.tentar_craft("espada_aco")
	_ok(bool(ok.get("ok", false)), "craft com material")


func _test_enemy_and_fx() -> void:
	print("\n[3] Enemy Nen + FX")
	var ed := EnemyData.new()
	ed.enemy_id = &"guardiao_elite"
	ed.enemy_name = "Guardião"
	ed.max_health = 200
	ed.strength = 20
	ed.defense = 10
	KitEnemy.enrich(ed)
	_ok(ed.hatsu_name == "Muralha de Pedra", "perfil muralha")
	_ok(not ed.resistance_tags.is_empty() or not ed.weakness_tags.is_empty(), "tags de combate")

	var before := get_child_count()
	KitFx.play_named(self, Vector2(40, 40), Vector2.RIGHT, ed.hatsu_name)
	KitFx.play_estilo(self, Vector2(80, 40), Vector2.RIGHT, HatsuData.EstiloVisual.LAMINA_CORTE, Color(1, 0.9, 0.4), 1.0)
	_ok(get_child_count() > before, "FX nodes anexados")

	var sent = DataManager.get_enemy(&"sentinela_pedra") as EnemyData
	_ok(sent != null and KitEnemy.move_speed_mult(sent) < 1.0, "sentinela lenta via kit")


func _test_hatsu_damage_tags() -> void:
	print("\n[4] Tags no dano de Hatsu")
	var golem := EnemyData.new()
	golem.enemy_id = &"golem_pedra"
	golem.enemy_name = "Golem"
	KitEnemy.enrich(golem)
	var h := HatsuData.new()
	h.categoria = HatsuData.Categoria.INTENSIFICACAO
	h.estilo_visual = HatsuData.EstiloVisual.ANEIS_IMPACTO
	var r: Dictionary = KitEnemy.apply_defense_tags(100.0, golem, h)
	_ok(bool(r.get("is_weakness", false)) or float(r.get("dano", 0)) >= 100.0, "golem fraco a Intensificação/Ko")
	h.categoria = HatsuData.Categoria.CONJURACAO
	var r2: Dictionary = KitEnemy.apply_defense_tags(100.0, golem, h)
	_ok(bool(r2.get("is_resisted", false)) or float(r2.get("dano", 100)) <= 100.0, "golem resiste Conjuração/piercing")
