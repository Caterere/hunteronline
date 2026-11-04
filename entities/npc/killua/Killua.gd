extends NPC

# ============================================================
# HUNTER ONLINE - NPC: KILLUA ZOLDYCK
# ============================================================
#
# Membro da família Zoldyck (Transformador - Eletricidade).
# Beats íntimos por arco/etapa — voz seca, sem ORDEM de HUD.
#
# ============================================================

@export var dialogue_tree: DialogueTree


func _ready() -> void:
	super()
	npc_name = "Killua"


func _on_interacted(_player: CharacterBody2D) -> void:
	print("Interagindo com Killua Zoldyck...")
	QuestSystem.register_npc_visit(&"killua")

	var arco = PlayerData.arco_atual if PlayerData != null else 1
	var etapa: int = int(PlayerData.etapa_quest_arco) if PlayerData != null else 1
	_exibir_falas(_falas_para(arco, etapa))


func _falas_para(arco: int, etapa: int) -> Array[Dictionary]:
	match arco:
		1:
			return [
				{"falante": "Killua", "texto": "Hunf. Exame moleza no skate… mas você e o Gon são chatos de um jeito bom."},
				{"falante": "Killua", "texto": "Mantém o ritmo. Se alguém te encostar de forma estranha, me chama."},
			]
		2:
			return [
				{"falante": "Killua", "texto": "…Casa. Não precisa entrar se não quiser. Eu aguento."},
				{"falante": "Killua", "texto": "Mike ouve presença. Se esconder aura, esconde de verdade — sem meia medida."},
			]
		3:
			if etapa >= 20:
				return [
					{"falante": "Killua", "texto": "200º. Hisoka não brinca. Se o telegraph colorir, sai. Eu cubro a abertura."},
					{"falante": "Killua", "texto": "Wing já te ensinou o básico. Agora é corpo — não bravata."},
				]
			return [
				{"falante": "Killua", "texto": "Wing-san falou potencial. Eu não compro papo fácil… mas o tatame não mente."},
				{"falante": "Killua", "texto": "Treina comigo entre andares. Sem rush pra cima."},
			]
		4:
			return [
				{"falante": "Killua", "texto": "Yorknew fede a sangue antigo. A Trupe não é “missável”."},
				{"falante": "Killua", "texto": "Eu cubro as costas do Kurapika. Você decide se fica — mas se ficar, fica de verdade."},
			]
		5:
			return [
				{"falante": "Killua", "texto": "Biscuit é pedra. Ko dói — e ela quer que doa. Eu aguento do seu lado."},
				{"falante": "Killua", "texto": "Quando o GPS apontar a Cova, some a aura. Sem heroísmo barato no Bomber."},
			]
		6:
			return [
				{"falante": "Killua", "texto": "Depois do Kite… eu fico. Godspeed depois. Um passo. Sem rush em Pitou."},
				{"falante": "Killua", "texto": "Se precisar sumir, some. Eu te acho."},
			]
		_:
			return [
				{"falante": "Killua", "texto": "Tô pronto. Só não fica pra trás — eu odeio esperar."},
			]


func _exibir_falas(falas: Array[Dictionary]) -> void:
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui") if get_tree() != null else null
	if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
		visual_dialogue.exibir_sequencia_falas(falas)
	elif not falas.is_empty():
		falar_balao(str(falas[0].get("texto", "")), 3.8, Color(0.3, 0.8, 1.0, 1.0))
