class_name SecretHiddenPassage
extends Area2D

# ============================================================
# HUNTER ONLINE - SECRET HIDDEN PASSAGE (EXPLORAÇÃO ORGÂNICA)
# ============================================================
#
# Entidade de exploração orgânica (Fase G — Epic 5):
# - Representa passagens falsas (paredes ilusórias, folhagens, cachoeiras).
# - NUNCA gera waypoint ou marcação na bússola.
# - Reage a impacto de ataque ou aproximação direta.
# - Ao ser revelada, desvanece suavemente e concede feedback de descoberta.
# ============================================================

signal passagem_revelada(passagem_nome: String)

@export var passage_id: String = "passagem_secreta_ruinas"
@export var passage_name: String = "Fissura Oculta nas Ruínas"
@export var requires_hit: bool = true # Se precisa ser golpeada para revelar
@export var secret_loot_item_id: String = "reliquia_cacador_antigo"
@export var secret_loot_amount: int = 1

var revelada: bool = false
var _sprite: Sprite2D = null
var _collision_blocker: CollisionShape2D = null

func _ready() -> void:
	collision_layer = 1
	collision_mask = 2 # Detecta Player e ataques
	monitoring = true
	monitorable = true

	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	_sprite = get_node_or_null("Sprite2D")
	_collision_blocker = get_node_or_null("StaticBody2D/CollisionShape2D")

	# Checar se já foi revelada nesta sessão / save
	if WorldState != null and WorldState.tem_marco_historico("segredo_" + passage_id):
		revelada = true
		if _sprite != null:
			_sprite.modulate.a = 0.25
		if _collision_blocker != null:
			_collision_blocker.disabled = true


func revelar() -> void:
	if revelada:
		return
	revelada = true

	# Feedback visual de revelação (Fade suave)
	if _sprite != null:
		var tween := create_tween()
		tween.tween_property(_sprite, "modulate:a", 0.20, 0.6)

	if _collision_blocker != null:
		_collision_blocker.disabled = true

	# Registrar descoberta no WorldState sem criar waypoints
	if WorldState != null:
		WorldState.registrar_marco_historico("segredo_" + passage_id, {
			"nome": passage_name,
			"timestamp": Time.get_ticks_msec()
		})

	if EventBus != null:
		EventBus.emit_toast("🔍 Descoberta Orgânica: %s Revelada!" % passage_name, Color(0.95, 0.85, 0.3))
		EventBus.emit_camera_shake(0.25, 0.15)

	# Entregar recompensa secreta se aplicável
	if not secret_loot_item_id.is_empty() and PlayerData != null:
		PlayerData.adicionar_item(StringName(secret_loot_item_id), secret_loot_amount)

	passagem_revelada.emit(passage_name)
	print("[SecretPassage] Passagem descoberta pelo jogador: %s" % passage_name)


func _on_body_entered(body: Node2D) -> void:
	if not requires_hit and body.is_in_group("player"):
		revelar()


func _on_area_entered(area: Area2D) -> void:
	# Detecta caixas de colisão de ataque do jogador (HitBox)
	if area.is_in_group("player_attack") or "hitbox" in area.name.to_lower():
		revelar()
