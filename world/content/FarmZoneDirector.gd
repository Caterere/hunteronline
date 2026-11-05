class_name FarmZoneDirector
extends Node2D

# ============================================================
# HUNTER ONLINE — FARM ZONE DIRECTOR
# ============================================================
#
# Mantém população aleatória de mobs numa FarmZone:
# - Sorteia enemy_id do pool + level na faixa
# - Escala EnemyData, marca elite/Hatsu
# - Respawn com delay após morte
# - Toast ao entrar na Area2D da zona
#
# ============================================================

signal zone_entered(zone)
signal entity_spawned(entity: CharacterBody2D, zone)
signal population_changed(alive: int, max_alive: int)

const ENEMY_SCENE := "res://scripts/systems/EnemySystem/Enemy.tscn"
const FarmZoneCatalogScript = preload("res://resource/world/FarmZoneCatalog.gd")
const HatsuConfigScript = preload("res://scripts/systems/hatsu/HatsuConfig.gd")

const FarmZoneScript = preload("res://resource/world/FarmZone.gd")

@export var zone_id: StringName = &""
@export var zone_override: Resource = null
@export var auto_start: bool = true
@export var show_enter_toast: bool = true

var zone = null # FarmZone
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _spawn_root: Node2D = null
var _alive: Array = [] # CharacterBody2D
var _pending_respawns: int = 0
var _zone_area: Area2D = null
var _player_inside: bool = false
var _fill_timer: float = 0.0
var _hud_label: Label = null


func _ready() -> void:
	rng.randomize()
	_resolver_zona()
	_spawn_root = Node2D.new()
	_spawn_root.name = "FarmZoneSpawns"
	add_child(_spawn_root)
	_criar_area_zona()
	_criar_hud_faixa()
	if auto_start and zone != null:
		call_deferred("_popular_inicial")


func _process(delta: float) -> void:
	if zone == null:
		return
	_limpar_mortos()
	_fill_timer -= delta
	if _fill_timer <= 0.0:
		_fill_timer = 0.75
		_tentar_preencher_populacao()


func configurar_zona(z) -> void:
	zone = z
	if z != null:
		zone_id = z.zone_id
	_atualizar_area_zona()
	_atualizar_hud_faixa()


func obter_vivos() -> Array:
	_limpar_mortos()
	return _alive.duplicate()


func contar_vivos() -> int:
	_limpar_mortos()
	return _alive.size()


func forcar_respawn_todos() -> void:
	for e in _alive:
		if e != null and is_instance_valid(e):
			e.queue_free()
	_alive.clear()
	_pending_respawns = 0
	_popular_inicial()


func spawn_um() -> CharacterBody2D:
	if zone == null:
		return null
	if NetworkManager != null and not NetworkManager.is_offline_singleplayer():
		return null
	if contar_vivos() + _pending_respawns >= zone.max_alive:
		return null
	var entry: Dictionary = zone.sortear_inimigo(rng)
	if entry.is_empty():
		return null
	var enemy_id := StringName(str(entry.get("enemy_id", "slime")))
	var level: int = zone.sortear_nivel(rng)
	var elite_chance: float = float(entry.get("elite_chance", 0.1))
	var force_hatsu: bool = bool(entry.get("force_hatsu", false))
	var is_elite: bool = force_hatsu or rng.randf() <= elite_chance

	var data: EnemyData = _montar_enemy_data(enemy_id, level, is_elite, force_hatsu)
	if data == null:
		return null

	if not ResourceLoader.exists(ENEMY_SCENE):
		return null
	var scn: PackedScene = load(ENEMY_SCENE) as PackedScene
	if scn == null:
		return null
	var enemy: CharacterBody2D = scn.instantiate() as CharacterBody2D
	if enemy == null:
		return null

	var pos: Vector2 = zone.ponto_spawn_aleatorio(rng)
	enemy.name = "Farm_%s_%s_%d" % [String(zone.zone_id), String(enemy_id), rng.randi() % 100000]

	var es = enemy.get_node_or_null("EnemySystem")
	if es != null:
		es.enemy_data = data
		es.enemy_id = data.enemy_id
		es.enemy_name = data.enemy_name
		es.farm_zone_id = zone.zone_id
		es.is_mission_enemy = false
		if not es.died.is_connected(_on_farm_enemy_died):
			es.died.connect(_on_farm_enemy_died.bind(enemy))

	_spawn_root.add_child(enemy)
	enemy.position = pos
	_alive.append(enemy)
	entity_spawned.emit(enemy, zone)
	population_changed.emit(contar_vivos(), zone.max_alive)
	return enemy


func _resolver_zona() -> void:
	if zone_override != null:
		zone = zone_override
		zone_id = zone.zone_id
		return
	if not zone_id.is_empty():
		zone = FarmZoneCatalogScript.obter_por_id(zone_id)
		return
	var scene_path := ""
	if get_tree() != null and get_tree().current_scene != null:
		scene_path = str(get_tree().current_scene.scene_file_path)
	if scene_path.is_empty() and get_parent() != null and get_parent().scene_file_path:
		scene_path = str(get_parent().scene_file_path)
	if not scene_path.is_empty():
		zone = FarmZoneCatalogScript.obter_para_mapa(scene_path)
		if zone != null:
			zone_id = zone.zone_id


func _montar_enemy_data(enemy_id: StringName, level: int, is_elite: bool, force_hatsu: bool) -> EnemyData:
	var base: EnemyData = null
	if DataManager != null:
		base = DataManager.get_enemy(enemy_id) as EnemyData
	if base == null:
		push_warning("[FarmZoneDirector] enemy_id ausente no registry: %s" % String(enemy_id))
		return null
	var data: EnemyData = base.duplicate(true) as EnemyData
	if data == null:
		data = EnemyData.new()
		data.enemy_id = base.enemy_id
		data.enemy_name = base.enemy_name
		data.role = base.role
		data.drop_table = base.drop_table.duplicate(true)
		data.hatsu_name = base.hatsu_name
		data.npc_tier = base.npc_tier
		data.is_elite = base.is_elite
		data.is_boss = base.is_boss
	if is_elite:
		data.is_elite = true
		if int(data.npc_tier) < 2:
			data.npc_tier = EnemyData.NPCTier.TIER_2_SPECIAL
	if force_hatsu and data.hatsu_name.is_empty():
		data.hatsu_name = "Golpe de Nen Remoto"
		if int(data.npc_tier) < 2:
			data.npc_tier = EnemyData.NPCTier.TIER_2_SPECIAL
	data.escalonar_para_nivel(level)
	var NenKit = load("res://scripts/systems/EnemySystem/EnemyNenKit.gd")
	if NenKit != null and NenKit.has_method("enrich"):
		NenKit.enrich(data)
	return data


func _popular_inicial() -> void:
	if zone == null:
		return
	var target: int = zone.max_alive
	for _i in range(target):
		spawn_um()


func _tentar_preencher_populacao() -> void:
	if zone == null:
		return
	var vivos: int = contar_vivos()
	var slots: int = zone.max_alive - vivos - _pending_respawns
	if slots <= 0:
		return
	# Preenche gradualmente (1 por tick) para evitar burst
	spawn_um()


func _limpar_mortos() -> void:
	for i in range(_alive.size() - 1, -1, -1):
		var e = _alive[i]
		if e == null or not is_instance_valid(e):
			_alive.remove_at(i)
			continue
		var es = e.get_node_or_null("EnemySystem")
		if es != null and bool(es.get("is_dead")):
			_alive.remove_at(i)


func _on_farm_enemy_died(_killed_id = null, enemy: CharacterBody2D = null) -> void:
	if enemy != null and _alive.has(enemy):
		_alive.erase(enemy)
	population_changed.emit(contar_vivos(), zone.max_alive if zone else 0)
	if zone == null:
		return
	_pending_respawns += 1
	var delay: float = maxf(0.5, zone.respawn_delay)
	get_tree().create_timer(delay).timeout.connect(func():
		_pending_respawns = maxi(0, _pending_respawns - 1)
		if is_inside_tree():
			spawn_um()
	)


func _criar_area_zona() -> void:
	_zone_area = Area2D.new()
	_zone_area.name = "FarmZoneArea"
	_zone_area.collision_layer = 0
	_zone_area.collision_mask = 2 # player layer típico; fallback via group
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	shape.shape = rect
	_zone_area.add_child(shape)
	add_child(_zone_area)
	_zone_area.body_entered.connect(_on_body_entered_zona)
	_zone_area.body_exited.connect(_on_body_exited_zona)
	_atualizar_area_zona()


func _atualizar_area_zona() -> void:
	if _zone_area == null or zone == null:
		return
	var shape_node := _zone_area.get_child(0) as CollisionShape2D
	if shape_node == null:
		return
	var rect_shape := shape_node.shape as RectangleShape2D
	if rect_shape == null:
		rect_shape = RectangleShape2D.new()
		shape_node.shape = rect_shape
	rect_shape.size = zone.spawn_rect.size
	_zone_area.position = zone.spawn_rect.get_center()


func _on_body_entered_zona(body: Node) -> void:
	if body == null:
		return
	if not (body.is_in_group("player") or body.name == "Player"):
		return
	_player_inside = true
	if zone != null:
		zone_entered.emit(zone)
		_mostrar_entrada()


func _on_body_exited_zona(body: Node) -> void:
	if body == null:
		return
	if body.is_in_group("player") or body.name == "Player":
		_player_inside = false
		if _hud_label != null:
			_hud_label.visible = false


func _mostrar_entrada() -> void:
	if zone == null:
		return
	_atualizar_hud_faixa()
	if _hud_label != null:
		_hud_label.visible = true
	if not show_enter_toast:
		return
	var msg := "🗺️ %s (%s)" % [zone.display_name, zone.faixa_level_texto()]
	if EventBus != null and EventBus.has_method("emit_toast"):
		EventBus.emit_toast(msg, Color(0.55, 0.95, 0.7))
	var hud = get_tree().get_first_node_in_group("player_hud") if is_inside_tree() else null
	if hud != null and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao(msg)


func _criar_hud_faixa() -> void:
	_hud_label = Label.new()
	_hud_label.name = "FarmZoneBanner"
	_hud_label.visible = false
	_hud_label.z_index = 50
	_hud_label.add_theme_font_size_override("font_size", 10)
	_hud_label.add_theme_color_override("font_color", Color(0.85, 1.0, 0.75))
	_hud_label.position = Vector2(8, -18)
	add_child(_hud_label)
	_atualizar_hud_faixa()


func _atualizar_hud_faixa() -> void:
	if _hud_label == null or zone == null:
		return
	_hud_label.text = "%s · %s" % [zone.display_name, zone.faixa_level_texto()]


## Soft-cap de drop de buff quando o jogador está muito acima da zona.
static func fator_anti_farm_drop(player_level: int, enemy_level: int) -> float:
	return float(HatsuConfigScript.calcular_penalidade_anti_farm(player_level, enemy_level))


static func anexar_ao_mapa(mapa: Node2D, zone_or_id = null):
	if mapa == null:
		return null
	var existing = mapa.get_node_or_null("FarmZoneDirector")
	if existing != null and existing.get_script() == load("res://world/content/FarmZoneDirector.gd"):
		return existing
	var director_script = load("res://world/content/FarmZoneDirector.gd")
	var director = director_script.new()
	director.name = "FarmZoneDirector"
	if zone_or_id != null and zone_or_id is Resource and "zone_id" in zone_or_id:
		director.zone_override = zone_or_id
		director.zone = zone_or_id
		director.zone_id = zone_or_id.zone_id
	elif zone_or_id != null:
		director.zone_id = StringName(str(zone_or_id))
	else:
		var path := str(mapa.scene_file_path) if mapa.scene_file_path else ""
		var z = FarmZoneCatalogScript.obter_para_mapa(path)
		if z != null:
			director.zone_override = z
			director.zone = z
			director.zone_id = z.zone_id
	mapa.add_child(director)
	return director
