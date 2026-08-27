extends NPC

# ============================================================
# HUNTER ONLINE - NPC: BODORO (ARCO 1 — EXAME HUNTER Nº 191)
# ============================================================
#
# Veterano mestre de artes marciais tradicionais.
# Preza pela honra, disciplina física e recusa o uso de trapaças.
#
# ============================================================

func _ready() -> void:
	super()
	npc_name = "Bodoro"


func _on_interacted(_player: CharacterBody2D) -> void:
	print("[Bodoro] Conversando com Bodoro...")
	QuestSystem.register_npc_visit(&"bodoro")

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null:
		var falas: Array[Dictionary] = [
			{
				"falante": "Bodoro (Nº 191)",
				"texto": "Humph! Mantenha a coluna ereta e a respiração ritmada, jovem. A corrida é um espelho da alma de um guerreiro."
			},
			{
				"falante": "Bodoro (Nº 191)",
				"texto": "Nos velhos tempos, aqueles que almejavam se tornar Caçadores forjavam o espírito nas montanhas e nos dojos através do combate desarmado e do respeito mútuo."
			},
			{
				"falante": "Bodoro (Nº 191)",
				"texto": "Hoje vejo novatos dependendo de truques sujos como venenos em latas de suco e armas automáticas. Mostre que sua determinação vem de dentro de sua própria musculatura e mente!"
			}
		]
		visual_dialogue.exibir_sequencia_falas(falas)
	else:
		falar_balao("Disciplina e honra! Não ceda ao cansaço corporal!", 4.0, Color(0.7, 0.7, 0.7, 1.0))
