class_name WorldInteractionObject
extends StaticBody2D

# ============================================================
# HUNTER ONLINE - OBJETOS INTERATIVOS DO MUNDO (FASES 6 & 7)
# ============================================================
#
# Permite ao jogador interagir física e contextualmente com o
# cenário usando mecânicas de Nen:
# - ROCHA_QUEBRAVEL_KO: Quebra apenas com golpe usando KO ativo.
# - RUNA_OCULTA_GYO: Pistas e glifos visíveis apenas com GYO.
# - FONTE_DESCANSO: Recupera 100% de HP e Aura ao interagir.
# - BAU_NEN: Baú com trava de Nen.
#
# ============================================================

enum ObjectType {
	ROCHA_QUEBRAVEL_KO,
	RUNA_OCULTA_GYO,
	FONTE_DESCANSO,
	BAU_NEN
}

@export var object_type: ObjectType = ObjectType.ROCHA_QUEBRAVEL_KO
@export var item_recompensa: StringName = &"minerio_aco"
@export var quantidade_recompensa: int = 2
@export var texto_interacao: String = "Interagir"
@export var id_objeto: String = ""

var destruido: bool = false
var revelado: bool = false
var _sprite: Sprite2D = null
var _interaction_comp: Node = null


func _ready() -> void:
	add_to_group("interactable")
	add_to_group("world_object")

	_sprite = get_node_or_null("Sprite2D") as Sprite2D

	if object_type == ObjectType.RUNA_OCULTA_GYO:
		modulate.a = 0.0 # Oculto por padrão aos olhos destreinados

	# Conectar interação via InteractionComponent se presente
	_interaction_comp = get_node_or_null("InteractionComponent")
	if _interaction_comp != null and _interaction_comp.has_signal("interacted"):
		_interaction_comp.interacted.connect(_on_interacted)


func _process(delta: float) -> void:
	if destruido:
		return

	if object_type == ObjectType.RUNA_OCULTA_GYO:
		_processar_visao_gyo(delta)


func _processar_visao_gyo(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	var dist = global_position.distance_to(player.global_position)
	var nen_sys = player.get_node_or_null("NenSystem")
	var em_gyo = (nen_sys != null and nen_sys.has_method("gyo_ativo") and nen_sys.gyo_ativo())

	if dist <= 120.0 and em_gyo:
		revelado = true
		modulate.a = lerp(modulate.a, 1.0, delta * 6.0)
	else:
		revelado = false
		modulate.a = lerp(modulate.a, 0.0, delta * 3.0)


func receber_dano(_dano: int, _dir: Vector2, _knockback: float, atacante: Node) -> void:
	if destruido:
		return

	if object_type == ObjectType.ROCHA_QUEBRAVEL_KO:
		var nen_sys = null
		if atacante != null:
			nen_sys = atacante.get_node_or_null("NenSystem")
		if nen_sys == null:
			var player = get_tree().get_first_node_in_group("player")
			if player: nen_sys = player.get_node_or_null("NenSystem")

		var tem_ko = (nen_sys != null and nen_sys.has_method("ko_ativo") and nen_sys.ko_ativo())

		if tem_ko:
			destruir_com_ko()
		else:
			if EventBus != null:
				EventBus.emit_toast("🛡️ Rocha impenetrável! Use KO para concentrar aura e quebrá-la!", Color(1.0, 0.7, 0.3))


func destruir_com_ko() -> void:
	destruido = true
	if EventBus != null:
		EventBus.emit_camera_shake(0.45, 0.25)
		EventBus.emit_toast("💥 CRASH! Rocha destruída com KO! (+%d %s)" % [quantidade_recompensa, item_recompensa], Color(0.4, 1.0, 0.4))

	# Conceder recompensa ao inventário
	PlayerData.adicionar_item(item_recompensa, quantidade_recompensa)

	# Remover do mundo
	queue_free()


func _on_interacted() -> void:
	var player = get_tree().get_first_node_in_group("player")
	interagir(player)


func interagir(jogador: Node) -> void:
	if destruido:
		return

	match object_type:
		ObjectType.FONTE_DESCANSO:
			var hp_max = int(PlayerData.attributes.get("vida_max", 100))
			var aura_max = int(PlayerData.attributes.get("aura_max", 100))
			PlayerData.attributes["vida"] = hp_max
			PlayerData.attributes["aura"] = aura_max
			if EventBus != null:
				EventBus.emit_toast("💧 Fonte de Descanso: Vida e Aura 100% restauradas!", Color(0.3, 0.9, 1.0))

		ObjectType.RUNA_OCULTA_GYO:
			var nen_sys = jogador.get_node_or_null("NenSystem") if jogador else null
			var em_gyo = (nen_sys != null and nen_sys.has_method("gyo_ativo") and nen_sys.gyo_ativo())
			if em_gyo:
				PlayerData.quest_states["runa_lida_%s" % id_objeto] = true
				if EventBus != null:
					EventBus.emit_toast("📜 Inscrição Antiga: 'O Guardião das Ruínas foca seu Ren nos 50% de HP.'", Color(1.0, 0.85, 0.2))
			else:
				if EventBus != null:
					EventBus.emit_toast("❓ Marcas difusas na pedra... Ative GYO para enxergar a aura!", Color(0.7, 0.7, 0.7))