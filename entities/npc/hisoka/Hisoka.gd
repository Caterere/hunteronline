extends NPC

# ============================================================
# HUNTER ONLINE - NPC: HISOKA MOROW (O MÁGICO)
# ============================================================
#
# Mágico misterioso e assassino implacável que busca frutos
# maduros para saciar seu desejo insaciável de combate mortal.
# Permite desbloquear a missão terciária da Bungee Gum.
#
# ============================================================

@export var dialogue_tree: DialogueTree


func _ready() -> void:
	super()
	npc_name = "Hisoka Morow"
	fala_padrao = "♥ Minha Bungee Gum tem as propriedades tanto da borracha quanto do chiclete... Schwing~!"


func _on_interacted(_player: CharacterBody2D) -> void:
	print("[Hisoka] Interagindo com Hisoka Morow...")
	QuestSystem.register_npc_visit(&"hisoka")

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")

	if visual_dialogue != null:
		var nivel_nen = PlayerData.attributes.get("nivel_nen", 0) if PlayerData else 0
		var falas: Array[Dictionary] = []

		if nivel_nen >= 12:
			falas = [
				{"falante": "Hisoka Morow", "texto": "♠ Schwing~! Olhe só como sua aura amadureceu... Tão densa, tão apetitosa... ♦"},
				{"falante": "Hisoka Morow", "texto": "♥ Você sabia? Minha Bungee Gum possui as propriedades elásticas da borracha e a aderência viscosa do chiclete. Uma combinação perfeita para enganar e estraçalhar presas."},
				{"falante": "Hisoka Morow", "texto": "♣ Aceite o Teste da Bungee Gum no seu Jornal de Missões [J] se tiver coragem de dançar comigo na névoa... Não me decepcione! ♠"}
			]
			if PlayerData:
				PlayerData.registrar_segredo("desafio_hisoka_liberado")
		else:
			falas = [
				{"falante": "Hisoka Morow", "texto": "♦ Sua fruta ainda está verde... Não tem graça cortar seu pescoço antes da hora. ♠"},
				{"falante": "Hisoka Morow", "texto": "♥ Sobreviva, treine seu Nen e fique mais forte. Quando sua aura estiver no auge, eu mesmo colherei você... Schwing~!"}
			]

		visual_dialogue.exibir_sequencia_falas(falas)
	else:
		falar_balao(fala_padrao, 4.0, Color(0.9, 0.1, 0.5, 1.0), Color(1.0, 0.2, 0.6, 1.0))
