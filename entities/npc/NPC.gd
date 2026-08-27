class_name NPC
extends CharacterBody2D

# ============================================================
# HUNTER ONLINE - NPC BASE CLASS (COM BALÃO DE FALA & MOVIMENTO)
# ============================================================
#
# Classe base para todos os NPCs do jogo.
# - Suporta balões de fala em nuvem flutuantes (SpeechBubbleNode).
# - Suporta movimentação física suave e corrida em grupo para cutscenes.
# - Mantém compatibilidade total com o InteractionComponent e Quests.
#
# ============================================================

signal destino_alcancado()

@export var npc_name: String = "NPC"
@export_multiline var fala_padrao: String = "Olá, Jovem Hunter! Seja bem-vindo ao mundo de Hunter x Hunter!"
@export var auto_cutscene_id: String = ""

@onready var interaction: InteractionComponent = get_node_or_null("InteractionComponent") as InteractionComponent

var balao_atual: SpeechBubbleNode = null

# Movimentação e Cutscene
var destino_atual: Vector2 = Vector2.ZERO
var movendo: bool = false
var velocidade_movimento: float = 65.0
var _animation_tree: AnimationTree = null


func _enter_tree() -> void:
	collision_layer = 8 # Layer 4 (NPC)
	collision_mask = 1  # Mask 1 (Paredes/Cenário apenas)


func _ready() -> void:
	add_to_group("npc")
	collision_layer = 8 # Layer 4 (NPC)
	collision_mask = 1  # Mask 1 (Paredes/Cenário apenas)
	
	_animation_tree = get_node_or_null("AnimationTree") as AnimationTree
	
	if interaction != null:
		if not interaction.interacted.is_connected(_on_interacted):
			interaction.interacted.connect(_on_interacted)

	# Configurar Gatilho de Cutscene por Proximidade se for personagem do mangá
	var id_alvo: String = auto_cutscene_id
	if id_alvo.is_empty():
		var n_lower = npc_name.to_lower()
		for k in CinematicManagerClass.PERFIS_MANGA.keys():
			if k in n_lower:
				id_alvo = k
				break

	if not id_alvo.is_empty():
		var trigger := CutsceneEncounterTrigger.new()
		trigger.character_id = id_alvo
		trigger.trigger_distance = 95.0
		add_child(trigger)

	# Label de Nome Fixo acima da cabeça do NPC (acompanha movimentação)
	call_deferred("_criar_label_nome")


func _criar_label_nome() -> void:
	if get_node_or_null("NPCNameLabel") != null:
		return
	var lbl := Label.new()
	lbl.name = "NPCNameLabel"
	lbl.text = npc_name
	lbl.position = Vector2(-50, -28)
	lbl.custom_minimum_size = Vector2(100, 10)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 3)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.95, 0.5, 1.0))
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	lbl.add_theme_constant_override("shadow_offset_x", 1)
	lbl.add_theme_constant_override("shadow_offset_y", 1)
	add_child(lbl)



func _physics_process(_delta: float) -> void:
	if movendo:
		var dist: float = global_position.distance_to(destino_atual)
		if dist <= 4.0:
			movendo = false
			velocity = Vector2.ZERO
			_atualizar_animacao(Vector2.DOWN, false)
			destino_alcancado.emit()
		else:
			var dir: Vector2 = (destino_atual - global_position).normalized()
			velocity = dir * velocidade_movimento
			_atualizar_animacao(dir, true)
			move_and_slide()


func andar_para(destino: Vector2, vel: float = 75.0) -> void:
	destino_atual = destino
	velocidade_movimento = vel
	movendo = true


func parar() -> void:
	movendo = false
	velocity = Vector2.ZERO
	_atualizar_animacao(Vector2.DOWN, false)


func _atualizar_animacao(dir: Vector2, andando: bool) -> void:
	if _animation_tree != null and _animation_tree.active:
		if andando:
			_animation_tree.set("parameters/walk/blend_position", dir)
			var state_machine = _animation_tree.get("parameters/playback")
			if state_machine != null:
				state_machine.travel("walk")
		else:
			_animation_tree.set("parameters/idle/blend_position", dir)
			var state_machine = _animation_tree.get("parameters/playback")
			if state_machine != null:
				state_machine.travel("idle")


func falar_balao(texto: String, duracao: float = 3.5, cor_borda: Color = Color(0.3, 0.7, 1.0, 0.95), cor_falante: Color = Color(1.0, 0.85, 0.3, 1.0)) -> SpeechBubbleNode:
	fechar_balao_atual()
	SpeechBubbleNode.fechar_balao_global()
	
	var novo_balao := SpeechBubbleNode.new()
	novo_balao.auto_advance_duration = duracao
	novo_balao.setup(npc_name, texto, cor_borda, cor_falante)
	add_child(novo_balao)
	balao_atual = novo_balao
	
	novo_balao.balao_fechado.connect(func():
		if balao_atual == novo_balao:
			balao_atual = null
	)
	
	return novo_balao


func fechar_balao_atual() -> void:
	if balao_atual != null and is_instance_valid(balao_atual):
		if not balao_atual.is_queued_for_deletion():
			balao_atual.fechar()
	balao_atual = null


func obter_fala_contextual(player: CharacterBody2D) -> String:

	# 1. Checar Ferimentos Graves (HP < 30%)
	var hp = PlayerData.attributes.get("vida", 100)
	var hp_max = PlayerData.attributes.get("vida_max", 100)
	if float(hp) <= float(hp_max) * 0.30 and hp > 0:
		return "Você está visivelmente ferido! Tome cuidado lá fora, as criaturas não terão piedade."

	# 2. Checar Técnicas de Nen ativas no jogador
	var nen_sys = player.get_node_or_null("NenSystem") if player != null else null
	if nen_sys != null and nen_sys.has_method("tecnica_ativa"):
		if nen_sys.tecnica_ativa(NenSystem.Tecnica.REN):
			return "Essa pressão de aura colossal...! Veio procurar uma disputa de força, Hunter?"
		elif nen_sys.tecnica_ativa(NenSystem.Tecnica.ZETSU):
			return "Uau! Você anda como uma sombra... Mal senti sua aproximação em Zetsu."
		elif nen_sys.tecnica_ativa(NenSystem.Tecnica.GYO):
			return "Seus olhos estão focados com Gyo. Está procurando por vestígios ou segredos ocultos por aqui?"

	# 3. Retornar fala padrão do NPC
	return fala_padrao


func _on_interacted(player: CharacterBody2D) -> void:
	QuestSystem.register_npc_visit(StringName(npc_name))
	QuestSystem.register_persuasion(StringName(npc_name))
	var texto_fala = obter_fala_contextual(player)
	falar_balao(texto_fala)
