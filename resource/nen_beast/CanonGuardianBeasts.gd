class_name CanonGuardianBeasts
extends Resource

# ============================================================
# HUNTER ONLINE - CANON GUARDIAN BEASTS (MANGÁ KAKIN IMPERIAL)
# ============================================================
#
# Catálogo de Bestas de Nen Guardiãs dos 14 Príncipes de Kakin
# (Arco da Guerra de Sucessão no Mangá). Servindo de base
# para o sistema de Bestas de Nen do jogador!
#
# ============================================================

static func obter_bestas_guardias_manga() -> Array[Dictionary]:
	return [
		{
			"principe": "1º Príncipe Benjamin",
			"nome_besta": "Herança do Soldado (Besta de Lealdade)",
			"efeito": "Herda passivamente os Hatsus e atributos de todos os subordinados que morrem em combate.",
			"tipo": NenBeastData.TipoHabilidade.FURIA_BERSERKER
		},
		{
			"principe": "2ª Princesa Camilla",
			"nome_besta": "Cat's Name (Gato de Nove Vidas)",
			"efeito": "Nen Pós-Morte: Se a hospedeira morrer, a besta gigante esmaga o agressor e drena sua vida para ressuscitá-la 100%.",
			"tipo": NenBeastData.TipoHabilidade.REGENERACAO_FENIX
		},
		{
			"principe": "3º Príncipe Zhang Lei",
			"nome_besta": "Moeda de Ouro da Fortuna",
			"efeito": "Gera moedas de Nen que acumulam poder passivo e aumentam os ganhos de Jenny (Gold) e regeneração de Aura.",
			"tipo": NenBeastData.TipoHabilidade.AURA_INFINITA
		},
		{
			"principe": "4º Príncipe Tserriednich",
			"nome_besta": "Besta de 2 Rostos & Visão do Futuro",
			"efeito": "Permite antever 10 segundos no futuro e aplicar ilusões mentais, reduzindo o dano recebido a 0.",
			"tipo": NenBeastData.TipoHabilidade.GUARDIAN_SHIELD
		},
		{
			"principe": "8º Príncipe Salé-salé",
			"nome_besta": "Fumaça de Manipulação de Massa",
			"efeito": "Exala uma névoa de aura que torna os inimigos ao redor dóceis e reduz seus ataques em 40%.",
			"tipo": NenBeastData.TipoHabilidade.DRENAGEM_VAMPIRICA
		},
		{
			"principe": "9º Príncipe Halkenburg",
			"nome_besta": "Flecha da Armadura Coletiva",
			"efeito": "Une a aura de todos os aliados no mapa para disparar uma flecha inesquivável que atravessa qualquer escudo.",
			"tipo": NenBeastData.TipoHabilidade.FURIA_BERSERKER
		}
	]
