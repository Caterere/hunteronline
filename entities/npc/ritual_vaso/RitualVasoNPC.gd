extends Area2D

# ============================================================
# HUNTER ONLINE - SANTUÁRIO DO VASO DE KAKIN (RITUAL DA BESTA DE NEN)
# ============================================================
#
# Requisito obrigatório:
# Concluir o Arco 6 (Formigas Chimera) em qualquer dificuldade
# (ou seja, max_arco_desbloqueado >= 7 ou modo_historia_concluido).
#
# ============================================================

@onready var sprite = $Sprite2D
@onready var interaction_label = $InteractionLabel

var _player_in_range: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if interaction_label != null:
		interaction_label.hide()


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		_player_in_range = true
		_update_label()
		if interaction_label != null:
			interaction_label.show()


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		_player_in_range = false
		if interaction_label != null:
			interaction_label.hide()


func _pode_realizar_ritual() -> bool:
	return (PlayerData.max_arco_desbloqueado >= 7 or PlayerData.modo_historia_concluido)


func _update_label() -> void:
	if interaction_label == null: return
	if PlayerData.besta_nen_desbloqueada:
		interaction_label.text = "[E] Vaso Imperial (Besta Ativa)"
	elif _pode_realizar_ritual():
		interaction_label.text = "[E] Iniciar Ritual do Vaso de Kakin"
	else:
		interaction_label.text = "[E] Vaso Selado (Requer Arco 6: Formigas Chimera)"


func _input(event: InputEvent) -> void:
	if _player_in_range and event.is_action_pressed("interact"):
		_interagir_vaso()


func _interagir_vaso() -> void:
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	
	if PlayerData.besta_nen_desbloqueada:
		if visual_dialogue != null:
			var b_nome: String = PlayerData.besta_nen_equipada.nome_besta if PlayerData.besta_nen_equipada != null else "Besta Guardiã"
			var falas: Array[Dictionary] = [
				{"falante": "Santuário de Kakin", "texto": "🏺 O Ritual da Sucessão já foi celebrado. Sua Besta de Nen (%s) está vinculada à sua aura e protege seus passos!" % b_nome}
			]
			visual_dialogue.exibir_sequencia_falas(falas)
		return

	if not _pode_realizar_ritual():
		if visual_dialogue != null:
			var falas: Array[Dictionary] = [
				{"falante": "Santuário de Kakin", "texto": "🏺 O Vaso Sagrado da Sucessão Imperial permanece SELADO."},
				{"falante": "Santuário de Kakin", "texto": "🔒 REQUISITO: Você precisa concluir o ARCO 6 (FORMIGAS CHIMERA) em qualquer dificuldade para provar que sobreviveu à maior provação do mundo e possui espírito digno de uma Besta de Nen!"}
			]
			visual_dialogue.exibir_sequencia_falas(falas)
		return

	# Realizar Ritual de Kakin
	realizar_ritual()


func realizar_ritual() -> void:
	print("=================================")
	print("[Santuário] RITUAL DO VASO DE KAKIN INICIADO!")
	print("=================================")
	
	var beast = NenBeastManager.gerar_besta_aleatoria()
	PlayerData.besta_nen_equipada = beast
	PlayerData.besta_nen_desbloqueada = true
	
	# Notificar o sistema do jogador para instanciar a Besta no mapa
	var player = get_tree().get_first_node_in_group("player")
	if player != null:
		var nen_beast_system = player.get_node_or_null("NenBeastSystem") as NenBeastSystem
		if nen_beast_system != null:
			nen_beast_system.equipar_besta(beast)
			
	_update_label()
	
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null:
		var falas: Array[Dictionary] = [
			{"falante": "Santuário de Kakin", "texto": "🩸 Você inseriu uma gota do seu sangue na fenda do Vaso Sagrado... Uma aura ancestral e imensa começa a emanar!"},
			{"falante": "Santuário de Kakin", "texto": "✨ Uma Besta Guardiã de Nen nasceu da sua energia vital: " + beast.nome_besta + "!"},
			{"falante": "Santuário de Kakin", "texto": "Habilidade Passiva: " + beast.obter_nome_tipo() + " (Potencial IV: " + str(beast.potencial_iv) + "). Ela agora flutua ao seu lado e protege seu corpo em batalha!"}
		]
		visual_dialogue.exibir_sequencia_falas(falas)

