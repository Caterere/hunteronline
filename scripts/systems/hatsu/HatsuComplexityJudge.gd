class_name HatsuComplexityJudge
extends RefCounted

const HatsuGuideBasesScript = preload("res://resource/hatsu/HatsuGuideBases.gd")

# ============================================================
# Juiz de complexidade / raridade do Hatsu Creator
# ============================================================
# Classifica FRACO → LENDÁRIO e bloqueia abuso por nível + afinidade.
# Bases guiadas: remover passos/condições reduz o teto permitido.
# ============================================================

enum Rank {
	FRACO,
	MEDIANO,
	FORTE,
	LENDARIO,
	ABUSIVO ## não forjável
}


## Teto de functional_power por rank (antes de bônus de afinidade)
const POWER_CAP := {
	Rank.FRACO: 85.0,
	Rank.MEDIANO: 145.0,
	Rank.FORTE: 220.0,
	Rank.LENDARIO: 310.0,
}

## Nível mínimo do jogador para forjar cada rank (espelha HatsuConfig)
static func _level_gate() -> Dictionary:
	return {
		Rank.FRACO: HatsuConfig.CREATOR_RANK_LEVEL_FRACO,
		Rank.MEDIANO: HatsuConfig.CREATOR_RANK_LEVEL_MEDIANO,
		Rank.FORTE: HatsuConfig.CREATOR_RANK_LEVEL_FORTE,
		Rank.LENDARIO: HatsuConfig.CREATOR_RANK_LEVEL_LENDARIO,
	}


static func rank_nome(r: int) -> String:
	match r:
		Rank.FRACO: return "Fraco"
		Rank.MEDIANO: return "Mediano"
		Rank.FORTE: return "Forte"
		Rank.LENDARIO: return "Lendário"
		Rank.ABUSIVO: return "Abusivo"
		_: return "?"


static func max_rank_for_player_level(nivel: int) -> int:
	var gate: Dictionary = _level_gate()
	if nivel >= int(gate[Rank.LENDARIO]):
		return Rank.LENDARIO
	if nivel >= int(gate[Rank.FORTE]):
		return Rank.FORTE
	if nivel >= int(gate[Rank.MEDIANO]):
		return Rank.MEDIANO
	return Rank.FRACO


static func classify_from_scores(functional_power: float, limitation_credits: float) -> int:
	var ratio: float = limitation_credits / maxf(1.0, functional_power)
	# Sem pagar limitações → abusivo
	if functional_power - limitation_credits > 8.0:
		return Rank.ABUSIVO
	if functional_power <= POWER_CAP[Rank.FRACO] and ratio >= 0.85:
		return Rank.FRACO
	if functional_power <= POWER_CAP[Rank.MEDIANO] and ratio >= 0.90:
		return Rank.MEDIANO
	if functional_power <= POWER_CAP[Rank.FORTE] and ratio >= 0.95:
		return Rank.FORTE
	if functional_power <= POWER_CAP[Rank.LENDARIO] and ratio >= 1.0:
		return Rank.LENDARIO
	return Rank.ABUSIVO


static func extract_guide_base_id(hatsu: HatsuData) -> String:
	if hatsu == null:
		return ""
	for t in hatsu.tags:
		var s := str(t)
		if s.begins_with("guide_base:"):
			return s.trim_prefix("guide_base:")
	return ""


static func apply_guide_tradeoffs(hatsu: HatsuData) -> Dictionary:
	## Ajusta poder se o jogador aliviar a base guiada (ex.: -1 passo no grimório).
	var base_id := extract_guide_base_id(hatsu)
	if base_id.is_empty():
		return {"applied": false, "power_mult": 1.0, "notes": []}
	var base: Dictionary = HatsuGuideBasesScript.obter_por_id(base_id)
	if base.is_empty():
		return {"applied": false, "power_mult": 1.0, "notes": []}

	var notes: Array[String] = []
	var power_mult: float = 1.0
	var steps_base: int = int(base.get("preparation_steps_base", 0))
	var steps_now: int = hatsu.preparation_steps.size() if hatsu.preparation_steps != null else 0
	var steal_base: int = (base.get("steal_conditions_base", []) as Array).size()
	var steal_now: int = hatsu.steal_conditions.size()

	if steps_base > 0 and steps_now < steps_base:
		var missing: int = steps_base - steps_now
		# Ex.: grimório com 1 passo a menos → mais fraco (pedido do usuário)
		power_mult *= maxf(0.45, 1.0 - 0.22 * float(missing))
		notes.append("Base guiada: -%d passo(s) de preparação → poder ×%.2f" % [missing, power_mult])

	if steal_base > 0 and steal_now < steal_base:
		var missing_sc: int = steal_base - steal_now
		power_mult *= maxf(0.40, 1.0 - 0.18 * float(missing_sc))
		notes.append("Base guiada: -%d condição(ões) de ritual → poder ×%.2f" % [missing_sc, power_mult])

	# Remover condição elite do contrato de corrente
	if base_id == "contrato_de_corrente":
		var has_elite := false
		for c in hatsu.condicoes:
			if int(c) == int(HatsuData.Condicao.ALVO_ELITE_BOSS):
				has_elite = true
		if not has_elite:
			power_mult *= 0.50
			notes.append("Sem restrição elite/boss → controle pela metade")

	if base_id == "cirurgia_imovel":
		var rooted := false
		for c in hatsu.condicoes:
			if int(c) == int(HatsuData.Condicao.IMOVEL_DURANTE_USO):
				rooted = true
		if not rooted and not (HatsuComponentLibrary.RestrictionType.IMMOBILE_DURING_USE in hatsu.modular_restrictions):
			power_mult *= 0.55
			notes.append("Sem imóvel → cura limitada (×0.55)")

	if base_id == "eficiencia_absoluta":
		var has_auto := false
		for c in hatsu.condicoes:
			if int(c) == int(HatsuData.Condicao.AUTO_DANO):
				has_auto = true
		if not has_auto:
			power_mult *= 0.60
			if hatsu.duracao > 20.0:
				hatsu.duracao = 20.0
			notes.append("Sem auto-dano → duração máx 20s e poder ×0.60")

	if base_id == "punho_concentrado":
		var immobile := HatsuComponentLibrary.RestrictionType.IMMOBILE_DURING_USE in hatsu.modular_restrictions \
			or HatsuData.Condicao.PARADO_CANALIZACAO in hatsu.condicoes
		if not immobile:
			power_mult *= 0.75
			notes.append("Sem canalização imóvel → teto de dano ×0.75")

	if not is_equal_approx(power_mult, 1.0):
		hatsu.poder_base = maxf(10.0, hatsu.poder_base * power_mult)
		if hatsu.custom_damage > 0.0:
			hatsu.custom_damage = maxf(10.0, hatsu.custom_damage * power_mult)
		if hatsu.cura_base > 0.0:
			hatsu.cura_base = maxf(5.0, hatsu.cura_base * power_mult)

	return {"applied": not notes.is_empty(), "power_mult": power_mult, "notes": notes, "base_id": base_id}


static func affinity_soft_gate(hatsu: HatsuData) -> Dictionary:
	## Off-affinity: pode forjar, mas rank máximo cai 1 degrau (exceto Especialista).
	if hatsu == null or PlayerData == null:
		return {"ok": true, "max_rank_penalty": 0, "note": ""}
	var natal = PlayerData.afinidade_nen
	if natal == NenAffinityData.CategoriaAfinidade.ESPECIALIZACAO:
		return {"ok": true, "max_rank_penalty": 0, "note": "Especialista: todas as categorias liberadas."}
	if int(natal) == int(hatsu.categoria):
		return {"ok": true, "max_rank_penalty": 0, "note": "Afinidade natal: orçamento cheio."}
	return {
		"ok": true,
		"max_rank_penalty": 1,
		"note": "Fora da afinidade natal: teto de raridade −1 (ainda forjável)."
	}


static func evaluate(hatsu: HatsuData, player_context: Dictionary = {}) -> Dictionary:
	if hatsu == null:
		return {"rank": Rank.ABUSIVO, "allowed": false, "reason": "Hatsu vazio", "label": "Abusivo"}

	var trade := apply_guide_tradeoffs(hatsu)
	var pb: Dictionary = {}
	if HatsuManager != null:
		pb = HatsuManager.calculate_power_budget(hatsu, player_context)
	var fp: float = float(pb.get("functional_power", hatsu.calcular_functional_power()))
	var lc: float = float(pb.get("limitation_credits", hatsu.calcular_limitation_credits()))
	var rank: int = classify_from_scores(fp, lc)

	var nivel: int = int(player_context.get("nivel", PlayerData.attributes.get("nivel", 1) if PlayerData else 1))
	var max_rank: int = max_rank_for_player_level(nivel)
	var aff := affinity_soft_gate(hatsu)
	max_rank = maxi(Rank.FRACO, max_rank - int(aff.get("max_rank_penalty", 0)))

	var allowed := true
	var reason := ""
	if rank == Rank.ABUSIVO:
		allowed = false
		reason = "Abusivo: poder não pago por limitações (ou spam ilegal)."
	elif rank > max_rank:
		allowed = false
		reason = "Nível %d só permite até %s. Esta técnica saiu %s — reduza poder ou suba de nível." % [
			nivel, rank_nome(max_rank), rank_nome(rank)
		]

	# Tag de rank no hatsu
	var clean_tags: Array[String] = []
	for t in hatsu.tags:
		if not str(t).begins_with("rank:"):
			clean_tags.append(str(t))
	clean_tags.append("rank:%s" % rank_nome(rank).to_lower())
	hatsu.tags = clean_tags

	return {
		"rank": rank,
		"rank_name": rank_nome(rank),
		"allowed": allowed,
		"reason": reason if not allowed else "OK — %s" % rank_nome(rank),
		"label": rank_nome(rank),
		"functional_power": fp,
		"limitation_credits": lc,
		"max_rank_for_level": max_rank,
		"max_rank_name": rank_nome(max_rank),
		"affinity_note": str(aff.get("note", "")),
		"tradeoff_notes": trade.get("notes", []),
		"guide_base_id": trade.get("base_id", extract_guide_base_id(hatsu)),
		"power_cap": float(POWER_CAP.get(max_rank, 85.0))
	}


static func obter_guia_jogador() -> String:
	return """GUIA DO HATSU CREATOR
━━━━━━━━━━━━━━━━━━━━
1) Créditos de Limitação
   Poder (dano/alcance/utilidade) consome créditos.
   Condições, restrições e passos de preparação PAGAM créditos.
   Déficit > 0 = não forja.

2) Raridade / Complexidade
   Fraco    — Lv 1+   | utilidade / DPS leve
   Mediano  — Lv 15+  | combate padrão
   Forte    — Lv 35+  | charge, controle, modos
   Lendário — Lv 55+  | grimório, síntese, estátua…

3) Afinidade de Nen
   Técnica na sua afinidade natal = orçamento cheio.
   Fora da afinidade = teto de raridade −1 (ainda cria).
   Especialista = todas as categorias.

4) Bases Guiadas
   São modelos inspirados no anime (sem nomes canônicos).
   Você pode mudar tudo — mas aliviar o ritual enfraquece
   a técnica (ex.: grimório com 3 passos em vez de 4).

5) Anti-abuso
   CD muito baixo + aura barata = inválido.
   Lendário exige nível + limitações reais.
   Mastery começa em 30% do potencial — cresce em combate.
"""
