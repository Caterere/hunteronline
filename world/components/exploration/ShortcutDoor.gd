class_name ShortcutDoor
extends StaticBody2D

# ============================================================
# HUNTER ONLINE - SHORTCUT DOOR (ATALHO DESBLOQUEÁVEL)
# ============================================================
#
# Portão ou porta de ferro trancada por dentro.
# - Pela frente: trancada ("Trancado por dentro").
# - Por trás (lado da dungeon): alavanca ou mecanismo destranca
#   permanentemente o atalho, salvando o estado no PlayerData.
#
# ============================================================

signal atalho_aberto(shortcut_id: StringName)

@export var shortcut_id: StringName = &"atalho_padokia_ruinas"
@export var door_name: String = "Portão de Ferro das Ruínas"
@export var lado_desbloqueio_pos: Vector2 = Vector2(0, 32)

var esta_aberto: bool = false
@onready var collision: CollisionShape2D = get_node_or_null("CollisionShape2D")
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var interaction: InteractionComponent = null

func _ready() -> void:
	add_to_group("shortcut_door")
	collision_layer = 1 # Parede sólida
	collision_mask = 0
	
	# Verificar se já foi destrancado em save anterior
	if PlayerData.quest_states.get("atalho_" + String(shortcut_id), false):
		abrir_silenciosamente()
	else:
		_configurar_interacao()

func _configurar_interacao() -> void:
	interaction = InteractionComponent.new()
	interaction.name = "InteractionComponent"
	interaction.interaction_text = "[E] Operar Mecanismo do Portão"
	interaction.interaction_radius = 32.0
	interaction.position = lado_desbloqueio_pos
	add_child(interaction)
	interaction.interacted.connect(_on_interacted)

func _on_interacted(player: CharacterBody2D) -> void:
	if esta_aberto:
		return
		
	# Verificar se o jogador está do lado correto (dentro da área da alavanca)
	abrir()

func abrir() -> void:
	if esta_aberto:
		return
		
	esta_aberto = true
	PlayerData.quest_states["atalho_" + String(shortcut_id)] = true
	
	if collision != null:
		collision.set_deferred("disabled", true)
		
	if sprite != null:
		sprite.modulate = Color(0.6, 1.5, 0.6, 0.6)
		
	var hud = get_tree().get_first_node_in_group("player_hud")
	if hud != null and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("🔓 ATALHO DESTRAVADO: %s aberto!" % door_name)
		
	atalho_aberto.emit(shortcut_id)

func abrir_silenciosamente() -> void:
	esta_aberto = true
	if collision != null:
		collision.set_deferred("disabled", true)
	if sprite != null:
		sprite.modulate = Color(0.6, 1.5, 0.6, 0.6)
