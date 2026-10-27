extends NPC

# ============================================================
# HUNTER ONLINE - NPC: ISAAC NETERO
# ============================================================
# Arco 1: no Exame teleporta ao dirigível após o diálogo;
# no deck completa o jogo da bola (etapa 15) e aponta Trick Tower.
# Arco 6+: falas Chimera / genéricas.
# ============================================================


func _ready() -> void:
	super()
	npc_name = "Netero"


func _on_interacted(_player: CharacterBody2D) -> void:
	print("[Netero] Interagindo com o Presidente Netero...")
	QuestSystem.register_npc_visit(&"netero")

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	var falas: Array[Dictionary] = []
	var arco = PlayerData.arco_atual if PlayerData != null else 1
	var no_dirigivel := _esta_no_dirigivel()

	if arco == 1 and not no_dirigivel:
		falas = [
			{"falante": "Netero", "texto": "Ho ho! Sou Isaac Netero, Presidente da Associação Hunter."},
			{"falante": "Netero", "texto": "Você chegou longe o bastante. Embarque no dirigível — quero ver seus reflexos num joguinho."},
			{"falante": "Netero", "texto": "Depois aterrisamos no topo da Trick Tower. Não se atrase!"}
		]
	elif arco == 1 and no_dirigivel:
		falas = [
			{"falante": "Netero", "texto": "No dirigível: tente tirar a bola das minhas mãos — só um aquecimento!"},
			{"falante": "Netero", "texto": "…Ho ho, ainda segura. Velocidade boa — o suficiente para a torre."},
			{"falante": "Netero", "texto": "Portal a LESTE: Trick Tower. Encontre o alçapão (Gyo ajuda). Boa sorte!"}
		]
	elif arco == 6:
		falas = [
			{"falante": "Netero", "texto": "As Formigas Chimera em NGL são a maior ameaça que a humanidade já enfrentou."},
			{"falante": "Netero", "texto": "Para esta missão, selecionei pessoalmente cada Hunter. Você está entre eles."},
			{"falante": "Netero", "texto": "Eu treinei durante mais de 50 anos. 10.000 socos de gratidão por dia. Esse é o meu Nen."},
			{"falante": "Netero", "texto": "O Rei Meruem... ele pode ser mais forte que eu. Mas a humanidade tem um trunfo: a evolução infinita do potencial!"}
		]
	else:
		falas = [
			{"falante": "Netero", "texto": "Ho ho ho! Continue treinando, jovem Hunter! O mundo é vasto e cheio de surpresas!"}
		]

	if visual_dialogue == null:
		if arco == 1 and not no_dirigivel:
			_teleportar_para_dirigivel()
		elif arco == 1 and no_dirigivel:
			_apos_jogo_bola()
		return

	visual_dialogue.exibir_sequencia_falas(falas)
	if arco == 1 and not no_dirigivel:
		visual_dialogue.dialogo_concluido.connect(_teleportar_para_dirigivel, CONNECT_ONE_SHOT)
	elif arco == 1 and no_dirigivel:
		visual_dialogue.dialogo_concluido.connect(_apos_jogo_bola, CONNECT_ONE_SHOT)


func _esta_no_dirigivel() -> bool:
	var cena := get_tree().current_scene
	if cena == null:
		return false
	var path := str(cena.scene_file_path).to_lower()
	return "dirigivel" in path


func _teleportar_para_dirigivel() -> void:
	if EventBus != null:
		EventBus.emit_toast("Embarcando no dirigível da Associação…", Color(0.7, 0.85, 1.0))
	var trans = get_node_or_null("/root/SceneTransition")
	if trans != null and trans.has_method("mudar_cena"):
		trans.mudar_cena(
			"res://world/maps/dirigivel_hunter.tscn",
			"Dirigível Hunter",
			"Viagem Noturna — Jogo da Bola de Netero",
			0.35,
			&"from_exame",
			Vector2(120, 180)
		)
	else:
		get_tree().change_scene_to_file("res://world/maps/dirigivel_hunter.tscn")


func _apos_jogo_bola() -> void:
	if EventBus != null:
		EventBus.emit_toast("Jogo da bola concluído — portal LESTE → Trick Tower (alçapão).", Color(1.0, 0.85, 0.45))
	var hud = get_tree().get_first_node_in_group("player_hud")
	if hud and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("🗼 Vá ao portal LESTE do deck — Topo da Trick Tower")
