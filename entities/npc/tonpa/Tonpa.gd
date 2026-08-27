extends NPC

# ============================================================
# HUNTER ONLINE - NPC: TONPA (O ESMAGA-NOVATOS)
# ============================================================
#
# Veterano do Exame Hunter que participa há 35 anos apenas
# para ver novatos talentosos entrarem em desespero e fracassarem.
# Dispara o evento surpresa da bebida com laxante/veneno.
#
# ============================================================

func _ready() -> void:
	super()
	npc_name = "Tonpa"
	fala_padrao = "Hehe... Cuidado para não desmaiar de exaustão na maratona!"


func _on_interacted(_player: CharacterBody2D) -> void:
	print("[Tonpa] Interagindo com Tonpa o Esmaga-Novatos...")
	QuestSystem.register_npc_visit(&"tonpa")

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null:
		var tem_gyo = PlayerData.attributes.get("nivel_nen", 0) > 0 if PlayerData else false
		var res_tonpa = SurpriseQuestSystem.processar_interacao_tonpa(tem_gyo) if SurpriseQuestSystem else {}
		
		var falas: Array[Dictionary] = [
			{"falante": "Tonpa", "texto": "Ora ora, veja só! Mais um novato cheio de sonhos! Este já é o meu 35º Exame Hunter, sabia? Conheço cada canto deste mundo."},
			{"falante": "Tonpa", "texto": "Para selar nossa aliança de Caçadores, pegue esta lata de suco gelada! Vai te dar uma energia incrível!"}
		]
		
		if tem_gyo:
			falas.append({"falante": "Você (Concentrando Gyo)", "texto": "(Concentrando Nen nos olhos com Gyo, você enxerga claramente os resíduos de laxante paralisante na tampa da lata! Você esmaga a lata com aura e encara o veterano!)"})
			falas.append({"falante": "Tonpa", "texto": "Argh!... Como você percebeu?! Esse olhar... você não é um novato comum! Título Desbloqueado: [👁️ Imune a Trapaças]!"})
		else:
			falas.append({"falante": "Você", "texto": "(Você aceita a bebida e bebe um gole... Alguns segundos depois uma dor aguda atinge seu estômago!)"})
			falas.append({"falante": "Tonpa", "texto": "Hahahahaha! Caiu direitinho! Mais um novato ingênuo destruído pelo veterano Tonpa!"})
			
		visual_dialogue.exibir_sequencia_falas(falas)
	else:
		falar_balao(fala_padrao, 3.5, Color(1.0, 0.7, 0.2, 1.0))
