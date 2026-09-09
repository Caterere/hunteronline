class_name ZetsuSensorZone
extends Area2D

# ============================================================
# HUNTER ONLINE - ZETSU SENSOR ZONE (CORREDOR DE SENTINELAS)
# ============================================================
#
# Área patrulhada por feras predatórias ou sensores de aura.
# - Se o jogador cruzar sem ZETSU: o alarme é disparado e emboscadas surgem.
# - Se o jogador cruzar em ZETSU: passa despercebido com sucesso.
#
# ============================================================

signal alarme_disparado(posicao: Vector2)
signal travessia_furtiva_sucesso(player: Node2D)

@export var zone_id: StringName = &"sensor_patrulha"
@export var zone_name: String = "Território de Predadores Sensíveis a Aura"
@export var spawn_inimigos_ao_falhar: bool = true

var jogador_dentro: CharacterBody2D = null
var falhou_stealth: bool = false

func _enter_tree() -> void:
	collision_layer = 0
	collision_mask = 2 # Player (Layer 2)

func _ready() -> void:
	add_to_group("zetsu_sensor_zone")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body is CharacterBody2D:
		jogador_dentro = body as CharacterBody2D
		falhou_stealth = false
		_checar_presenca_aura()

func _on_body_exited(body: Node2D) -> void:
	if body == jogador_dentro:
		if not falhou_stealth and is_instance_valid(jogador_dentro):
			# Travessia concluída em sigilo!
			travessia_furtiva_sucesso.emit(jogador_dentro)
			var nen_sys = jogador_dentro.get_node_or_null("NenSystem") as NenSystem
			if nen_sys != null and nen_sys.has_method("adicionar_nen_xp"):
				nen_sys.adicionar_nen_xp(35)
			if EventBus != null:
				EventBus.emit_toast("🥷 Travessia Furtiva com Zetsu Concluída (+35 Nen XP)!", Color(0.4, 1.0, 0.4, 1.0))
			var quest_sys = Engine.get_main_loop().root.get_node_or_null("/root/QuestSystem") if Engine.get_main_loop() else null
			if quest_sys != null and quest_sys.has_method("register_stealth_pass"):
				quest_sys.register_stealth_pass(zone_id)
		jogador_dentro = null

func _process(_delta: float) -> void:
	if jogador_dentro != null and not falhou_stealth:
		_checar_presenca_aura()

func _checar_presenca_aura() -> void:
	var nen_sys = jogador_dentro.get_node_or_null("NenSystem") as NenSystem
	var em_zetsu: bool = (nen_sys != null and nen_sys.has_method("tecnica_ativa") and nen_sys.tecnica_ativa(NenSystem.Tecnica.ZETSU))
	
	if not em_zetsu and not falhou_stealth:
		falhou_stealth = true
		alarme_disparado.emit(global_position)
		_acionar_alerta_emboscada()

func _acionar_alerta_emboscada() -> void:
	var hud = get_tree().get_first_node_in_group("player_hud")
	if hud != null and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("⚠️ ALARME! Sua presença de aura atraiu os predadores!")

	if EventBus != null:
		EventBus.emit_toast("⚠️ Sensor de aura: emboscada!", Color(1.0, 0.35, 0.25, 1.0))
		EventBus.emit_camera_shake(0.25, 0.18)

	if AudioManager != null and AudioManager.has_method("tocar_sfx_tipo"):
		AudioManager.tocar_sfx_tipo("boss_intro", 0.7)

	if not spawn_inimigos_ao_falhar:
		return

	var enemy_scn = load("res://scripts/systems/EnemySystem/Enemy.tscn")
	if enemy_scn == null:
		return

	var offsets: Array[Vector2] = [Vector2(-48, -24), Vector2(48, -16), Vector2(0, 40)]
	for i in range(offsets.size()):
		var mob = enemy_scn.instantiate()
		mob.name = "Emboscada_%s_%d" % [String(zone_id), i]
		mob.position = global_position + offsets[i]
		var parent_map = get_parent()
		if parent_map != null:
			parent_map.add_child(mob)
		else:
			get_tree().current_scene.add_child(mob)
		var es = mob.get_node_or_null("EnemySystem")
		if es != null:
			es.enemy_id = &"slime"
			es.enemy_name = "Predador Alertado"
			if es.enemy_data != null:
				es.enemy_data = es.enemy_data.duplicate(true)
				es.enemy_data.role = "ambusher"
			if QuestSystem != null and not es.died.is_connected(QuestSystem.register_enemy_kill):
				es.died.connect(QuestSystem.register_enemy_kill)
