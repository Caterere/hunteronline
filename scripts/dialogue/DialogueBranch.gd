class_name DialogueBranch
extends Resource

# =========================================================
# RAMIFICAÇÃO DE DIÁLOGO
# =========================================================
#
# Representa uma opção que o jogador pode escolher
# dentro de um DialogueNode
#
# =========================================================


# =========================================================
# IDENTIDADE
# =========================================================

@export_category("Branch")

@export var branch_id: StringName = &""

@export_multiline var choice_text: String = "Continuar"


# =========================================================
# DESTINO
# =========================================================

@export_category("Destination")

# ID do próximo DialogueNode
@export var next_node_id: StringName = &""


# =========================================================
# CONDIÇÕES
# =========================================================

@export_category("Conditions")

# Se true, só pode escolher esta opção em certas condições
@export var has_condition: bool = false

# Tipo de condição: "level", "quest_completed", "nen_level"
@export var condition_type: String = ""

# Valor para comparar
@export var condition_value: int = 0


# =========================================================
# AÇÕES
# =========================================================

@export_category("Actions")

# Quest a iniciar ao escolher (opcional)
@export var start_quest: Quest = null

# Técnica de Nen a desbloquear (opcional)
@export var unlock_technique: StringName = &""

# XP a dar ao escolher
@export var reward_xp: int = 0


# =========================================================
# FUNÇÕES
# =========================================================

func get_display_text() -> String:

	return choice_text


func can_choose() -> bool:

	if not has_condition:
		return true

	match condition_type:

		"level":
			return PlayerData.attributes["nivel"] >= condition_value

		"nen_level":
			return PlayerData.attributes["nivel_nen"] >= condition_value

		"quest_completed":
			# condition_value seria o ID da quest
			return true

		_:
			return true


func execute_actions() -> void:

	# =====================================================
	# INICIAR QUEST
	# =====================================================

	if start_quest != null:

		QuestSystem.start_quest(start_quest)


	# =====================================================
	# DESBLOQUEAR TÉCNICA
	# =====================================================

	if not unlock_technique.is_empty():

		var tree = Engine.get_main_loop() as SceneTree
		if tree == null:
			return
		var _player = tree.get_first_node_in_group("player")
		if _player == null:
			return
		var nen_system = _player.get_node_or_null("NenSystem")

		if nen_system != null:

			nen_system.desbloquear_tecnica(unlock_technique)

			print(
				"Técnica desbloqueada: ",
				unlock_technique
			)


	# =====================================================
	# DAR XP
	# =====================================================

	if reward_xp > 0:

		var tree2 = Engine.get_main_loop() as SceneTree
		if tree2 == null:
			return
		var player = tree2.get_first_node_in_group("player")

		if player != null:

			var xp_system = player.get_node_or_null("XPSystem")

			if xp_system != null:

				xp_system.adicionar_xp(
					reward_xp,
					"Diálogo"
				)
