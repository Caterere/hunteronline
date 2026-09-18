class_name KoObstacle
extends StaticBody2D

# ============================================================
# HUNTER ONLINE - KO DESTRUCTIBLE OBSTACLE
# ============================================================
#
# Barreira maciça de rocha ou cristal de Nen que bloqueia atalhos,
# cavernas e baús secretos.
# - Só é destruída se receber dano com a técnica KO ativada.
# - Golpes normais sem KO são absorvidos sem efeito.
#
# ============================================================

signal destruido(objeto: Node)

@export var obstacle_name: String = "Parede de Rocha Maciça"
@export var durabilidade: float = 1.0
@export var item_recompensa_id: StringName = &""
## Se preenchido, quebrar com KO registra INVESTIGATE neste clue_id.
@export var clue_id_on_break: StringName = &""

var foi_destruido: bool = false
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var collision: CollisionShape2D = get_node_or_null("CollisionShape2D")

func _ready() -> void:
	add_to_group("ko_obstacle")
	collision_layer = 1 # Bloqueia movimento físico (Mask 1 do Player)
	collision_mask = 0

func receber_dano(dano: int, _direcao: Vector2 = Vector2.ZERO, _forca_knockback: float = 0.0, atacante: Node = null) -> void:
	if foi_destruido:
		return
		
	# Verificar se o atacante está utilizando a técnica KO
	var nen_sys: NenSystem = null
	if atacante != null:
		nen_sys = atacante.get_node_or_null("NenSystem") as NenSystem
		
	if nen_sys == null:
		var players = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			nen_sys = players[0].get_node_or_null("NenSystem") as NenSystem

	var em_ko: bool = (nen_sys != null and nen_sys.has_method("tecnica_ativa") and nen_sys.tecnica_ativa(NenSystem.Tecnica.KO))
	
	if em_ko:
		destruir_com_ko()
	else:
		_exibir_aviso_ko()

func _exibir_aviso_ko() -> void:
	# Flash visual de bloqueio
	if sprite != null:
		sprite.modulate = Color(1.5, 0.4, 0.4, 1.0)
		await get_tree().create_timer(0.2).timeout
		if is_instance_valid(sprite):
			sprite.modulate = Color.WHITE

func destruir_com_ko() -> void:
	foi_destruido = true
	destruido.emit(self)
	
	# Conceder Nen XP e recompensas
	if PlayerData != null:
		if not item_recompensa_id.is_empty():
			PlayerData.adicionar_item(item_recompensa_id, 1)
		else:
			PlayerData.adicionar_item(&"pocao_vida", 1)
		if PlayerData.attributes.has("xp_nen"):
			PlayerData.attributes["xp_nen"] += 50
	
	if EventBus != null:
		EventBus.emit_camera_shake(0.3, 0.2)
		EventBus.emit_toast("💥 Obstáculo Quebrado com KO! (+50 Nen XP)", Color(1.0, 0.85, 0.2, 1.0))

	# Wire investigativo: KO conta como pista decifrada quando clue_id_on_break está setado
	if not clue_id_on_break.is_empty():
		var quest_mgr = Engine.get_main_loop().root.get_node_or_null("/root/QuestSystem") if Engine.get_main_loop() else null
		if quest_mgr != null and quest_mgr.has_method("register_investigation"):
			quest_mgr.register_investigation(clue_id_on_break)
		if PlayerData != null:
			var cid := str(clue_id_on_break)
			if not cid.is_empty() and not PlayerData.segredos_descobertos.has(cid):
				PlayerData.segredos_descobertos.append(cid)
		if EventBus != null:
			EventBus.emit_toast("🔍 KO revelou a pista: %s" % str(clue_id_on_break).replace("_", " "), Color(0.95, 0.75, 0.35))
	
	# Feedback visual e sonoro de quebra de rocha
	if collision != null:
		collision.set_deferred("disabled", true)
		
	if sprite != null:
		sprite.modulate = Color(3.0, 2.0, 0.5, 1.0)
		var tween = create_tween()
		tween.tween_property(sprite, "scale", Vector2.ZERO, 0.25)
		tween.tween_callback(queue_free)
	else:
		queue_free()

