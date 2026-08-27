class_name MapTransitionArea
extends Area2D

# ============================================================
# HUNTER ONLINE - MAP TRANSITION AREA & PORTAL DIMENSIONAL
# ============================================================
#
# Área de transição para troca de mapas com:
# - Suporte a tecla [E] nativa através de InteractionComponent
# - Detecção física de colisão ao pisar no portal (Layer 2 - Player)
# - StoryGate: Validação oficial de requisitos de história e objetivos (Anti-Bypass)
# - Label flutuante identificador e feedback visual
# - Transição suave com Fade e Banner através de SceneTransition
# - Suporte a diálogo prévio de transição/conclusão de fase
# - Pertence ao grupo "portal" para o MissionGPSIndicator
#
# ============================================================

const StoryGate = preload("res://world/components/StoryGate.gd")

@export_file("*.tscn") var target_scene_path: String = ""
@export var target_spawn_position: Vector2 = Vector2.ZERO
@export var portal_name: String = "Próximo Mapa"
@export var map_subtitle: String = ""
@export var requires_e_key: bool = true

@export_group("Story Gate Requisitos")
@export var required_story_arc: int = 0
@export var required_story_stage: int = 0
@export var required_all_arc_stages: bool = false

var story_gate = null
var ja_trocando: bool = false
var callback_dialogo_previo: Callable = Callable()


func _ready() -> void:
	add_to_group("portal")
	collision_layer = 0
	collision_mask = 2 # Detecta Player (Layer 2)

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	if story_gate == null and (required_story_arc > 0 or required_story_stage > 0 or required_all_arc_stages):
		story_gate = StoryGate.new(required_story_arc, required_story_stage, required_all_arc_stages)
		story_gate.gate_title = portal_name

	_configurar_componente_interacao()
	_criar_visual_portal()


func _configurar_componente_interacao() -> void:
	var inter = get_node_or_null("InteractionComponent") as InteractionComponent
	if inter == null:
		inter = InteractionComponent.new()
		inter.name = "InteractionComponent"
		inter.interaction_text = "[E] Entrar no Portal (%s)" % portal_name
		inter.interaction_radius = 28.0
		add_child(inter)

	if not inter.interacted.is_connected(_on_interacted):
		inter.interacted.connect(_on_interacted)


func _criar_visual_portal() -> void:
	if get_node_or_null("PortalVisualLabel") != null:
		return

	var lbl := Label.new()
	lbl.name = "PortalVisualLabel"
	lbl.text = "⛩️ %s\n[E] Entrar" % portal_name
	lbl.position = Vector2(-60, -38)
	lbl.custom_minimum_size = Vector2(120, 16)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 4)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3, 1.0))
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	lbl.add_theme_constant_override("shadow_offset_x", 1)
	lbl.add_theme_constant_override("shadow_offset_y", 1)
	add_child(lbl)


func _on_interacted(_player: CharacterBody2D) -> void:
	if ja_trocando:
		return
	print("[MapTransitionArea] Jogador pressionou [E] no portal: ", portal_name)
	_tentar_executar_transicao(_player)


func _on_body_entered(body: Node) -> void:
	if ja_trocando or requires_e_key:
		return
	if not body.is_in_group("player") and body.name != "Player":
		return
	print("[MapTransitionArea] Jogador entrou na área do portal: ", portal_name)
	_tentar_executar_transicao(body as CharacterBody2D)


func _tentar_executar_transicao(_player: CharacterBody2D = null) -> void:
	if ja_trocando:
		return

	# --- VALIDAÇÃO DE REQUISITOS DE HISTÓRIA (STORY GATE) ---
	if story_gate != null and not story_gate.can_advance():
		var pendencias = story_gate.get_unmet_requirements()
		print("[MapTransitionArea] ⛔ Passagem bloqueada pelo StoryGate para: ", portal_name)
		print("[MapTransitionArea] ⛔ Pendências: ", pendencias)

		if EventBus != null:
			var msg_curta = "⛔ Passagem Bloqueada: Conclua os objetivos obrigatórios primeiro!"
			if not pendencias.is_empty():
				msg_curta = "⛔ Bloqueado: " + pendencias[0]
			EventBus.emit_toast(msg_curta, Color(1.0, 0.4, 0.4))

		var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
		if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
			visual_dialogue.exibir_sequencia_falas(story_gate.get_formatted_rejection_dialogue())
		return

	_executar_transicao()


func _executar_transicao() -> void:
	if ja_trocando:
		return

	if target_scene_path.is_empty():
		push_warning("[MapTransitionArea] Nenhuma cena de destino configurada para: %s" % portal_name)
		return

	# Se houver diálogo prévio registrado (ex: conclusão de fase do Exame)
	if callback_dialogo_previo.is_valid():
		ja_trocando = true
		callback_dialogo_previo.call(func():
			_mudar_cena()
		)
		return

	ja_trocando = true
	print("=================================")
	print("[MapTransitionArea] Trocando de mapa suavemente para: ", target_scene_path)
	print("=================================")

	call_deferred("_mudar_cena")


func _mudar_cena() -> void:
	var trans = get_node_or_null("/root/SceneTransition")
	if trans != null and trans.has_method("mudar_cena"):
		trans.mudar_cena(target_scene_path, portal_name, map_subtitle)
	else:
		var audio_mgr = get_node_or_null("/root/AudioManager")
		if audio_mgr and audio_mgr.has_method("tocar_musica_por_cena"):
			audio_mgr.tocar_musica_por_cena(target_scene_path)
		get_tree().change_scene_to_file(target_scene_path)