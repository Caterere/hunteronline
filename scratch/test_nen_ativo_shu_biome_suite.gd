extends Node

# ============================================================
# Suite: Nen ativo só Gyo/Zetsu/En + Shu visual + biome drops
# ============================================================

const BiomeLootCatalogScript = preload("res://resource/item/BiomeLootCatalog.gd")
const ShuWeaponAuraScript = preload("res://entities/effects/ShuWeaponAura.gd")

var _passed: int = 0
var _failed: int = 0


func _ready() -> void:
	print("\n========== TEST NEN ATIVO + SHU + BIOME LOOT ==========")
	await get_tree().process_frame
	_reset()
	await _teste_nen_ativo_restrito()
	await _teste_quick_bar_config()
	await _teste_shu_aura()
	_teste_biome_loot()
	_teste_cutscenes_arco()
	print("========== RESULTADO: %d ok / %d fail ==========" % [_passed, _failed])
	get_tree().quit(1 if _failed > 0 else 0)


func _assert(cond: bool, msg: String) -> void:
	if cond:
		_passed += 1
		print("  PASS: ", msg)
	else:
		_failed += 1
		print("  FAIL: ", msg)


func _reset() -> void:
	PlayerData.reset()
	PlayerData.inventory.clear()
	PlayerData.equipped = {"cabeca": "", "corpo": "", "mao_princ": "", "mao_sec": "", "acessorio": "", "licenca": ""}
	PlayerData.active_modifiers.clear()
	PlayerData.despertou_nen = true
	PlayerData.aplicar_nivel_nen(1)
	PlayerData.recalcular_todos_atributos()


func _teste_nen_ativo_restrito() -> void:
	print("\n[1] Nen ativo restrito a Gyo/Zetsu/En")
	var nen_script = load("res://scripts/systems/NenSystem.gd")
	var nen = nen_script.new()
	add_child(nen)
	await get_tree().process_frame

	# Passivas devem falhar
	for t in [NenSystem.Tecnica.TEN, NenSystem.Tecnica.REN, NenSystem.Tecnica.KO, NenSystem.Tecnica.SHU, NenSystem.Tecnica.KEN, NenSystem.Tecnica.RYU]:
		var ok: bool = nen.ativar_tecnica(t)
		_assert(not ok, "passiva %s bloqueada" % nen.nome_tecnica(t))
		_assert(not nen.tecnica_ativa(t) or t == NenSystem.Tecnica.REN or t == NenSystem.Tecnica.TEN, "passiva %s nao fica ativa por toggle" % nen.nome_tecnica(t))

	# Ativas devem funcionar (Zetsu/Gyo/En)
	var z: bool = nen.ativar_tecnica(NenSystem.Tecnica.ZETSU)
	_assert(z, "Zetsu ativa")
	_assert(nen.tecnica_ativa(NenSystem.Tecnica.ZETSU), "Zetsu reporta ativo")
	nen.desativar_tecnica(NenSystem.Tecnica.ZETSU)

	var g: bool = nen.ativar_tecnica(NenSystem.Tecnica.GYO)
	_assert(g, "Gyo ativa")
	_assert(nen.tecnica_ativa(NenSystem.Tecnica.GYO), "Gyo reporta ativo")
	nen.desativar_tecnica(NenSystem.Tecnica.GYO)

	var e: bool = nen.ativar_tecnica(NenSystem.Tecnica.EN)
	_assert(e, "En ativa")
	_assert(nen.tecnica_ativa(NenSystem.Tecnica.EN), "En reporta ativo")
	nen.desativar_tecnica(NenSystem.Tecnica.EN)
	nen.queue_free()
	await get_tree().process_frame


func _teste_quick_bar_config() -> void:
	print("\n[2] Quick bar so com ativas")
	var bar_script = load("res://ui/hud/NenQuickActionBar.gd")
	_assert(bar_script != null, "NenQuickActionBar carrega")
	var bar = bar_script.new()
	add_child(bar)
	await get_tree().process_frame
	var nomes: Array = []
	for cfg in bar.TECNICAS_CONFIG:
		nomes.append(str(cfg["nome"]))
	_assert(nomes.has("ZETSU") and nomes.has("GYO") and nomes.has("EN"), "barra tem Zetsu/Gyo/En")
	_assert(not nomes.has("TEN") and not nomes.has("REN") and not nomes.has("KO"), "barra sem Ten/Ren/Ko")
	var ativas_count: int = 0
	for n in nomes:
		if n != "OFF":
			ativas_count += 1
	_assert(ativas_count == 3, "barra tem exatamente 3 tecnicas ativas (+ OFF)")
	_assert(nomes.has("OFF"), "barra tem OFF para desligar ativas")
	bar.queue_free()
	await get_tree().process_frame


func _teste_shu_aura() -> void:
	print("\n[3] Shu weapon aura")
	var aura = ShuWeaponAuraScript.new()
	add_child(aura)
	await get_tree().process_frame
	_assert(not aura._ativo, "aura off sem arma")
	PlayerData.adicionar_item(&"adaga_zaban", 1)
	var eq: Dictionary = PlayerData.equipar_item("adaga_zaban")
	_assert(bool(eq.get("sucesso", false)), "equipou adaga_zaban")
	_assert(PlayerData.obter_equipado("mao_princ") == "adaga_zaban", "slot mao_princ preenchido")
	aura._atualizar_estado()
	_assert(aura._ativo, "aura on com arma + Nen")
	PlayerData.desequipar_slot("mao_princ")
	aura._atualizar_estado()
	_assert(not aura._ativo, "aura off apos desequipar")
	aura.queue_free()
	await get_tree().process_frame


func _teste_biome_loot() -> void:
	print("\n[4] Biome loot catalog")
	_assert(BiomeLootCatalogScript.resolver_bioma_cena("res://world/maps/montanha_kukuroo.tscn") == "forest", "kukuroo forest")
	_assert(BiomeLootCatalogScript.resolver_bioma_cena("res://world/maps/dungeon_ruinas_zaban.tscn") == "dungeon", "zaban dungeon")
	_assert(BiomeLootCatalogScript.resolver_bioma_cena("res://world/lobby.tscn") == "city", "lobby city")
	_assert(BiomeLootCatalogScript.resolver_bioma_cena("res://world/maps/arena_celestial.tscn") == "arena", "arena biome")
	_assert(BiomeLootCatalogScript.DROPS_POR_BIOMA.has("forest"), "drop forest")
	_assert(BiomeLootCatalogScript.DROPS_POR_BIOMA.has("arena"), "drop arena")
	_assert(BiomeLootCatalogScript.DROPS_POR_BIOMA.has("ruins"), "drop ruins")
	_assert(BiomeLootCatalogScript.DROPS_POR_BIOMA.has("city"), "drop city")
	_assert(BiomeLootCatalogScript.DROPS_POR_BIOMA.has("dungeon"), "drop dungeon")

	var marker := Node2D.new()
	add_child(marker)
	var got := false
	for i in range(40):
		var r: Dictionary = BiomeLootCatalogScript.tentar_drop_raro(marker, Vector2.ZERO, "res://world/maps/montanha_kukuroo.tscn", 1.0)
		if r.get("sucesso", false):
			got = true
			_assert(str(r.get("item_id", "")) != "", "drop retorna item_id")
			_assert(str(r.get("bioma", "")) == "forest", "drop bioma forest")
			break
	_assert(got, "drop raro com bonus 100% ocorre")
	marker.queue_free()


func _teste_cutscenes_arco() -> void:
	print("\n[5] Semi-cutscenes Arco 1-2")
	var scm = load("res://scripts/cutscenes/StoryCutsceneManager.gd")
	_assert(scm != null, "StoryCutsceneManager carrega")
	_assert(scm.has_method("executar_pantanal_hisoka"), "tem pantanal_hisoka")
	_assert(scm.has_method("executar_gourmet_menchi_buhara"), "tem gourmet_menchi")
	_assert(scm.has_method("executar_conclusao_exame_hunter"), "tem conclusao_exame")
	_assert(scm.has_method("executar_maratona_hunter"), "tem maratona_hunter")
