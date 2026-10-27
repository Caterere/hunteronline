class_name MidLateDensityKit
extends RefCounted

const CheckpointCutsceneLibraryScript = preload("res://scripts/cutscenes/CheckpointCutsceneLibrary.gd")
const CompanionChatterScript = preload("res://scripts/story/CompanionChatter.gd")
const HatsuConfigScript = preload("res://scripts/systems/hatsu/HatsuConfig.gd")

# ============================================================
# HUNTER ONLINE — Mid/Late Steam density helpers (G1–G4)
# ============================================================
# Baús de clareira, Hatsu moments, checkpoint cutscenes e
# CompanionChatter — sem sistemas MMO novos.
# ============================================================

const PATH_CHEST_WOOD := "res://assets/sprites/objects/chest_01.png"
const PATH_CHEST_GOLD := "res://assets/sprites/objects/chest_02.png"
const PATH_CHEST_FALLBACK := "res://assets/sprites/objects/nen_stone_monolith.png"
## Spritesheet 64×16 = 4 frames 16×16; frame 0 = fechado.
const CHEST_FRAME := Rect2(0, 0, 16, 16)


static func spawna_bau(
	parent: Node2D,
	nome: String,
	pos: Vector2,
	titulo: String,
	loot: Array,
	dourado: bool = false
) -> void:
	if parent == null or parent.get_node_or_null(nome) != null:
		return
	var bau := Area2D.new()
	bau.name = nome
	bau.position = pos
	bau.collision_layer = 0
	bau.collision_mask = 0

	var col := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(28, 28)
	col.shape = box
	bau.add_child(col)

	var spr := Sprite2D.new()
	spr.name = "Sprite2D"
	_aplicar_sprite_bau(spr, dourado)
	bau.add_child(spr)

	var lbl := Label.new()
	lbl.text = "📦 %s" % titulo
	lbl.position = Vector2(-55, -36)
	lbl.custom_minimum_size = Vector2(110, 12)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	HunterUIStyle.aplicar_fonte_pixel_bold(lbl, 6, Color(0.95, 0.88, 0.55))
	bau.add_child(lbl)

	var inter = InteractionComponent.new()
	inter.name = "InteractionComponent"
	inter.interaction_text = "[E] Abrir %s" % titulo
	inter.interaction_radius = 28.0
	inter.interacted.connect(func(_p):
		_abrir_bau(bau, titulo, loot)
	)
	bau.add_child(inter)
	parent.add_child(bau)


static func _aplicar_sprite_bau(spr: Sprite2D, dourado: bool = false) -> void:
	var path := PATH_CHEST_GOLD if dourado else PATH_CHEST_WOOD
	if not ResourceLoader.exists(path):
		path = PATH_CHEST_FALLBACK if ResourceLoader.exists(PATH_CHEST_FALLBACK) else ""
	if path.is_empty():
		return
	spr.texture = load(path) as Texture2D
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if path == PATH_CHEST_WOOD or path == PATH_CHEST_GOLD:
		spr.region_enabled = true
		spr.region_rect = CHEST_FRAME
		spr.scale = Vector2(1.5, 1.5)
		spr.position = Vector2(0, -6)
		spr.modulate = Color.WHITE
	else:
		spr.scale = Vector2(0.35, 0.28)
		spr.modulate = Color(0.95, 0.8, 0.35, 1.0)
		spr.position = Vector2(0, -8)


static func _abrir_bau(bau_node: Node, titulo: String, loot: Array) -> void:
	if bau_node == null or not is_instance_valid(bau_node):
		return
	var partes: PackedStringArray = []
	if PlayerData != null:
		for entry in loot:
			var id: StringName = entry.get("id", &"")
			var qtd: int = int(entry.get("qtd", 1))
			if id.is_empty() or qtd <= 0:
				continue
			PlayerData.adicionar_item(id, qtd)
			partes.append("%dx %s" % [qtd, str(id)])
	var resumo := ", ".join(partes) if not partes.is_empty() else "nada"
	if EventBus != null:
		EventBus.emit_toast("✨ %s: %s" % [titulo, resumo], Color(0.35, 1.0, 0.55))
	var tree := bau_node.get_tree()
	if tree != null:
		var hud = tree.get_first_node_in_group("player_hud")
		if hud != null and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("✨ %s: %s" % [titulo, resumo])
	bau_node.queue_free()


static func plant_hatsu_moment(
	parent: Node2D,
	nome: String,
	pos: Vector2,
	titulo: String,
	descricao: String,
	flag: String
) -> void:
	if parent == null or parent.get_node_or_null(nome) != null:
		return
	var area := Area2D.new()
	area.name = nome
	area.position = pos
	area.collision_layer = 0
	area.collision_mask = 2
	area.set_meta("hatsu_moment", true)
	area.set_meta("hatsu_flag", flag)

	var col := CollisionShape2D.new()
	var circ := CircleShape2D.new()
	circ.radius = 36.0
	col.shape = circ
	area.add_child(col)

	var lbl := Label.new()
	lbl.text = "⚡ %s\n[E] Momento Hatsu" % titulo
	lbl.position = Vector2(-60, -42)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 5)
	lbl.add_theme_color_override("font_color", Color(0.95, 0.75, 1.0, 0.95))
	area.add_child(lbl)

	var inter = InteractionComponent.new()
	inter.name = "InteractionComponent"
	inter.interaction_text = "[E] %s" % titulo
	inter.interaction_radius = 36.0
	inter.interacted.connect(func(_p):
		_ativar_hatsu_moment(area, titulo, descricao, flag)
	)
	area.add_child(inter)
	parent.add_child(area)


static func _ativar_hatsu_moment(area: Node, titulo: String, descricao: String, flag: String) -> void:
	if StoryManager != null and not flag.is_empty():
		if bool(StoryManager.get_story_flag(flag, false)):
			if EventBus != null:
				EventBus.emit_toast("⚡ %s — já vivido." % titulo, Color(0.7, 0.8, 0.95))
			return
		StoryManager.set_story_flag(flag, true)
	var mastery_msg := _conceder_mastery_real_momento()
	if EventBus != null:
		if mastery_msg.is_empty():
			EventBus.emit_toast("⚡ Momento Hatsu: %s" % titulo, Color(0.85, 0.55, 1.0))
		else:
			EventBus.emit_toast("⚡ Momento Hatsu: %s — %s" % [titulo, mastery_msg], Color(0.85, 0.55, 1.0))
	var tree := area.get_tree() if area != null else null
	if tree != null:
		var visual = tree.get_first_node_in_group("visual_dialogue_ui")
		if visual != null and visual.has_method("exibir_sequencia_falas"):
			visual.exibir_sequencia_falas([
				{"falante": "Narrador", "texto": descricao},
				{"falante": "Aura", "texto": "A identidade do seu Hatsu fica um pouco mais clara. Continue."}
			])


## Concede mastery real via HatsuData (não o atributo fantasma attributes["hatsu_mastery"]).
static func _conceder_mastery_real_momento() -> String:
	var h: HatsuData = _obter_hatsu_para_momento()
	if h == null:
		return "equipe um Hatsu para receber mastery"
	if h.is_mastered():
		return "%s já mastered" % h.nome
	var antes: int = int(h.mastery)
	var xp_nivel: float = HatsuConfigScript.get_xp_for_mastery_level(antes)
	# ~+10 níveis early (100 XP/nível) — reward narrativo, sem farm infinito
	var res: Dictionary = h.adicionar_mastery_xp(xp_nivel * 10.0)
	if HatsuProgressionManager != null:
		HatsuProgressionManager.hatsu_mastery_alterada.emit(
			h.hatsu_id, h.mastery, h.mastery_xp, h.is_mastered()
		)
	var ganho: int = int(h.mastery) - antes
	if bool(res.get("mastered", false)):
		return "%s MASTERED" % h.nome
	if ganho > 0:
		return "%s +%d mastery" % [h.nome, ganho]
	return "%s +%.0f XP mastery" % [h.nome, xp_nivel * 10.0]


static func _obter_hatsu_para_momento() -> HatsuData:
	if PlayerData == null:
		return null
	for i in range(4):
		var slot_h: HatsuData = PlayerData.obter_hatsu_slot(i)
		if slot_h != null:
			return slot_h
	for entry in PlayerData.hatsu_criados:
		if entry is HatsuData:
			return entry as HatsuData
	return null


static func plant_checkpoint_cutscene(
	parent: Node2D,
	nome: String,
	pos: Vector2,
	cutscene_id: StringName,
	titulo: String = "Checkpoint"
) -> void:
	if parent == null or parent.get_node_or_null(nome) != null:
		return
	var area := Area2D.new()
	area.name = nome
	area.position = pos
	area.collision_layer = 0
	area.collision_mask = 2
	area.set_meta("checkpoint_cutscene_id", String(cutscene_id))
	area.monitoring = true

	var col := CollisionShape2D.new()
	var circ := CircleShape2D.new()
	circ.radius = 42.0
	col.shape = circ
	area.add_child(col)

	var lbl := Label.new()
	lbl.text = "🎬 %s" % titulo
	lbl.position = Vector2(-40, -28)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 5)
	lbl.add_theme_color_override("font_color", Color(0.85, 0.9, 1.0, 0.9))
	area.add_child(lbl)

	var fired := {"v": false}
	area.body_entered.connect(func(body: Node):
		if fired["v"]:
			return
		if body == null or not body.is_in_group("player"):
			return
		fired["v"] = true
		CheckpointCutsceneLibraryScript.executar(parent.get_tree(), cutscene_id)
	)
	parent.add_child(area)


static func attach_companion_chatter(parent: Node2D, saga_id: int) -> void:
	if parent == null:
		return
	if parent.get_node_or_null("CompanionChatter") != null:
		return
	var chatter := CompanionChatterScript.new()
	chatter.name = "CompanionChatter"
	chatter.saga_id = saga_id
	parent.add_child(chatter)


static func densify_profile(parent: Node2D, profile: Dictionary) -> void:
	if parent == null:
		return
	var saga_id: int = int(profile.get("saga_id", 0))
	if bool(profile.get("companion", true)) and saga_id > 0:
		attach_companion_chatter(parent, saga_id)
	for b in profile.get("baus", []):
		if b is Dictionary:
			spawna_bau(
				parent,
				str(b.get("name", "BauClareira")),
				b.get("pos", Vector2.ZERO),
				str(b.get("titulo", "Baú da Clareira")),
				b.get("loot", [{"id": &"pedra_aura", "qtd": 1}]),
				bool(b.get("dourado", false))
			)
	for h in profile.get("hatsu_moments", []):
		if h is Dictionary:
			plant_hatsu_moment(
				parent,
				str(h.get("name", "HatsuMoment")),
				h.get("pos", Vector2.ZERO),
				str(h.get("titulo", "Momento Hatsu")),
				str(h.get("descricao", "Sua aura responde.")),
				str(h.get("flag", "hatsu_moment"))
			)
	for c in profile.get("checkpoints", []):
		if c is Dictionary:
			plant_checkpoint_cutscene(
				parent,
				str(c.get("name", "CheckpointCutscene")),
				c.get("pos", Vector2.ZERO),
				StringName(str(c.get("id", "generic"))),
				str(c.get("titulo", "Checkpoint"))
			)
