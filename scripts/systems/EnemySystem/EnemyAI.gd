class_name EnemyAI
extends Node

const ComicBalloon = preload("res://scripts/ui/ComicBalloon.gd")
const CombatComicQuotes = preload("res://resource/dialogue/CombatComicQuotes.gd")

# =========================================================
# CONFIGURAÇÕES
# =========================================================

@export_category("AI")

@export var detection_range: float = 260.0
@export var attack_range: float = 48.0
@export var move_speed: float = 88.0
@export var stop_distance: float = 32.0

var attack_cooldown: float = 1.25
var attack_timer: float = 0.0


# =========================================================
# COMPORTAMENTO
# =========================================================

@export_category("Behavior")

@export var chase_player: bool = true
@export var return_to_position: bool = true
@export var return_speed: float = 35.0


# =========================================================
# REFERÊNCIAS
# =========================================================

var enemy_body: CharacterBody2D = null
var player: Node2D = null

var _state_machine


# =========================================================
# POSIÇÃO INICIAL
# =========================================================

var initial_position: Vector2


# =========================================================
# ESTADOS
# =========================================================

enum State {
	IDLE,
	CHASE,
	PREPARE_ATTACK,
	ATTACK,
	RECOVERY,
	RETURN,
	STAGGER
}

var current_state = State.IDLE

# Windup & Recovery (Fase 2: Enemy Windup & Telegraph)
var windup_timer: float = 0.0
var recovery_timer: float = 0.0
var _telegraph_indicator: Node = null




# =========================================================
# INICIALIZAÇÃO
# =========================================================

func _ready() -> void:

	enemy_body = get_parent() as CharacterBody2D

	if enemy_body == null:
		push_error(
			"EnemyAI precisa estar dentro de um CharacterBody2D."
		)
		return

	# Garantir isolamento de colisão física para nunca empurrar o jogador
	enemy_body.set_collision_layer_value(1, false)
	enemy_body.set_collision_layer_value(2, false)
	enemy_body.set_collision_layer_value(3, true)
	enemy_body.set_collision_layer_value(4, false)
	enemy_body.set_collision_mask_value(1, true)
	enemy_body.set_collision_mask_value(2, false)
	enemy_body.set_collision_mask_value(3, false)
	enemy_body.set_collision_mask_value(4, false)

	initial_position = enemy_body.global_position
	enemy_system = enemy_body.get_node_or_null("EnemySystem") as EnemySystem

	# Procura a AnimationTree do Enemy.
	var animation_tree: AnimationTree = enemy_body.get_node_or_null("AnimationTree")


	if animation_tree != null:
		animation_tree.active = true
		_state_machine = animation_tree["parameters/playback"]
	else:
		push_warning(
			"Enemy não possui AnimationTree."
		)

	_find_player()


var is_fase_2: bool = false
var enemy_system: EnemySystem = null
var hatsu_timer: float = 2.0
var hatsu_cooldown: float = 4.5
var nobunaga_en_ativo: bool = false
var phinks_windup_count: int = 0

# =========================================================
# PROCESSAMENTO
# =========================================================

func _physics_process(delta: float) -> void:

	if attack_timer > 0.0:
		attack_timer -= delta

	if hatsu_timer > 0.0:
		hatsu_timer -= delta

	if enemy_body == null:
		return

	if not is_instance_valid(enemy_body):
		return

	if enemy_system == null:
		enemy_system = enemy_body.get_node_or_null("EnemySystem") as EnemySystem

	# Checar transição de Fase para Chefes (GDD Vol 5 & 7)
	if enemy_system != null and (enemy_system.is_boss or (enemy_system.enemy_data != null and enemy_system.enemy_data.is_boss)):
		if not is_fase_2 and enemy_system.health <= enemy_system.max_health * 0.5 and enemy_system.health > 0:
			_entrar_fase_2_boss()

	if player == null or not is_instance_valid(player):
		_find_player()

	# Disparar Hatsu Canônico do Inimigo se o jogador estiver ao alcance
	if player != null and is_instance_valid(player) and hatsu_timer <= 0.0:
		var dist_player: float = enemy_body.global_position.distance_to(player.global_position)
		if dist_player <= detection_range:
			executar_hatsu_inimigo()
			var cd_base: float = enemy_system.enemy_data.hatsu_cooldown if (enemy_system != null and enemy_system.enemy_data != null and enemy_system.enemy_data.hatsu_cooldown > 0.0) else hatsu_cooldown
			hatsu_timer = cd_base * (0.60 if is_fase_2 else 1.0)

	_update_state()
	_execute_state()
	_update_animation()
	_processar_habilidades_boss_fase_2(delta)



var earthquake_timer: float = 6.0


func _entrar_fase_2_boss() -> void:
	is_fase_2 = true
	move_speed *= 1.35
	attack_cooldown = 0.65
	hatsu_cooldown *= 0.65
	var boss_nome = enemy_system.enemy_name if enemy_system != null else "Guardião Ancestral"
	print("=================================")
	print("[BOSS FASE 2] %s liberou todo o seu REN! (Frenesi Ativado)" % boss_nome)
	print("=================================")
	
	var sprite = enemy_body.get_node_or_null("Sprite2D")
	if sprite != null:
		sprite.modulate = Color(1.8, 0.3, 0.3, 1.0) # Aura vermelha ardente de Ren

	if EventBus != null:
		EventBus.boss_phase_changed.emit(boss_nome, 2)
		EventBus.emit_camera_shake(0.65, 0.40)
		EventBus.emit_hitstop(0.08)

	if enemy_system != null:
		ComicBalloon.mostrar(enemy_body, "⚡ FRENESI ANCESTRAL! REN MÁXIMO!", 2.5, -45.0)

	_invocar_minions_boss()


func _invocar_minions_boss() -> void:
	var parent_map = enemy_body.get_parent()
	if parent_map == null or not is_instance_valid(parent_map):
		return

	var enemy_scn = load("res://scripts/systems/EnemySystem/Enemy.tscn")
	if enemy_scn == null:
		return

	var offsets = [Vector2(-50, 40), Vector2(50, 40)]
	for i in range(offsets.size()):
		var minion = enemy_scn.instantiate()
		minion.name = "Sentinela_Suporte_%d" % (i + 1)
		minion.position = enemy_body.position + offsets[i]
		parent_map.add_child(minion)
		var es = minion.get_node_or_null("EnemySystem")
		if es:
			es.enemy_name = "Sentinela de Suporte"
			es.max_health = 120
			es.health = 120
			es.defense = 4
			es.strength = 10


func _processar_habilidades_boss_fase_2(delta: float) -> void:
	if not is_fase_2 or enemy_body == null or player == null or not is_instance_valid(player):
		return
		
	earthquake_timer -= delta
	if earthquake_timer <= 0.0:
		earthquake_timer = 7.0
		_executar_terremoto_ancestral()


func _executar_terremoto_ancestral() -> void:
	if enemy_body == null or player == null:
		return
		
	ComicBalloon.mostrar(enemy_body, "💥 TERREMOTO ANCESTRAL!", 1.8, -45.0)
	if EventBus != null:
		EventBus.emit_camera_shake(0.55, 0.35)
		
	var dist = enemy_body.global_position.distance_to(player.global_position)
	if dist <= 140.0:
		var dir = (player.global_position - enemy_body.global_position).normalized()
		var dano_aoe = int((enemy_system.get_strength() if enemy_system else 15) * 1.3)
		if player.has_method("receber_dano"):
			player.receber_dano(dano_aoe, dir, 180.0, enemy_body)
		elif player.has_node("CombatSystem"):
			player.get_node("CombatSystem").receber_dano(dano_aoe, dir, 180.0, enemy_body)




# =========================================================
# ENCONTRAR PLAYER
# =========================================================

func _find_player() -> void:

	var players: Array[Node] = get_tree().get_nodes_in_group("player")

	if players.is_empty():
		player = null
		return

	player = players[0] as Node2D


# =========================================================
# ATUALIZAR ESTADO
# =========================================================

func _update_state() -> void:

	if enemy_system != null and enemy_system.em_stagger:
		current_state = State.STAGGER
		return

	# Manter estados atômicos de combate (Windup, Ataque e Recuperação)
	if current_state == State.PREPARE_ATTACK or current_state == State.ATTACK or current_state == State.RECOVERY:
		return

	if player == null or not is_instance_valid(player):
		current_state = State.IDLE
		return

	var distance: float = enemy_body.global_position.distance_to(
		player.global_position
	)

	# -----------------------------------------------------
	# LEITURA DE NEN DO JOGADOR (ZETSU & REN)
	# -----------------------------------------------------
	var range_ativo = detection_range
	var nen_sys = player.get_node_or_null("NenSystem")
	var em_zetsu = (nen_sys != null and nen_sys.has_method("tecnica_ativa") and nen_sys.tecnica_ativa(NenSystem.Tecnica.ZETSU))
	var em_ren = (nen_sys != null and nen_sys.has_method("tecnica_ativa") and nen_sys.tecnica_ativa(NenSystem.Tecnica.REN))

	if em_zetsu:
		# Zetsu reduz a percepção do inimigo apenas para contato direto
		range_ativo = min(detection_range, stop_distance + 16.0)
		if current_state == State.CHASE and distance > range_ativo:
			ComicBalloon.mostrar(enemy_body, "❓ A presença sumiu?! Onde foi?!", 1.8, -38.0)
			current_state = State.RETURN if return_to_position else State.IDLE
			return
	elif em_ren:
		# Ren emite pressão intensa de aura, alertando inimigos mais longe
		range_ativo = detection_range * 1.30
	elif WorldState != null and WorldState.obter_infamia() >= 100:
		# Alta infâmia atrai atenção redobrada de patrulhas e caçadores
		range_ativo = detection_range * 1.40

	# Player fora do alcance de detecção
	if distance > range_ativo:
		if return_to_position:
			current_state = State.RETURN
		else:
			current_state = State.IDLE
		return

	# Se puder atacar e estiver dentro do alcance de ataque -> INICIAR WINDUP
	if distance <= attack_range and attack_timer <= 0.0:
		_iniciar_prepare_attack()
		return

	# Se estiver em perseguição e ainda fora da distância de parada
	if chase_player and distance > stop_distance:
		current_state = State.CHASE
		return

	# Perto e pronto para atacar -> INICIAR WINDUP
	if distance <= stop_distance and attack_timer <= 0.0:
		_iniciar_prepare_attack()
		return

	current_state = State.IDLE


# =========================================================
# EXECUTAR ESTADO
# =========================================================

func _execute_state() -> void:

	match current_state:

		State.IDLE:
			_idle()

		State.CHASE:
			_chase()

		State.PREPARE_ATTACK:
			_prepare_attack()

		State.ATTACK:
			_attack()

		State.RECOVERY:
			_recovery()

		State.RETURN:
			_return()

		State.STAGGER:
			_stagger()


# =========================================================
# STAGGER
# =========================================================

func _stagger() -> void:
	_remover_telegraph()
	enemy_body.velocity = Vector2.ZERO


func _obter_role() -> String:
	if enemy_system != null and enemy_system.enemy_data != null and not enemy_system.enemy_data.role.is_empty():
		return enemy_system.enemy_data.role
	return "bruiser"


# =========================================================
# IDLE
# =========================================================

func _idle() -> void:
	_remover_telegraph()
	var role: String = _obter_role()
	if role == "ambusher" and enemy_body != null:
		var sprite = enemy_body.get_node_or_null("Sprite2D") as Sprite2D
		if sprite != null:
			sprite.modulate.a = 0.25 # Camuflagem na vegetação
	enemy_body.velocity = Vector2.ZERO


# =========================================================
# PREPARE ATTACK (WINDUP & TELEGRAPH)
# =========================================================

func _iniciar_prepare_attack() -> void:
	current_state = State.PREPARE_ATTACK
	windup_timer = _obter_windup() * (0.65 if is_fase_2 else 1.0)
	_mostrar_telegraph()


func _obter_windup() -> float:
	if enemy_system != null and enemy_system.enemy_data != null and enemy_system.enemy_data.attack_windup > 0.0:
		return enemy_system.enemy_data.attack_windup
	var role: String = _obter_role()
	match role:
		"fast": return 0.15
		"tank": return 0.45
		"ambusher": return 0.18
		_: return 0.25


func _obter_recovery() -> float:
	if enemy_system != null and enemy_system.enemy_data != null and enemy_system.enemy_data.attack_recovery > 0.0:
		return enemy_system.enemy_data.attack_recovery
	var role: String = _obter_role()
	match role:
		"fast": return 0.45 # Tempo para executar o recuo tático
		"tank": return 0.50
		_: return 0.35


func _mostrar_telegraph() -> void:
	if enemy_body == null:
		return
	var sprite = enemy_body.get_node_or_null("Sprite2D") as Sprite2D
	if sprite != null:
		sprite.modulate = Color(2.4, 0.4, 0.4, 1.0) # Flash de alerta de ataque iminente
	
	if _telegraph_indicator == null or not is_instance_valid(_telegraph_indicator):
		var lbl = Label.new()
		lbl.name = "TelegraphAlert"
		lbl.text = "⚠️"
		lbl.position = Vector2(-8, -42)
		lbl.add_theme_font_size_override("font_size", 8)
		lbl.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2, 1.0))
		enemy_body.add_child(lbl)
		_telegraph_indicator = lbl


func _remover_telegraph() -> void:
	if enemy_body != null:
		var sprite = enemy_body.get_node_or_null("Sprite2D") as Sprite2D
		if sprite != null and not is_fase_2:
			sprite.modulate = Color.WHITE
		elif sprite != null and is_fase_2:
			sprite.modulate = Color(1.5, 0.4, 0.4, 1.0)
	
	if _telegraph_indicator != null and is_instance_valid(_telegraph_indicator):
		_telegraph_indicator.queue_free()
		_telegraph_indicator = null


func _prepare_attack() -> void:
	enemy_body.velocity = Vector2.ZERO
	if player != null and is_instance_valid(player):
		var direction = (player.global_position - enemy_body.global_position).normalized()
		_set_animation_direction(direction)
	
	windup_timer -= get_physics_process_delta_time()
	if windup_timer <= 0.0:
		_remover_telegraph()
		current_state = State.ATTACK


# =========================================================
# PERSEGUIR
# =========================================================

func _chase() -> void:
	_remover_telegraph()

	if player == null or not is_instance_valid(player):
		enemy_body.velocity = Vector2.ZERO
		return

	var role: String = _obter_role()
	if role == "ambusher" and enemy_body != null:
		var sprite = enemy_body.get_node_or_null("Sprite2D") as Sprite2D
		if sprite != null:
			sprite.modulate.a = 1.0 # Revelação surpresa da emboscada

	var distance: float = enemy_body.global_position.distance_to(
		player.global_position
	)

	if distance <= stop_distance:
		enemy_body.velocity = Vector2.ZERO
		if attack_timer <= 0.0:
			_iniciar_prepare_attack()
		else:
			current_state = State.IDLE
		return

	var enemy_sys: EnemySystem = enemy_body.get_node_or_null("EnemySystem") as EnemySystem
	if enemy_sys != null and not enemy_sys.falou_spawn:
		enemy_sys.falou_spawn = true
		ComicBalloon.mostrar(enemy_body, CombatComicQuotes.obter_frase_inimigo_spawn(enemy_sys.enemy_name), 2.2, -38.0)

	var direction: Vector2 = (
		player.global_position
		- enemy_body.global_position
	).normalized()

	# Atualiza direção da animação
	_set_animation_direction(direction)

	# Modificador de velocidade por arquétipo
	var vel_atual = move_speed
	if role == "fast":
		vel_atual *= 1.35
	elif role == "tank":
		vel_atual *= 0.85

	# Modificador de velocidade se intimidado por Ren do jogador
	var nen_sys = player.get_node_or_null("NenSystem")
	if nen_sys != null and nen_sys.has_method("tecnica_ativa") and nen_sys.tecnica_ativa(NenSystem.Tecnica.REN):
		if enemy_sys == null or not enemy_sys.is_boss:
			vel_atual *= 0.75 # Intimidado pela pressão de Ren

	enemy_body.velocity = direction * vel_atual
	enemy_body.move_and_slide()


# =========================================================
# ATAQUE
# =========================================================

func _attack() -> void:

	enemy_body.velocity = Vector2.ZERO

	if player == null or not is_instance_valid(player):
		current_state = State.IDLE
		return

	var direction: Vector2 = (
		player.global_position
		- enemy_body.global_position
	).normalized()

	_set_animation_direction(direction)

	# Disparar animação de ataque uma vez
	if _state_machine != null:
		_state_machine.travel("attack")
	
	# Obter dano do EnemySystem ou valor base 12
	var dano: int = 12
	var enemy_sys = enemy_body.get_node_or_null("EnemySystem")
	if enemy_sys != null and enemy_sys.has_method("get_strength"):
		dano = enemy_sys.get_strength()
		if randf() < 0.22:
			ComicBalloon.mostrar(enemy_body, CombatComicQuotes.obter_frase_inimigo_ataque(enemy_sys.enemy_name), 1.8, -38.0)
		
	var player_combat = player.get_node_or_null("CombatSystem")
	if player.has_method("receber_dano"):
		player.receber_dano(dano, direction, 0.0, enemy_body)
		print("[EnemyAI] Golpeou o jogador! Dano: ", dano)
	elif player_combat != null and player_combat.has_method("receber_dano"):
		player_combat.receber_dano(dano, direction, 0.0, enemy_body)
		print("[EnemyAI] Golpeou o jogador via CombatSystem! Dano: ", dano)
	else:
		var hp_atual: int = int(PlayerData.attributes.get("vida", 100))
		PlayerData.attributes["vida"] = max(0, hp_atual - dano)
		print("[EnemyAI] Dano direto ao PlayerData! Dano: ", dano)

	recovery_timer = _obter_recovery() * (0.65 if is_fase_2 else 1.0)
	current_state = State.RECOVERY


# =========================================================
# RECUPERAÇÃO PÓS-ATAQUE (RECOVERY & HIT-AND-RUN)
# =========================================================

func _recovery() -> void:
	var role: String = _obter_role()
	if role == "fast" and player != null and is_instance_valid(player) and enemy_body != null:
		# Hit-and-run: recua taticamente após golpear
		var retreat_dir: Vector2 = (enemy_body.global_position - player.global_position).normalized()
		enemy_body.velocity = retreat_dir * (move_speed * 1.15)
		enemy_body.move_and_slide()
	else:
		enemy_body.velocity = Vector2.ZERO

	recovery_timer -= get_physics_process_delta_time()
	if recovery_timer <= 0.0:
		attack_timer = attack_cooldown
		current_state = State.IDLE




# =========================================================
# VOLTAR
# =========================================================

func _return() -> void:

	var distance: float = enemy_body.global_position.distance_to(
		initial_position
	)


	if distance <= 4.0:

		enemy_body.velocity = Vector2.ZERO

		enemy_body.global_position = initial_position

		current_state = State.IDLE

		return


	var direction: Vector2 = (
		initial_position
		- enemy_body.global_position
	).normalized()


	_set_animation_direction(direction)


	enemy_body.velocity = direction * return_speed

	enemy_body.move_and_slide()


# =========================================================
# ANIMAÇÃO
# =========================================================

func _update_animation() -> void:

	if _state_machine == null:
		return


	match current_state:

		State.IDLE:
			_state_machine.travel("idle")

		State.CHASE:
			_state_machine.travel("walk")

		State.RETURN:
			_state_machine.travel("walk")


# =========================================================
# DIREÇÃO DA ANIMAÇÃO
# =========================================================

func _set_animation_direction(direction: Vector2) -> void:

	var animation_tree: AnimationTree = enemy_body.get_node_or_null(
		"AnimationTree"
	)

	if animation_tree == null:
		return


	if direction == Vector2.ZERO:
		return


	animation_tree["parameters/idle/blend_position"] = direction
	animation_tree["parameters/walk/blend_position"] = direction
	animation_tree["parameters/attack/blend_position"] = direction


# =========================================================
# UTILITÁRIOS
# =========================================================

func get_current_state():
	return current_state


func is_player_detected() -> bool:

	if player == null:
		return false

	var distance: float = enemy_body.global_position.distance_to(
		player.global_position
	)

	return distance <= detection_range


# =========================================================
# SISTEMA DE HATSUS CANÔNICOS DO MANGÁ PARA INIMIGOS
# =========================================================

func executar_hatsu_inimigo() -> void:
	if enemy_body == null or player == null or not is_instance_valid(player):
		return

	var e_name: String = enemy_system.enemy_name.to_lower() if enemy_system != null else enemy_body.name.to_lower()
	var dir: Vector2 = (player.global_position - enemy_body.global_position).normalized()
	if dir == Vector2.ZERO: dir = Vector2.DOWN
	_set_animation_direction(dir)

	# 1. Genei Ryodan (Trupe Fantasma)
	if "hisoka" in e_name:
		_hatsu_hisoka(dir)
	elif "uvogin" in e_name:
		_hatsu_uvogin()
	elif "feitan" in e_name:
		_hatsu_feitan(dir)
	elif "chrollo" in e_name:
		_hatsu_chrollo()
	elif "nobunaga" in e_name:
		_hatsu_nobunaga()
	elif "phinks" in e_name:
		_hatsu_phinks(dir)
	elif "bonolenov" in e_name:
		_hatsu_bonolenov(dir)
	elif "machi" in e_name:
		_hatsu_machi(dir)

	# 2. Família Zoldyck
	elif "illumi" in e_name or "gittarackur" in e_name:
		_hatsu_illumi(dir)
	elif "silva" in e_name:
		_hatsu_silva(dir)
	elif "zeno" in e_name:
		_hatsu_zeno(dir)

	# 3. Formigas Quimera (Chimera Ants)
	elif "meruem" in e_name or "rei" in e_name:
		_hatsu_meruem(dir)
	elif "pitou" in e_name or "neferpitou" in e_name:
		_hatsu_pitou(dir)
	elif "pouf" in e_name or "shaiapouf" in e_name:
		_hatsu_pouf()
	elif "youpi" in e_name or "menthuthuyoupi" in e_name:
		_hatsu_youpi()

	# 4. Greed Island & Exame
	elif "genthru" in e_name or "bombardeiro" in e_name:
		_hatsu_genthru(dir)
	elif "razor" in e_name:
		_hatsu_razor(dir)
	elif "kastro" in e_name:
		_hatsu_kastro(dir)

	# 5. Hunters da Associação
	elif "netero" in e_name:
		_hatsu_netero()
	elif "knuckle" in e_name:
		_hatsu_knuckle(dir)
	elif "morel" in e_name:
		_hatsu_morel()

	# 6. Monstros e Quimeras Menores
	else:
		_hatsu_monstro_padrao(dir)


func _aplicar_dano_jogador(dano_val: int, dir_val: Vector2, knock_val: float = 0.0) -> void:
	if player == null or not is_instance_valid(player): return
	var player_combat = player.get_node_or_null("CombatSystem")
	if player.has_method("receber_dano"):
		player.receber_dano(dano_val, dir_val, knock_val, enemy_body)
	elif player_combat != null and player_combat.has_method("receber_dano"):
		player_combat.receber_dano(dano_val, dir_val, knock_val, enemy_body)
	else:
		var hp_atual: int = int(PlayerData.attributes.get("vida", 100))
		PlayerData.attributes["vida"] = max(0, hp_atual - dano_val)


# --- ROTINAS INDIVIDUAIS DOS HATSUS DO MANGÁ ---

func _hatsu_hisoka(dir: Vector2) -> void:
	ComicBalloon.mostrar(enemy_body, "♠️ Bungee Gum tem as propriedades de borracha e goma!", 2.2, -42.0)
	var h := HatsuData.new()
	h.nome = "Bungee Gum"
	h.estilo_visual = HatsuData.EstiloVisual.PURO_PULSANTE
	h.cor_aura = Color(1.0, 0.35, 0.75)

	var proj := HatsuProjectileNode.new()
	proj.setup(enemy_body.global_position, dir, 220.0, 240.0, 20, h.cor_aura, enemy_body, h)
	if enemy_body.get_parent() != null:
		enemy_body.get_parent().add_child(proj)


func _hatsu_uvogin() -> void:
	ComicBalloon.mostrar(enemy_body, "💥 BIG BANG IMPACT! 100% DE PURA DESTRUIÇÃO!", 2.2, -42.0)
	var fx := HatsuAreaExplosionNode.new()
	fx.setup(95.0, Color(1.0, 0.85, 0.2), Color.WHITE)
	enemy_body.add_child(fx)

	var dist: float = enemy_body.global_position.distance_to(player.global_position)
	if dist <= 95.0:
		var dir: Vector2 = (player.global_position - enemy_body.global_position).normalized()
		_aplicar_dano_jogador(35, dir, 320.0)


func _hatsu_feitan(dir: Vector2) -> void:
	if is_fase_2 or (enemy_system != null and enemy_system.health <= enemy_system.max_health * 0.55):
		ComicBalloon.mostrar(enemy_body, "☀️ PAIN PACKER: RISING SUN! QUEIMEM ATÉ AS CINZAS!", 2.5, -42.0)
		var fx := HatsuAreaExplosionNode.new()
		fx.setup(110.0, Color(1.0, 0.3, 0.1), Color(1.0, 0.9, 0.2))
		enemy_body.add_child(fx)

		var dist: float = enemy_body.global_position.distance_to(player.global_position)
		if dist <= 110.0:
			_aplicar_dano_jogador(42, (player.global_position - enemy_body.global_position).normalized(), 150.0)
	else:
		ComicBalloon.mostrar(enemy_body, "🗡️ Lâmina Oculta de Feitan!", 1.8, -40.0)
		var h := HatsuData.new()
		h.nome = "Lâmina Oculta"
		h.estilo_visual = HatsuData.EstiloVisual.LAMINA_CORTE
		h.cor_aura = Color(0.9, 0.2, 0.4)

		var proj := HatsuProjectileNode.new()
		proj.setup(enemy_body.global_position, dir, 160.0, 320.0, 18, h.cor_aura, enemy_body, h)
		if enemy_body.get_parent() != null:
			enemy_body.get_parent().add_child(proj)


func _hatsu_chrollo() -> void:
	ComicBalloon.mostrar(enemy_body, "📖 SKILL HUNTER: INDOOR FISH!", 2.2, -42.0)
	var fx := HatsuAreaExplosionNode.new()
	fx.setup(85.0, Color(0.3, 0.1, 0.4), Color(0.7, 0.2, 1.0))
	enemy_body.add_child(fx)

	var dist: float = enemy_body.global_position.distance_to(player.global_position)
	if dist <= 85.0:
		_aplicar_dano_jogador(28, Vector2.ZERO, 0.0)


func _hatsu_nobunaga() -> void:
	ComicBalloon.mostrar(enemy_body, "⚔️ IAI SLASH: RAIO DE EN DE 4 METROS!", 2.0, -42.0)
	var fx := HatsuAreaExplosionNode.new()
	fx.setup(60.0, Color(0.9, 0.9, 1.0), Color.WHITE)
	enemy_body.add_child(fx)

	var dist: float = enemy_body.global_position.distance_to(player.global_position)
	if dist <= 60.0:
		_aplicar_dano_jogador(30, (player.global_position - enemy_body.global_position).normalized(), 180.0)


func _hatsu_phinks(dir: Vector2) -> void:
	ComicBalloon.mostrar(enemy_body, "💪 RIPPER CYCLOTRON: ROTAÇÃO MÁXIMA!", 2.0, -42.0)
	var fx := HatsuAreaExplosionNode.new()
	fx.setup(50.0, Color(1.0, 0.8, 0.2), Color.WHITE)
	enemy_body.add_child(fx)

	var dist: float = enemy_body.global_position.distance_to(player.global_position)
	if dist <= 50.0:
		_aplicar_dano_jogador(40, dir, 260.0)


func _hatsu_bonolenov(dir: Vector2) -> void:
	ComicBalloon.mostrar(enemy_body, "🪐 BATTLE CANTABILE: JÚPITER!", 2.2, -42.0)
	var h := HatsuData.new()
	h.nome = "Júpiter"
	h.estilo_visual = HatsuData.EstiloVisual.ANEIS_IMPACTO
	h.cor_aura = Color(0.85, 0.7, 0.2)

	var proj := HatsuProjectileNode.new()
	proj.setup(enemy_body.global_position, dir, 200.0, 180.0, 28, h.cor_aura, enemy_body, h)
	if enemy_body.get_parent() != null:
		enemy_body.get_parent().add_child(proj)


func _hatsu_machi(dir: Vector2) -> void:
	ComicBalloon.mostrar(enemy_body, "🧵 LINHAS DE NEN: RESTRIÇÃO!", 2.0, -40.0)
	var h := HatsuData.new()
	h.nome = "Linhas de Nen"
	h.estilo_visual = HatsuData.EstiloVisual.PURO_PULSANTE
	h.cor_aura = Color(0.3, 0.9, 0.8)

	var proj := HatsuProjectileNode.new()
	proj.setup(enemy_body.global_position, dir, 180.0, 260.0, 16, h.cor_aura, enemy_body, h)
	if enemy_body.get_parent() != null:
		enemy_body.get_parent().add_child(proj)


func _hatsu_illumi(dir: Vector2) -> void:
	ComicBalloon.mostrar(enemy_body, "📍 AGULHAS DE MANIPULAÇÃO!", 2.0, -40.0)
	var h := HatsuData.new()
	h.nome = "Agulhas de Manipulação"
	h.estilo_visual = HatsuData.EstiloVisual.LAMINA_CORTE
	h.cor_aura = Color(0.9, 0.85, 0.3)

	# Disparo triplo em leque
	var offsets = [-0.25, 0.0, 0.25]
	for off in offsets:
		var d_rot = dir.rotated(off)
		var proj := HatsuProjectileNode.new()
		proj.setup(enemy_body.global_position, d_rot, 210.0, 300.0, 16, h.cor_aura, enemy_body, h)
		if enemy_body.get_parent() != null:
			enemy_body.get_parent().add_child(proj)


func _hatsu_silva(dir: Vector2) -> void:
	ComicBalloon.mostrar(enemy_body, "⚡ ORBES GIGANTES DE EMISSÃO!", 2.2, -42.0)
	var h := HatsuData.new()
	h.nome = "Orbe de Emissão"
	h.estilo_visual = HatsuData.EstiloVisual.RELAMPAGOS_ELETRICOS
	h.cor_aura = Color(0.2, 0.8, 1.0)

	var proj := HatsuProjectileNode.new()
	proj.setup(enemy_body.global_position, dir, 220.0, 240.0, 34, h.cor_aura, enemy_body, h)
	if enemy_body.get_parent() != null:
		enemy_body.get_parent().add_child(proj)


func _hatsu_zeno(dir: Vector2) -> void:
	ComicBalloon.mostrar(enemy_body, "🐉 DRAGON DIVE: CHUVA DE DRAGÕES!", 2.5, -42.0)
	var h := HatsuData.new()
	h.nome = "Dragon Dive"
	h.estilo_visual = HatsuData.EstiloVisual.DRAGAO_SERPENTE
	h.cor_aura = Color(0.9, 0.8, 0.2)

	var proj := HatsuProjectileNode.new()
	proj.setup(enemy_body.global_position, dir, 240.0, 260.0, 32, h.cor_aura, enemy_body, h)
	if enemy_body.get_parent() != null:
		enemy_body.get_parent().add_child(proj)


func _hatsu_netero() -> void:
	ComicBalloon.mostrar(enemy_body, "🙏 100-TYPE GUANYIN BODHISATTVA!", 2.2, -42.0)
	var fx := HatsuAreaExplosionNode.new()
	fx.setup(100.0, Color(1.0, 0.9, 0.3), Color.WHITE)
	enemy_body.add_child(fx)

	var dist: float = enemy_body.global_position.distance_to(player.global_position)
	if dist <= 100.0:
		_aplicar_dano_jogador(38, (player.global_position - enemy_body.global_position).normalized(), 200.0)


func _hatsu_pitou(dir: Vector2) -> void:
	ComicBalloon.mostrar(enemy_body, "🐱 TERPSICHORA: DANÇA DA MARIONETE!", 2.2, -42.0)
	enemy_body.global_position = enemy_body.global_position.lerp(player.global_position, 0.5)

	var fx := HatsuAreaExplosionNode.new()
	fx.setup(75.0, Color(1.0, 0.1, 0.2), Color(0.4, 0.0, 0.1))
	enemy_body.add_child(fx)

	var dist: float = enemy_body.global_position.distance_to(player.global_position)
	if dist <= 75.0:
		_aplicar_dano_jogador(35, dir, 180.0)


func _hatsu_meruem(dir: Vector2) -> void:
	ComicBalloon.mostrar(enemy_body, "👑 FÓTONS DE EN: SÍNTESE DE AURA!", 2.5, -42.0)
	var fx := HatsuAreaExplosionNode.new()
	fx.setup(120.0, Color(1.0, 1.0, 0.8), Color(0.9, 0.7, 0.2))
	enemy_body.add_child(fx)

	var dist: float = enemy_body.global_position.distance_to(player.global_position)
	if dist <= 120.0:
		_aplicar_dano_jogador(45, dir, 250.0)


func _hatsu_pouf() -> void:
	ComicBalloon.mostrar(enemy_body, "🦋 ESCAMAS ESPIRITUAIS: HIPNOSE!", 2.2, -40.0)
	var fx := HatsuAreaExplosionNode.new()
	fx.setup(90.0, Color(0.8, 0.6, 1.0), Color(0.3, 0.1, 0.5))
	enemy_body.add_child(fx)

	var dist: float = enemy_body.global_position.distance_to(player.global_position)
	if dist <= 90.0:
		_aplicar_dano_jogador(22, Vector2.ZERO, 0.0)


func _hatsu_youpi() -> void:
	ComicBalloon.mostrar(enemy_body, "🔥 EXPLOSÃO DE FÚRIA & TENTÁCULOS!", 2.2, -42.0)
	var fx := HatsuAreaExplosionNode.new()
	fx.setup(95.0, Color(1.0, 0.2, 0.1), Color(0.5, 0.0, 0.0))
	enemy_body.add_child(fx)

	var dist: float = enemy_body.global_position.distance_to(player.global_position)
	if dist <= 95.0:
		_aplicar_dano_jogador(36, (player.global_position - enemy_body.global_position).normalized(), 220.0)


func _hatsu_genthru(dir: Vector2) -> void:
	ComicBalloon.mostrar(enemy_body, "💣 LITTLE FLOWER! LIBEREM!", 2.0, -40.0)
	var fx := HatsuAreaExplosionNode.new()
	fx.setup(55.0, Color(1.0, 0.4, 0.1), Color.WHITE)
	enemy_body.add_child(fx)

	var dist: float = enemy_body.global_position.distance_to(player.global_position)
	if dist <= 55.0:
		_aplicar_dano_jogador(26, dir, 160.0)


func _hatsu_razor(dir: Vector2) -> void:
	ComicBalloon.mostrar(enemy_body, "🏐 ESFERAS DE NEN DOS 14 DEMÔNIOS!", 2.2, -42.0)
	var h := HatsuData.new()
	h.nome = "Esfera de Razor"
	h.estilo_visual = HatsuData.EstiloVisual.SHURIKEN_GIRATORIO
	h.cor_aura = Color(0.9, 0.2, 0.2)

	var proj := HatsuProjectileNode.new()
	proj.setup(enemy_body.global_position, dir, 240.0, 310.0, 30, h.cor_aura, enemy_body, h)
	if enemy_body.get_parent() != null:
		enemy_body.get_parent().add_child(proj)


func _hatsu_kastro(dir: Vector2) -> void:
	ComicBalloon.mostrar(enemy_body, "🐯 TIGRE MORDEDOR!", 2.0, -40.0)
	var h := HatsuData.new()
	h.nome = "Tigre Mordedor"
	h.estilo_visual = HatsuData.EstiloVisual.LAMINA_CORTE
	h.cor_aura = Color(0.4, 0.8, 1.0)

	var proj := HatsuProjectileNode.new()
	proj.setup(enemy_body.global_position, dir, 150.0, 320.0, 22, h.cor_aura, enemy_body, h)
	if enemy_body.get_parent() != null:
		enemy_body.get_parent().add_child(proj)


func _hatsu_knuckle(dir: Vector2) -> void:
	ComicBalloon.mostrar(enemy_body, "📈 HAKOWARE! POTCLEAN ATIVADO!", 2.0, -40.0)
	var dist: float = enemy_body.global_position.distance_to(player.global_position)
	if dist <= 55.0:
		_aplicar_dano_jogador(15, dir, 80.0)


func _hatsu_morel() -> void:
	ComicBalloon.mostrar(enemy_body, "💨 DEEP PURPLE: GUERREIROS DE FUMAÇA!", 2.2, -40.0)
	var fx := HatsuAreaExplosionNode.new()
	fx.setup(80.0, Color(0.6, 0.3, 0.7), Color(0.2, 0.1, 0.3))
	enemy_body.add_child(fx)


func _hatsu_monstro_padrao(dir: Vector2) -> void:
	if randf() < 0.35:
		ComicBalloon.mostrar(enemy_body, "💥 DISPARO DE AURA!", 1.8, -38.0)
	var h := HatsuData.new()
	h.nome = "Disparo de Aura"
	h.estilo_visual = HatsuData.EstiloVisual.PURO_PULSANTE
	h.cor_aura = Color(0.8, 0.3, 0.2)

	var proj := HatsuProjectileNode.new()
	proj.setup(enemy_body.global_position, dir, 180.0, 220.0, 14, h.cor_aura, enemy_body, h)
	if enemy_body.get_parent() != null:
		enemy_body.get_parent().add_child(proj)
