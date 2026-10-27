class_name QuestWorldPickup
extends Area2D

# ============================================================
# Pickup de item de missão no mundo (ex.: ovo_aguia no Exame)
# Grupo "loot" → GPS. InteractionComponent → inventário + quest.
# ============================================================

@export var item_id: StringName = &""
@export var quantidade: int = 1
@export var titulo: String = "Item"
@export var dica: String = "[E] Coletar"


static func spawn(
	parent: Node2D,
	nome: String,
	pos: Vector2,
	p_item_id: StringName,
	p_titulo: String,
	p_qtd: int = 1,
	tint: Color = Color(1.0, 0.92, 0.55, 1.0)
) -> Area2D:
	if parent == null:
		return null
	if parent.get_node_or_null(nome) != null:
		return parent.get_node_or_null(nome) as Area2D
	var node = (load("res://world/components/exploration/QuestWorldPickup.gd") as GDScript).new()
	node.name = nome
	node.position = pos
	node.item_id = p_item_id
	node.quantidade = maxi(1, p_qtd)
	node.titulo = p_titulo
	node.dica = "[E] Coletar %s" % p_titulo
	parent.add_child(node)
	if node.has_method("_aplicar_visual"):
		node._aplicar_visual(tint)
	return node as Area2D


func _ready() -> void:
	collision_layer = 0
	collision_mask = 0
	add_to_group("loot")
	add_to_group("quest_pickup")
	set_meta("item_id", String(item_id))
	set_meta("quest_item_id", String(item_id))

	if get_node_or_null("CollisionShape2D") == null:
		var col := CollisionShape2D.new()
		var circ := CircleShape2D.new()
		circ.radius = 18.0
		col.shape = circ
		add_child(col)

	if get_node_or_null("InteractionComponent") == null:
		var inter = InteractionComponent.new()
		inter.name = "InteractionComponent"
		inter.interaction_text = dica if not dica.is_empty() else "[E] Coletar"
		inter.interaction_radius = 28.0
		inter.interacted.connect(_on_interacted)
		add_child(inter)


func _aplicar_visual(tint: Color) -> void:
	if get_node_or_null("Sprite2D") != null:
		return
	var spr := Sprite2D.new()
	spr.name = "Sprite2D"
	# Fallback procedural (sem asset dedicado): “ovo” oval legível
	var img := Image.create(12, 14, false, Image.FORMAT_RGBA8)
	for x in range(12):
		for y in range(14):
			var nx := (float(x) - 5.5) / 5.0
			var ny := (float(y) - 7.0) / 6.5
			if nx * nx + ny * ny <= 1.0:
				img.set_pixel(x, y, Color(tint.r, tint.g, tint.b, 0.95))
	spr.texture = ImageTexture.create_from_image(img)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.scale = Vector2(1.6, 1.6)
	spr.position = Vector2(0, -6)
	add_child(spr)

	var lbl := Label.new()
	lbl.name = "Label"
	lbl.text = "🥚 %s" % titulo
	lbl.position = Vector2(-40, -28)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 5)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.45))
	add_child(lbl)


func _on_interacted(_player: Node) -> void:
	if item_id.is_empty():
		queue_free()
		return
	# adicionar_item → EventBus.item_obtained → QuestSystem.register_item_collected
	if PlayerData != null:
		PlayerData.adicionar_item(item_id, quantidade)
	if EventBus != null:
		EventBus.emit_toast("🥚 Coletado: %s ×%d" % [titulo, quantidade], Color(1.0, 0.85, 0.35))
	var tree := get_tree()
	if tree != null:
		var hud = tree.get_first_node_in_group("player_hud")
		if hud != null and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🥚 %s coletado — volte a Menchi se o GPS pedir." % titulo)
	queue_free()
