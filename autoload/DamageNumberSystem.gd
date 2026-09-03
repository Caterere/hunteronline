extends Node

# ============================================================
# HUNTER ONLINE — DAMAGE NUMBER & COMBAT FEEDBACK SYSTEM
# ============================================================
#
# Sistema central de feedback flutuante (Floating Combat Text):
# - Responde automaticamente a sinais de combate globais:
#   - EventBus.combat_hit_landed
#   - CombatEngine.hit_processado
# - Tipos visuais suportados:
#   1. Dano normal: -25 (Branco / Amarelo suave)
#   2. Acerto Crítico: CRITICAL -60 (Ouro brilhante com pop de escala)
#   3. Ponto Fraco: WEAK POINT -45 (Laranja vibrante)
#   4. Dano Resistido: RESISTED -10 (Cinza / Azul metálico)
#   5. Esquiva: DODGE (Ciano ágil)
#   6. Bloqueio / Ten: BLOCKED (Azul cobalto de Ten)
#   7. Regeneração / Cura: +50 HP (Verde esmeralda)
#   8. Texto tático genérico: COUNTER STRIKE, STAGGER, etc.
# - Anti-spam e distribuição espacial para evitar sobreposição exata.
# ============================================================

const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")

var _recent_spawns: Array[Vector2] = []
var _cleanup_timer: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_conectar_sinais()


func _process(delta: float) -> void:
	_cleanup_timer += delta
	if _cleanup_timer >= 0.5:
		_cleanup_timer = 0.0
		_recent_spawns.clear()


func _conectar_sinais() -> void:
	if EventBus != null and EventBus.has_signal("combat_hit_landed"):
		EventBus.combat_hit_landed.connect(_on_combat_hit_landed)

	if CombatEngine != null and CombatEngine.has_signal("hit_processado"):
		CombatEngine.hit_processado.connect(_on_combat_engine_hit)


func _on_combat_hit_landed(_atacante: Node, defensor: Node, dano: int, is_crit: bool) -> void:
	if defensor == null or not is_instance_valid(defensor):
		return
	spawn_dano(defensor, dano, is_crit)


func _on_combat_engine_hit(_atacante: Node, defensor: Node, dano: int, is_crit: bool) -> void:
	if defensor == null or not is_instance_valid(defensor):
		return
	spawn_dano(defensor, dano, is_crit)


## Spawna um número de dano estilizado sobre o alvo
func spawn_dano(alvo_ou_pos: Variant, dano: int, is_crit: bool = false, is_weakness: bool = false, is_resisted: bool = false, _tag: String = "") -> void:
	var pos: Vector2 = _resolver_posicao(alvo_ou_pos)
	if pos == Vector2.ZERO and not (alvo_ou_pos is Vector2 and alvo_ou_pos == Vector2.ZERO):
		return

	var texto: String = ""
	var cor: Color = HunterUIStyle.COLOR_TEXT_PRIMARY
	var escala: float = 1.0

	if is_crit:
		texto = "💥 CRIT -%d" % dano
		cor = HunterUIStyle.COLOR_CRIT_GOLD
		escala = 1.25
	elif is_weakness:
		texto = "🎯 WEAK -%d" % dano
		cor = HunterUIStyle.COLOR_WEAK_ORANGE
		escala = 1.15
	elif is_resisted:
		texto = "🛡️ RESIST -%d" % dano
		cor = HunterUIStyle.COLOR_BLOCK_STEEL
		escala = 0.85
	else:
		texto = "-%d" % dano
		cor = Color(1.0, 0.95, 0.7)
		escala = 1.0

	spawn_texto(pos, texto, cor, escala)


## Spawna indicação de esquiva
func spawn_esquiva(alvo_ou_pos: Variant) -> void:
	var pos: Vector2 = _resolver_posicao(alvo_ou_pos)
	spawn_texto(pos, "🍃 DODGE", HunterUIStyle.COLOR_DODGE_CYAN, 1.1)


## Spawna indicação de bloqueio
func spawn_bloqueio(alvo_ou_pos: Variant) -> void:
	var pos: Vector2 = _resolver_posicao(alvo_ou_pos)
	spawn_texto(pos, "🛡️ BLOCKED", HunterUIStyle.COLOR_BLOCK_STEEL, 1.0)


## Spawna indicação de cura
func spawn_cura(alvo_ou_pos: Variant, valor: int) -> void:
	var pos: Vector2 = _resolver_posicao(alvo_ou_pos)
	spawn_texto(pos, "+%d HP" % valor, HunterUIStyle.COLOR_HEAL_GREEN, 1.15)


## Spawna um texto arbitrário estilizado no mundo
func spawn_texto(alvo_ou_pos: Variant, texto: String, cor: Color, escala: float = 1.0, duracao: float = 0.75) -> void:
	var world_pos: Vector2 = _resolver_posicao(alvo_ou_pos)

	# Jitter aleatório para evitar sobreposição em golpes rápidos de combo
	var jitter_x := randf_range(-14.0, 14.0)
	var jitter_y := randf_range(-4.0, 4.0)
	world_pos += Vector2(jitter_x, -16.0 + jitter_y)

	var root_node := _obter_container_mundo()
	if root_node == null:
		return

	# Nó container para permitir posicionamento e animação
	var container := Node2D.new()
	container.position = world_pos
	container.scale = Vector2(escala, escala)
	root_node.add_child(container)

	var lbl := Label.new()
	lbl.text = texto
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", HunterUIStyle.FONT_SIZE_DAMAGE)
	lbl.add_theme_color_override("font_color", cor)
	lbl.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.95))
	lbl.add_theme_constant_override("shadow_offset_x", 1)
	lbl.add_theme_constant_override("shadow_offset_y", 1)
	lbl.position = Vector2(-30, -8)
	lbl.custom_minimum_size = Vector2(60, 16)
	container.add_child(lbl)

	# Animação suave com Tween
	var tween := container.create_tween()
	var dest_y := container.position.y - randf_range(16.0, 24.0)
	tween.tween_property(container, "position:y", dest_y, duracao).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(container, "modulate:a", 0.0, duracao * 0.45).set_delay(duracao * 0.55)
	tween.tween_callback(container.queue_free)


func _resolver_posicao(alvo_ou_pos: Variant) -> Vector2:
	if alvo_ou_pos is Vector2:
		return alvo_ou_pos
	elif alvo_ou_pos != null and alvo_ou_pos is Node2D:
		if is_instance_valid(alvo_ou_pos):
			return alvo_ou_pos.global_position
	elif alvo_ou_pos != null and alvo_ou_pos is Control:
		if is_instance_valid(alvo_ou_pos):
			return alvo_ou_pos.global_position
	return Vector2.ZERO


func _obter_container_mundo() -> Node:
	var tree := get_tree()
	if tree == null:
		return null
	var cur_scene := tree.current_scene
	if cur_scene != null:
		return cur_scene
	return tree.root
