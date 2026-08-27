extends NPC

# ============================================================
# HUNTER ONLINE - NPC: BISCUIT KRUEGER (ARCO 5 — GREED ISLAND)
# ============================================================
#
# Mestra de Hatsu em Greed Island.
# Treina o jogador para desbloquear e criar seus próprios Hatsus.
#
# ============================================================

@export var quest: Quest


func _ready() -> void:
	super()
	npc_name = "Biscuit"
	if quest == null:
		quest = load("res://data/quests/arco5_treino_biscuit.tres") as Quest


func _on_interacted(_player: CharacterBody2D) -> void:
	print("[Biscuit] Interagindo com Biscuit Krueger...")
	QuestSystem.register_npc_visit(&"biscuit")

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue == null:
		return

	var falas_biscuit: Array[Dictionary] = []

	if not PlayerData.despertou_nen:
		falas_biscuit.append({"falante": "Biscuit Krueger", "texto": "Ora ora! Vejo que você ainda nem despertou seus nós de Nen!"})
		falas_biscuit.append({"falante": "Biscuit Krueger", "texto": "🔒 REQUISITO: Vá falar primeiro com o Mestre Wing para realizar o Teste da Água e aprender os fundamentos (Ten e Ren) antes de vir criar seu Hatsu comigo!"})
		visual_dialogue.exibir_sequencia_falas(falas_biscuit)
		return

	if not PlayerData.hatsu_desbloqueado:
		PlayerData.hatsu_desbloqueado = true
		falas_biscuit.append({"falante": "Biscuit Krueger", "texto": "Ora ora! Vejo que você já aprendeu os fundamentos com Wing, mas ainda é como uma pedra bruta precisando de lapidação!"})
		falas_biscuit.append({"falante": "Biscuit Krueger", "texto": "Eu sou Biscuit Krueger, Mestra de Shingen-ryu. Vou te ensinar a verdadeira arte do HATSU!"})
		falas_biscuit.append({"falante": "Biscuit Krueger", "texto": "Hatsu é a manifestação pessoal da sua aura. Com ele, você pode disparar projéteis, criar explosões em área ou curar ferimentos."})
		falas_biscuit.append({"falante": "Biscuit Krueger", "texto": "Abrindo o Menu de Criação de Hatsu! Defina sua Categoria, Forma e Juramentos/Restrições (Vows) para multiplicar seu poder!"})
	else:
		falas_biscuit.append({"falante": "Biscuit Krueger", "texto": "Lembre-se: quanto mais severas forem suas restrições e juramentos de Nen, mais avassalador será o seu Hatsu!"})

	visual_dialogue.exibir_sequencia_falas(falas_biscuit)
	await visual_dialogue.dialogo_concluido

	var hatsu_ui = get_tree().root.get_node_or_null("HatsuCreationUI")
	if hatsu_ui != null and hatsu_ui.has_method("abrir"):
		hatsu_ui.abrir()
