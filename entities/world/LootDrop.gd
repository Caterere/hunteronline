class_name LootDrop
extends RefCounted

# ============================================================
# HUNTER ONLINE - RECOMPENSAS DIRETAS (JENNY / ITENS)
# ============================================================
#
# Antes: orbs Area2D no chão (coleta quebrada por collision mask).
# Agora: concede Jenny/itens imediatamente ao jogador com feedback
# flutuante (+Jenny / +item) no local da morte — sem pickup no chão.
#
# APIs estáticas mantêm os nomes spawn_* para compatibilidade.
#
# ============================================================


## Concede Jenny direto + feedback visual/SFX no mundo.
static func spawn_jenny(parent: Node, world_pos: Vector2, quantidade: int) -> void:
	var qtd: int = maxi(1, quantidade)
	if Economy != null:
		Economy.adicionar_gold(qtd)

	_feedback_mundo(parent, world_pos, "+%d Jenny" % qtd, Color(1.0, 0.85, 0.2), true)

	if EventBus != null:
		EventBus.emit_toast("+%d Jenny" % qtd, Color(1.0, 0.85, 0.2))


## Concede item direto ao inventário + feedback.
static func spawn_item_drop(parent: Node, world_pos: Vector2, id: String) -> void:
	var item_id: String = id.strip_edges()
	if item_id.is_empty():
		return

	if PlayerData != null:
		PlayerData.adicionar_item(StringName(item_id), 1)

	var label: String = "+%s" % item_id.replace("_", " ").capitalize()
	_feedback_mundo(parent, world_pos, label, Color(0.35, 1.0, 0.55), false)

	if EventBus != null:
		EventBus.emit_toast("Loot: %s" % item_id.replace("_", " ").capitalize(), Color(0.35, 1.0, 0.55))


## Compat: aliases antigos usados em testes/docs.
static func setup_gold_api_marker() -> String:
	return "direct_grant"


static func _feedback_mundo(parent: Node, world_pos: Vector2, texto: String, cor: Color, is_jenny: bool) -> void:
	if DamageNumberSystem != null:
		if is_jenny:
			# Extrai valor numérico se for "+N Jenny"
			var digits := ""
			for ch in texto:
				if ch >= "0" and ch <= "9":
					digits += ch
			var valor: int = int(digits) if not digits.is_empty() else 0
			if valor > 0:
				DamageNumberSystem.spawn_jenny(world_pos, valor)
			else:
				DamageNumberSystem.spawn_texto(world_pos, texto, cor, 1.05, 0.85)
		else:
			DamageNumberSystem.spawn_texto(world_pos, texto, cor, 1.05, 0.9)

	if AudioManager != null:
		if AudioManager.has_method("tocar_sfx_posicional"):
			AudioManager.tocar_sfx_posicional("item_pickup", world_pos, 0.95)
		elif AudioManager.has_method("tocar_sfx_tipo"):
			AudioManager.tocar_sfx_tipo("item_pickup", 0.95)

	# Micro sparkle no ponto da kill (sem Area2D / sem coleta)
	if parent == null or not is_instance_valid(parent):
		return
	var spark := Node2D.new()
	spark.z_index = 40
	parent.add_child(spark)
	spark.global_position = world_pos
	var spr := Sprite2D.new()
	var img := Image.create(6, 6, false, Image.FORMAT_RGBA8)
	for x in range(6):
		for y in range(6):
			if Vector2(x - 3, y - 3).length() <= 3.0:
				img.set_pixel(x, y, Color(1, 1, 1, 0.95))
	spr.texture = ImageTexture.create_from_image(img)
	spr.modulate = cor
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spark.add_child(spr)
	var tw := spark.create_tween()
	tw.tween_property(spark, "scale", Vector2(1.6, 1.6), 0.12).set_trans(Tween.TRANS_BACK)
	tw.parallel().tween_property(spark, "modulate:a", 0.0, 0.28)
	tw.tween_callback(spark.queue_free)
