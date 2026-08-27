extends NPC

# ============================================================
# HUNTER ONLINE - NPC: LEORIO PARADINIGHT
# ============================================================
#
# Estudante de medicina e Hunter (Emissor).
# Restaura HP do jogador e oferece conselhos amigáveis.
#
# ============================================================

@export var dialogue_tree: DialogueTree


func _ready() -> void:
	super()
	npc_name = "Leorio"


func _on_interacted(_player: CharacterBody2D) -> void:
	print("Interagindo com Leorio Paradinight...")
	QuestSystem.register_npc_visit(&"leorio")

	# Curar HP do jogador gratuitamente como serviço médico
	var hp_max: int = int(PlayerData.attributes.get("vida_max", 100))
	PlayerData.attributes["vida"] = hp_max

	var arco = PlayerData.arco_atual
	match arco:
		1, 2:
			falar_balao("Ufa... ufa... Droga de túnel sem fim! Eu vou ser Hunter pra pagar minha faculdade de medicina! Deixa eu curar suas feridas!", 3.8, Color(0.9, 0.5, 0.2, 1.0))
		7:
			falar_balao("Aquele soco no Ging? Ele mereceu! Que tipo de pai abandona o filho daquele jeito?! Fui eleito Zodíaco Javali!", 3.8, Color(0.9, 0.5, 0.2, 1.0))
		_:
			falar_balao("Ei, você parece cansado! Cuidei dos seus ferimentos com meus primeiros socorros!", 3.8, Color(0.9, 0.5, 0.2, 1.0))

