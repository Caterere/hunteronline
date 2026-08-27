extends Node

# ============================================================
# HUNTER ONLINE - ACHIEVEMENT SYSTEM (AUTOLOAD / SINGLETON)
# ============================================================
#
# Sistema de Conquistas & Platina estilo Dragon Ball Xenoverse:
# - 40 Conquistas profundas e desafiadoras (Bronze, Prata, Ouro, Platina).
# - Monitoramento em tempo real de mortes, perfect dodges, andares,
#   missões paralelas, técnicas de Nen e economia.
# - Recompensas em Jenny, Títulos lendários e Aura.
#
# ============================================================

signal conquista_desbloqueada(id_conquista: String, info: Dictionary)
signal progresso_atualizado()

enum Raridade { BRONZE, PRATA, OURO, PLATINA }

const CONQUISTAS_CATALOGO := {
	# HISTÓRIA & LICENÇA
	"primeiro_passo": {
		"nome": "Primeiro Passo",
		"categoria": "História",
		"raridade": Raridade.BRONZE,
		"descricao": "Inicie o Exame Hunter e conclua a Maratona Subterrânea.",
		"recompensa_jenny": 5000,
		"recompensa_titulo": "Aspirante",
		"icone": "🥉"
	},
	"cacador_licenciado": {
		"nome": "Caçador Licenciado",
		"categoria": "História",
		"raridade": Raridade.BRONZE,
		"descricao": "Conquiste a Licença Hunter oficial da Associação.",
		"recompensa_jenny": 25000,
		"recompensa_titulo": "Hunter Licenciado",
		"icone": "🥉"
	},
	"cacador_1_estrela": {
		"nome": "Caçador de 1 Estrela",
		"categoria": "História",
		"raridade": Raridade.PRATA,
		"descricao": "Atinja o Nível 50 e complete uma especialização Hunter.",
		"recompensa_jenny": 100000,
		"recompensa_titulo": "Hunter 1-Star",
		"icone": "🥈"
	},
	"cacador_2_estrelas": {
		"nome": "Caçador de 2 Estrelas",
		"categoria": "História",
		"raridade": Raridade.PRATA,
		"descricao": "Conclua todas as 9 Sagas principais do Modo História.",
		"recompensa_jenny": 500000,
		"recompensa_titulo": "Hunter 2-Star",
		"icone": "🥈"
	},
	"cacador_3_estrelas": {
		"nome": "Caçador de 3 Estrelas (Lendário)",
		"categoria": "História",
		"raridade": Raridade.OURO,
		"descricao": "Alcance o Nível 100 de Personagem e Nível 100 de Nen.",
		"recompensa_jenny": 2000000,
		"recompensa_titulo": "Hunter 3-Star Lendário",
		"icone": "🥇"
	},

	# COMBATE & NEN
	"reflexos_cacador": {
		"nome": "Reflexos de Caçador",
		"categoria": "Combate",
		"raridade": Raridade.BRONZE,
		"descricao": "Execute 50 Perfect Dodges em batalha.",
		"meta": 50,
		"stat_chave": "perfect_dodges",
		"recompensa_jenny": 10000,
		"recompensa_titulo": "Ágil",
		"icone": "🥉"
	},
	"mestre_do_tempo": {
		"nome": "Mestre do Tempo",
		"categoria": "Combate",
		"raridade": Raridade.PRATA,
		"descricao": "Execute 500 Perfect Dodges em batalha.",
		"meta": 500,
		"stat_chave": "perfect_dodges",
		"recompensa_jenny": 100000,
		"recompensa_titulo": "Espectro Temporal",
		"icone": "🥈"
	},
	"instinto_assassino": {
		"nome": "Instinto Superior de Esquiva",
		"categoria": "Combate",
		"raridade": Raridade.OURO,
		"descricao": "Execute 2.000 Perfect Dodges em combate real.",
		"meta": 2000,
		"stat_chave": "perfect_dodges",
		"recompensa_jenny": 1000000,
		"recompensa_titulo": "Intocável",
		"icone": "🥇"
	},
	"despertar_aura": {
		"nome": "Despertar da Aura",
		"categoria": "Combate",
		"raridade": Raridade.BRONZE,
		"descricao": "Abra seus nós de Nen com o Mestre Wing na Arena Celestial.",
		"recompensa_jenny": 15000,
		"recompensa_titulo": "Iniciado de Nen",
		"icone": "🥉"
	},
	"mestre_das_9_artes": {
		"nome": "Mestre Supremo das 9 Técnicas",
		"categoria": "Combate",
		"raridade": Raridade.OURO,
		"descricao": "Alcance o Nível 100 em TODAS as 9 técnicas de Nen (Ten, Ren, Zetsu, Gyo, Shu, Ko, En, Ken, Ryu).",
		"recompensa_jenny": 5000000,
		"recompensa_titulo": "Grão-Mestre Shingen-ryu",
		"icone": "🥇"
	},
	"deus_do_dano": {
		"nome": "Impacto Devastador",
		"categoria": "Combate",
		"raridade": Raridade.OURO,
		"descricao": "Cause mais de 1.000.000 de dano em um único golpe de Ko/Hatsu.",
		"meta": 1000000,
		"stat_chave": "dano_maximo_golpe",
		"recompensa_jenny": 1500000,
		"recompensa_titulo": "Destruidor de Nações",
		"icone": "🥇"
	},
	"exterminador": {
		"nome": "Exterminador de Criaturas",
		"categoria": "Combate",
		"raridade": Raridade.OURO,
		"descricao": "Derrote 10.000 inimigos pelo mundo.",
		"meta": 10000,
		"stat_chave": "inimigos_derrotados",
		"recompensa_jenny": 2500000,
		"recompensa_titulo": "O Flagelo",
		"icone": "🥇"
	},

	# TORRE CELESTIAL
	"guerreiro_50": {
		"nome": "Guerreiro da Arena (50F)",
		"categoria": "Torre",
		"raridade": Raridade.BRONZE,
		"descricao": "Alcance o 50º Andar da Torre Celestial.",
		"recompensa_jenny": 50000,
		"recompensa_titulo": "Gladiador",
		"icone": "🥉"
	},
	"guerreiro_100": {
		"nome": "Combatente de Elite (100F)",
		"categoria": "Torre",
		"raridade": Raridade.PRATA,
		"descricao": "Alcance o 100º Andar da Torre Celestial.",
		"recompensa_jenny": 200000,
		"recompensa_titulo": "Veterano da Arena",
		"icone": "🥈"
	},
	"batismo_superado": {
		"nome": "O Batismo de Nen (200F)",
		"categoria": "Torre",
		"raridade": Raridade.PRATA,
		"descricao": "Sobreviva à Barreira Assassina de Nen e alcance o 200º Andar.",
		"recompensa_jenny": 500000,
		"recompensa_titulo": "Sobrevivente do Batismo",
		"icone": "🥈"
	},
	"floor_master": {
		"nome": "Mestre de Andar (Floor Master)",
		"categoria": "Torre",
		"raridade": Raridade.OURO,
		"descricao": "Derrote os desafiantes do 200º Andar e conquiste o título de Floor Master.",
		"recompensa_jenny": 5000000,
		"recompensa_titulo": "Floor Master",
		"icone": "🥇"
	},

	# MISSÕES PARALELAS (XENOVERSE PQs)
	"alterador_tempo": {
		"nome": "Fenda Temporal Inicial",
		"categoria": "Missões",
		"raridade": Raridade.BRONZE,
		"descricao": "Conclua 10 Missões Paralelas com o Examinador Chrono.",
		"recompensa_jenny": 50000,
		"recompensa_titulo": "Patrulheiro Temporal",
		"icone": "🥉"
	},
	"guardiao_temporal": {
		"nome": "Guardião da Linha do Tempo",
		"categoria": "Missões",
		"raridade": Raridade.PRATA,
		"descricao": "Conclua 25 Missões Paralelas What-If.",
		"recompensa_jenny": 250000,
		"recompensa_titulo": "Guardião das Fendas",
		"icone": "🥈"
	},
	"dominador_temporal": {
		"nome": "Dominador Temporal Supremo",
		"categoria": "Missões",
		"raridade": Raridade.OURO,
		"descricao": "Conclua TODAS as 50 Missões Paralelas What-If.",
		"recompensa_jenny": 5000000,
		"recompensa_titulo": "Mestre das Dimensões",
		"icone": "🥇"
	},

	# ECONOMIA, FORJA & RECOMPENSAS
	"primeira_fortuna": {
		"nome": "Primeira Fortuna",
		"categoria": "Economia",
		"raridade": Raridade.BRONZE,
		"descricao": "Acumule um saldo de 100.000 Jenny.",
		"recompensa_jenny": 10000,
		"recompensa_titulo": "Próspero",
		"icone": "🥉"
	},
	"milionario_yorknew": {
		"nome": "Milionário de Yorknew",
		"categoria": "Economia",
		"raridade": Raridade.PRATA,
		"descricao": "Acumule um saldo de 10.000.000 Jenny.",
		"recompensa_jenny": 500000,
		"recompensa_titulo": "Milionário",
		"icone": "🥈"
	},
	"magnata_submundo": {
		"nome": "Magnata do Submundo",
		"categoria": "Economia",
		"raridade": Raridade.OURO,
		"descricao": "Acumule um saldo de 100.000.000 Jenny.",
		"recompensa_jenny": 10000000,
		"recompensa_titulo": "Magnata Mundial",
		"icone": "🥇"
	},
	"mestre_armeiro": {
		"nome": "Forja dos Deuses",
		"categoria": "Economia",
		"raridade": Raridade.PRATA,
		"descricao": "Aprimore um equipamento ou acessório até o nível +10 no Ferreiro.",
		"recompensa_jenny": 250000,
		"recompensa_titulo": "Mestre da Forja",
		"icone": "🥈"
	},
	"cacador_recompensas": {
		"nome": "Terror da Máfia",
		"categoria": "Economia",
		"raridade": Raridade.OURO,
		"descricao": "Capture 50 criminosos no Quadro de Procurados.",
		"meta": 50,
		"stat_chave": "bounties_capturados",
		"recompensa_jenny": 1500000,
		"recompensa_titulo": "Caçador de Recompensas",
		"icone": "🥇"
	},

	# GREED ISLAND, BESTAS DE NEN & ESPECIALIZAÇÃO
	"mestre_greed_island": {
		"nome": "Vencedor de Greed Island",
		"categoria": "Coleção",
		"raridade": Raridade.OURO,
		"descricao": "Colete todas as 100 Cartas Especificadas de Greed Island no Binder.",
		"recompensa_jenny": 10000000,
		"recompensa_titulo": "Vencedor de Greed Island",
		"icone": "🥇"
	},
	"hospedeiro_imperial": {
		"nome": "Hospedeiro Imperial",
		"categoria": "Coleção",
		"raridade": Raridade.PRATA,
		"descricao": "Desperte sua primeira Besta de Nen Guardiã na Urna Sagrada de Kakin.",
		"recompensa_jenny": 200000,
		"recompensa_titulo": "Hospedeiro da Besta",
		"icone": "🥈"
	},
	"besta_suprema": {
		"nome": "Besta Sagrada Perfeita",
		"categoria": "Coleção",
		"raridade": Raridade.OURO,
		"descricao": "Obtenha uma Besta de Nen com Potencial de Aura (IV) de 1.40x ou superior.",
		"recompensa_jenny": 2000000,
		"recompensa_titulo": "Guardião Lendário",
		"icone": "🥇"
	},
	"escolhido_deuses": {
		"nome": "O Escolhido dos Deuses",
		"categoria": "Coleção",
		"raridade": Raridade.OURO,
		"descricao": "Desperte a raríssima Categoria de Especialização (1 em 100.000).",
		"recompensa_jenny": 5000000,
		"recompensa_titulo": "Especialista Absoluto",
		"icone": "🥇"
	},

	# PLATINA SUPREMA (100% DE CONCLUSÃO DO JOGO)
	"hunter_supremo_platina": {
		"nome": "💎 HUNTER SUPREMO (TROFÉU DE PLATINA)",
		"categoria": "Platina",
		"raridade": Raridade.PLATINA,
		"descricao": "Conclua 100% de todas as outras conquistas de Hunter Online. A glória máxima para os verdadeiros mestres!",
		"recompensa_jenny": 50000000,
		"recompensa_titulo": "👑 O Caçador Absoluto (Platina)",
		"icone": "💎"
	}
}


func _ready() -> void:
	print("=================================")
	print("[AchievementSystem] SISTEMA DE CONQUISTAS & PLATINA ATIVO")
	print("TOTAL DE CONQUISTAS:", CONQUISTAS_CATALOGO.size())
	print("=================================")


func verificar_todas_conquistas() -> void:
	for ach_id in CONQUISTAS_CATALOGO.keys():
		if ach_id == "hunter_supremo_platina":
			continue
		if not esta_desbloqueada(ach_id):
			if _checar_condicao(ach_id):
				desbloquear_conquista(ach_id)

	# Verificar Platina
	if not esta_desbloqueada("hunter_supremo_platina"):
		if _checar_platina():
			desbloquear_conquista("hunter_supremo_platina")


func _checar_condicao(ach_id: String) -> bool:
	var info: Dictionary = CONQUISTAS_CATALOGO[ach_id]

	# Checagem por Stat
	if info.has("stat_chave") and info.has("meta"):
		var stat_atual = int(PlayerData.stats_globais.get(info["stat_chave"], 0))
		return stat_atual >= int(info["meta"])

	match ach_id:
		"primeiro_passo":
			return PlayerData.arco_atual > 1 or PlayerData.etapa_quest_arco > 1
		"cacador_licenciado":
			return PlayerData.arco_atual >= 2
		"cacador_1_estrela":
			return int(PlayerData.attributes.get("nivel", 1)) >= 50
		"cacador_2_estrelas":
			return PlayerData.modo_historia_concluido or PlayerData.arco_atual >= 9
		"cacador_3_estrelas":
			return int(PlayerData.attributes.get("nivel", 1)) >= 100 and int(PlayerData.attributes.get("nivel_nen", 0)) >= 100
		"despertar_aura":
			return PlayerData.despertou_nen
		"mestre_das_9_artes":
			var n_sys = Engine.get_main_loop().root.get_tree().get_first_node_in_group("nen_system") as NenSystem if Engine.get_main_loop() else null
			if n_sys != null:
				for i in range(9):
					if n_sys.niveis_tecnicas[i] < 100:
						return false
				return true
			return false
		"guerreiro_50":
			return PlayerData.torre_andar_atual >= 50
		"guerreiro_100":
			return PlayerData.torre_andar_atual >= 100
		"batismo_superado":
			return PlayerData.torre_andar_atual >= 200
		"floor_master":
			return PlayerData.torre_andar_atual > 200
		"alterador_tempo":
			return PlayerData.parallel_quests_concluidas.size() >= 10
		"guardiao_temporal":
			return PlayerData.parallel_quests_concluidas.size() >= 25
		"dominador_temporal":
			return PlayerData.parallel_quests_concluidas.size() >= 50
		"primeira_fortuna":
			return Economy.obter_gold() >= 100000
		"milionario_yorknew":
			return Economy.obter_gold() >= 10000000
		"magnata_submundo":
			return Economy.obter_gold() >= 100000000
		"mestre_armeiro":
			return int(PlayerData.stats_globais.get("equipamentos_mais_10", 0)) >= 1
		"mestre_greed_island":
			return int(PlayerData.stats_globais.get("cartas_coletadas", 0)) >= 100
		"hospedeiro_imperial":
			return PlayerData.besta_nen_desbloqueada
		"besta_suprema":
			if PlayerData.besta_nen_equipada != null:
				return PlayerData.besta_nen_equipada.potencial_iv >= 1.40
			return false
		"escolhido_deuses":
			return PlayerData.afinidade_nen == NenAffinityData.CategoriaAfinidade.ESPECIALIZACAO

	return false


func _checar_platina() -> bool:
	for ach_id in CONQUISTAS_CATALOGO.keys():
		if ach_id == "hunter_supremo_platina":
			continue
		if not esta_desbloqueada(ach_id):
			return false
	return true


func desbloquear_conquista(ach_id: String) -> void:
	if not CONQUISTAS_CATALOGO.has(ach_id):
		return
	if esta_desbloqueada(ach_id):
		return

	PlayerData.conquistas_desbloqueadas.append(ach_id)
	var info: Dictionary = CONQUISTAS_CATALOGO[ach_id]
	conquista_desbloqueada.emit(ach_id, info)
	progresso_atualizado.emit()

	var hud = Engine.get_main_loop().root.get_tree().get_first_node_in_group("player_hud") if Engine.get_main_loop() else null
	if hud and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("🏆 CONQUISTA DESBLOQUEADA!\n%s %s" % [info["icone"], info["nome"].to_upper()])

	print("=================================")
	print("[AchievementSystem] CONQUISTA CONQUISTADA: ", info["nome"])
	print("=================================")

	if GameState != null:
		GameState.salvar_jogo()


func resgatar_recompensa(ach_id: String) -> bool:
	if not esta_desbloqueada(ach_id) or esta_resgatada(ach_id):
		return false

	var info: Dictionary = CONQUISTAS_CATALOGO[ach_id]
	PlayerData.conquistas_resgatadas.append(ach_id)

	# Conceder Jenny
	if info.has("recompensa_jenny") and info["recompensa_jenny"] > 0:
		Economy.adicionar_gold(info["recompensa_jenny"])

	# Conceder Título
	if info.has("recompensa_titulo") and not info["recompensa_titulo"].is_empty():
		PlayerData.titulo_equipado = info["recompensa_titulo"]

	var hud = Engine.get_main_loop().root.get_tree().get_first_node_in_group("player_hud") if Engine.get_main_loop() else null
	if hud and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("🎁 RECOMPENSA RESGATADA!\n+%s Jenny | Título: %s" % [
			Economy.formatar_numero(info.get("recompensa_jenny", 0)), info.get("recompensa_titulo", "")
		])

	progresso_atualizado.emit()
	return true


func esta_desbloqueada(ach_id: String) -> bool:
	return PlayerData.conquistas_desbloqueadas.has(ach_id) if PlayerData != null else false


func tem_conquista(ach_id: String) -> bool:
	return esta_desbloqueada(ach_id)


func esta_resgatada(ach_id: String) -> bool:
	return PlayerData.conquistas_resgatadas.has(ach_id) if PlayerData != null else false


func obter_porcentagem_conclusao() -> float:
	var total: int = CONQUISTAS_CATALOGO.size()
	var desbloqueadas: int = PlayerData.conquistas_desbloqueadas.size() if PlayerData != null else 0
	return clamp((float(desbloqueadas) / float(total)) * 100.0, 0.0, 100.0)


func obter_catalogo_completo() -> Array:
	var lista: Array = []
	for id_k in CONQUISTAS_CATALOGO.keys():
		var d: Dictionary = CONQUISTAS_CATALOGO[id_k].duplicate()
		d["id"] = id_k
		lista.append(d)
	return lista


var conquistas_desbloqueadas: Array:
	get:
		return PlayerData.conquistas_desbloqueadas if PlayerData != null else []
