extends NPC

# ============================================================
# HUNTER ONLINE - NPC: KILLUA ZOLDYCK
# ============================================================
#
# Membro da família Zoldyck (Transformador - Eletricidade).
# Oferece diálogos sobre táticas de combate e agilidade.
#
# ============================================================

@export var dialogue_tree: DialogueTree


func _ready() -> void:
	super()
	npc_name = "Killua"


func _on_interacted(_player: CharacterBody2D) -> void:
	print("Interagindo com Killua Zoldyck...")
	QuestSystem.register_npc_visit(&"killua")

	var arco = PlayerData.arco_atual
	match arco:
		1, 2:
			falar_balao("Hunf, esse exame é moleza pra mim no skate! Mas você e o Gon são bem rápidos. Vamos manter o ritmo!", 3.8, Color(0.3, 0.8, 1.0, 1.0))
		3:
			falar_balao("O Wing-san disse que temos grande potencial pra Nen! Vamos treinar juntos na Arena Celestial!", 3.8, Color(0.3, 0.8, 1.0, 1.0))
		4:
			falar_balao("Yorknew City é perigosa. A Trupe Fantasma tá na área... Vamos dar cobertura pro Kurapika!", 3.8, Color(0.3, 0.8, 1.0, 1.0))
		5:
			falar_balao("Greed Island é como um videogame real! A Biscuit pega pesado, mas o treino funciona.", 3.8, Color(0.3, 0.8, 1.0, 1.0))
		6:
			falar_balao("As Formigas Chimera são monstros de verdade. Eu vou proteger vocês com meu Godspeed!", 3.8, Color(0.3, 0.8, 1.0, 1.0))
		_:
			falar_balao("Tô sempre pronto pra próxima aventura! Só não fica pra trás!", 3.8, Color(0.3, 0.8, 1.0, 1.0))
