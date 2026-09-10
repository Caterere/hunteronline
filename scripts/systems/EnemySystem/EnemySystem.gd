class_name EnemySystem
extends Node


signal damaged(damage: int)
signal died(enemy_type: StringName)
signal health_changed(current_health: int, max_health: int)
signal postura_alterada(atual: float, maxima: float)
signal entrou_em_stagger()
signal saiu_de_stagger()
signal defesa_alterada(atual: float, maxima: float)
signal defesa_quebrada()
signal defesa_restaurada()

const ComicBalloon = preload("res://scripts/ui/ComicBalloon.gd")
const CombatComicQuotes = preload("res://resource/dialogue/CombatComicQuotes.gd")


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
# ESTADO & BARRA DE DEFESA (DEFENSE GAUGE / GUARD BREAK)
# =========================================================

var health: int = 0
var is_dead: bool = false
var is_invulnerable: bool = false

var defesa_barra_max: float = 100.0
var defesa_barra_atual: float = 100.0
var em_defesa_quebrada: bool = false
var tempo_defesa_quebrada: float = 3.5
var tempo_timer_quebrada: float = 0.0
var tempo_sem_receber_dano: float = 0.0
var taxa_regeneracao_defesa: float = 25.0

# Compatibilidade com sistemas legados de postura/stagger
var postura: float = 100.0
var postura_max: float = 100.0
var em_stagger: bool = false
## Alias legado — EnemyAI e VFX antigos consultam em_knockdown
var em_knockdown: bool = false

func esta_em_stagger_ou_knockdown() -> bool:
	return em_stagger or em_knockdown

var stagger_timer: float = 0.0
var stagger_duracao: float = 3.5

# Informações de Nen e Investigação de Gyo (HxH / CrossCode)
var categoria_nen_info: String = "Intensificação"
var concentracao_aura_info: String = "Equilibrada"
var fraqueza_info: String = "Vulnerável a sequências de ataques e quebra de defesa"
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
var falou_spawn: bool = false
var falou_ferido: bool = false
## Temperamento de combate (espelha EnemyData.battle_personality)
var battle_personality: Resource = null




# =========================================================
# REFERÊNCIAS
# =========================================================

var enemy_sprite: Sprite2D
var enemy_body: CharacterBody2D
var tex_idle_8dir: Texture2D = null
var tex_walk_8x8: Texture2D = null


# =========================================================
# KNOCKBACK
# =========================================================

var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0


# =========================================================
# INICIALIZAÇÃO
# =========================================================

func _ready() -> void:

	enemy_body = get_parent() as CharacterBody2D
	var p_name: String = enemy_body.name.to_lower() if enemy_body != null else ""

	# Auto-resolução inteligente de EnemyData com base no nome do nó caso esteja com InimigoBase padrão
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
	is_boss = enemy_data.is_boss
	battle_personality = enemy_data.battle_personality

	knockback_resistance = (
		enemy_data.knockback_resistance
	)

	hit_invulnerability_time = (
		enemy_data.hit_invulnerability_time
	)


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
	else:
		_vincular_textura_inimigo()


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

	# Processamento da Barra de Defesa & Estado Quebrado
	if em_defesa_quebrada:
		tempo_timer_quebrada -= delta
		stagger_timer = tempo_timer_quebrada
		if tempo_timer_quebrada <= 0.0:
			em_defesa_quebrada = false
			em_stagger = false
			em_knockdown = false
			defesa_barra_atual = defesa_barra_max
			postura = postura_max
			defesa_alterada.emit(defesa_barra_atual, defesa_barra_max)
			postura_alterada.emit(postura, postura_max)
			defesa_restaurada.emit()
			saiu_de_stagger.emit()
			if enemy_sprite != null:
				enemy_sprite.modulate = Color.WHITE
			ComicBalloon.mostrar(enemy_body if enemy_body != null else self, "🛡️ DEFESA RESTAURADA!", 1.5, -42.0)
	else:
		tempo_sem_receber_dano += delta
		# Se ficar 2.5s sem tomar golpes, a barra de defesa regenera gradualmente
		if tempo_sem_receber_dano >= 2.5 and defesa_barra_atual < defesa_barra_max:
			defesa_barra_atual = min(defesa_barra_atual + delta * taxa_regeneracao_defesa, defesa_barra_max)
			postura = (defesa_barra_atual / defesa_barra_max) * postura_max
			defesa_alterada.emit(defesa_barra_atual, defesa_barra_max)
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
# FALAS DE COMBATE (BattlePersonality + fallbacks)
# =========================================================

func disparar_intro() -> void:
	var linha := ""
	if battle_personality != null and battle_personality.has_method("obter_intro"):
		linha = str(battle_personality.obter_intro())
	if linha.is_empty():
		linha = CombatComicQuotes.obter_frase_inimigo_spawn(enemy_name)
	_mostrar_fala_combate(linha, 2.2)


func disparar_taunt() -> void:
	var linha := ""
	if battle_personality != null and battle_personality.has_method("obter_taunt"):
		linha = str(battle_personality.obter_taunt())
	if linha.is_empty():
		return
	_mostrar_fala_combate(linha, 1.8)


func disparar_fala_ataque(skill_name: String = "") -> void:
	var linha := ""
	if battle_personality != null and battle_personality.has_method("obter_fala_ataque"):
		linha = str(battle_personality.obter_fala_ataque(skill_name))
	if linha.is_empty() and not skill_name.is_empty():
		if battle_personality != null and battle_personality.has_method("obter_fala_hatsu"):
			linha = str(battle_personality.obter_fala_hatsu())
		if linha.is_empty():
			linha = skill_name
	if linha.is_empty():
		linha = CombatComicQuotes.obter_frase_inimigo_ataque(enemy_name)
	_mostrar_fala_combate(linha, 1.6)


func _mostrar_fala_combate(linha: String, duracao: float = 2.0) -> void:
	if linha.is_empty():
		return
	var ancora: Node = enemy_body if enemy_body != null else self
	ComicBalloon.mostrar(ancora, linha, duracao, -38.0)


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
# BARRA DE DEFESA & QUEBRA DE GUARDA
# =========================================================

func aplicar_dano_defesa(quantidade: float, is_heavy: bool = false) -> void:
	if is_dead or em_defesa_quebrada:
		return

	tempo_sem_receber_dano = 0.0
	defesa_barra_atual = max(0.0, defesa_barra_atual - quantidade)
	postura = (defesa_barra_atual / max(1.0, defesa_barra_max)) * postura_max
	defesa_alterada.emit(defesa_barra_atual, defesa_barra_max)
	postura_alterada.emit(postura, postura_max)

	if defesa_barra_atual <= 0.0:
		em_defesa_quebrada = true
		em_stagger = true
		em_knockdown = true
		tempo_timer_quebrada = tempo_defesa_quebrada
		stagger_timer = tempo_defesa_quebrada
		defesa_quebrada.emit()
		entrou_em_stagger.emit()
		if EventBus != null:
			EventBus.enemy_staggered.emit(enemy_body if enemy_body != null else self)
			EventBus.emit_hitstop(0.12 if is_heavy else 0.08)
			EventBus.emit_camera_shake(0.55 if is_heavy else 0.35, 0.25)
		ComicBalloon.mostrar(enemy_body if enemy_body != null else self, "💥 DEFESA QUEBRADA! (VULNERÁVEL)", 2.4, -46.0)
		if enemy_sprite != null:
			enemy_sprite.modulate = Color(0.6, 1.2, 2.5, 1.0)


func aplicar_dano_postura(quantidade: float) -> void:
	aplicar_dano_defesa(quantidade, false)


# =========================================================
# RECEBER DANO
# =========================================================

func take_damage(
	damage: int,
	attack_direction: Vector2 = Vector2.ZERO,
	knockback_force: float = 0.0,
	attacker: Node = null,
	pressionar_guarda: bool = true
) -> void:

	# -----------------------------------------------------
	# VERIFICAÇÕES
	# -----------------------------------------------------

	if is_dead:
		return

	if is_invulnerable:
		return

	if damage <= 0:
		return

	# Proteção Camada 2: Inimigo de missão não pode receber dano se seu objetivo não estiver ativo
	if is_mission_enemy and QuestSystem != null and QuestSystem.has_method("is_enemy_valid_for_active_objective"):
		if not QuestSystem.is_enemy_valid_for_active_objective(enemy_id, self):
			return

	if escudo_imune_ativo:
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
	# REDUÇÃO DE DEFESA / GUARDA
	# -----------------------------------------------------

	tempo_sem_receber_dano = 0.0
	# Hits diretos (sem CombatSystem) também pressionam a guarda.
	# CombatSystem passa pressionar_guarda=false porque já chama aplicar_dano_defesa.
	if pressionar_guarda and not em_defesa_quebrada:
		var pressao: float = clampf(float(damage) * 0.85, 15.0, defesa_barra_max * 0.55)
		aplicar_dano_defesa(pressao, damage >= 45)

	# -----------------------------------------------------
	# CALCULAR DANO FINAL (Curva Defensiva Balanceada)
	# -----------------------------------------------------

	var def_factor: float = 100.0 / (100.0 + max(0.0, float(defense)))
	var final_damage: int = max(
		int(round(float(damage) * def_factor)),
		1
	)

	# Bônus de Dano Crítico se a Defesa estiver Quebrada (+80%)
	if em_defesa_quebrada or em_stagger:
		final_damage = int(round(float(final_damage) * 1.80))

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

	# Balão de fala estilo mangá ao ficar ferido (< 35% HP)
	if not falou_ferido and float(health) <= float(max_health) * 0.35 and health > 0:
		falou_ferido = true
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

	if enemy_sprite == null:
		return

	if original_modulate == Color.WHITE and enemy_sprite.modulate != Color(3.0, 3.0, 3.0, 1.0):
		original_modulate = enemy_sprite.modulate

	enemy_sprite.modulate = Color(
		3.0,
		3.0,
		3.0,
		1.0
	)


	await get_tree().create_timer(
		0.20
	).timeout


	if is_instance_valid(enemy_sprite):

		enemy_sprite.modulate = original_modulate


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

	knockback_timer = 0.12


# =========================================================
# PROCESSAR KNOCKBACK
# =========================================================

func _process_knockback(
	delta: float
) -> void:

	if enemy_body == null:
		return

	if knockback_timer <= 0.0:
		knockback_velocity = Vector2.ZERO
		return

	knockback_timer -= delta
	knockback_velocity = knockback_velocity.lerp(
		Vector2.ZERO,
		12.0 * delta
	)


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

	if nen_system != null and PlayerData != null and PlayerData.despertou_nen and nen_xp_reward > 0:
		nen_system.adicionar_xp_nen(
			nen_xp_reward
		)

		print(
			"NEN XP ENTREGUE: +",
			nen_xp_reward,
			" para ",
			last_attacker.name
		)

	else:

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

	var enemy_lv: int = max(1, enemy_data.level if enemy_data != null else 1)
	var qtd_gold: int = 0
	if Economy != null:
		qtd_gold = Economy.calcular_drop_jenny_inimigo(enemy_lv)
		Economy.adicionar_gold(qtd_gold)
	else:
		qtd_gold = maxi(5, int(round(float(randi_range(12, 36) * enemy_lv) * 0.45)))


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


func _vincular_textura_inimigo() -> void:
	if enemy_sprite == null:
		return

	var e_id: String = String(enemy_id).to_lower()
	var e_name: String = enemy_name.to_lower()
	var b_name: String = enemy_body.name.to_lower() if enemy_body != null else ""
	var alvo_id: String = ""

	const MAPA_INIMIGOS = {
		"meruem": "enemy_boss_meruem",
		"rei_formiga": "enemy_boss_meruem",
		"razor": "enemy_boss_razor",
		"laser": "enemy_boss_razor",
		"pitou": "enemy_guarda_real",
		"guarda_real": "enemy_guarda_real",
		"youpi": "enemy_guarda_real",
		"pouf": "enemy_guarda_real",
		"formiga_lider": "enemy_formiga_lider",
		"lider": "enemy_formiga_lider",
		"formiga": "enemy_formiga_soldado",
		"soldado": "enemy_formiga_soldado",
		"bomber": "enemy_bomber_greed",
		"genthru": "enemy_bomber_greed",
		"greed": "enemy_bomber_greed",
		"monstro_greed": "enemy_bomber_greed",
		"mafioso": "enemy_mafioso_yorknew",
		"yorknew": "enemy_mafioso_yorknew",
		"mafia": "enemy_mafioso_yorknew",
		"lutador": "enemy_lutador_arena",
		"arena": "enemy_lutador_arena",
		"torre": "enemy_lutador_arena",
		"mordomo": "enemy_mordomo_zoldyck",
		"zoldyck": "enemy_mordomo_zoldyck",
		"canario": "enemy_mordomo_zoldyck",
		"gotoh": "enemy_mordomo_zoldyck",
		"mike": "enemy_mordomo_zoldyck",
		"pantanal": "enemy_criatura_pantanal",
		"criatura": "enemy_criatura_pantanal",
		"candidato": "enemy_candidato_exame",
		"exame": "enemy_candidato_exame",
		"maratona": "enemy_candidato_exame",
		"ladrao": "enemy_mafioso_yorknew",
		"ladrao_estrada": "enemy_mafioso_yorknew",
		"salteador": "enemy_mafioso_yorknew",
		"bandido": "enemy_mafioso_yorknew",
		"lobo": "enemy_lobo_sombras",
		"lobo_sombras": "enemy_lobo_sombras",
		"fera_sombra": "enemy_lobo_sombras",
		"fera_alada": "enemy_fera_alada",
		"alada": "enemy_fera_alada",
		"emboscadora": "enemy_fera_alada",
		"ambusher": "enemy_fera_alada",
		"sentinela": "enemy_sentinela_pedra",
		"sentinela_pedra": "enemy_sentinela_pedra",
		"pedra": "enemy_sentinela_pedra"
	}

	for k in MAPA_INIMIGOS.keys():
		if k in e_id or k in e_name or k in b_name:
			alvo_id = MAPA_INIMIGOS[k]
			break

	# Fallback para candidato_exame se for inimigo padrão
	if alvo_id.is_empty():
		alvo_id = "enemy_candidato_exame"

	var tex_path = "res://assets/sprites/characters/" + alvo_id + "_8dir.png"
	var walk_path = "res://assets/sprites/characters/" + alvo_id + "_walk_8x8.png"
	tex_walk_8x8 = null
	tex_idle_8dir = null

	# Já tem folha 8dir custom (não player) — só alinha e tenta walk
	if enemy_sprite.hframes == 8 and enemy_sprite.vframes == 1 \
			and enemy_sprite.texture != null \
			and not enemy_sprite.texture.resource_path.ends_with("player.png"):
		tex_idle_8dir = enemy_sprite.texture
		var rp: String = enemy_sprite.texture.resource_path
		if rp.ends_with("_8dir.png"):
			var base_id: String = rp.get_file().replace("_8dir.png", "")
			walk_path = "res://assets/sprites/characters/" + base_id + "_walk_8x8.png"
		if ResourceLoader.exists(walk_path):
			tex_walk_8x8 = load(walk_path)
		enemy_sprite.position = Vector2(0, -17)
		_ajustar_arvore_animacao_para_8dir()
		return

	if ResourceLoader.exists(tex_path):
		var tex = load(tex_path)
		tex_idle_8dir = tex
		enemy_sprite.texture = tex
		enemy_sprite.hframes = 8
		enemy_sprite.vframes = 1
		enemy_sprite.position = Vector2(0, -17)
		if ResourceLoader.exists(walk_path):
			tex_walk_8x8 = load(walk_path)
		_ajustar_arvore_animacao_para_8dir()


func aplicar_folha_movimento(andando: bool) -> void:
	if enemy_sprite == null:
		return
	if andando and tex_walk_8x8 != null:
		if enemy_sprite.texture != tex_walk_8x8:
			enemy_sprite.texture = tex_walk_8x8
			enemy_sprite.hframes = 8
			enemy_sprite.vframes = 8
		return
	if tex_idle_8dir != null and enemy_sprite.texture != tex_idle_8dir:
		enemy_sprite.texture = tex_idle_8dir
		enemy_sprite.hframes = 8
		enemy_sprite.vframes = 1


func _ajustar_arvore_animacao_para_8dir() -> void:
	if enemy_body == null:
		return
	var anim_tree = enemy_body.get_node_or_null("AnimationTree") as AnimationTree
	if anim_tree != null:
		anim_tree.active = false
