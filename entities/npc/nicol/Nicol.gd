extends NPC

# ============================================================
# HUNTER ONLINE - NPC: NICOL (ARCO 1 — EXAME HUNTER Nº 187)
# ============================================================
#
# O novato com memória fotográfica e laptop.
# Calcula meticulosamente estatísticas de aprovação, mas não possui
# o condicionamento físico sobre-humano exigido pelo Exame Hunter.
#
# ============================================================

func _ready() -> void:
	super()
	npc_name = "Nicol"


func _on_interacted(_player: CharacterBody2D) -> void:
	print("[Nicol] Conversando com Nicol...")
	QuestSystem.register_npc_visit(&"nicol")

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null:
		var falas: Array[Dictionary] = [
			{
				"falante": "Nicol (Nº 187)",
				"texto": "(Ofegante, digitando freneticamente no laptop) Meus cálculos... as probabilidades... nada faz sentido aqui!"
			},
			{
				"falante": "Nicol (Nº 187)",
				"texto": "Já corremos mais de 50 quilômetros sob a terra! A taxa média de desistência deveria ser de 23.4%, mas aquele examinador nem sequer está transpirando!"
			},
			{
				"falante": "Nicol (Nº 187)",
				"texto": "Minhas pernas estão dormentes... Como aqueles garotos conseguem conversar e rir enquanto correm a 40 km/h?! Este teste é uma loucura!"
			}
		]
		visual_dialogue.exibir_sequencia_falas(falas)
	else:
		falar_balao("Minhas estatísticas... o ritmo dessa maratona é humanamente impossível!", 4.0, Color(0.8, 0.8, 0.4, 1.0))
