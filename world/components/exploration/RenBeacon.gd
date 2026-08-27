class_name RenBeacon
extends Area2D

# ============================================================
# HUNTER ONLINE - REN ANCIENT BEACON (TOTEM ANCESTRAL)
# ============================================================
#
# Monólito ou altar ancestral que reage à emanação de REN.
# - Quando o jogador ativa REN perto do totem, ele é energizado.
# - Desbloqueia passagens secretas, ilumina ruínas ou ativa mecanismos.
#
# ============================================================

signal beacon_ativado()

@export var beacon_name: String = "Monólito Ancestral de Nen"
@export var acionar_apenas_uma_vez: bool = true
@export var no_alvo_para_destravar: NodePath = NodePath("")

var foi_ativado: bool = false
var jogador_por_perto: CharacterBody2D = null

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var label_status: Label = null

func _enter_tree() -> void:
	collision_layer = 0
	collision_mask = 2 # Player (Layer 2)

func _ready() -> void:
	add_to_group("ren_beacon")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_criar_label_indicativo()

func _criar_label_indicativo() -> void:
	if get_node_or_null("BeaconLabel") == null:
		label_status = Label.new()
		label_status.name = "BeaconLabel"
		label_status.text = "⚡ [Requer REN]"
		label_status.position = Vector2(-50, -32)
		label_status.custom_minimum_size = Vector2(100, 12)
		label_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label_status.add_theme_font_size_override("font_size", 8)
		label_status.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 0.9))
		label_status.visible = false
		add_child(label_status)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body is CharacterBody2D:
		jogador_por_perto = body as CharacterBody2D
		if label_status != null and not foi_ativado:
			label_status.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body == jogador_por_perto:
		jogador_por_perto = null
		if label_status != null:
			label_status.visible = false

func _process(_delta: float) -> void:
	if foi_ativado or jogador_por_perto == null:
		return
		
	var nen_sys = jogador_por_perto.get_node_or_null("NenSystem") as NenSystem
	if nen_sys != null and nen_sys.has_method("tecnica_ativa") and nen_sys.tecnica_ativa(NenSystem.Tecnica.REN):
		ativar_beacon()

func ativar_beacon() -> void:
	foi_ativado = true
	beacon_ativado.emit()
	
	if label_status != null:
		label_status.text = "✨ [ATIVADO]"
		label_status.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5, 1.0))
		
	if sprite != null:
		sprite.modulate = Color(2.0, 1.8, 0.4, 1.0)
		
	if not no_alvo_para_destravar.is_empty():
		var alvo = get_node_or_null(no_alvo_para_destravar)
		if alvo != null:
			if alvo.has_method("abrir"):
				alvo.abrir()
			elif alvo is CollisionShape2D:
				alvo.set_deferred("disabled", true)
			elif alvo is Node2D:
				alvo.visible = false
