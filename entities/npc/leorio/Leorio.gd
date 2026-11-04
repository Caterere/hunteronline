extends NPC

# ============================================================
# HUNTER ONLINE - NPC: LEORIO PARADINIGHT
# ============================================================
#
# Estudante de medicina e Hunter (Emissor).
# Restaura HP e oferece beats práticos por arco (sem checklist HUD).
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

	var arco = PlayerData.arco_atual if PlayerData != null else 1
	var etapa: int = int(PlayerData.etapa_quest_arco) if PlayerData != null else 1
	_exibir_falas(_falas_para(arco, etapa))


func _falas_para(arco: int, etapa: int) -> Array[Dictionary]:
	match arco:
		1:
			return [
				{"falante": "Leorio", "texto": "Ufa… droga de túnel sem fim! Eu vou ser Hunter pra pagar a faculdade — sério!"},
				{"falante": "Leorio", "texto": "Pronto, limpei o que deu. Não se mata de graça, ok?"},
			]
		2:
			return [
				{"falante": "Leorio", "texto": "Montanha de assassinos… ótimo. Eu cuido dos ferimentos; vocês cuidam de não virar ferimento."},
				{"falante": "Leorio", "texto": "Se o portão te esmagar o ego, respira. Medicina começa com não desistir."},
			]
		3:
			return [
				{"falante": "Leorio", "texto": "Arena Celestial. Eu não luto por esporte — mas se sangrar, eu costuro."},
				{"falante": "Leorio", "texto": "Wing fala Nen; eu falo: coma, durma, não seja idiota no ringue."},
			]
		4:
			return [
				{"falante": "Leorio", "texto": "Yorknew… leilão, sangue e políticos. Eu odeio metade disso e respeito a outra."},
				{"falante": "Leorio", "texto": "Kurapika tá no limite. A gente segura o corpo dele enquanto a cabeça dele segura o voto."},
			]
		5:
			return [
				{"falante": "Leorio", "texto": "Cartas, bombas, Biscuit gritando… isso ainda é “jogo”? Pronto, HP cheio. Vai."},
				{"falante": "Leorio", "texto": "Se o Bomber te encostar, volta. Eu não enterro amigo por teimosia."},
			]
		7:
			return [
				{"falante": "Leorio", "texto": "Aquele soco no Ging? Ele mereceu! Que tipo de pai faz isso?!"},
				{"falante": "Leorio", "texto": "Zodíaco Javali. Eu voto com a mão — e com o que resta de ética neste circo."},
			]
		_:
			return [
				{"falante": "Leorio", "texto": "Ei, você parece cansado. Cuidei dos ferimentos — agora não estrague meu trabalho."},
			]


func _exibir_falas(falas: Array[Dictionary]) -> void:
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui") if get_tree() != null else null
	if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
		visual_dialogue.exibir_sequencia_falas(falas)
	elif not falas.is_empty():
		falar_balao(str(falas[0].get("texto", "")), 3.8, Color(0.9, 0.5, 0.2, 1.0))
