class_name GyoInspectable
extends Area2D

# ============================================================
# HUNTER ONLINE - GYO INSPECTABLE COMPONENT
# ============================================================
#
# Componente para objetos, marcas de Nen, segredos e pistas no mapa
# que reagem dinamicamente à visão de Gyo (CrossCode / HxH).
#
# Comportamento:
# - Sem Gyo: Invisível ou discreto, sem interação de aura.
# - Com Gyo: Revela partículas de aura, rótulo de pista e permite
#   inspeção investigativa detalhada.
#
# ============================================================

signal inspecionado(detalhes: Dictionary)
signal visibilidade_aura_alterada(visivel: bool)

@export_category("Informações de Investigação")
@export var clue_id: StringName = &""
@export var titulo_pista: String = "Vestígio de Nen"
@export_multiline var descricao_pista: String = "Uma concentração residual de aura foi descoberta aqui."
@export var categoria_nen: String = "Desconhecida"
@export var requer_gyo: bool = true
@export var consumir_ao_inspecionar: bool = false

@export_category("Visual da Aura")
@export var cor_aura: Color = Color(0.3, 0.8, 1.0, 0.85)

var gyo_ativo_no_jogador: bool = false
var jogador_proximo: Node2D = null
var foi_inspecionado: bool = false

@onready var label_dica: Label = null
@onready var aura_sprite: Sprite2D = null

func _enter_tree() -> void:
	collision_layer = 16 # Layer 5 (Pistas/Interativos)
	collision_mask = 2   # Detecta Player (Layer 2)

func _ready() -> void:
	add_to_group("gyo_inspectable")
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	_criar_elementos_visuais()
	atualizar_estado_gyo(false)

func _criar_elementos_visuais() -> void:
	# Criar label flutuante indicando a pista revelada
	if get_node_or_null("GyoLabel") == null:
		label_dica = Label.new()
		label_dica.name = "GyoLabel"
		label_dica.text = "🔍 [GYO] " + titulo_pista
		label_dica.position = Vector2(-75, -36)
		label_dica.custom_minimum_size = Vector2(150, 14)
		label_dica.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label_dica.add_theme_font_size_override("font_size", 8)
		label_dica.add_theme_color_override("font_color", cor_aura)
		label_dica.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
		label_dica.add_theme_constant_override("shadow_offset_x", 1)
		label_dica.add_theme_constant_override("shadow_offset_y", 1)
		label_dica.visible = false
		add_child(label_dica)

func atualizar_estado_gyo(ativo: bool) -> void:
	gyo_ativo_no_jogador = ativo
	var visivel = (not requer_gyo) or ativo
	
	if label_dica != null:
		label_dica.visible = visivel and (jogador_proximo != null)
	
	modulate = Color.WHITE if visivel else Color(1.0, 1.0, 1.0, 0.15 if requer_gyo else 1.0)
	visibilidade_aura_alterada.emit(visivel)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		jogador_proximo = body
		# Verificar estado de Gyo atual do player
		var nen_sys = body.get_node_or_null("NenSystem")
		if nen_sys != null and nen_sys.has_method("tecnica_ativa"):
			gyo_ativo_no_jogador = nen_sys.tecnica_ativa(NenSystem.Tecnica.GYO)
		
		if label_dica != null:
			label_dica.visible = (not requer_gyo) or gyo_ativo_no_jogador

func _on_body_exited(body: Node2D) -> void:
	if body == jogador_proximo:
		jogador_proximo = null
		if label_dica != null:
			label_dica.visible = false

func inspecionar(player: Node2D) -> Dictionary:
	if requer_gyo and not gyo_ativo_no_jogador:
		return {
			"sucesso": false,
			"mensagem": "Você precisa ativar GYO para decifrar este vestígio de aura."
		}
	
	foi_inspecionado = true
	var dados := {
		"sucesso": true,
		"clue_id": clue_id,
		"titulo": titulo_pista,
		"descricao": descricao_pista,
		"categoria_nen": categoria_nen
	}
	
	# Registrar segredo descoberto no PlayerData
	var cid_str = String(clue_id)
	if not cid_str.is_empty() and PlayerData != null:
		if not PlayerData.segredos_descobertos.has(cid_str):
			PlayerData.segredos_descobertos.append(cid_str)
			# Recompensar com Nen XP pela dedução com Gyo
			var nen_sys = player.get_node_or_null("NenSystem") if player != null else null
			if nen_sys != null and nen_sys.has_method("adicionar_nen_xp"):
				nen_sys.adicionar_nen_xp(50)
			elif PlayerData.attributes.has("xp_nen"):
				PlayerData.attributes["xp_nen"] += 50
	
	# Notificar QuestManager
	var quest_mgr = Engine.get_main_loop().root.get_node_or_null("/root/QuestSystem") if Engine.get_main_loop() else null
	if quest_mgr != null and quest_mgr.has_method("register_investigation"):
		quest_mgr.register_investigation(clue_id)
	
	if EventBus != null:
		EventBus.emit_toast("🔍 Vestígio Decifrado com Gyo: " + titulo_pista, Color(0.3, 0.9, 1.0, 1.0))
	
	inspecionado.emit(dados)
	
	if consumir_ao_inspecionar:
		queue_free()
		
	return dados

