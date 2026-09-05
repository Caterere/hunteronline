class_name EnemySystem
extends Node


signal damaged(damage: int)
signal died(enemy_type: StringName)
signal health_changed(current_health: int, max_health: int)
signal postura_alterada(atual: float, maxima: float)
signal entrou_em_stagger()
signal saiu_de_stagger()
signal knockdown_iniciado()
signal knockdown_finalizado()

const ComicBalloon = preload("res://scripts/ui/ComicBalloon.gd")
const CombatComicQuotes = preload("res://resource/dialogue/CombatComicQuotes.gd")
const BattlePersonalityScript = preload("res://resource/personality/BattlePersonality.gd")


# =========================================================
# CONFIGURAÇÕES
# =========================================================

@export_category("Enemy Data")

@export var enemy_data: EnemyData


@export_category("Feedback")

@export var damage_number_scene: PackedScene


@export_category("Nen XP")

# XP de Nen entregue ao jogador ao derrotar este inimigo.
#
# IMPORTANTE:
#
# XP normal:
# enemy_data.xp_reward
#
# XP Nen:
# nen_xp_reward
#
# Os dois são sistemas separados.
#
@export var nen_xp_reward: int = 0


# =========================================================
# VÍNCULO DE MISSÃO & OBJETIVO (CONTROLE DE CICLO DE VIDA)
# =========================================================

@export_category("Mission Binding")

## Se true, este inimigo é governado pelo estado do QuestManager / Missão ativa.
@export var is_mission_enemy: bool = false

## Arco a que este inimigo pertence (0 = qualquer arco / não restrito).
@export var quest_arc: int = 0

## Etapa / Missão do arco a que pertence (0 = qualquer etapa).
@export var quest_etapa: int = 0

## Índice do objetivo dentro da quest (-1 = qualquer objetivo).
@export var quest_objective_index: int = -1

## ID específico de missão secundária / paralela.
@export var mission_id: StringName = &""

## Posição original de spawn para fins de reconciliação e respawn.
var spawn_position_origin: Vector2 = Vector2.ZERO
var spawner_ref: Node = null


# =========================================================
# ESTADO & POSTURA (STAGGER)
# =========================================================

var health: int = 0
var is_dead: bool = false
var is_invulnerable: bool = false

var postura: float = 100.0
var postura_max: float = 100.0
var em_stagger: bool = false
var stagger_timer: float = 0.0
var stagger_duracao: float = 2.5
var em_knockdown: bool = false
var knockdown_timer: float = 0.0

# Informações de Nen e Investigação de Gyo (HxH / CrossCode)
var categoria_nen_info: String = "Intensificação"
var concentracao_aura_info: String = "Equilibrada"
var fraqueza_info: String = "Vulnerável a ataques furtivos e quebra de postura"
var escudo_imune_ativo: bool = false

# Último personagem que acertou o inimigo.
var last_attacker: Node = null


# =========================================================
# DADOS CARREGADOS DO ENEMY DATA
# =========================================================

var max_health: int = 0
var defense: int = 0
var strength: int = 0
var xp_reward: int = 0

var enemy_id: StringName = &""
var enemy_name: String = ""

var knockback_resistance: float = 0.0
var hit_invulnerability_time: float = 0.15
var is_boss: bool = false
var npc_tier: int = 1
var battle_personality: Resource = null
var taunt_timer: float = 8.0
var _reagiu_hatsu_player: bool = false
var falou_spawn: bool = false
var falou_ferido: bool = false




# =========================================================
# REFERÊNCIAS
# =========================================================

var enemy_sprite: Sprite2D
var enemy_body: CharacterBody2D


# =========================================================
# KNOCKBACK
# =========================================================

var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0


# =========================================================
# INICIALIZAÇÃO DINÂMICA (CONTENT PIPELINE / MAP SPAWNERS)
# =========================================================

func setup_from_data(data: EnemyData) -> void:
	if data == null:
		return
	enemy_data = data
	enemy_id = data.enemy_id
	enemy_name = data.enemy_name

	if PlayerData != null:
		var mult: Dictionary = PlayerData.obter_multiplicador_dificuldade_inimigo()
		max_health = int(float(data.max_health) * mult.get("hp", 1.0))
		strength = int(float(data.strength) * mult.get("dano", 1.0))
		defense = int(float(data.defense) * mult.get("defesa", 1.0))
	else:
		max_health = data.max_health
		strength = data.strength
		defense = data.defense

	health = max_health
	xp_reward = data.xp_reward
	knockback_resistance = data.knockback_resistance
	hit_invulnerability_time = data.hit_invulnerability_time

	if "is_boss" in data and data.is_boss:
		is_boss = true
	if "npc_tier" in data:
		npc_tier = int(data.npc_tier)
	if "battle_personality" in data and data.battle_personality != null:
		battle_personality = data.battle_personality

	health_changed.emit(health, max_health)


func setup_from_boss_definition(boss_def: Resource) -> void:
	if boss_def == null:
		return
	is_boss = true
	npc_tier = 3 # Tier Boss
	enemy_id = boss_def.get("boss_id") if boss_def.get("boss_id") != null else &"boss"
	var b_name = boss_def.get("boss_name")
	enemy_name = str(b_name) if b_name != null else "Chefe Poderoso"

	var b_stats = boss_def.get("base_stats")
	var stats: Dictionary = (b_stats as Dictionary) if b_stats != null else {}
	var base_hp = int(stats.get("max_health", 25000))
	var base_dmg = int(stats.get("damage", 350))
	var base_def = int(stats.get("defense", 180))

	if PlayerData != null:
		var mult: Dictionary = PlayerData.obter_multiplicador_dificuldade_inimigo()
		max_health = int(float(base_hp) * mult.get("hp", 1.0))
		strength = int(float(base_dmg) * mult.get("dano", 1.0))
		defense = int(float(base_def) * mult.get("defesa", 1.0))
	else:
		max_health = base_hp
		strength = base_dmg
		defense = base_def

	health = max_health
	knockback_resistance = float(stats.get("knockback_resistance", 0.95))
	hit_invulnerability_time = float(stats.get("hit_invulnerability_time", 0.15))
	xp_reward = int(stats.get("xp_reward", 5000))

	# Conectar fases ao EnemyAI se existir
	var ai = get_node_or_null("../EnemyAI")
	if ai != null and boss_def.get("phases") is Array:
		var phases_arr: Array = boss_def.phases
		for p in phases_arr:
			if p != null:
				var p_idx = int(p.get("phase_index", 2))
				if p_idx == 2 and ai.has_method("_entrar_fase_2_boss"):
					pass # fases serão acionadas pelo fluxo de combate do EnemyAI

	health_changed.emit(health, max_health)
	print("[EnemySystem] 👑 Chefe instanciado via BossDefinition: '%s' (%s) | HP: %d | DEF: %d" % [
		enemy_id, enemy_name, max_health, defense
	])


# =========================================================
# INICIALIZAÇÃO
# =========================================================

func _ready() -> void:

	enemy_body = get_parent() as CharacterBody2D
	var p_name: String = enemy_body.name.to_lower() if enemy_body != null else ""

	# Auto-resolução inteligente de EnemyData com base no DataManager ou nome do nó
	if DataManager != null:
		if enemy_id != &"" and enemy_id != &"inimigo" and enemy_id != &"slime":
			var d_res = DataManager.get_enemy(enemy_id) as EnemyData
			if d_res != null:
				enemy_data = d_res
		if (enemy_data == null or enemy_data.enemy_id == &"slime") and not p_name.is_empty():
			var d_res2 = DataManager.get_enemy(p_name) as EnemyData
			if d_res2 != null:
				enemy_data = d_res2

	if enemy_data == null or enemy_data.enemy_id == &"slime":
		if "pantanal" in p_name:
			var res = load("res://resource/status/enemies/criatura_pantanal.tres")
			if res: enemy_data = res
		elif "maratona" in p_name or "candidato" in p_name:
			var res = load("res://resource/status/enemies/candidato_exame.tres")
			if res: enemy_data = res
		elif "mike" in p_name or "cao" in p_name or "zoldyck" in p_name or "mordomo" in p_name or "portao" in p_name:
			var res = load("res://resource/status/enemies/mordomo_zoldyck.tres")
			if res: enemy_data = res
		elif "lutador" in p_name or "arena" in p_name:
			var res = load("res://resource/status/enemies/lutador_arena.tres")
			if res: enemy_data = res
		elif "mafioso" in p_name or "yorknew" in p_name:
			var res = load("res://resource/status/enemies/mafioso_yorknew.tres")
			if res: enemy_data = res
		elif "monstro_greed" in p_name or "greed" in p_name:
			var res = load("res://resource/status/enemies/monstro_greed.tres")
			if res: enemy_data = res
		elif "bomber" in p_name or "genthru" in p_name:
			var res = load("res://resource/status/enemies/bomber_greed.tres")
			if res: enemy_data = res
		elif "guarda_real" in p_name or "pitou" in p_name or "youpi" in p_name or "pouf" in p_name:
			var res = load("res://resource/status/enemies/guarda_real.tres")
			if res: enemy_data = res
		elif "formiga" in p_name:
			var res = load("res://resource/status/enemies/formiga_soldado.tres")
			if res: enemy_data = res
		elif "hisoka" in p_name:
			var res = load("res://resource/status/enemies/boss_hisoka.tres")
			if res: enemy_data = res
		elif "razor" in p_name:
			var res = load("res://resource/status/enemies/boss_razor.tres")
			if res: enemy_data = res
		elif "meruem" in p_name or "rei" in p_name:
			var res = load("res://resource/status/enemies/boss_meruem.tres")
			if res: enemy_data = res
		elif "black_whale" in p_name:
			var res = load("res://resource/status/enemies/guarda_black_whale.tres")
			if res: enemy_data = res

	if enemy_data == null:
		var fallback_res = load("res://resource/status/InimigoBase.tres")
		if fallback_res != null:
			enemy_data = fallback_res
		elif ResourceLoader.exists("res://resource/status/enemies/candidato_exame.tres"):
			enemy_data = load("res://resource/status/enemies/candidato_exame.tres")

	if enemy_data == null:
		push_warning("EnemySystem: Usando configuração padrão em memória para inimigo genérico.")
		enemy_data = EnemyData.new()
		enemy_data.enemy_id = &"inimigo_generico"
		enemy_data.enemy_name = "Inimigo"
		enemy_data.max_health = 100
		enemy_data.strength = 10
		enemy_data.defense = 5
		enemy_data.xp_reward = 50


	# -----------------------------------------------------
	# CARREGAR DADOS DO ENEMY DATA
	# -----------------------------------------------------

	if enemy_id == &"" or enemy_id == &"inimigo":
		enemy_id = enemy_data.enemy_id
	if enemy_name.is_empty() or enemy_name == "Inimigo":
		enemy_name = enemy_data.enemy_name
	
	if PlayerData != null:
		var mult: Dictionary = PlayerData.obter_multiplicador_dificuldade_inimigo()
		max_health = int(float(enemy_data.max_health) * mult.get("hp", 1.0))
		strength = int(float(enemy_data.strength) * mult.get("dano", 1.0))
		defense = int(float(enemy_data.defense) * mult.get("defesa", 1.0))
	else:
		max_health = enemy_data.max_health
		defense = enemy_data.defense
		strength = enemy_data.strength

	xp_reward = enemy_data.xp_reward

	knockback_resistance = (
		enemy_data.knockback_resistance
	)

	hit_invulnerability_time = (
		enemy_data.hit_invulnerability_time
	)

	if enemy_data != null:
		npc_tier = int(enemy_data.npc_tier) if "npc_tier" in enemy_data else 1
		battle_personality = enemy_data.battle_personality if "battle_personality" in enemy_data else null

	# Auto-resolução de personalidade para Mini Boss (Tier 3), Boss (Tier 4) ou figuras icônicas
	if battle_personality == null and (is_boss or npc_tier >= 3 or enemy_name in ["Hisoka", "Razor", "Meruem"]):
		var lower_n := enemy_name.to_lower()
		if "hisoka" in lower_n:
			battle_personality = BattlePersonalityScript.criar_hisoka()
			npc_tier = 4
		elif "razor" in lower_n:
			battle_personality = BattlePersonalityScript.criar_razor()
			npc_tier = 4
		elif "meruem" in lower_n or "rei" in lower_n:
			battle_personality = BattlePersonalityScript.criar_meruem()
			npc_tier = 4
		elif is_boss or npc_tier == 4:
			battle_personality = BattlePersonalityScript.criar_padrao(enemy_name, "Orgulhoso")
			npc_tier = 4
		elif npc_tier == 3:
			battle_personality = BattlePersonalityScript.criar_padrao(enemy_name, "Desafiador")

	if EventBus != null and not EventBus.hatsu_dramatic_callout_requested.is_connected(_on_player_hatsu_callout):
		EventBus.hatsu_dramatic_callout_requested.connect(_on_player_hatsu_callout)

	# -----------------------------------------------------
	# REFERÊNCIA AO CORPO
	# -----------------------------------------------------

	enemy_body = get_parent() as CharacterBody2D

	if enemy_body == null:

		push_error(
			"EnemySystem precisa estar dentro de um CharacterBody2D."
		)

		return

	spawn_position_origin = enemy_body.global_position
	enemy_body.collision_layer = 4 # Layer 3 (Inimigo)
	enemy_body.collision_mask = 1  # Mask 1 (Paredes/Cenário apenas)
	enemy_body.add_to_group("enemies")
	enemy_body.add_to_group("enemy")
	add_to_group("enemy_systems")


	# -----------------------------------------------------
	# REFERÊNCIA AO SPRITE
	# -----------------------------------------------------

	enemy_sprite = enemy_body.get_node_or_null(
		"Sprite2D"
	)

	if enemy_sprite == null:

		push_warning(
			"EnemySystem: Sprite2D não encontrado."
		)


	# -----------------------------------------------------
	# INICIALIZAR HP
	# -----------------------------------------------------

	health = max_health


	# -----------------------------------------------------
	# ATUALIZAR HP BAR
	# -----------------------------------------------------

	health_changed.emit(
		health,
		max_health
	)


	# -----------------------------------------------------
	# DEBUG
	# -----------------------------------------------------

	print("=================================")
	print("[EnemySystem] ", enemy_name, " criado!")
	print("LEVEL: ", enemy_data.level)
	print("HP: ", health, "/", max_health)
	print("DEFESA: ", defense)
	print("FORÇA: ", strength)

	print(
		"XP NORMAL: ",
		xp_reward
	)

	print(
		"XP NEN: ",
		nen_xp_reward
	)

	print(
		"KNOCKBACK RESISTANCE: ",
		knockback_resistance
	)

	print(
		"INVULNERABILIDADE: ",
		hit_invulnerability_time
	)

	print("=================================")


	# CONECTAR AO QUESTSYSTEM
	# Quando este inimigo morrer, notificará o QuestSystem
	# -----

	if not died.is_connected(QuestSystem.register_enemy_kill):
		died.connect(QuestSystem.register_enemy_kill)


# =========================================================
# PROCESSAMENTO
# =========================================================

var invulnerability_timer: float = 0.0

func _physics_process(delta: float) -> void:

	if is_dead:
		return

	if invulnerability_timer > 0.0:
		invulnerability_timer -= delta
		if invulnerability_timer <= 0.0:
			is_invulnerable = false

	# Processamento de Stagger e Recuperação de Postura
	if em_stagger:
		stagger_timer -= delta
		if stagger_timer <= 0.0:
			em_stagger = false
			postura = postura_max
			postura_alterada.emit(postura, postura_max)
			saiu_de_stagger.emit()
			if enemy_sprite != null:
				enemy_sprite.modulate = Color.WHITE
	else:
		if postura < postura_max:
			postura = min(postura + delta * 12.0, postura_max)
			postura_alterada.emit(postura, postura_max)

	_process_knockback(delta)


# =========================================================
# ATIVAÇÃO / DESATIVAÇÃO DE INIMIGO DE MISSÃO
# =========================================================

func ativar_inimigo_missao(ativo: bool) -> void:
	if enemy_body == null:
		enemy_body = get_parent() as CharacterBody2D
	if enemy_body == null or not is_instance_valid(enemy_body):
		return

	enemy_body.visible = ativo
	enemy_body.set_physics_process(ativo)
	enemy_body.set_process(ativo)

	var col_shape = enemy_body.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if col_shape != null:
		col_shape.disabled = not ativo

	var hurtbox = enemy_body.get_node_or_null("HurtBox") as Area2D
	if hurtbox != null:
		hurtbox.monitoring = ativo
		hurtbox.monitorable = ativo
		var hb_shape = hurtbox.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if hb_shape != null:
			hb_shape.disabled = not ativo

	var ai = enemy_body.get_node_or_null("EnemyAI") as EnemyAI
	if ai != null:
		ai.set_physics_process(ativo)
		if not ativo:
			ai.current_state = EnemyAI.State.IDLE
			if is_instance_valid(enemy_body):
				enemy_body.velocity = Vector2.ZERO

	if ativo:
		if not enemy_body.is_in_group("enemies"):
			enemy_body.add_to_group("enemies")
		if not enemy_body.is_in_group("enemy"):
			enemy_body.add_to_group("enemy")
	else:
		enemy_body.remove_from_group("enemies")
		enemy_body.remove_from_group("enemy")


# =========================================================
# DADOS DE INSPEÇÃO DE GYO
# =========================================================

func obter_dados_inspecao_gyo() -> Dictionary:
	return {
		"nome": enemy_name,
		"categoria_nen": categoria_nen_info,
		"concentracao_aura": concentracao_aura_info,
		"fraqueza": fraqueza_info,
		"em_stagger": em_stagger,
		"postura": postura,
		"postura_max": postura_max,
		"escudo_ativo": escudo_imune_ativo
	}


# =========================================================
# RECEBER DANO
# =========================================================

func take_damage(
	damage: int,
	attack_direction: Vector2 = Vector2.ZERO,
	knockback_force: float = 0.0,
	attacker: Node = null
) -> void:

	# -----------------------------------------------------
	# VERIFICAÇÕES
	# -----------------------------------------------------

	if is_dead:
		return

	if is_invulnerable:
		if DamageNumberSystem != null and enemy_body != null:
			DamageNumberSystem.spawn_esquiva(enemy_body.global_position)
		return

	if damage <= 0:
		return

	# Proteção Camada 2: Inimigo de missão não pode receber dano se seu objetivo não estiver ativo
	if is_mission_enemy and QuestSystem != null and QuestSystem.has_method("is_enemy_valid_for_active_objective"):
		if not QuestSystem.is_enemy_valid_for_active_objective(enemy_id, self):
			return

	if escudo_imune_ativo:
		if DamageNumberSystem != null and enemy_body != null:
			DamageNumberSystem.spawn_bloqueio(enemy_body.global_position)
		if AudioManager != null:
			AudioManager.tocar_bloqueio()
		ComicBalloon.mostrar(enemy_body if enemy_body != null else self, "🛡️ ESCUDO DE HATSU IMPENETRÁVEL!", 1.5, -42.0)
		return

	# -----------------------------------------------------
	# REGISTRAR ATACANTE
	# -----------------------------------------------------

	if attacker != null:
		last_attacker = attacker
		if enemy_body != null:
			var ai = enemy_body.get_node_or_null("EnemyAI")
			if ai != null and ai.has_method("adicionar_ameaca"):
				ai.adicionar_ameaca(attacker, float(damage) * 1.5)

	# -----------------------------------------------------
	# REDUÇÃO DE POSTURA & STAGGER
	# -----------------------------------------------------

	var dano_postura: float = float(damage) * 0.9
	if not em_stagger:
		postura -= dano_postura
		if postura <= 0.0:
			postura = 0.0
			em_stagger = true
			stagger_timer = stagger_duracao
			entrou_em_stagger.emit()
			if EventBus != null:
				EventBus.enemy_staggered.emit(enemy_body if enemy_body != null else self)
			ComicBalloon.mostrar(enemy_body if enemy_body != null else self, "⚡ STAGGER! (VULNERÁVEL)", 2.2, -45.0)
			if enemy_sprite != null:
				enemy_sprite.modulate = Color(0.6, 0.9, 2.0, 1.0)
		postura_alterada.emit(postura, postura_max)

	# -----------------------------------------------------
	# CALCULAR DANO FINAL (Curva Defensiva Balanceada)
	# -----------------------------------------------------

	var def_factor: float = 100.0 / (100.0 + max(0.0, float(defense)))
	var final_damage: int = max(
		int(round(float(damage) * def_factor)),
		1
	)

	# Bônus de Dano Crítico se estiver em Stagger (+50%)
	if em_stagger:
		final_damage = int(round(float(final_damage) * 1.5))

	# -----------------------------------------------------
	# APLICAR DANO
	# -----------------------------------------------------

	health -= final_damage
	health = max(health, 0)

	# -----------------------------------------------------
	# FEEDBACK VISUAL
	# -----------------------------------------------------

	_hit_flash()



	# -----------------------------------------------------
	# SINAIS E NOTIFICAÇÃO DE BOSS
	# -----------------------------------------------------

	damaged.emit(
		final_damage
	)

	health_changed.emit(
		health,
		max_health
	)

	# Reação a dano pesado / crítico da BattlePersonality
	if attacker != null and attacker.is_in_group("player"):
		disparar_reacao_dano(final_damage >= 30)

	# Balão de fala ao ficar ferido (< 35% HP)
	if not falou_ferido and float(health) <= float(max_health) * 0.35 and health > 0:
		falou_ferido = true
		if battle_personality != null:
			var txt_hp = battle_personality.obter_reacao_hp_baixo()
			if not txt_hp.is_empty():
				falar_personalidade(txt_hp, 2.4)
		else:
			ComicBalloon.mostrar(enemy_body if enemy_body != null else self, CombatComicQuotes.obter_frase_inimigo_ferido(enemy_name), 2.0, -38.0)

	if is_boss or (enemy_data != null and enemy_data.is_boss):
		var hud = get_tree().get_first_node_in_group("player_hud")
		if hud != null and hud.has_method("notificar_boss_status"):
			hud.notificar_boss_status(enemy_name, health, max_health)



	# -----------------------------------------------------
	# DAMAGE NUMBER
	# -----------------------------------------------------

	_show_damage_number(
		final_damage
	)


	# -----------------------------------------------------
	# DEBUG
	# -----------------------------------------------------

	print(
		enemy_name,
		" recebeu ",
		final_damage,
		" de dano. HP: ",
		health,
		"/",
		max_health
	)


	# -----------------------------------------------------
	# KNOCKBACK
	# -----------------------------------------------------

	if (
		attack_direction != Vector2.ZERO
		and knockback_force > 0.0
	):

		_apply_knockback(
			attack_direction.normalized(),
			knockback_force
		)


	# -----------------------------------------------------
	# INVULNERABILIDADE APÓS HIT
	# -----------------------------------------------------

	_start_hit_invulnerability()


	# -----------------------------------------------------
	# MORTE
	# -----------------------------------------------------

	if health <= 0:

		die()


# =========================================================
# BATTLE PERSONALITY METHODS (FASE G)
# =========================================================

func falar_personalidade(texto: String, duracao: float = 2.2) -> void:
	if texto.strip_edges().is_empty():
		return
	var node = enemy_body if enemy_body != null else self
	var bg_col: Color = battle_personality.balloon_color_bg if battle_personality != null else Color(0.08, 0.08, 0.12, 0.95)
	var border_col: Color = battle_personality.balloon_color_border if battle_personality != null else Color(1.0, 0.85, 0.25, 1.0)
	ComicBalloon.mostrar(node, texto, duracao, -45.0, bg_col, border_col)


func disparar_intro() -> void:
	if battle_personality != null:
		var txt = battle_personality.obter_intro()
		falar_personalidade(txt, 2.8)


func disparar_taunt() -> void:
	if battle_personality != null and not is_dead:
		var txt = battle_personality.obter_taunt()
		falar_personalidade(txt, 2.2)


func disparar_fala_ataque(skill_nome: String = "") -> void:
	if battle_personality != null and not is_dead:
		var txt = battle_personality.obter_fala_ataque(skill_nome)
		falar_personalidade(txt, 1.8)


func disparar_reacao_dano(pesado: bool) -> void:
	if battle_personality != null and not is_dead and (pesado or randf() < 0.35):
		var txt = battle_personality.obter_reacao_dano_pesado()
		falar_personalidade(txt, 1.9)


func _on_player_hatsu_callout(user_node: Node, hatsu_nome: String, subtitle: String, _cor: Color) -> void:
	if is_dead or battle_personality == null or not battle_personality.reads_player_nen:
		return
	if enemy_body == null or user_node == null:
		return
	if enemy_body.global_position.distance_to((user_node as Node2D).global_position) <= 380.0:
		if not _reagiu_hatsu_player or randf() < 0.40:
			_reagiu_hatsu_player = true
			var txt = battle_personality.obter_reacao_player_hatsu(hatsu_nome, subtitle)
			falar_personalidade(txt, 2.5)


var original_modulate: Color = Color.WHITE

func receber_dano(
	damage: int,
	attack_direction: Vector2 = Vector2.ZERO,
	knockback_force: float = 0.0,
	attacker: Node = null
) -> void:
	take_damage(damage, attack_direction, knockback_force, attacker)


# =========================================================
# HIT FLASH
# =========================================================

func _hit_flash() -> void:
	if enemy_sprite == null or not is_instance_valid(enemy_sprite):
		return

	if original_modulate == Color.WHITE and enemy_sprite.modulate != Color(2.5, 2.5, 2.5, 1.0):
		original_modulate = enemy_sprite.modulate

	enemy_sprite.modulate = Color(2.5, 2.5, 2.5, 1.0)
	var tween = create_tween()
	if tween != null:
		tween.tween_property(enemy_sprite, "modulate", original_modulate, 0.08)


# =========================================================
# KNOCKBACK
# =========================================================

func _apply_knockback(
	direction: Vector2,
	force: float
) -> void:

	if enemy_body == null:
		return

	var resistance: float = clamp(
		knockback_resistance,
		0.0,
		1.0
	)

	var final_force: float = force * (
		1.0 - resistance
	)

	knockback_velocity = (
		direction * final_force
	)

	knockback_timer = 0.16

	# Knockdown por impactos severos (force >= 190 em não-chefes)
	if final_force >= 190.0 and not is_boss:
		em_knockdown = true
		knockdown_timer = 0.45
		knockdown_iniciado.emit()
		if EventBus != null:
			EventBus.combat_knockdown_triggered.emit(enemy_body, 0.45)
		if enemy_sprite != null:
			enemy_sprite.rotation_degrees = -20.0 if direction.x > 0 else 20.0


# =========================================================
# PROCESSAR KNOCKBACK
# =========================================================

func _process_knockback(
	delta: float
) -> void:

	if enemy_body == null:
		return

	if knockback_timer > 0.0:
		knockback_timer -= delta
		enemy_body.velocity = knockback_velocity
		enemy_body.move_and_slide()
		knockback_velocity = knockback_velocity.lerp(
			Vector2.ZERO,
			10.0 * delta
		)
	else:
		knockback_velocity = Vector2.ZERO

	if em_knockdown:
		knockdown_timer -= delta
		if knockdown_timer <= 0.0:
			em_knockdown = false
			knockdown_finalizado.emit()
			if enemy_sprite != null:
				enemy_sprite.rotation_degrees = 0.0


# =========================================================
# INVULNERABILIDADE APÓS HIT
# =========================================================

func _start_hit_invulnerability() -> void:
	is_invulnerable = true
	invulnerability_timer = max(0.08, hit_invulnerability_time)


# =========================================================
# FINALIZAR INVULNERABILIDADE
# =========================================================

func _end_hit_invulnerability() -> void:
	is_invulnerable = false


# =========================================================
# MORTE
# =========================================================

func die() -> void:

	if is_dead:
		return


	is_dead = true
	health = 0

	if battle_personality != null:
		var txt_derrota = battle_personality.obter_derrota()
		if not txt_derrota.is_empty():
			falar_personalidade(txt_derrota, 2.5)

	if enemy_body != null and is_instance_valid(enemy_body):
		enemy_body.remove_from_group("enemies")
		enemy_body.remove_from_group("enemy")


	# -----------------------------------------------------
	# ATUALIZAR HP BAR
	# -----------------------------------------------------

	health_changed.emit(
		health,
		max_health
	)


	# -----------------------------------------------------
	# DEBUG
	# -----------------------------------------------------

	print(
		enemy_name,
		" morreu!"
	)


	# -----------------------------------------------------
	# ENTREGAR XP E GERAR DROPS DE LOOT
	# -----------------------------------------------------

	_entregar_xp()
	_gerar_drop_loot()



	# -----------------------------------------------------
	# SINAL DE MORTE
	# Passa o enemy_id para QuestSystem registrar a morte
	# -----------------------------------------------------

	died.emit(enemy_id)
	PlayerData.registrar_estatistica("inimigos_derrotados", 1)



	# -----------------------------------------------------
	# REMOVER INIMIGO
	# -----------------------------------------------------

	await get_tree().create_timer(
		0.15
	).timeout


	if spawner_ref != null and spawner_ref.has_method("on_spawned_died"):
		spawner_ref.on_spawned_died(enemy_body)

	if enemy_body != null:
		enemy_body.queue_free()


# =========================================================
# ENTREGAR XP
# =========================================================
#
# Ao matar um inimigo:
#
# XP NORMAL
# ↓
# XPSystem
#
# XP NEN
# ↓
# NenSystem
#
# São sistemas completamente separados.
#
# =========================================================

func _entregar_xp() -> void:

	if last_attacker == null:

		print(
			"Nenhum atacante registrado."
		)

		print(
			"XP não entregue."
		)

		return


	# =====================================================
	# XP NORMAL
	# =====================================================

	var xp_system = last_attacker.get_node_or_null(
		"XPSystem"
	)


	if xp_system != null:

		xp_system.adicionar_xp(
			xp_reward,
			"Inimigo: " + enemy_name
		)

		print(
			"XP NORMAL ENTREGUE: +",
			xp_reward,
			" para ",
			last_attacker.name
		)

	else:

		print(
			"XPSystem não encontrado no atacante: ",
			last_attacker.name
		)


	# =====================================================
	# XP NEN
	# =====================================================
	#
	# O NenSystem deve estar no Player.
	#
	# Procuramos diretamente no atacante.
	#
	# =====================================================

	var nen_system = last_attacker.get_node_or_null(
		"NenSystem"
	)

	if nen_xp_reward > 0:
		if nen_system != null and PlayerData != null and PlayerData.despertou_nen:
			nen_system.adicionar_xp_nen(
				nen_xp_reward
			)
			print(
				"NEN XP ENTREGUE: +",
				nen_xp_reward,
				" para ",
				last_attacker.name
			)
		elif nen_system == null:
			print(
				"NenSystem não encontrado no atacante: ",
				last_attacker.name
			)


	# =====================================================
	# RESUMO
	# =====================================================

	print("=================================")
	print("RECOMPENSAS DO INIMIGO")
	print("INIMIGO: ", enemy_name)
	print("JOGADOR: ", last_attacker.name)
	print("XP NORMAL: +", xp_reward)
	print("XP NEN: +", nen_xp_reward)
	print("=================================")


func _gerar_drop_loot() -> void:
	if enemy_data != null and enemy_data.is_boss:
		var hud = get_tree().get_first_node_in_group("player_hud")
		if hud != null and hud.has_method("esconder_boss_bar"):
			hud.esconder_boss_bar()

	var qtd_gold: int = randi_range(25, 80) * max(1, enemy_data.level if enemy_data != null else 1)
	if Economy != null:
		Economy.adicionar_gold(qtd_gold)

	# Processar Tabela de Drops (GDD Vol 8)
	if enemy_data != null and not enemy_data.drop_table.is_empty():
		for drop_info in enemy_data.drop_table:
			var chance: float = float(drop_info.get("chance", 0.5))
			if randf() <= chance:
				var item_id = drop_info.get("item_id", "")
				var qtd: int = int(drop_info.get("quantidade", 1))
				if not item_id.is_empty() and PlayerData != null:
					PlayerData.adicionar_item(StringName(item_id), qtd)
					print("[EnemySystem] LOOT COLETADO: %s x%d" % [item_id, qtd])




# =========================================================
# CURA
# =========================================================

func heal(amount: int) -> void:

	if is_dead:
		return


	if amount <= 0:
		return


	health += amount


	health = min(
		health,
		max_health
	)


	health_changed.emit(
		health,
		max_health
	)


# =========================================================
# DAMAGE NUMBER
# =========================================================

func _show_damage_number(
	damage: int,
	tipo: String = "fisico",
	is_crit: bool = false
) -> void:

	if enemy_body == null or not is_instance_valid(enemy_body):
		return

	var scn = damage_number_scene
	if scn == null and ResourceLoader.exists("res://scripts/ui/Damage/DamageNumber.tscn"):
		scn = load("res://scripts/ui/Damage/DamageNumber.tscn")

	if scn == null:
		return

	var damage_number = scn.instantiate()
	if enemy_body.get_parent() != null:
		enemy_body.get_parent().add_child(damage_number)
		damage_number.global_position = enemy_body.global_position + Vector2(0, -28)
		if damage_number.has_method("mostrar_dano"):
			damage_number.mostrar_dano(damage, tipo, is_crit)


# =========================================================
# UTILITÁRIOS
# =========================================================

func is_alive() -> bool:

	return not is_dead


func get_health_percent() -> float:

	if max_health <= 0:
		return 0.0


	return (
		float(health)
		/
		float(max_health)
	)


func get_health() -> int:

	return health


func get_max_health() -> int:

	return max_health


func get_defense() -> int:

	return defense


func get_strength() -> int:

	return strength


func get_xp_reward() -> int:

	return xp_reward


func get_nen_xp_reward() -> int:

	return nen_xp_reward


func get_level() -> int:

	if enemy_data == null:

		return 1


	return enemy_data.level


func obter_hatsu_real() -> HatsuData:
	if enemy_data != null:
		return enemy_data.obter_hatsu_real()
	return null
