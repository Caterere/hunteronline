extends Node

# ============================================================
# HUNTER ONLINE - COMBAT ENGINE (CENTRAL DAMAGE PIPELINE)
# ============================================================
#
# Pipeline Oficial de Cálculo de Dano e Mitigações:
# INPUT -> TARGET -> ATTACK -> NEN MODS -> HATSU MODS -> DAMAGE ->
# DEFENSE SUBTRACTION -> TEN/KEN/RYU MITIGATION -> CRIT/STAGGER -> OUTPUT
#
# ============================================================

signal hit_processado(atacante: Node, defensor: Node, dano_final: int, is_crit: bool)

func calcular_dano(
	atacante: Variant,
	defensor: Variant = null,
	hatsu: Resource = null,
	is_ko: bool = false,
	attack_tags: Array = []
) -> int:
	var det := calcular_dano_detalhado(atacante, defensor, hatsu, is_ko, attack_tags)
	return det.get("dano", 1)


func calcular_dano_detalhado(
	atacante: Variant,
	defensor: Variant = null,
	hatsu: Resource = null,
	is_ko: bool = false,
	attack_tags: Array = []
) -> Dictionary:
	var forca: float = 10.0
	var dano_base: float = 10.0

	# 1. Obter Atributos do Atacante
	if atacante is Dictionary:
		forca = float(atacante.get("forca", 10.0))
		dano_base = float(atacante.get("dano_base", 10.0))
		if atacante.get("ren_ativo", false):
			forca *= float(atacante.get("ren_mult", 1.5))
		if is_ko or atacante.get("ko_ativo", false):
			forca *= float(atacante.get("ko_mult", 2.0))
		if attack_tags.is_empty() and atacante.has("attack_tags"):
			attack_tags = atacante.get("attack_tags", [])
	elif atacante != null and atacante is Node:
		var ply_data = PlayerData if atacante.is_in_group("player") else null
		if ply_data != null:
			forca = float(ply_data.attributes.get("forca", 10))
			if ply_data.quest_states.get("guanyin_bodhisattva_ativo", false):
				dano_base = 100.0
			elif ply_data.quest_states.get("godspeed_ativo", false):
				dano_base = 65.0
		elif "strength" in atacante:
			forca = float(atacante.strength)
		elif "forca" in atacante:
			forca = float(atacante.forca)

		if is_ko:
			forca *= 2.0

		if attack_tags.is_empty():
			if "attack_tags" in atacante and atacante.attack_tags != null:
				attack_tags = atacante.attack_tags
			elif "enemy_data" in atacante and atacante.enemy_data != null and atacante.enemy_data.attack_tags != null:
				attack_tags = atacante.enemy_data.attack_tags

	var dano: float = dano_base + forca

	# 2. Multiplicadores de Hatsu & Tags de Ataque
	var tags_efetivas: Array = attack_tags.duplicate()
	if hatsu != null:
		var h_mult: float = 1.0
		if hatsu.has_method("get_multiplicador"):
			h_mult = hatsu.get_multiplicador()
		var compat: float = float(hatsu.get("compatibilidade")) if "compatibilidade" in hatsu and hatsu.get("compatibilidade") != null else 1.0
		dano *= (h_mult * compat)
		if "tags" in hatsu and hatsu.tags is Array:
			for tg in hatsu.tags:
				if tg not in tags_efetivas:
					tags_efetivas.append(tg)

	tags_efetivas = GameplayTags.normalize(tags_efetivas)

	# 3. Reduções do Defensor
	var reducao_defesa: float = 0.0
	var reducao_ten: float = 0.0
	var def_weakness: Array = []
	var def_resistance: Array = []
	var def_immunity: Array = []

	if defensor is Dictionary:
		reducao_defesa = float(defensor.get("defesa", 0.0)) * 0.5
		if defensor.get("ten_ativo", false):
			reducao_ten = float(defensor.get("aura", 0.0)) * 0.1
		def_weakness = defensor.get("weakness_tags", [])
		def_resistance = defensor.get("resistance_tags", [])
		def_immunity = defensor.get("immunity_tags", [])
	elif defensor != null and defensor is Node:
		if defensor.is_in_group("player"):
			reducao_defesa = float(PlayerData.attributes.get("defesa", 10)) * 0.5
			if PlayerData.despertou_nen:
				# Ten Passivo: Absorção contínua de impacto sem necessidade de ativação manual
				reducao_ten = float(PlayerData.attributes.get("aura_max", 100.0)) * 0.08
			def_weakness = PlayerData.weakness_tags
			def_resistance = PlayerData.resistance_tags
			def_immunity = PlayerData.immunity_tags
		var ai = defensor.get_node_or_null("EnemyAI")
		if ai != null and ai.has_method("obter_defesa_efetiva"):
			reducao_defesa = ai.obter_defesa_efetiva() * 0.5
		elif "defense" in defensor:
			reducao_defesa = float(defensor.defense) * 0.5
		elif "defesa" in defensor:
			reducao_defesa = float(defensor.defesa) * 0.5

		if "enemy_data" in defensor and defensor.enemy_data != null:
			def_weakness = defensor.enemy_data.weakness_tags
			def_resistance = defensor.enemy_data.resistance_tags
			def_immunity = defensor.enemy_data.immunity_tags
		elif "weakness_tags" in defensor:
			def_weakness = defensor.weakness_tags
			def_resistance = defensor.resistance_tags
			def_immunity = defensor.immunity_tags

	# 4. Processar Fraquezas, Resistências e Imunidades via GameplayTags
	var is_weakness := false
	var is_resisted := false
	var is_immune := false

	if not tags_efetivas.is_empty():
		if GameplayTags.has_any(def_immunity, tags_efetivas):
			is_immune = true
			dano = 0.0
		else:
			if GameplayTags.has_any(def_weakness, tags_efetivas):
				is_weakness = true
				dano *= 1.50
			if GameplayTags.has_any(def_resistance, tags_efetivas):
				is_resisted = true
				dano *= 0.50

	var dano_final: float = 0.0
	if not is_immune:
		dano_final = max(1.0, dano - reducao_defesa - reducao_ten)

	# Quebra canônica de Zetsu (Stealth) ao desferir ou receber dano em combate
	var player_node = atacante if (atacante != null and atacante is Node and atacante.is_in_group("player")) else (defensor if (defensor != null and defensor is Node and defensor.is_in_group("player")) else null)
	if player_node != null:
		var nen_sys = player_node.get_node_or_null("NenSystem")
		if nen_sys == null:
			for ch in player_node.get_children():
				if ch.has_method("esta_em_zetsu"):
					nen_sys = ch
					break
		if nen_sys != null and nen_sys.has_method("esta_em_zetsu") and nen_sys.esta_em_zetsu():
			nen_sys.desativar_tecnica(NenSystem.Tecnica.ZETSU)

	# Game Feel & Sensory Impact
	if EventBus != null and dano_final > 0.0:
		if is_ko:
			EventBus.emit_hitstop(0.10)
			EventBus.emit_camera_shake(0.50, 0.25)
		elif is_weakness:
			EventBus.emit_hitstop(0.08)
			EventBus.emit_camera_shake(0.40, 0.20)
		elif hatsu != null:
			EventBus.emit_hitstop(0.09)
			EventBus.emit_camera_shake(0.45, 0.25)
		else:
			EventBus.emit_hitstop(0.04)
			EventBus.emit_camera_shake(0.20, 0.12)

	var dano_int := int(round(dano_final))
	return {
		"dano": dano_int,
		"is_weakness": is_weakness,
		"is_resisted": is_resisted,
		"is_immune": is_immune,
		"tags": tags_efetivas
	}


# ============================================================
# CONTEXTO CANÔNICO DE COMBATE & SKILL TREE INTEGRATION
# ============================================================

## Constrói um dicionário padronizado de contexto para GameplayCondition.
func construir_contexto_combate(atacante: Variant, defensor: Variant = null, extras: Dictionary = {}) -> Dictionary:
	var ctx: Dictionary = extras.duplicate(true)

	# 1. Percentual de vida do jogador
	if PlayerData != null and PlayerData.attributes != null:
		var hp = float(PlayerData.attributes.get("vida", 100))
		var hp_max = max(1.0, float(PlayerData.attributes.get("vida_max", 100)))
		ctx["player_hp_percent"] = clamp(hp / hp_max, 0.0, 1.0)
	elif not ctx.has("player_hp_percent"):
		ctx["player_hp_percent"] = 1.0

	# 2. Percentual de vida do alvo
	if not ctx.has("target_hp_percent"):
		if defensor is Dictionary:
			var t_hp = float(defensor.get("vida", defensor.get("hp", 100.0)))
			var t_max = max(1.0, float(defensor.get("vida_max", defensor.get("max_hp", 100.0))))
			ctx["target_hp_percent"] = clamp(t_hp / t_max, 0.0, 1.0)
		elif defensor != null and defensor is Node:
			if "current_hp" in defensor and "max_hp" in defensor:
				ctx["target_hp_percent"] = clamp(float(defensor.current_hp) / max(1.0, float(defensor.max_hp)), 0.0, 1.0)
			elif "hp" in defensor and "max_hp" in defensor:
				ctx["target_hp_percent"] = clamp(float(defensor.hp) / max(1.0, float(defensor.max_hp)), 0.0, 1.0)
			elif "vida" in defensor and "vida_max" in defensor:
				ctx["target_hp_percent"] = clamp(float(defensor.vida) / max(1.0, float(defensor.vida_max)), 0.0, 1.0)
			else:
				ctx["target_hp_percent"] = 1.0
		else:
			ctx["target_hp_percent"] = 1.0

	# 3. Alvo marcado
	if not ctx.has("target_marked"):
		if defensor is Dictionary:
			ctx["target_marked"] = bool(defensor.get("marked", defensor.get("marcado", false)))
		elif defensor != null and defensor is Node:
			ctx["target_marked"] = bool(defensor.get("marked")) if "marked" in defensor else false
		else:
			ctx["target_marked"] = false

	# 4. Inimigos próximos e tempo sem dano (defaults seguros)
	if not ctx.has("nearby_enemy_count"):
		ctx["nearby_enemy_count"] = 1 if defensor != null else 0
	if not ctx.has("seconds_since_damage"):
		ctx["seconds_since_damage"] = 10.0

	# 5. Nós de habilidades desbloqueados
	if PlayerData != null and not ctx.has("unlocked_skill_ids"):
		var unlocked: Array[StringName] = []
		for skill_id in PlayerData.nen_skill_tree_progress.keys():
			if PlayerData.nen_skill_tree_progress[skill_id] > 0:
				unlocked.append(StringName(skill_id))
		ctx["unlocked_skill_ids"] = unlocked

	return ctx


## Atualiza as instâncias ativas da NenSkillTree com o contexto de combate.
func atualizar_contexto_skill_tree(contexto: Dictionary) -> Dictionary:
	if get_tree() == null:
		return {}

	var skill_trees := get_tree().get_nodes_in_group("nen_skill_tree")
	var resultado: Dictionary = {}
	for st in skill_trees:
		if st.has_method("atualizar_modificadores_contextuais"):
			resultado = st.atualizar_modificadores_contextuais(contexto)
	return resultado


func calcular_dano_jogador(
	player_node: Node2D,
	nen_system: Node = null,
	inimigo_alvo: Node = null,
	contexto_combate: Dictionary = {},
	attack_tags: Array = [],
	hatsu: Resource = null
) -> int:
	var ctx := construir_contexto_combate(player_node, inimigo_alvo, contexto_combate)
	atualizar_contexto_skill_tree(ctx)

	var forca: float = float(PlayerData.attributes.get("forca", 10))
	var dano_base: float = 10.0

	if PlayerData.quest_states.get("guanyin_bodhisattva_ativo", false):
		dano_base = 100.0
	elif PlayerData.quest_states.get("godspeed_ativo", false):
		dano_base = 65.0

	var dano_fisico: float = dano_base + forca
	var dano_nen: float = 0.0

	if nen_system != null and nen_system.has_method("calcular_dano"):
		dano_nen = nen_system.calcular_dano(forca)

	var dano_final: float = dano_fisico + dano_nen

	# Processar tags de ataque e bônus de Hatsu
	var tags_efetivas: Array = attack_tags.duplicate()
	if tags_efetivas.is_empty() and contexto_combate.has("attack_tags"):
		tags_efetivas = contexto_combate.get("attack_tags", []).duplicate()

	if hatsu != null:
		var h_mult: float = 1.0
		if hatsu.has_method("get_multiplicador"):
			h_mult = hatsu.get_multiplicador()
		var compat: float = float(hatsu.get("compatibilidade")) if "compatibilidade" in hatsu and hatsu.get("compatibilidade") != null else 1.0
		dano_final *= (h_mult * compat)
		if "tags" in hatsu and hatsu.tags is Array:
			for tg in hatsu.tags:
				if tg not in tags_efetivas:
					tags_efetivas.append(tg)

	tags_efetivas = GameplayTags.normalize(tags_efetivas)

	if nen_system != null:
		if nen_system.has_method("aplicar_shu_no_dano"):
			dano_final = nen_system.aplicar_shu_no_dano(dano_final)
		if nen_system.has_method("aplicar_ryu_no_dano_ataque"):
			dano_final = nen_system.aplicar_ryu_no_dano_ataque(dano_final)
		if nen_system.has_method("tecnica_ativa"):
			if nen_system.tecnica_ativa(NenSystem.Tecnica.GYO):
				dano_final *= 1.35
			if nen_system.tecnica_ativa(NenSystem.Tecnica.ZETSU) and inimigo_alvo != null:
				dano_final *= 3.0

	if PlayerData.afinidade_nen == NenAffinityData.CategoriaAfinidade.ESPECIALIZACAO:
		dano_final *= 1.50

	# Mitigações do alvo com base em fraquezas, resistências e imunidades
	if inimigo_alvo != null and not tags_efetivas.is_empty():
		var def_weakness: Array = []
		var def_resistance: Array = []
		var def_immunity: Array = []

		if "enemy_data" in inimigo_alvo and inimigo_alvo.enemy_data != null:
			def_weakness = inimigo_alvo.enemy_data.weakness_tags
			def_resistance = inimigo_alvo.enemy_data.resistance_tags
			def_immunity = inimigo_alvo.enemy_data.immunity_tags
		elif "weakness_tags" in inimigo_alvo:
			def_weakness = inimigo_alvo.weakness_tags
			def_resistance = inimigo_alvo.resistance_tags
			def_immunity = inimigo_alvo.immunity_tags

		if GameplayTags.has_any(def_immunity, tags_efetivas):
			dano_final = 0.0
		else:
			if GameplayTags.has_any(def_weakness, tags_efetivas):
				dano_final *= 1.50
			if GameplayTags.has_any(def_resistance, tags_efetivas):
				dano_final *= 0.50

	return max(1 if dano_final > 0.0 else 0, int(round(dano_final)))

func calcular_dano_sofrido_jogador(
	dano_bruto: int,
	nen_system: Node = null,
	hatsu_system: Node = null,
	atacante: Node = null,
	contexto_combate: Dictionary = {},
	attack_tags: Array = []
) -> int:
	var ctx := construir_contexto_combate(atacante, null, contexto_combate)
	atualizar_contexto_skill_tree(ctx)

	var tags_efetivas: Array = attack_tags.duplicate()
	if tags_efetivas.is_empty():
		if contexto_combate.has("attack_tags"):
			tags_efetivas = contexto_combate.get("attack_tags", []).duplicate()
		elif atacante != null:
			if "attack_tags" in atacante and atacante.attack_tags != null:
				tags_efetivas = atacante.attack_tags.duplicate()
			elif "enemy_data" in atacante and atacante.enemy_data != null and atacante.enemy_data.attack_tags != null:
				tags_efetivas = atacante.enemy_data.attack_tags.duplicate()

	tags_efetivas = GameplayTags.normalize(tags_efetivas)

	var dano_modificado: float = float(dano_bruto)
	if not tags_efetivas.is_empty():
		if PlayerData.eh_imune_a(tags_efetivas):
			return 0
		if PlayerData.eh_vulneravel_a(tags_efetivas):
			dano_modificado *= 1.50
		if PlayerData.eh_resistente_a(tags_efetivas):
			dano_modificado *= 0.50

	var dano_com_ten: float = dano_modificado

	if nen_system != null:
		if nen_system.has_method("aplicar_ten_no_dano"):
			dano_com_ten = nen_system.aplicar_ten_no_dano(dano_com_ten)
		if nen_system.has_method("aplicar_ken_no_dano"):
			dano_com_ten = nen_system.aplicar_ken_no_dano(dano_com_ten)
		if nen_system.has_method("aplicar_ryu_no_dano_defesa"):
			dano_com_ten = nen_system.aplicar_ryu_no_dano_defesa(dano_com_ten)

	if PlayerData.afinidade_nen == NenAffinityData.CategoriaAfinidade.ESPECIALIZACAO:
		dano_com_ten *= 0.65

	var defesa: int = int(PlayerData.attributes.get("defesa", 10))
	var dano_final: int = max(int(round(dano_com_ten)) - defesa, 1)

	if hatsu_system != null:
		if hatsu_system.has_method("registrar_dano_sofrido_vow"):
			hatsu_system.registrar_dano_sofrido_vow(dano_final, atacante)
		if hatsu_system.has_method("absorver_dano_escudo"):
			dano_final = hatsu_system.absorver_dano_escudo(dano_final, atacante)

	return max(0, dano_final)
