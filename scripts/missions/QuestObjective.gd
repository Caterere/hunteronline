class_name QuestObjective
extends Resource


enum Type {
	KILL,
	COLLECT,
	CRAFT,
	VISIT,
	INVESTIGATE,
	STEALTH_PASS,
	PERSUASION
}


@export var type: Type = Type.VISIT


@export_group("Kill")

@export var enemy_type: StringName = &""


@export_group("Item")

@export var item_id: StringName = &""
@export var required_amount: int = 1


@export_group("NPC")

@export var target_npc_id: StringName = &""
@export var target_npc_name: String = ""


@export_group("Investigation / Stealth")

@export var target_clue_id: StringName = &""
@export var target_zone_id: StringName = &""


@export_group("Condições & Opcionalidade")

@export var is_optional: bool = false
@export var conditions: Array[GameplayCondition] = []


func avaliar_condicoes(contexto: Dictionary) -> bool:
	if conditions.is_empty():
		return true
	for cond in conditions:
		if cond != null and not cond.evaluate(contexto):
			return false
	return true


func describe() -> String:
	var desc_base: String = ""
	match type:

		Type.KILL:
			var nome_inimigo := str(enemy_type)
			if nome_inimigo.is_empty() or nome_inimigo == "any" or nome_inimigo == "inimigo" or nome_inimigo == "monstro":
				desc_base = "⚔️ Derrote Criaturas / Inimigos da Área"
			elif nome_inimigo == "fera_floresta":
				desc_base = "⚔️ Derrote Feras da Floresta (GPS → Floresta dos Vestígios)"
			elif nome_inimigo == "guardiao_ancestral":
				desc_base = "⚔️ Derrote o Guardião Ancestral (Ruínas de Zaban)"
			else:
				desc_base = "⚔️ Derrote %s" % nome_inimigo.replace("_", " ").capitalize()

		Type.COLLECT:
			desc_base = "🎒 Colete %s" % str(item_id).replace("_", " ").capitalize()

		Type.CRAFT:
			desc_base = "🔨 Forje/Crie %s" % str(item_id).replace("_", " ").capitalize()

		Type.VISIT:
			if target_npc_name.is_empty():
				desc_base = "💬 Converse com o NPC"
			else:
				desc_base = "💬 Fale com %s" % target_npc_name

		Type.INVESTIGATE:
			var cid := str(target_clue_id).to_lower()
			match cid:
				"floresta_aura_raizes":
					desc_base = "🔍 [G] Gyo — Raízes Pulsantes (Árvore Milenar)"
				"floresta_pegadas_fera":
					desc_base = "🔍 [G] Gyo — Pegadas Predatórias (sul → Ruínas)"
				"zaban_selo_antecamara":
					desc_base = "🔍 [G] Gyo — Selo de Pedra (Antecâmara)"
				"zaban_fissura_aura":
					desc_base = "🔍 [G] Gyo — Fissura de Aura (Câmara)"
				"zaban_pilar_ko":
					desc_base = "💥 [KO] Quebre o Pilar Rachado da Câmara"
				"livro_greed":
					desc_base = "🔍 [G] Gyo — Spell Book (Antokiba)"
				"desfiladeiro_biscuit":
					desc_base = "🔍 [G] Gyo — Desfiladeiro de Pedras (Biscuit)"
				"explosao_bomber":
					desc_base = "🔍 [G] Gyo — Marca da Explosão do Bomber"
				"quiz_100_cartas":
					desc_base = "🔍 [G] Gyo — Altar das 100 Cartas"
				"porto_soufrabi":
					desc_base = "🔍 [G] Gyo — Porto de Soufrabi"
				"ginasio_razor":
					desc_base = "🔍 [G] Gyo — Ginásio da Queimada Mortal"
				"carta_002_litoral":
					desc_base = "🔍 [G] Gyo — Eco da Carta 002"
				"sopro_arcanjo":
					desc_base = "🔍 [G] Gyo — Sopro do Arcanjo (Carta 017)"
				"fabrica_d2_gyro":
					desc_base = "🔍 [G] Gyo — Fábrica Clandestina de D2"
				"nascimento_rei_meruem":
					desc_base = "🔍 [G] Gyo — Vestígio do Nascimento do Rei"
				"portas_knov":
					desc_base = "🔍 [G] Gyo — Portas Dimensionais de Knov"
				"chuva_dragoes_zeno":
					desc_base = "🔍 [G] Gyo — Marcas da Chuva de Dragões"
				"buda_guanyin_netero":
					desc_base = "🔍 [G] Gyo — Guanyin Bodhisattva (Netero)"
				"explosao_rosa_pobre":
					desc_base = "🔍 [G] Gyo — Rosa Pobre (Poor Man's Rose)"
				"escadaria_youpi":
					desc_base = "🔍 [G] Gyo — Escadaria Central (Youpi)"
				"cela_alluka":
					desc_base = "🔍 [G] Gyo — Cela / Cofre de Alluka"
				"uti_gon_associacao":
					desc_base = "🔍 [G] Gyo — UTI de Gon (Hospital Hunter)"
				"plenario_eleicao":
					desc_base = "🔍 [G] Gyo — Plenário da Eleição"
				"mapa_lago_mobius":
					desc_base = "🔍 [G] Gyo — Mapa do Lago Mobius"
				"ruinas_botanicas":
					desc_base = "🔍 [G] Gyo — Ruínas Botânicas Ancestrais"
				"horizonte_infinito":
					desc_base = "🔍 [G] Gyo — Horizonte Sem Fim"
				"pista_furto_janela", "pista_furto_pegada", "pista_furto_esconderijo":
					desc_base = "🔍 [G] Gyo — Pista do furto '%s'" % cid.replace("pista_furto_", "").capitalize()
				_:
					desc_base = "🔍 [GYO] Investigue a pista '%s'" % str(target_clue_id).replace("_", " ").capitalize()

		Type.STEALTH_PASS:
			var zid := str(target_zone_id).to_lower()
			match zid:
				"acampamento_salteadores_norte":
					desc_base = "🥷 [Z] Zetsu — atravesse o Acampamento Norte"
				"zaban_corredor_sentinelas":
					desc_base = "🥷 [Z] Zetsu — atravesse o Corredor das Sentinelas"
				"clareira_predadores_leste":
					desc_base = "🥷 [Z] Zetsu — atravesse a Clareira Leste"
				"armadilha_cova_gon":
					desc_base = "🥷 [Z] Zetsu — atravesse a Cova-Armadilha"
				"apagao_yorknew":
					desc_base = "🥷 [Z] Zetsu — Subestação do Apagão"
				"greed_ginasio_vestibulo":
					desc_base = "🥷 [Z] Zetsu — Vestíbulo do Ginásio"
				"fronteira_goruto":
					desc_base = "🥷 [Z] Zetsu — Fronteira Fortificada de Goruto"
				"ngl_vestibulo_tumba":
					desc_base = "🥷 [Z] Zetsu — Vestíbulo da Tumba Nuclear"
				"aguas_proibidas":
					desc_base = "🥷 [Z] Zetsu — Águas Proibidas"
				"caverna_hellbell":
					desc_base = "🥷 [Z] Zetsu — Caverna Hellbell"
				_:
					desc_base = "🥷 [ZETSU] Atravesse a zona '%s' furtivamente" % str(target_zone_id).replace("_", " ").capitalize()

		Type.PERSUASION:
			desc_base = "🤝 Convença / Negocie com %s" % (target_npc_name if not target_npc_name.is_empty() else str(target_npc_id).capitalize())

		_:
			desc_base = "Objetivo da Missão"

	if is_optional:
		return "⭐ [OPCIONAL] " + desc_base
	return desc_base
