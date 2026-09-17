class_name XPSystem
extends Node


signal xp_changed(current_xp: int, required_xp: int)
signal level_up(new_level: int)
signal skill_points_changed(pontos_disponiveis: int)


# ============================================================
# HUNTER ONLINE — SISTEMA UNIFICADO DE PROGRESSÃO (NEN XP)
# ============================================================
#
# Este é o ÚNICO sistema de XP do personagem.
#
# Toda fonte de XP alimenta este sistema:
# - Inimigos
# - Quests
# - Bosses
# - Eventos
# - Treinamento
#
# Level Up concede:
# 1. Atributos base (via PlayerData.aplicar_nivel)
# 2. +1 Nen Skill Point
# 3. Aura Máxima (via PlayerData.aplicar_nivel_nen)
#
# ============================================================


# ============================================================
# LEVEL
# ============================================================

@export_category("Level")

@export var level: int = 1
@export var xp: int = 0


# ============================================================
# XP
# ============================================================

@export var xp_base: int = 400
@export var xp_growth: float = 1.65


# ============================================================
# READY
# ============================================================

func _ready() -> void:
	add_to_group("xp_system")
	sincronizar_com_player_data()

	print("=================================")
	print("XP SYSTEM INICIADO (CENTRALIZADO)")
	print("LEVEL: %d / %d" % [level, ProgressionConfig.MAX_LEVEL])
	print("XP: %d / %d" % [xp, xp_necessario()])
	print("SKILL POINTS: %d" % PlayerData.nen_skill_points)
	print("=================================")


# ============================================================
# ADICIONAR XP (FUNÇÃO CENTRAL)
# ============================================================
#
# Toda fonte de XP chama esta função.
# O nome permanece "adicionar_xp" para compatibilidade
# com todos os locais que já a chamam.
#
# ============================================================

func adicionar_xp(
	valor: int,
	origem: String = "Desconhecida"
) -> void:

	if valor <= 0:
		return

	# Se já for nível máximo configurado (Cap 1000), mantém no topo
	if level >= ProgressionConfig.MAX_LEVEL:
		level = ProgressionConfig.MAX_LEVEL
		xp = xp_necessario()
		PlayerData.attributes["nivel"] = ProgressionConfig.MAX_LEVEL
		PlayerData.attributes["xp"] = xp
		xp_changed.emit(xp, xp_necessario())
		return

	var multiplicador = PlayerData.potencial * PlayerData.obter_multiplicador_dificuldade()["xp"]
	# Soft-cap por saga: impede subir de nível sem freio antes da curva narrativa
	var soft_mult: float = ProgressionConfig.obter_multiplicador_xp_soft_cap(level)
	var valor_final = int(valor * multiplicador * soft_mult)

	if valor_final <= 0:
		valor_final = 1

	xp += valor_final
	PlayerData.attributes["xp"] = xp

	if soft_mult < 1.0:
		print(
			"XP RECEBIDO: +",
			valor_final,
			" | Origem: ",
			origem,
			" | SoftCap x%.2f (saga teto %d)" % [soft_mult, ProgressionConfig.obter_soft_max_saga_atual()]
		)
	else:
		print(
			"XP RECEBIDO: +",
			valor_final,
			" | Origem: ",
			origem
		)

	_verificar_level_up()

	xp_changed.emit(
		xp,
		xp_necessario()
	)

	if EventBus != null and valor_final > 0:
		if origem.to_lower().contains("nen"):
			EventBus.nen_xp_gained.emit(valor_final, xp)
		else:
			EventBus.player_xp_gained.emit(valor_final)

	# Feedback flutuante de XP (Maple-style)
	if DamageNumberSystem != null and valor_final > 0:
		var player_node = get_parent()
		if player_node != null and player_node is Node2D:
			DamageNumberSystem.spawn_xp(player_node, valor_final)


# ============================================================
# XP DE QUEST (WRAPPER DE COMPATIBILIDADE)
# ============================================================

func receber_xp_quest(valor: int) -> void:

	if valor <= 0:
		return

	adicionar_xp(
		valor,
		"Quest"
	)


# ============================================================
# ADICIONAR XP NEN (WRAPPER DE COMPATIBILIDADE)
# ============================================================

func adicionar_xp_nen(valor: int) -> void:
	adicionar_xp(valor, "Nen")


# ============================================================
# LEVEL UP
# ============================================================

func _verificar_level_up() -> void:
	if level >= ProgressionConfig.MAX_LEVEL:
		level = ProgressionConfig.MAX_LEVEL
		xp = xp_necessario()
		PlayerData.attributes["nivel"] = ProgressionConfig.MAX_LEVEL
		PlayerData.attributes["xp"] = xp
		return

	while xp >= xp_necessario() and level < ProgressionConfig.MAX_LEVEL:
		xp -= xp_necessario()
		level += 1

		print("=================================")
		print("LEVEL UP!")
		print("NOVO LEVEL: %d / %d" % [level, ProgressionConfig.MAX_LEVEL])
		print("=================================")

		var antes := {
			"vida_max": int(PlayerData.attributes.get("vida_max", 0)),
			"forca": int(PlayerData.attributes.get("forca", 0)),
			"defesa": int(PlayerData.attributes.get("defesa", 0)),
			"velocidade": int(PlayerData.attributes.get("velocidade", 0)),
			"aura_max": int(PlayerData.attributes.get("aura_max", 0)),
		}

		# 1. Atributos base aumentados automaticamente pela pipeline determinística
		PlayerData.aplicar_nivel(
			level
		)
		PlayerData.attributes["xp"] = xp

		# 2. Concessão de Skill Point (+1 SP por nível)
		var sp_ganhos: int = ProgressionConfig.obter_skill_points_por_level(level)
		PlayerData.nen_skill_points += sp_ganhos
		skill_points_changed.emit(PlayerData.nen_skill_points)
		if EventBus != null and sp_ganhos > 0:
			EventBus.player_skill_points_gained.emit(sp_ganhos)

		print("+%d SKILL POINT (Total: %d)" % [sp_ganhos, PlayerData.nen_skill_points])

		level_up.emit(
			level
		)

		var deltas: PackedStringArray = []
		for k in ["vida_max", "forca", "defesa", "velocidade", "aura_max"]:
			var d: int = int(PlayerData.attributes.get(k, 0)) - int(antes.get(k, 0))
			if d != 0:
				deltas.append("%s %+d" % [str(k).replace("_", " "), d])
		if sp_ganhos > 0:
			deltas.append("SP +%d" % sp_ganhos)
		var delta_txt: String = ", ".join(deltas)

		# Juice de level-up (áudio + toast + pop visual)
		if AudioManager != null:
			AudioManager.tocar_sfx_tipo("level_up", 1.25)
		if EventBus != null:
			var toast_msg: String = "NÍVEL %d!" % level
			if not delta_txt.is_empty():
				toast_msg = "NÍVEL %d! %s" % [level, delta_txt]
			EventBus.emit_toast(toast_msg, Color(1.0, 0.85, 0.3))
		if DamageNumberSystem != null:
			var player_node = get_parent()
			if player_node != null and player_node is Node2D:
				DamageNumberSystem.spawn_texto(player_node, "LEVEL UP!", Color(1.0, 0.9, 0.35), 1.4, 1.2)
				if not delta_txt.is_empty():
					DamageNumberSystem.spawn_texto(player_node, delta_txt, Color(0.55, 1.0, 0.7), 1.1, 0.95)
		if EventBus != null and EventBus.has_method("emit_camera_shake"):
			EventBus.emit_camera_shake(0.35, 0.25)

		if level >= ProgressionConfig.MAX_LEVEL:
			level = ProgressionConfig.MAX_LEVEL
			xp = xp_necessario()
			PlayerData.attributes["nivel"] = ProgressionConfig.MAX_LEVEL
			PlayerData.attributes["xp"] = xp
			break


# ============================================================
# XP NECESSÁRIO
# ============================================================

func xp_necessario() -> int:
	return ProgressionConfig.calcular_xp_necessario(level)


# ============================================================
# UTILIDADES & SINCRONIZAÇÃO
# ============================================================

func sincronizar_com_player_data() -> void:
	var old_lvl = level
	level = clamp(int(PlayerData.attributes.get("nivel", 1)), ProgressionConfig.BASE_LEVEL, ProgressionConfig.MAX_LEVEL)
	xp = int(PlayerData.attributes.get("xp", 0))
	if level >= ProgressionConfig.MAX_LEVEL:
		level = ProgressionConfig.MAX_LEVEL
		xp = xp_necessario()
		PlayerData.attributes["nivel"] = ProgressionConfig.MAX_LEVEL
		PlayerData.attributes["xp"] = xp

	if old_lvl != level:
		level_up.emit(level)
	xp_changed.emit(xp, xp_necessario())


static func obter_xp_acumulado_para_nivel(target_level: int, _base_val: int = 300, _growth_val: float = 1.6) -> int:
	return ProgressionConfig.calcular_xp_acumulado(target_level)


func obter_xp() -> int:
	return xp


func obter_level() -> int:
	return level


func obter_xp_necessario() -> int:
	return xp_necessario()
