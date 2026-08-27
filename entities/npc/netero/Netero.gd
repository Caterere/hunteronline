extends NPC

# ============================================================
# HUNTER ONLINE - NPC: ISAAC NETERO (ARCO 6 — FORMIGAS CHIMERA)
# ============================================================
#
# Presidente da Associação Hunter.
# Lidera a invasão de extermínio às Formigas Chimera em NGL.
#
# ============================================================


func _ready() -> void:
	super()
	npc_name = "Netero"


func _on_interacted(_player: CharacterBody2D) -> void:
	print("[Netero] Interagindo com o Presidente Netero...")
	QuestSystem.register_npc_visit(&"netero")

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue == null:
		return

	var falas: Array[Dictionary] = []
	var arco = PlayerData.arco_atual
	
	if arco == 1:
		falas = [
			{"falante": "Netero", "texto": "Ho ho! Sou Isaac Netero, Presidente da Associação Hunter. Boa sorte no exame!"}
		]
	elif arco == 6:
		falas = [
			{"falante": "Netero", "texto": "As Formigas Chimera em NGL são a maior ameaça que a humanidade já enfrentou."},
			{"falante": "Netero", "texto": "Para esta missão, selecionei pessoalmente cada Hunter. Você está entre eles."},
			{"falante": "Netero", "texto": "Eu treinei durante mais de 50 anos. 10.000 socos de gratidão por dia. Esse é o meu Nen."},
			{"falante": "Netero", "texto": "O Rei Meruem... ele pode ser mais forte que eu. Mas a humanidade tem um trunfo: a evolução infinita do potencial!"}
		]
	else:
		falas = [
			{"falante": "Netero", "texto": "Ho ho ho! Continue treinando, jovem Hunter! O mundo é vasto e cheio de surpresas!"}
		]

	visual_dialogue.exibir_sequencia_falas(falas)
