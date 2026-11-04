extends NPC

# ============================================================
# HUNTER ONLINE - NPC: GON FREECSS
# ============================================================
#
# Protagonista de Hunter x Hunter (Intensificador).
# Ao interagir na Fase 1 do Exame Hunter, inicia a cutscene
# dos 4 amigos. Demais arcos: beats íntimos por etapa (padrão Wing).
#
# ============================================================

@export var dialogue_tree: DialogueTree
var ja_executou_cutscene: bool = false


func _ready() -> void:
	super()
	npc_name = "Gon"


func _on_interacted(_player: CharacterBody2D) -> void:
	print("Interagindo com Gon Freecss...")
	QuestSystem.register_npc_visit(&"gon")

	var arco = PlayerData.arco_atual if PlayerData != null else 1
	var etapa: int = int(PlayerData.etapa_quest_arco) if PlayerData != null else 1
	if arco == 1 and not ja_executou_cutscene:
		ja_executou_cutscene = true
		
		# Localizar amigos e Satotz na cena
		var parent = get_parent()
		var killua = parent.get_node_or_null("Killua") as NPC
		var leorio = parent.get_node_or_null("Leorio") as NPC
		var kurapika = parent.get_node_or_null("Kurapika") as NPC
		var satotz = parent.get_node_or_null("Satotz") as NPC
		
		StoryCutsceneManager.executar_maratona_hunter(get_tree(), self, killua, leorio, kurapika, satotz)
		return

	_exibir_falas(_falas_para(arco, etapa))


func _falas_para(arco: int, etapa: int) -> Array[Dictionary]:
	match arco:
		1:
			if etapa <= 3:
				return [
					{"falante": "Gon", "texto": "O túnel é enorme… mas eu sinto que a gente consegue. Corre comigo!"},
					{"falante": "Gon", "texto": "Satotz tá na frente. Se cansar, respira — eu espero."},
				]
			return [
				{"falante": "Gon", "texto": "Cada prova do Exame é diferente. Eu quero ver todas!"},
				{"falante": "Gon", "texto": "Quando travar, a gente resolve junto. Combinado?"},
			]
		2:
			return [
				{"falante": "Gon", "texto": "Killua tá lá dentro… a família dele assusta, mas eu não vou deixar ele sozinho."},
				{"falante": "Gon", "texto": "O portão é alto pra caramba. Um degrau de cada vez — eu empurro com você."},
			]
		3:
			if etapa >= 20:
				return [
					{"falante": "Gon", "texto": "O 200º… minha aura ainda treme. Mas eu quero ver o Hisoka de verdade."},
					{"falante": "Gon", "texto": "Wing disse pra não sangrar aura. Eu tô tentando. Fica do meu lado?"},
				]
			return [
				{"falante": "Gon", "texto": "O Mestre Wing vai ensinar Nen! Eu mal posso esperar o Teste da Água."},
				{"falante": "Gon", "texto": "Arena é alta… mas cada andar é um treino. Vamos subir!"},
			]
		4:
			return [
				{"falante": "Gon", "texto": "Kurapika tá carregando demais sozinho. Eu não entendo tudo… mas eu fico."},
				{"falante": "Gon", "texto": "Yorknew é barulhenta. Se a Trupe aparecer, a gente não foge um do outro."},
			]
		5:
			return [
				{"falante": "Gon", "texto": "Biscuit-san é dura… mas eu sinto que ela acredita na gente."},
				{"falante": "Gon", "texto": "Greed Island é um jogo, né? Então eu quero jogar de verdade — sem trapacear o coração."},
			]
		6:
			return [
				{"falante": "Gon", "texto": "Kite… eu prometi. Formiga ou não, eu vou até o fim."},
			]
		_:
			return [
				{"falante": "Gon", "texto": "Vou continuar treinando. Quero ser um Hunter que faz o Killua sorrir de verdade."},
			]


func _exibir_falas(falas: Array[Dictionary]) -> void:
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui") if get_tree() != null else null
	if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
		visual_dialogue.exibir_sequencia_falas(falas)
	elif not falas.is_empty():
		falar_balao(str(falas[0].get("texto", "")), 3.5, Color(0.2, 0.9, 0.4, 1.0))
