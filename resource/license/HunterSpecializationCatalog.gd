class_name HunterSpecializationCatalog
extends Resource

# ============================================================
# HUNTER ONLINE - HUNTER LICENSE & SPECIALIZATIONS CATALOG
# ============================================================

enum Patente {
	CIVIL,
	CANDIDATO_AO_EXAME,
	HUNTER_LICENCIADO,
	HUNTER_UMA_ESTRELA,
	HUNTER_DUAS_ESTRELAS,
	HUNTER_TRES_ESTRELAS
}

enum Especializacao {
	NENHUMA,
	GOURMET_HUNTER,
	TREASURE_HUNTER,
	BEAST_HUNTER,
	BLACKLIST_HUNTER,
	RUINS_HUNTER
}

const DADOS_ESPECIALIZACOES := {
	Especializacao.GOURMET_HUNTER: {
		"nome": "Gourmet Hunter (Caçador Gourmet)",
		"icone": "🍲",
		"inspiracao": "Menchi & Buhara",
		"descricao": "Especialista em ingredientes raros e nutrição de aura. +35% de eficácia em poções e regeneração natural dobrada.",
		"bonus_tipo": "REGENERACAO_E_CURA",
		"bonus_valor": 0.35
	},
	Especializacao.TREASURE_HUNTER: {
		"nome": "Treasure Hunter (Caçador de Tesouros)",
		"icone": "💎",
		"inspiracao": "Biscuit Krueger",
		"descricao": "Buscador de relíquias e itens lendários. +40% de Jenny em todas as atividades e dobro de chance de cartas raras.",
		"bonus_tipo": "DROP_E_OURO",
		"bonus_valor": 0.40
	},
	Especializacao.BEAST_HUNTER: {
		"nome": "Beast Hunter (Caçador de Feras)",
		"icone": "🐾",
		"inspiracao": "Kite & Knuckle",
		"descricao": "Protetor e estudioso de criaturas mágicas. +30% de dano contra monstros/quimeras e +20% poder para a Besta de Nen.",
		"bonus_tipo": "DANO_MONSTROS_E_BESTA",
		"bonus_valor": 0.30
	},
	Especializacao.BLACKLIST_HUNTER: {
		"nome": "Blacklist Hunter (Caçador de Criminosos)",
		"icone": "⚖️",
		"inspiracao": "Kurapika & Bushidora",
		"descricao": "Executor de mandados de prisão da Associação. Bounties de procurados pagam 100% a mais e +25% de dano em vilões.",
		"bonus_tipo": "BOUNTY_E_DANO_VILOES",
		"bonus_valor": 0.50
	},
	Especializacao.RUINS_HUNTER: {
		"nome": "Ruins Hunter (Caçador de Ruínas)",
		"icone": "🏛️",
		"inspiracao": "Ging Freecss & Satotz",
		"descricao": "Arqueólogo de civilizações perdidas. Imunidade a armadilhas de masmorras e acesso exclusivo a áreas do Continente Negro.",
		"bonus_tipo": "EXPLORACAO_E_TEMPLOS",
		"bonus_valor": 0.30
	}
}


static func obter_dados(esp: Especializacao) -> Dictionary:
	return DADOS_ESPECIALIZACOES.get(esp, {
		"nome": "Nenhuma Especialização",
		"icone": "🔰",
		"descricao": "Sem foco de caçada definido."
	})


static func obter_nome_patente(patente: Patente) -> String:
	match patente:
		Patente.CIVIL: return "Civil Comum"
		Patente.CANDIDATO_AO_EXAME: return "Candidato ao Exame Hunter"
		Patente.HUNTER_LICENCIADO: return "Hunter Licenciado (Licença Oficial)"
		Patente.HUNTER_UMA_ESTRELA: return "Hunter de 1 Estrela (★)"
		Patente.HUNTER_DUAS_ESTRELAS: return "Hunter de 2 Estrelas (★★)"
		Patente.HUNTER_TRES_ESTRELAS: return "Hunter de 3 Estrelas (★★★)"
		_: return "Desconhecido"
