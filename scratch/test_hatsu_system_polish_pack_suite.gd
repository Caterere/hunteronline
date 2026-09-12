extends Node

# ============================================================
# SUÍTE: HATSU SYSTEM POLISH PACK
# ============================================================

var passados: int = 0
var totais: int = 0


func _ready() -> void:
	print("\n============================================================")
	print("🧪 HATSU SYSTEM POLISH PACK SUITE")
	print("============================================================\n")

	_run("1. Glossário HxH + 3 atos (10 etapas)", _t_glossary_acts)
	_run("2. Eixos aura×CD×setup sobem com força", _t_cost_axes)
	_run("3. Preview combate (pedido/efetivo/uptime/risco)", _t_combat_preview)
	_run("4. Composição modular por categoria", _t_composition)
	_run("5. Voto vivo: quebra → penalidade + Zetsu", _t_live_vow)
	_run("6. Camadas pós-forja por mastery", _t_growth_layers)
	_run("7. Condição bilateral (Chain Jail style)", _t_bilateral)
	_run("8. Exorcismo / anti-Hatsu kits", _t_exorcism)
	_run("9. Morphs PvE/PvP/Suporte", _t_morphs)
	_run("10. Nen gems (≤2) sobem créditos", _t_nen_gems)
	_run("11. Galeria social + rate limit 3/h", _t_gallery)
	_run("12. Softcap por modo open/ranked/raid", _t_mode_caps)
	_run("13. UI tematizada (HunterUIStyle) smoke", _t_ui_theme_smoke)

	print("\n============================================================")
	print("RESULTADO: %d / %d" % [passados, totais])
	print("============================================================\n")
	get_tree().quit(0 if passados == totais else 1)


func _run(nome: String, fn: Callable) -> void:
	totais += 1
	print("▶ ", nome)
	var ok: bool = fn.call()
	if ok:
		passados += 1
		print("  ✅ PASSOU\n")
	else:
		print("  ❌ FALHOU\n")


func _t_glossary_acts() -> bool:
	var g1 := HatsuCreationPolish.glossario_condicao()
	var g2 := HatsuCreationPolish.glossario_restricao()
	var g3 := HatsuCreationPolish.glossario_juramento()
	if "CONDIÇÃO" not in g1 or "RESTRIÇÃO" not in g2 or "JURAMENTO" not in g3:
		print("  glossário inválido:", g1, "|", g2, "|", g3)
		return false
	if HatsuCreationPolish.obter_ato_da_etapa(0) != HatsuCreationPolish.AtoUI.IDENTIDADE:
		return false
	if HatsuCreationPolish.obter_ato_da_etapa(4) != HatsuCreationPolish.AtoUI.PODER:
		return false
	if HatsuCreationPolish.obter_ato_da_etapa(8) != HatsuCreationPolish.AtoUI.PRECO:
		return false
	print("  Atos OK | ", HatsuCreationPolish.obter_nome_ato(HatsuCreationPolish.AtoUI.PRECO))
	return true


func _t_cost_axes() -> bool:
	var low: Dictionary = HatsuCreationPolish.calcular_eixos_custo(20.0, 1)
	var high: Dictionary = HatsuCreationPolish.calcular_eixos_custo(220.0, 1)
	print("  low aura=%.1f cd=%.1f setup=%.2f | high aura=%.1f cd=%.1f setup=%.2f" % [
		float(low["aura_cost"]), float(low["cooldown"]), float(low["setup_time"]),
		float(high["aura_cost"]), float(high["cooldown"]), float(high["setup_time"])
	])
	return float(high["aura_cost"]) > float(low["aura_cost"]) \
		and float(high["cooldown"]) > float(low["cooldown"]) \
		and float(high["setup_time"]) > float(low["setup_time"])


func _t_combat_preview() -> bool:
	var eixos: Dictionary = HatsuCreationPolish.calcular_eixos_custo(120.0, 1)
	var prev: Dictionary = HatsuCreationPolish.gerar_preview_combate(120.0, 0.6, eixos, 50.0, 0.3)
	print("  pedido=%d efetivo=%d uptime=%d risco=%s" % [
		int(prev["dano_pedido"]), int(prev["dano_efetivo"]), int(prev["uptime_pct"]), str(prev["risco_texto"])
	])
	if int(prev["dano_efetivo"]) >= int(prev["dano_pedido"]):
		print("  afinidade 60% deveria reduzir efetivo")
		return false
	return prev.has("dps_efetivo")


func _t_composition() -> bool:
	var tr: Dictionary = HatsuCreationPolish.obter_composicao_por_categoria(1)
	var em: Dictionary = HatsuCreationPolish.obter_composicao_por_categoria(2)
	var cj: Dictionary = HatsuCreationPolish.obter_composicao_por_categoria(3)
	print("  TR=%s EM=%s CJ=%s" % [tr.get("modo"), em.get("modo"), cj.get("modo")])
	return str(tr.get("modo")) == "dual" and str(em.get("modo")) == "slider_pair" and str(cj.get("modo")) == "clarity"


func _t_live_vow() -> bool:
	var h := HatsuData.new()
	h.nome = "VotoVivo"
	h.custom_damage = 80.0
	h.poder_base = 80.0
	h.mastery = 100.0
	var before := h.obter_poder_com_penalidade()
	var br: Dictionary = h.aplicar_quebra_juramento(0.3)
	var after := h.obter_poder_com_penalidade()
	print("  poder antes=%.1f depois=%.1f zetsu=%.1fs pen=%.2f" % [
		before, after, float(br.get("zetsu_seconds", 0.0)), float(br.get("permanent_power_penalty", 0.0))
	])
	return after < before and float(br.get("zetsu_seconds", 0.0)) >= 8.0


func _t_growth_layers() -> bool:
	var c0: Dictionary = HatsuCreationPolish.camada_atual(0.0)
	var c60: Dictionary = HatsuCreationPolish.camada_atual(60.0)
	var c100: Dictionary = HatsuCreationPolish.camada_atual(100.0)
	print("  0=%s 60=%s 100=%s" % [c0.get("nome"), c60.get("nome"), c100.get("nome")])
	if int(c0.get("rank", 0)) >= int(c60.get("rank", 0)):
		return false
	if int(c100.get("rank", 0)) < 5:
		return false
	var h := HatsuData.new()
	h.mastery = 60.0
	h.desbloquear_camadas_por_mastery()
	print("  growth_layer_unlocked=", h.growth_layer_unlocked)
	return h.growth_layer_unlocked >= 4


func _t_bilateral() -> bool:
	var h := HatsuData.new()
	h.bilateral_rules = [{
		"self_rule": "requires_chain",
		"target_rule": "specific_faction",
		"faction": "phantom_troupe",
		"label": "Chain Jail-like",
		"credit": 45.0
	}]
	var bad: Dictionary = h.validar_regra_bilateral({"has_chain": false}, {"faction": "phantom_troupe"})
	var good: Dictionary = h.validar_regra_bilateral({"has_chain": true}, {"faction": "phantom_troupe"})
	var wrong_fac: Dictionary = h.validar_regra_bilateral({"has_chain": true}, {"faction": "other"})
	print("  bad=%s good=%s wrong=%s" % [bad.get("ok"), good.get("ok"), wrong_fac.get("ok")])
	return (not bool(bad.get("ok"))) and bool(good.get("ok")) and (not bool(wrong_fac.get("ok")))


func _t_exorcism() -> bool:
	var kits: Array = HatsuExorcismSystem.obter_kits()
	if kits.size() < 3:
		return false
	var dummy := Node.new()
	dummy.set_meta("nen_marks", ["mark_a"])
	add_child(dummy)
	var res: Dictionary = HatsuExorcismSystem.executar(int(HatsuExorcismSystem.ExorcismTier.BASIC), self, dummy)
	print("  kits=%d ok=%s purged=%s" % [kits.size(), res.get("ok"), res.get("purged")])
	dummy.queue_free()
	return bool(res.get("ok", false))


func _t_morphs() -> bool:
	var morphs: Array = HatsuMorphLibrary.obter_morphs_padrao()
	if morphs.size() < 3:
		return false
	var h := HatsuData.new()
	h.mastery = 10.0
	var locked: Dictionary = HatsuMorphLibrary.aplicar_morph(h, int(HatsuMorphLibrary.MorphId.PVE_BURST))
	h.mastery = 80.0
	var ok: Dictionary = HatsuMorphLibrary.aplicar_morph(h, int(HatsuMorphLibrary.MorphId.PVE_BURST))
	print("  locked=%s ok=%s mult=%.2f" % [locked.get("ok"), ok.get("ok"), h.obter_multiplicador_morph_dano()])
	return (not bool(locked.get("ok"))) and bool(ok.get("ok")) and h.obter_multiplicador_morph_dano() > 1.0


func _t_nen_gems() -> bool:
	var mods: Array = [
		HatsuCreationPolish.SupportModifier.TRACKING,
		HatsuCreationPolish.SupportModifier.AREA
	]
	var cr: float = HatsuCreationPolish.credito_modifiers(mods)
	print("  credito gems=%.1f" % cr)
	if cr < 50.0:
		return false
	var h := HatsuData.new()
	h.support_modifiers = mods
	h.composition_data = {"clarity": 1.0, "properties": ["rubber", "gum"]}
	h.bilateral_rules = [{"credit": 45.0}]
	var extra: float = h.credito_extra_composicao()
	print("  credito_extra_composicao=%.1f" % extra)
	return extra > cr


func _t_gallery() -> bool:
	var h := HatsuData.new()
	h.nome = "GaleriaTest"
	h.custom_damage = 200.0
	h.set_meta("playstyle_tags", [0])
	h.set_meta("composition", {"focus_id": "ko_punch"})
	HatsuBuildGallery._post_timestamps.clear()
	HatsuBuildGallery._posts.clear()
	var a: Dictionary = HatsuBuildGallery.publicar_conceito(h, "Tester")
	var b: Dictionary = HatsuBuildGallery.publicar_conceito(h, "Tester")
	var c: Dictionary = HatsuBuildGallery.publicar_conceito(h, "Tester")
	var d: Dictionary = HatsuBuildGallery.publicar_conceito(h, "Tester")
	print("  posts ok=%s %s %s | 4th=%s reason=%s" % [a.get("ok"), b.get("ok"), c.get("ok"), d.get("ok"), d.get("reason")])
	if not (bool(a.get("ok")) and bool(b.get("ok")) and bool(c.get("ok"))):
		return false
	if bool(d.get("ok")):
		print("  rate limit falhou")
		return false
	var entry_id: String = str(a.get("entry", {}).get("id", ""))
	var copy: Dictionary = HatsuBuildGallery.copiar_conceito(entry_id)
	print("  copy ok=%s note=%s" % [copy.get("ok"), copy.get("note")])
	return bool(copy.get("ok"))


func _t_mode_caps() -> bool:
	var h := HatsuData.new()
	h.custom_damage = 200.0
	h.credit_deficit = 0.0
	h.vow_credits = 10.0
	h.modular_restrictions = []
	var open_ok: Dictionary = HatsuModeRules.validar_hatsu_no_modo(h, HatsuModeRules.GameMode.OPEN_WORLD)
	var ranked: Dictionary = HatsuModeRules.validar_hatsu_no_modo(h, HatsuModeRules.GameMode.RANKED_PVP)
	print("  open=%s ranked=%s reasons=%s" % [open_ok.get("ok"), ranked.get("ok"), ranked.get("reasons")])
	return bool(open_ok.get("ok")) and (not bool(ranked.get("ok")))


func _t_ui_theme_smoke() -> bool:
	var src := FileAccess.get_file_as_string("res://ui/Hatsu/HatsuCreationUI.gd")
	if src.is_empty():
		print("  UI vazia")
		return false
	var checks := [
		"HunterUIStyle.criar_style_painel_principal",
		"HunterUIStyle.aplicar_estilo_botao",
		"_montar_eixos_e_preview",
		"_montar_bloco_composicao",
		"_montar_extras_preco",
		"HatsuCreationPolish.glossario_condicao",
		"HatsuBuildGallery.publicar_conceito"
	]
	for c in checks:
		if c not in src:
			print("  faltando na UI: ", c)
			return false
	print("  UI contém tema + wiring polish")
	return true
