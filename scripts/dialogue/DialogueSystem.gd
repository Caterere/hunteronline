class_name DialogueSystem
extends Node

# =========================================================
# SISTEMA DE DIÁLOGO
# =========================================================
#
# Gerencia o fluxo de diálogo com ramificações
#
# Responsabilidades:
# - Carregar árvore de diálogo
# - Navegar entre nós
# - Processar ramificações
# - Executar ações (quests, desbloqueios)
# - Comunicar com DialogueBox
#
# =========================================================


# =========================================================
# SINAIS
# =========================================================

signal dialogue_started(npc_name: String)
signal dialogue_node_shown(node: DialogueNode)
signal dialogue_choices_shown(branches: Array[DialogueBranch])
signal dialogue_choice_made(branch: DialogueBranch)
signal dialogue_ended()


# =========================================================
# ESTADO
# =========================================================

var current_dialogue_tree: DialogueTree = null
var current_node: DialogueNode = null
var dialogue_box: DialogueBox = null


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	add_to_group("dialogue_system")

	print("=================================")
	print("DIALOGUE SYSTEM INICIADO")
	print("=================================")


# =========================================================
# INICIAR DIÁLOGO
# =========================================================

func start_dialogue(dialogue_tree: DialogueTree) -> void:

	if dialogue_tree == null:

		push_error("DialogueTree é nulo!")
		return

	if not dialogue_tree.is_valid():

		push_error("DialogueTree não é válida!")
		return

	print(
		"[DialogueSystem] Iniciando diálogo: ",
		dialogue_tree.tree_id
	)

	# Encontrar DialogueBox
	if dialogue_box == null:

		dialogue_box = get_tree().get_first_node_in_group("dialogue_box") as DialogueBox

		if dialogue_box == null:

			push_error("DialogueBox não encontrado!")
			return

	current_dialogue_tree = dialogue_tree
	current_node = null

	dialogue_started.emit(dialogue_tree.npc_name)

	_show_node(dialogue_tree.get_root_node())


# =========================================================
# MOSTRAR NÓ
# =========================================================

func _show_node(node: DialogueNode) -> void:

	if node == null:

		_end_dialogue()

		return

	current_node = node

	# Executar ações de entrada
	current_node.execute_on_enter()

	# Mostrar texto
	dialogue_box.show_dialogue(
		node.get_speaker(),
		node.get_display_text()
	)

	dialogue_node_shown.emit(node)

	# Se não tem ramificações, mostrar botão de continuar
	if not node.has_branches():

		if node.auto_end:

			await get_tree().create_timer(2.0).timeout

			_end_dialogue()

		return

	# Mostrar ramificações (escolhas)
	var valid_branches: Array[DialogueBranch] = []

	for branch in node.get_branches():

		if branch.can_choose():

			valid_branches.append(branch)

	dialogue_choices_shown.emit(valid_branches)

	dialogue_box.show_choices(valid_branches)


# =========================================================
# PROCESSAR ESCOLHA
# =========================================================

func choose_branch(branch: DialogueBranch) -> void:

	if branch == null:

		push_error("Branch é nulo!")

		return

	if current_node == null:

		return

	print(
		"[DialogueSystem] Escolha feita: \"",
		branch.choice_text,
		"\""
	)

	dialogue_choice_made.emit(branch)

	# Executar ações da ramificação
	branch.execute_actions()

	# Ir para próximo nó
	if branch.next_node_id.is_empty():

		_end_dialogue()

		return

	var next_node = current_dialogue_tree.get_node(branch.next_node_id)

	_show_node(next_node)


# =========================================================
# FINALIZAR DIÁLOGO
# =========================================================

func _end_dialogue() -> void:

	print("[DialogueSystem] Diálogo finalizado")

	current_dialogue_tree = null
	current_node = null

	if dialogue_box != null:

		dialogue_box.hide()

	dialogue_ended.emit()
