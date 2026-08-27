class_name ZushiNPC
extends NPC

# ============================================================
# HUNTER ONLINE - NPC: ZUSHI (DISCÍPULO DE SHINGEN-RYU)
# ============================================================
#
# Jovem discípulo de Mestre Wing na Arena Celestial.
# Famoso pelo seu grito de determinação: "Osu!"
#
# ============================================================


func _ready() -> void:
	npc_name = "Zushi"
	fala_padrao = "Osu! Mestre Wing está me ensinando os fundamentos de Shingen-ryu!"
	super()


func _on_interacted(_player: CharacterBody2D) -> void:
	super(_player)
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue == null:
		return

	var falas: Array[Dictionary] = []
	falas.append({"falante": "Zushi", "texto": "Osu! Bem-vindo ao dojo da Associação Hunter!"})
	falas.append({"falante": "Zushi", "texto": "Mestre Wing diz que um em cem mil possui o dom do Nen, mas apenas com treino diário de Ten e Ren alcançaremos a maestria, Osu!"})
	if PlayerData.despertou_nen:
		falas.append({"falante": "Zushi", "texto": "Incrível! Sua aura é impressionante! Continue treinando firme, Osu!"})
	else:
		falas.append({"falante": "Zushi", "texto": "Fale com o Mestre Wing aqui ao lado para realizar o Teste da Água e despertar seus nós de aura, Osu!"})

	visual_dialogue.exibir_sequencia_falas(falas)
