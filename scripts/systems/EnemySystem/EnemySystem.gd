class_name EnemySystem
extends Node


signal damaged(damage: int)
signal died(enemy_type: StringName)
signal health_changed(current_health: int, max_health: int)
signal postura_alterada(atual: float, maxima: float)
signal entrou_em_stagger()
signal saiu_de_stagger()

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
		return

	if damage <= 0:
		return

	if escudo_imune_ativo:
		ComicBalloon.mostrar(enemy_body if enemy_body != null else self, "🛡️ ESCUDO DE HATSU IMPENETRÁVEL!", 1.5, -42.0)
		return

	# -----------------------------------------------------
	# REGISTRAR ATACANTE
	# -----------------------------------------------------

	if attacker != null:
		last_attacker = attacker

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
	damage: int
) -> void:

	if damage_number_scene == null:
		return


	if enemy_body == null:
		return


	var damage_number = (
		damage_number_scene.instantiate()
	)


	enemy_body.get_parent().add_child(
		damage_number
	)


	damage_number.global_position = (
		enemy_body.global_position
		+ Vector2(0, -30)
	)


	damage_number.mostrar_dano(
		damage
	)


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
