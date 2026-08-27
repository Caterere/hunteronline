extends NPC

# ============================================================
# HUNTER ONLINE - NPC: GON FREECSS
# ============================================================
#
# Protagonista de Hunter x Hunter (Intensificador).
# Ao interagir na Fase 1 do Exame Hunter, inicia a cutscene
# dos 4 amigos conversando com balões de fala e correndo juntos!
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

	var arco = PlayerData.arco_atual
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

	# Diálogos padrão com balão de fala
	match arco:
		1:
			falar_balao("Vamos correr rápido! O Satotz está nos esperando mais à frente no túnel!", 3.5, Color(0.2, 0.9, 0.4, 1.0))
		2:
			falar_balao("Killua foi levado pela família... Precisamos ir à Montanha Kukuroo resgatá-lo!", 3.5, Color(0.2, 0.9, 0.4, 1.0))
		3:
			falar_balao("O Mestre Wing vai nos ensinar Nen! A Arena Celestial é o lugar perfeito pra treinar!", 3.5, Color(0.2, 0.9, 0.4, 1.0))
		4:
			falar_balao("O Kurapika precisa da nossa ajuda em Yorknew! A Trupe Fantasma é muito perigosa!", 3.5, Color(0.2, 0.9, 0.4, 1.0))
		5:
			falar_balao("Biscuit-san é incrível! Com o treino dela em Greed Island, nosso Hatsu vai melhorar muito!", 3.5, Color(0.2, 0.9, 0.4, 1.0))
		6:
			falar_balao("Kite... nós precisamos salvar o Kite das Formigas Chimera!", 3.5, Color(0.2, 0.9, 0.4, 1.0))
		_:
			falar_balao("Vou continuar treinando duro para me tornar um grande Hunter!", 3.5, Color(0.2, 0.9, 0.4, 1.0))
