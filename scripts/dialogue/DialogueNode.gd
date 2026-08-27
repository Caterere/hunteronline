class_name DialogueNode
extends Resource

# =========================================================
# NÓ DE DIÁLOGO
# =========================================================
#
# Representa um ponto de diálogo com:
# - Texto a falar
# - Possíveis ramificações (escolhas)
# - Ações ao entrar
#
# =========================================================


# =========================================================
# IDENTIDADE
# =========================================================

@export_category("Identity")

@export var node_id: StringName = &""


# =========================================================
# CONTEÚDO
# =========================================================

@export_category("Content")

@export var speaker_name: String = "NPC"

@export_multiline var dialogue_text: String = ""


# =========================================================
# RAMIFICAÇÕES
# =========================================================

@export_category("Branches")

# Se vazio, é um nó terminal (fim da conversa)
@export var branches: Array[DialogueBranch] = []


# =========================================================
# AÇÕES
# =========================================================

@export_category("Actions")

# Finalizar a conversa automaticamente após este nó
@export var auto_end: bool = false

# Desbloquear técnica ao entrar neste nó (fora de branches)
@export var unlock_technique_on_enter: StringName = &""

# Iniciar quest ao entrar neste nó
@export var start_quest_on_enter: Quest = null


# =========================================================
# GETTERS
# =========================================================

func get_display_text() -> String:

	return dialogue_text


func get_speaker() -> String:

	return speaker_name


func get_branches() -> Array[DialogueBranch]:

	return branches


func has_branches() -> bool:

	return branches.size() > 0


func is_terminal() -> bool:

	return branches.is_empty() or auto_end


# =========================================================
# EXECUTAR AÇÕES DE ENTRADA
# =========================================================

func execute_on_enter() -> void:

	if not unlock_technique_on_enter.is_empty():

		var tree = Engine.get_main_loop() as SceneTree
		if tree == null:
			return
		var player = tree.get_first_node_in_group("player")

		if player != null:

			var nen_system = player.get_node_or_null("NenSystem")

			if nen_system != null:

				nen_system.desbloquear_tecnica(unlock_technique_on_enter)

				print(
					"[DialogueNode] Técnica desbloqueada: ",
					unlock_technique_on_enter
				)


	if start_quest_on_enter != null:

		QuestSystem.start_quest(start_quest_on_enter)

		print(
			"[DialogueNode] Quest iniciada: ",
			start_quest_on_enter.quest_name
		)
