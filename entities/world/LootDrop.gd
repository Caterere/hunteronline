class_name LootDrop
extends Area2D

# ============================================================
# HUNTER ONLINE - LOOT DROP (MOEDAS DE JENNY & ITENS DO CHÃO)
# ============================================================
#
# Item físico/moeda que cai do monstro ao morrer no chão 2D.
# Coletado ao passar por cima — com juice de pickup (RO/Tibia).
#
# ============================================================

enum TipoLoot {
	JENNY,
	POCAO_HP,
	ELIXIR_AURA
}

@export var tipo: TipoLoot = TipoLoot.JENNY
@export var valor_gold: int = 50
@export var item_id: String = "pocao_hp"

var sprite: Sprite2D
var tempo_vida: float = 0.0
var _coletado: bool = false
var _spawn_offset: Vector2 = Vector2.ZERO


static func spawn_jenny(parent: Node, world_pos: Vector2, quantidade: int) -> LootDrop:
	var drop := LootDrop.new()
	drop.setup_gold(quantidade)
	drop._spawn_offset = Vector2(randf_range(-10.0, 10.0), randf_range(-6.0, 6.0))
	parent.add_child(drop)
	drop.global_position = world_pos + drop._spawn_offset
	drop._play_spawn_pop()
	return drop


static func spawn_item_drop(parent: Node, world_pos: Vector2, id: String) -> LootDrop:
	var drop := LootDrop.new()
	drop.setup_item(id)
	drop._spawn_offset = Vector2(randf_range(-12.0, 12.0), randf_range(-8.0, 8.0))
	parent.add_child(drop)
	drop.global_position = world_pos + drop._spawn_offset
	drop._play_spawn_pop()
	return drop


func setup_gold(qtd: int) -> void:
	tipo = TipoLoot.JENNY
	valor_gold = maxi(1, qtd)
	_criar_visual(Color(1.0, 0.85, 0.2, 1.0)) # Dourado


func setup_item(id: String) -> void:
	tipo = TipoLoot.POCAO_HP
	item_id = id
	_criar_visual(Color(0.2, 0.9, 0.4, 1.0)) # Verde


func _ready() -> void:
	monitoring = true
	monitorable = false
	collision_layer = 0
	collision_mask = 1 # Player layer
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _criar_visual(cor: Color) -> void:
	if sprite != null and is_instance_valid(sprite):
		sprite.queue_free()
	sprite = Sprite2D.new()
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	for x in range(8):
		for y in range(8):
			var dist: float = Vector2(x - 4, y - 4).length()
			if dist <= 4.0:
				img.set_pixel(x, y, Color(1, 1, 1, 0.9))

	var tex := ImageTexture.create_from_image(img)
	sprite.texture = tex
	sprite.modulate = cor
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)

	if get_node_or_null("CollisionShape2D") == null:
		var col := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 10.0
		col.shape = circle
		add_child(col)


func _play_spawn_pop() -> void:
	scale = Vector2(0.35, 0.35)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Bounce de queda
	var start_y := global_position.y - 10.0
	var end_y := global_position.y
	global_position.y = start_y
	tween.parallel().tween_property(self, "global_position:y", end_y, 0.22).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	tempo_vida += delta
	if sprite != null:
		sprite.position.y = sin(tempo_vida * 5.0) * 2.0
	# Despawn após 45s para não poluir o mapa
	if tempo_vida > 45.0 and not _coletado:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if _coletado:
		return
	if body == null or not body.is_in_group("player"):
		return
	_coletado = true
	monitoring = false

	var pickup_pos: Vector2 = global_position
	var label_txt := ""
	var label_cor := Color(1.0, 0.9, 0.3)

	if tipo == TipoLoot.JENNY:
		if Economy != null:
			Economy.adicionar_gold(valor_gold)
		label_txt = "+%d Jenny" % valor_gold
		label_cor = Color(1.0, 0.85, 0.2)
		if EventBus != null:
			EventBus.emit_toast("+%d Jenny" % valor_gold, label_cor)
	else:
		if PlayerData != null:
			PlayerData.adicionar_item(item_id, 1)
		label_txt = "+%s" % item_id
		label_cor = Color(0.35, 1.0, 0.55)
		if EventBus != null:
			EventBus.emit_toast("Loot: %s" % item_id, label_cor)

	if DamageNumberSystem != null:
		DamageNumberSystem.spawn_texto(pickup_pos, label_txt, label_cor, 1.05, 0.85)

	if AudioManager != null:
		if AudioManager.has_method("tocar_sfx_posicional"):
			AudioManager.tocar_sfx_posicional("item_pickup", pickup_pos, 0.95)
		else:
			AudioManager.tocar_sfx_tipo("item_pickup", 0.95)

	# Pop de coleta
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.4, 1.4), 0.08)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.12)
	tween.tween_callback(queue_free)
