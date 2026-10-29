extends NPC

# ============================================================
# HUNTER ONLINE - NPC: TONPA (O ESMAGA-NOVATOS)
# ============================================================
#
# Veterano do Exame Hunter. Piloto Fase 1:
# - Etapa 1: DialogueTree ramificado (bebida / recusa / observação)
# - Etapa 17: persuasão + cutscene de votação majoritária
#
# ============================================================

const TonpaExameDialogueFactoryScript = preload("res://data/dialogues/TonpaExameDialogueFactory.gd")
const StoryCutsceneManagerScript = preload("res://scripts/cutscenes/StoryCutsceneManager.gd")

var _exame_tree: DialogueTree = null


func _ready() -> void:
	super()
	npc_name = "Tonpa"
	fala_padrao = "Hehe... Cuidado para não desmaiar de exaustão na maratona!"


func _on_interacted(_player: CharacterBody2D) -> void:
	print("[Tonpa] Interagindo com Tonpa o Esmaga-Novatos...")
	if QuestSystem != null:
		QuestSystem.register_npc_visit(&"tonpa")
		if QuestSystem.has_method("register_persuasion"):
			QuestSystem.register_persuasion(&"tonpa")

	var etapa: int = int(PlayerData.etapa_quest_arco) if PlayerData != null else 1
	var arco: int = int(PlayerData.arco_atual) if PlayerData != null else 1

	# Etapa 17 — votação majoritária (cutscene com escolha)
	if arco == 1 and etapa == 17:
		StoryCutsceneManagerScript.executar_votacao_trick_tower(get_tree())
		return

	# Etapa 1 (e reforço) — diálogo ramificado
	if arco == 1 and etapa <= 2:
		if _tentar_dialogue_tree():
			return

	_fallback_visual_dialogue()


func _tentar_dialogue_tree() -> bool:
	var diag_sys = get_tree().get_first_node_in_group("dialogue_system") as DialogueSystem
	if diag_sys == null:
		return false
	if _exame_tree == null:
		_exame_tree = TonpaExameDialogueFactoryScript.criar()
	if _exame_tree == null or not _exame_tree.is_valid():
		return false
	# Registrar escolha ao terminar via conexão one-shot no ended
	if not diag_sys.dialogue_ended.is_connected(_on_tonpa_dialogue_ended):
		diag_sys.dialogue_ended.connect(_on_tonpa_dialogue_ended, CONNECT_ONE_SHOT)
	if not diag_sys.dialogue_choice_made.is_connected(_on_tonpa_choice):
		diag_sys.dialogue_choice_made.connect(_on_tonpa_choice)
	diag_sys.start_dialogue(_exame_tree)
	return true


func _on_tonpa_choice(branch: DialogueBranch) -> void:
	if branch == null or StoryManager == null:
		return
	var bid := str(branch.branch_id)
	if bid.is_empty():
		bid = str(branch.next_node_id)
	StoryManager.register_choice("tonpa_bebida_exame", bid)


func _on_tonpa_dialogue_ended() -> void:
	var diag_sys = get_tree().get_first_node_in_group("dialogue_system") as DialogueSystem
	if diag_sys != null and diag_sys.dialogue_choice_made.is_connected(_on_tonpa_choice):
		diag_sys.dialogue_choice_made.disconnect(_on_tonpa_choice)


func _fallback_visual_dialogue() -> void:
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue == null:
		falar_balao(fala_padrao, 3.5, Color(1.0, 0.7, 0.2, 1.0))
		return

	var tem_gyo = PlayerData.attributes.get("nivel_nen", 0) > 0 if PlayerData else false
	var res_tonpa = SurpriseQuestSystem.processar_interacao_tonpa(tem_gyo) if SurpriseQuestSystem else {}
	var _unused = res_tonpa

	var falas: Array[Dictionary] = [
		{"falante": "Tonpa", "texto": "Ora ora! Mais um novato cheio de sonhos. Este já é o meu 35º Exame — conheço cada armadilha deste túnel."},
		{"falante": "Tonpa", "texto": "Para 'selar' camaradagem, pegue esta lata gelada. Vai te dar uma energia… especial."}
	]
	if tem_gyo:
		falas.append({"falante": "Você", "texto": "(A tampa não fecha limpa. Você devolve a lata.)"})
		falas.append({"falante": "Tonpa", "texto": "Argh… olhos afiados. Não é um novato comum."})
		if StoryManager != null:
			StoryManager.register_choice("tonpa_bebida_exame", "observar_tampa")
	else:
		falas.append({"falante": "Você", "texto": "(Um gole — depois a dor. Tonpa ri.)"})
		falas.append({"falante": "Tonpa", "texto": "Hah! Caiu. Guarde a lição: no Exame, ninguém oferece nada de graça."})
		if StoryManager != null:
			StoryManager.register_choice("tonpa_bebida_exame", "aceitar_bebida")
	visual_dialogue.exibir_sequencia_falas(falas)
