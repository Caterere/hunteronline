extends NPC

# ============================================================
# HUNTER ONLINE - NPC: HANZO (ARCO 1 — EXAME HUNTER Nº 294)
# ============================================================
#
# Ninja descendente da Vila Oculta de Shinobi.
# Treinado rigorosamente desde os 4 anos em infiltração, venenos
# e técnicas marciais mortais. Deseja a Licença Hunter para
# encontrar o lendário "Pergaminho da Verdade" de seu clã.
#
# ============================================================

func _ready() -> void:
	super()
	npc_name = "Hanzo"


func _on_interacted(_player: CharacterBody2D) -> void:
	print("[Hanzo] Conversando com Hanzo...")
	QuestSystem.register_npc_visit(&"hanzo")

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null:
		var falas: Array[Dictionary] = [
			{
				"falante": "Hanzo (Nº 294)",
				"texto": "Ei, você! Não tente me ultrapassar se não tiver fôlego. Venho de uma linhagem direta de shinobi e treino meu corpo desde os 4 anos de idade!"
			},
			{
				"falante": "Hanzo (Nº 294)",
				"texto": "Já passei por testes de resistência onde precisei ficar submerso na neve durante semanas sem emitir um único som. Uma maratona de 80km subterrânea é apenas um aquecimento matinal."
			},
			{
				"falante": "Hanzo (Nº 294)",
				"texto": "Meu objetivo é obter a Licença Hunter para ter livre trânsito mundial e localizar o lendário 'Pergaminho Secreto de Shinobi'. Economize seu oxigênio se quiser sobreviver!"
			}
		]
		visual_dialogue.exibir_sequencia_falas(falas)
	else:
		falar_balao("Eu treino artes shinobi desde os 4 anos. Esta corrida é apenas um aquecimento!", 4.0, Color(0.9, 0.6, 0.2, 1.0))
