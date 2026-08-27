class_name HunterCombatSystem
extends Node

signal perfect_dodge_executado()
signal player_morreu()


# ============================================================
# HUNTER ONLINE - SISTEMA DE COMBATE
# ============================================================
#
# Responsabilidades:
#
# - Ataque básico
# - Dano físico
# - Dano Nen
# - Defesa
# - HP
# - Esquiva
# - Invulnerabilidade durante esquiva
# - Aura
# - Cooldowns
#
# IMPORTANTE:
#
# Os atributos pertencem ao PlayerData.
# O Nen pertence ao NenSystem.
#
# ============================================================


# ============================================================
# ATAQUE
# ============================================================

@export_category("Attack")

@export var ataque_dano_base: int = 10
@export var ataque_alcance: float = 35.0
@export var ataque_cooldown: float = 0.35

var pode_atacar: bool = true
var ataque_timer: float = 0.0


# ============================================================
# ESQUIVA
# ============================================================

@export_category("Dodge")

@export var esquiva_velocidade: float = 350.0
@export var esquiva_duracao: float = 0.20
@export var esquiva_cooldown: float = 0.60

var pode_esquivar: bool = true
var esquivando: bool = false

var esquiva_timer: float = 0.0
var esquiva_duracao_timer: float = 0.0


# ============================================================
# ESTADO
# ============================================================

enum Estado {
	NORMAL,
	ATACANDO,
	ESQUIVANDO,
	MORTO
}

var estado: Estado = Estado.NORMAL


# ============================================================
# INVULNERABILIDADE
# ============================================================

var invulneravel: bool = false


# ============================================================
# DIREÇÃO
# ============================================================

var ultima_direcao: Vector2 = Vector2.DOWN
var direcao_esquiva: Vector2 = Vector2.DOWN


# ============================================================
# REFERÊNCIAS
# ============================================================

var owner_body: CharacterBody2D = null
var nen_system: NenSystem = null
var hatsu_system: HatsuSystem = null
var nen_beast_system: NenBeastSystem = null




# ============================================================
# READY
# ============================================================

func _ready() -> void:

	add_to_group("player_combat_system")


# ============================================================
# SETUP
var _cached_hitbox: Area2D = null
var _cached_shape: CollisionShape2D = null
var _cached_circle: CircleShape2D = null
var _alvos_atingidos_neste_golpe: Array[Node] = []
var _hitbox_desativar_timer: float = 0.0

# ============================================================
# SETUP
# ============================================================

func setup(body: CharacterBody2D) -> void:
	owner_body = body

	nen_system = owner_body.get_node_or_null("NenSystem") as NenSystem
	hatsu_system = owner_body.get_node_or_null("HatsuSystem") as HatsuSystem
	nen_beast_system = owner_body.get_node_or_null("NenBeastSystem") as NenBeastSystem

	# Criar e cachear a hitbox de ataque persistente para evitar alocações por frame
	if _cached_hitbox == null or not is_instance_valid(_cached_hitbox):
		_cached_hitbox = Area2D.new()
		_cached_hitbox.name = "PlayerPersistentHitbox"
		_cached_hitbox.collision_layer = 1 << 3 # Layer 4 (Hitbox)
		_cached_hitbox.collision_mask = (1 << 4) | (1 << 2) # Hurtbox (16) e Inimigos (4)
		_cached_hitbox.monitoring = false
		_cached_hitbox.monitorable = true

		_cached_shape = CollisionShape2D.new()
		_cached_circle = CircleShape2D.new()
		_cached_circle.radius = 36.0
		_cached_shape.shape = _cached_circle
		_cached_shape.disabled = true
		_cached_hitbox.add_child(_cached_shape)

		owner_body.add_child(_cached_hitbox)

		_cached_hitbox.area_entered.connect(_on_cached_hitbox_hit)
		_cached_hitbox.body_entered.connect(_on_cached_hitbox_hit)

	estado = Estado.NORMAL
	pode_atacar = true
	pode_esquivar = true
	invulneravel = false
	esquivando = false
	ataque_timer = 0.0
	esquiva_timer = 0.0

	if nen_system == null:
		push_warning("HunterCombatSystem: NenSystem não encontrado.")

# ============================================================
# PROCESS
# ============================================================

func _process(delta: float) -> void:
	_atualizar_timers(delta)
	if _hitbox_desativar_timer > 0.0:
		_hitbox_desativar_timer -= delta
		if _hitbox_desativar_timer <= 0.0:
			_desativar_hitbox_ataque()

# ============================================================
# ATAQUE
# ============================================================

func tentar_atacar(direcao: Vector2) -> void:
	if not pode_atacar or esquivando or estado == Estado.MORTO or owner_body == null:
		return

	if hatsu_system != null and hatsu_system.has_method("ataques_bloqueados") and hatsu_system.ataques_bloqueados():
		_mostrar_texto_flutuante("🛡️ DEFESA PACÍFICA: ATAQUE BLOQUEADO", Color(0.3, 0.8, 1.0))
		return

	var cd_ataque: float = ataque_cooldown

	if PlayerData.quest_states.get("guanyin_bodhisattva_ativo", false):
		var aura_atual: float = float(PlayerData.attributes.get("aura", 0.0))
		if aura_atual < 20.0:
			PlayerData.quest_states["guanyin_bodhisattva_ativo"] = false
			_mostrar_texto_flutuante("Aura do Bodhisattva Esgotada!", Color(1.0, 0.4, 0.4))
		else:
			PlayerData.attributes["aura"] = aura_atual - 20.0
			cd_ataque = 0.12
	elif PlayerData.quest_states.get("godspeed_ativo", false):
		var aura_atual: float = float(PlayerData.attributes.get("aura", 0.0))
		if aura_atual < 12.0:
			PlayerData.quest_states["godspeed_ativo"] = false
			_mostrar_texto_flutuante("Aura do Godspeed Esgotada!", Color(1.0, 0.4, 0.4))
		else:
			PlayerData.attributes["aura"] = aura_atual - 12.0
			cd_ataque = 0.18

	if direcao == Vector2.ZERO:
		direcao = ultima_direcao

	ultima_direcao = direcao.normalized()
	pode_atacar = false
	estado = Estado.ATACANDO

	_disparar_hitbox_ataque(ultima_direcao)
	ataque_timer = cd_ataque

# ============================================================
# DISPARAR HITBOX (REUTILIZAÇÃO CACHEADA SEM ALOCAÇÃO)
# ============================================================

func _disparar_hitbox_ataque(direcao: Vector2) -> void:
	if owner_body == null or _cached_hitbox == null:
		return

	_alvos_atingidos_neste_golpe.clear()

	var alcance_final: float = max(54.0, ataque_alcance * 1.2)
	if nen_system != null:
		alcance_final = nen_system.aplicar_ren_no_alcance(alcance_final)

	if _cached_circle != null:
		_cached_circle.radius = max(36.0, alcance_final * 0.85)

	_cached_hitbox.position = direcao.normalized() * (alcance_final * 0.45)
	_cached_hitbox.monitoring = true
	if _cached_shape != null:
		_cached_shape.disabled = false

	_hitbox_desativar_timer = 0.14

	# Checar colisões imediatas
	for a in _cached_hitbox.get_overlapping_areas():
		_on_cached_hitbox_hit(a)
	for b in _cached_hitbox.get_overlapping_bodies():
		_on_cached_hitbox_hit(b)

func _desativar_hitbox_ataque() -> void:
	if _cached_hitbox != null and is_instance_valid(_cached_hitbox):
		_cached_hitbox.monitoring = false
	if _cached_shape != null and is_instance_valid(_cached_shape):
		_cached_shape.disabled = true
	_alvos_atingidos_neste_golpe.clear()

func _on_cached_hitbox_hit(alvo: Node) -> void:
	if alvo == null or not is_instance_valid(alvo) or alvo == owner_body:
		return

	var root_target: Node = alvo.get_parent() if alvo is Area2D and alvo.get_parent() != null else alvo
	if root_target == owner_body or root_target in _alvos_atingidos_neste_golpe or alvo in _alvos_atingidos_neste_golpe:
		return

	_alvos_atingidos_neste_golpe.append(alvo)
	_alvos_atingidos_neste_golpe.append(root_target)

	_on_attack_hit(alvo, _cached_hitbox)



# ============================================================
# ATAQUE ACERTOU
# ============================================================

func _on_attack_hit(
	alvo: Node,
	_hitbox: Area2D
) -> void:

	if owner_body == null:
		return

	if estado == Estado.MORTO:
		return

	if not is_instance_valid(alvo):
		return


	# ========================================================
	# ENCONTRAR INIMIGO
	# ========================================================

	var enemy: Node = alvo.get_parent() if alvo is Area2D and alvo.get_parent() != null else alvo

	if enemy == owner_body or alvo == owner_body:
		return

	# ========================================================
	# ENEMY SYSTEM / HURTBOX
	# ========================================================

	var enemy_system: Node = enemy.get_node_or_null("EnemySystem")
	if enemy_system == null and alvo.has_node("EnemySystem"):
		enemy_system = alvo.get_node("EnemySystem")

	var dano: int = calcular_dano_fisico()

	var is_crit: bool = false
	if nen_system != null and (nen_system.tecnica_ativa(NenSystem.Tecnica.KO) or nen_system.tecnica_ativa(NenSystem.Tecnica.GYO)):
		is_crit = true

	# Disparar Hitstop e Camera Shake (Fase 1: Game Feel & Juice)
	if EventBus != null:
		if is_crit:
			EventBus.emit_hitstop(0.08)
			EventBus.emit_camera_shake(0.45, 0.25)
		else:
			EventBus.emit_hitstop(0.04)
			EventBus.emit_camera_shake(0.20, 0.15)
		EventBus.combat_hit_landed.emit(owner_body, enemy, dano, is_crit)

	print("=================================")
	print("ATAQUE ACERTOU: ", enemy.name)
	print("DANO FINAL: ", dano)
	print("=================================")

	if enemy_system != null and enemy_system.has_method("take_damage"):
		enemy_system.take_damage(dano, ultima_direcao, 120.0, owner_body)
	elif alvo.has_method("receber_dano"):
		alvo.receber_dano(dano, ultima_direcao, 120.0, owner_body)
	elif enemy.has_method("receber_dano"):
		enemy.receber_dano(dano, ultima_direcao, 120.0, owner_body)



# ============================================================
# CÁLCULO DE DANO
# ============================================================
#
# DANO FÍSICO:
#
#     dano_base + força
#
# DANO NEN:
#
#     força × poder_nen
#
# PODER NEN:
#
#     baseado na AURA MÁXIMA
#
# KO:
#
# ============================================================
# DANO FÍSICO & TÁTICAS DE NEN (SKILL-BASED)
# ============================================================

func calcular_dano_fisico(inimigo_alvo: Node = null) -> int:
	if CombatEngine != null and CombatEngine.has_method("calcular_dano_jogador"):
		return CombatEngine.calcular_dano_jogador(owner_body, nen_system, inimigo_alvo)

	var forca: float = float(obter_forca())
	var dano_base: float = float(ataque_dano_base)
	var dano_fisico: float = dano_base + forca
	return max(1, int(round(dano_fisico)))

# ============================================================
# RECEBER DANO (COM PERFECT DODGE)
# ============================================================

func receber_dano(
	dano: int,
	direcao_ataque: Vector2 = Vector2.ZERO,
	forca_knockback: float = 140.0,
	atacante: Node = null
) -> void:
	if estado == Estado.MORTO:
		return

	# ========================================================
	# ESQUIVA & PERFECT DODGE (BULLET TIME + AURA RECOVERY)
	# ========================================================
	if invulneravel:
		if esquivando and esquiva_duracao_timer > (esquiva_duracao - 0.22):
			_executar_perfect_dodge(atacante)
		return

	var dano_final: int = 1
	if CombatEngine != null and CombatEngine.has_method("calcular_dano_sofrido_jogador"):
		dano_final = CombatEngine.calcular_dano_sofrido_jogador(dano, nen_system, hatsu_system, atacante)
	else:
		var defesa: int = obter_defesa()
		dano_final = max(1, dano - defesa)

	if dano_final <= 0:
		return

	# ========================================================
	# HP
	# ========================================================
	var hp: int = obter_hp()


	hp -= dano_final

	hp = max(
		hp,
		0
	)

	PlayerData.attributes["vida"] = hp

	if EventBus != null:
		EventBus.emit_camera_shake(0.35, 0.20)
		EventBus.player_damaged.emit(hp, obter_hp_max(), dano_final)

	print(
		"DANO RECEBIDO: ",
		dano_final,
		" | HP: ",
		hp,
		"/",
		obter_hp_max()
	)

	# ========================================================
	# MORTE
	# ========================================================

	if hp <= 0:
		morrer()



# ============================================================
# ESQUIVA
# ============================================================

func tentar_esquivar(
	direcao: Vector2 = Vector2.ZERO
) -> bool:

	if not pode_esquivar:
		return false

	if esquivando:
		return false

	if estado == Estado.MORTO:
		return false

	if owner_body == null:
		return false

	if hatsu_system != null and hatsu_system.has_method("esquivas_bloqueadas") and hatsu_system.esquivas_bloqueadas():
		_mostrar_texto_flutuante("🚫 ESQUIVA BLOQUEADA POR JURAMENTO", Color(1.0, 0.4, 0.4))
		return false


	if direcao == Vector2.ZERO:
		direcao = ultima_direcao


	direcao_esquiva = (
		direcao.normalized()
	)

	esquivando = true
	invulneravel = true
	pode_esquivar = false

	estado = Estado.ESQUIVANDO

	if hatsu_system != null and hatsu_system.has_method("registrar_esquiva_perfeita"):
		hatsu_system.registrar_esquiva_perfeita()


	# ========================================================
	# DURAÇÃO
	# ========================================================

	esquiva_duracao_timer = (
		esquiva_duracao
	)

	esquiva_timer = (
		esquiva_cooldown
	)


	print(
		"ESQUIVA!"
	)
	return true



# ============================================================
# ATUALIZAR TIMERS
# ============================================================

func _atualizar_timers(
	delta: float
) -> void:


	# ========================================================
	# ATAQUE
	# ========================================================

	if ataque_timer > 0.0:

		ataque_timer -= delta

		if ataque_timer <= 0.0:

			ataque_timer = 0.0

			pode_atacar = true

			if estado == Estado.ATACANDO:

				estado = Estado.NORMAL


	# ========================================================
	# COOLDOWN ESQUIVA
	# ========================================================

	if esquiva_timer > 0.0:

		esquiva_timer -= delta

		if esquiva_timer <= 0.0:

			esquiva_timer = 0.0

			pode_esquivar = true


	# ========================================================
	# DURAÇÃO ESQUIVA
	# ========================================================

	if esquivando:

		esquiva_duracao_timer -= delta

		if esquiva_duracao_timer <= 0.0:

			esquiva_duracao_timer = 0.0

			_finalizar_esquiva()


# ============================================================
# MOVIMENTO DA ESQUIVA
# ============================================================

func processar_movimento_esquiva() -> void:

	if not esquivando:
		return

	if owner_body == null:
		return


	owner_body.velocity = (
		direcao_esquiva
		* esquiva_velocidade
	)

	owner_body.move_and_slide()


# ============================================================
# FINALIZAR ESQUIVA
# ============================================================

func _finalizar_esquiva() -> void:

	esquivando = false

	invulneravel = false


	if estado == Estado.ESQUIVANDO:

		estado = Estado.NORMAL


	if owner_body != null:

		owner_body.velocity = Vector2.ZERO


# ============================================================
# MORTE
# ============================================================

func morrer() -> void:

	if estado == Estado.MORTO:
		return

	# Intercepção da Besta de Nen (Fênix)
	if nen_beast_system != null and nen_beast_system.verificar_morte_fatal():
		return

	estado = Estado.MORTO

	PlayerData.attributes["vida"] = 0

	if owner_body != null:
		owner_body.velocity = Vector2.ZERO
		if owner_body.has_method("travar_controles"):
			owner_body.travar_controles(true)

	# ========================================================
	# DESATIVAR NEN
	# ========================================================

	if nen_system != null:
		nen_system.desativar_todas_tecnicas()

	if EventBus != null:
		EventBus.emit_hitstop(0.12)
		EventBus.emit_camera_shake(0.70, 0.40)
		EventBus.player_died.emit()

	print(
		"PERSONAGEM MORREU!"
	)
	player_morreu.emit()
	_exibir_tela_morte()



func _exibir_tela_morte() -> void:
	var death_ui = get_tree().root.get_node_or_null("DeathScreenUI")
	if death_ui == null:
		var scn_death = load("res://ui/DeathScreen/DeathScreenUI.gd")
		if scn_death:
			death_ui = scn_death.new()
			death_ui.name = "DeathScreenUI"
			get_tree().root.call_deferred("add_child", death_ui)
	if death_ui != null and death_ui.has_method("exibir"):
		death_ui.exibir()


func reviver() -> void:
	estado = Estado.NORMAL
	pode_atacar = true
	pode_esquivar = true
	esquivando = false
	invulneravel = true

	var hp_max: int = obter_hp_max()
	PlayerData.attributes["vida"] = hp_max

	var a_max: float = obter_aura_max()
	PlayerData.attributes["aura"] = a_max

	if owner_body != null:
		if owner_body.has_method("travar_controles"):
			owner_body.travar_controles(false)

	var tree := get_tree()
	if tree != null:
		var timer := tree.create_timer(1.2)
		timer.timeout.connect(func():
			invulneravel = false
		)



# ============================================================
# GASTAR AURA
# ============================================================

func gastar_aura(
	valor: int
) -> bool:

	if nen_system != null:

		return nen_system.gastar_aura(
			valor
		)


	return false


# ============================================================
# RECUPERAR AURA
# ============================================================

func recuperar_aura(
	valor: int
) -> void:

	if nen_system != null:

		nen_system.recuperar_aura(
			valor
		)


# ============================================================
# UTILIDADES — PLAYER DATA
# ============================================================

func obter_hp() -> int:

	return int(
		PlayerData.attributes["vida"]
	)


func obter_hp_max() -> int:

	return int(
		PlayerData.attributes["vida_max"]
	)


func obter_forca() -> int:

	var base_forca: int = int(
		PlayerData.attributes["forca"]
	)

	if nen_beast_system != null and nen_beast_system.berserker_ativo:
		return int(base_forca * 1.5)

	return base_forca



func obter_defesa() -> int:
	var def_base: int = int(PlayerData.attributes.get("defesa", 10))
	var bonus_nen: int = 0
	if PlayerData.despertou_nen:
		var nivel_nen: int = int(PlayerData.attributes.get("nivel_nen", 0))
		var aura_atual: float = float(PlayerData.attributes.get("aura", 0.0))
		var aura_max: float = float(PlayerData.attributes.get("aura_max", 1.0))
		var perc_aura: float = clamp(aura_atual / max(1.0, aura_max), 0.0, 1.0)
		# Nen fortalece a pele e a resistência corporal: +15% base + escalonamento por nível de Nen e aura
		bonus_nen = int(float(def_base) * 0.15 + (float(nivel_nen) * 2.0) * (0.5 + 0.5 * perc_aura))
	return def_base + bonus_nen


func obter_velocidade() -> int:

	return int(
		PlayerData.attributes["velocidade"]
	)


func obter_aura() -> float:

	return float(
		PlayerData.attributes["aura"]
	)


func obter_aura_max() -> float:

	return float(
		PlayerData.attributes["aura_max"]
	)


func obter_level() -> int:

	return int(
		PlayerData.attributes["nivel"]
	)


# ============================================================
# ESTADO
# ============================================================

func esta_vivo() -> bool:

	return (
		estado != Estado.MORTO
		and obter_hp() > 0
	)


# ============================================================
# SKILL & PERFECT DODGE EXECUTION
# ============================================================

func _executar_perfect_dodge(_atacante: Node) -> void:
	perfect_dodge_executado.emit()
	print("[CombatSystem] ⚡ PERFECT DODGE EXECUTADO COM SUCESSO!")
	PlayerData.registrar_estatistica("perfect_dodges", 1)

	# Recuperar +15 de Aura pela maestria da esquiva perfeita
	if nen_system != null:
		nen_system.recuperar_aura(15)
	else:
		var a_max: float = float(PlayerData.attributes.get("aura_max", 100.0))
		var a_cur: float = float(PlayerData.attributes.get("aura", 0.0))
		PlayerData.attributes["aura"] = min(a_max, a_cur + 15.0)

	_mostrar_texto_flutuante("⚡ PERFECT DODGE! +15 AURA", Color(0.2, 1.0, 0.5))



func _mostrar_texto_flutuante(texto: String, cor: Color) -> void:
	if owner_body == null:
		return
	var lbl := Label.new()
	lbl.text = texto
	lbl.add_theme_font_size_override("font_size", 5)
	lbl.add_theme_color_override("font_color", cor)
	lbl.position = Vector2(-25, -30)
	owner_body.add_child(lbl)

	var tween = owner_body.create_tween()
	tween.tween_property(lbl, "position", lbl.position + Vector2(0, -18), 0.9)
	tween.parallel().tween_property(lbl, "modulate:a", 0.0, 0.9)
	tween.tween_callback(lbl.queue_free)
