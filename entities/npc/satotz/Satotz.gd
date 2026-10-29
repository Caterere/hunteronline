extends NPC

# ============================================================
# HUNTER ONLINE - NPC: SATOTZ (ARCO 1 — EXAME HUNTER)
# ============================================================
#
# Examinador da 1ª Fase do 287º Exame Hunter.
# Dispara a sequência cinemática do Pantanal Numere e explica
# a gravidade e o rigor das provas da Associação Hunter.
#
# ============================================================

var ja_executou_cutscene_pantanal: bool = false


func _ready() -> void:
	super()
	npc_name = "Satotz"


func _on_interacted(_player: CharacterBody2D) -> void:
	print("[Satotz] Interagindo com o Examinador Satotz...")
	QuestSystem.register_npc_visit(&"satotz")

	var arco: int = int(PlayerData.arco_atual) if PlayerData != null else 0
	var etapa: int = int(PlayerData.etapa_quest_arco) if PlayerData != null else 0

	# Embarque Zevil — cutscene de regras da 4ª fase (piloto)
	if arco == 1 and etapa == 20:
		if StoryManager == null or not bool(StoryManager.get_story_flag("cutscene_zevil_embarque", false)):
			StoryCutsceneManager.executar_zevil_embarque(get_tree())
			return

	# Saída do túnel / entrada no pantanal
	if arco == 1 and etapa <= 6 and not ja_executou_cutscene_pantanal:
		ja_executou_cutscene_pantanal = true

		var parent = get_parent()
		var hisoka = parent.get_node_or_null("Hisoka") as NPC
		var amigos: Array[NPC] = []
		var gon = parent.get_node_or_null("Gon") as NPC
		var killua = parent.get_node_or_null("Killua") as NPC
		var kurapika = parent.get_node_or_null("Kurapika") as NPC
		var leorio = parent.get_node_or_null("Leorio") as NPC
		if gon: amigos.append(gon)
		if killua: amigos.append(killua)
		if kurapika: amigos.append(kurapika)
		if leorio: amigos.append(leorio)

		StoryCutsceneManager.executar_pantanal_hisoka(get_tree(), self, hisoka, amigos)
		return

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null:
		var falas: Array[Dictionary] = [
			{"falante": "Examinador Satotz", "texto": "Mantenham o foco. O Exame não recompensa pressa cega — recompensa quem lê o terreno e o adversário."},
			{"falante": "Examinador Satotz", "texto": "Siga o GPS. Um marco por vez. A Associação observa quem chega… e como chega."}
		]
		visual_dialogue.exibir_sequencia_falas(falas)
	else:
		falar_balao("Mantenham-se atentos. Um marco por vez.", 4.0, Color(0.4, 0.7, 1.0, 1.0))