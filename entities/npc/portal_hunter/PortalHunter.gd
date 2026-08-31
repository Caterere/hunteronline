extends NPC

# ============================================================
# HUNTER ONLINE - NPC: GUIA DE EXPEDIÇÃO & MUNDO (LOBBY)
# ============================================================
#
# NPC da Associação Hunter no Lobby (lobby.tscn):
# - Orienta o jogador sobre a travessia contínua pelo mundo
# - Fornece informações sobre o Arco atual e status das rotas
# - Explica o funcionamento dos Portais de Saga e StoryGates
#
# ============================================================


func _ready() -> void:
	super()
	npc_name = "Guia de Expedição"
	fala_padrao = "Saudações, Hunter! O mundo lá fora é vasto e repleto de desafios. Atravesse o Portão Sul para iniciar sua jornada pelo 287º Exame Hunter!"


func _on_interacted(_player: CharacterBody2D) -> void:
	QuestSystem.register_npc_visit(&"portal_hunter")

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null:
		var arco: int = PlayerData.arco_atual if PlayerData != null else 1
		var etapa: int = PlayerData.etapa_quest_arco if PlayerData != null else 1
		var total_etapas: int = CanonQuestCatalog.obter_total_quests_do_arco(arco) if CanonQuestCatalog != null else 24
		
		var info_saga: String = ""
		match arco:
			1: info_saga = "Você está no [Arco 1: 287º Exame Hunter]. Atravesse o Portão Sul de Hunter Plaza para entrar no Túnel Subterrâneo de Zaban!"
			2: info_saga = "Você está no [Arco 2: Montanha Kukuroo]. Siga pelo portão ao final do Exame para alcançar a residência dos Zoldyck."
			3: info_saga = "Você está no [Arco 3: Arena Celestial]. O elevador dimensional do Distrito Leste ou o portal da montanha levam você aos 200 andares."
			4: info_saga = "Você está no [Arco 4: Yorknew City]. O leilão subterrâneo e a Trupe Fantasma aguardam seu avanço."
			5: info_saga = "Você está no [Arco 5: Greed Island]. O console mágico do jogo dos caçadores está ativo."
			6: info_saga = "Você está no [Arco 6: NGL Formigas Chimera]. Território hostil em alerta máximo."
			7: info_saga = "Você está no [Arco 7: Eleição Hunter]. A Associação está reunida na sede."
			8: info_saga = "Você está no [Arco 8: Continente Negro]. Expedição das 5 Calamidades."
			9: info_saga = "Você está no [Arco 9: Black Whale 1]. Guerra de Sucessão de Kakin."
			_: info_saga = "Explore o mundo e viaje através dos portais de cada região!"

		var falas: Array[Dictionary] = [
			{
				"falante": "Guia de Expedição",
				"texto": "Bem-vindo à Associação Hunter! Não operamos mais por simples teletransporte. Para ser um verdadeiro Caçador, você deve viajar fisicamente pelo mundo!"
			},
			{
				"falante": "Guia de Expedição",
				"texto": "%s (Progresso atual da Saga: Fase %d/%d)" % [info_saga, etapa, total_etapas]
			},
			{
				"falante": "Guia de Expedição",
				"texto": "Lembre-se: os Portais entre Sagas possuem selos de Nen (StoryGates). Eles só se abrirão após você concluir as missões e requisitos de cada região. Boa sorte na viagem!"
			}
		]
		visual_dialogue.exibir_sequencia_falas(falas)
		await visual_dialogue.dialogo_concluido
