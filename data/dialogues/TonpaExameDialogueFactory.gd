class_name TonpaExameDialogueFactory
extends RefCounted

# ============================================================
# Diálogo ramificado original do Tonpa (piloto Exame — Fase 1).
# Construído em runtime para evitar dependência de UIDs de .tres.
# ============================================================


static func criar() -> DialogueTree:
	var tree := DialogueTree.new()
	tree.tree_id = &"tonpa_exame_intro"
	tree.npc_name = "Tonpa"
	tree.npc_id = &"tonpa"
	tree.root_node_id = &"intro"

	var intro := DialogueNode.new()
	intro.node_id = &"intro"
	intro.speaker_name = "Tonpa"
	intro.dialogue_text = "Heh. Mais um número no túnel. Eu já fiz este Exame trinta e cinco vezes — sei onde os novatos tropeçam.\n\nAntes da maratona… que tal um brinde de camaradagem?"

	var b_aceitar := DialogueBranch.new()
	b_aceitar.branch_id = &"aceitar_bebida"
	b_aceitar.choice_text = "Aceitar a bebida (confiança arriscada)"
	b_aceitar.next_node_id = &"aceita"

	var b_recusar := DialogueBranch.new()
	b_recusar.branch_id = &"recusar_bebida"
	b_recusar.choice_text = "Recusar com educação"
	b_recusar.next_node_id = &"recusa"

	var b_observar := DialogueBranch.new()
	b_observar.branch_id = &"observar_tampa"
	b_observar.choice_text = "Observar a tampa antes de beber"
	b_observar.next_node_id = &"observa"

	intro.branches.clear()
	intro.branches.append(b_aceitar)
	intro.branches.append(b_recusar)
	intro.branches.append(b_observar)

	var aceita := DialogueNode.new()
	aceita.node_id = &"aceita"
	aceita.speaker_name = "Tonpa"
	aceita.dialogue_text = "Hah! Saúde, novato. O túnel ainda é longo — e a maratona não espera quem fica enjoado."
	aceita.auto_end = true

	var recusa := DialogueNode.new()
	recusa.node_id = &"recusa"
	recusa.speaker_name = "Tonpa"
	recusa.dialogue_text = "Prudente. Sem problema — sobra mais pra mim. Só não atrase o ritmo LESTE, ou o pantanal te engole primeiro."
	recusa.auto_end = true

	var observa := DialogueNode.new()
	observa.node_id = &"observa"
	observa.speaker_name = "Você"
	observa.dialogue_text = "(A tampa tem um resíduo oleoso. Não é suco comum.)"
	var b_cont := DialogueBranch.new()
	b_cont.branch_id = &"confrontar"
	b_cont.choice_text = "Devolver a lata e seguir"
	b_cont.next_node_id = &"confrontado"
	b_cont.reward_xp = 25
	observa.branches.clear()
	observa.branches.append(b_cont)

	var confrontado := DialogueNode.new()
	confrontado.node_id = &"confrontado"
	confrontado.speaker_name = "Tonpa"
	confrontado.dialogue_text = "Tsk… olhos afiados. Guarde isso — o Exame pune quem bebe tudo o que oferecem. Vá. GPS marca o próximo marco."
	confrontado.auto_end = true

	tree.nodes = {
		&"intro": intro,
		&"aceita": aceita,
		&"recusa": recusa,
		&"observa": observa,
		&"confrontado": confrontado,
	}
	return tree
