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

@export var xp_base: int = 300
@export var xp_growth: float = 1.6


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
	var valor_final = int(valor * multiplicador)

	if valor_final <= 0:
		valor_final = 1

	xp += valor_final
	PlayerData.attributes["xp"] = xp

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

		# 1. Atributos base aumentados automaticamente pela pipeline determinística
		PlayerData.aplicar_nivel(
			level
		)
		PlayerData.attributes["xp"] = xp

		# 2. Concessão de Skill Point (+1 SP por nível)
		var sp_ganhos: int = ProgressionConfig.obter_skill_points_por_level(level)
		PlayerData.nen_skill_points += sp_ganhos
		skill_points_changed.emit(PlayerData.nen_skill_points)

		print("+%d SKILL POINT (Total: %d)" % [sp_ganhos, PlayerData.nen_skill_points])

		level_up.emit(
			level
		)

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

