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
	# Sincronizar nível e XP atuais do PlayerData
	level = int(PlayerData.attributes.get("nivel", 1))
	xp = int(PlayerData.attributes.get("xp", 0))
	if level >= 100:
		level = 100
		xp = xp_necessario()

	print("=================================")
	print("NEN XP SYSTEM INICIADO")
	print("LEVEL: ", level)
	print(
		"NEN XP: ",
		xp,
		"/",
		xp_necessario()
	)
	print("SKILL POINTS: ", PlayerData.nen_skill_points)
	print("=================================")


# ============================================================
# ADICIONAR XP (FUNÇÃO CENTRAL)
# ============================================================
#
# Toda fonte de XP chama esta função.
# O nome permanece "adicionar_xp" para compatibilidade
# com todos os 14+ locais que já a chamam.
#
# ============================================================

func adicionar_xp(
	valor: int,
	origem: String = "Desconhecida"
) -> void:

	if valor <= 0:
		return

	# Se já for nível 100 (Cap Máximo), não reseta nem ultrapassa
	if level >= 100:
		level = 100
		xp = xp_necessario()
		PlayerData.attributes["nivel"] = 100
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
		"NEN XP RECEBIDO: +",
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
#
# Para compatibilidade com código que chamava
# NenSystem.adicionar_xp_nen(), o NenSystem agora
# redireciona para este método.
#
# ============================================================

func adicionar_xp_nen(valor: int) -> void:
	adicionar_xp(valor, "Nen")


# ============================================================
# LEVEL UP
# ============================================================

func _verificar_level_up() -> void:
	if level >= 100:
		level = 100
		xp = xp_necessario()
		PlayerData.attributes["nivel"] = 100
		PlayerData.attributes["xp"] = xp
		return

	while xp >= xp_necessario():
		xp -= xp_necessario()
		level += 1

		print("=================================")
		print("LEVEL UP!")
		print("NOVO LEVEL: ", level)
		print("=================================")

		# 1. Atributos base
		PlayerData.aplicar_nivel(
			level
		)
		PlayerData.attributes["xp"] = xp

		# 2. Nen Level (aura máxima)
		PlayerData.attributes["nivel_nen"] = level
		var nova_aura_maxima: float = float(level) * 100.0
		PlayerData.attributes["aura_max"] = nova_aura_maxima
		PlayerData.attributes["aura"] = nova_aura_maxima

		# 3. +1 Nen Skill Point
		PlayerData.nen_skill_points += 1
		skill_points_changed.emit(PlayerData.nen_skill_points)

		print("+1 NEN SKILL POINT (Total: ", PlayerData.nen_skill_points, ")")

		level_up.emit(
			level
		)

		if level >= 100:
			level = 100
			xp = xp_necessario()
			PlayerData.attributes["nivel"] = 100
			PlayerData.attributes["xp"] = xp
			break


# ============================================================
# XP NECESSÁRIO
# ============================================================

func xp_necessario() -> int:

	return int(
		xp_base
		* pow(
			level,
			xp_growth
		)
	)


# ============================================================
# UTILIDADES & SINCRONIZAÇÃO
# ============================================================

func sincronizar_com_player_data() -> void:
	var old_lvl = level
	level = int(PlayerData.attributes.get("nivel", 1))
	xp = int(PlayerData.attributes.get("xp", 0))
	if level >= 100:
		level = 100
		xp = xp_necessario()
		PlayerData.attributes["nivel"] = 100
		PlayerData.attributes["xp"] = xp

	if old_lvl != level:
		level_up.emit(level)
	xp_changed.emit(xp, xp_necessario())


static func obter_xp_acumulado_para_nivel(target_level: int, base_val: int = 300, growth_val: float = 1.6) -> int:
	if target_level <= 1:
		return 0
	var total: int = 0
	for l in range(1, target_level):
		total += int(base_val * pow(l, growth_val))
	return total


func obter_xp() -> int:
	return xp


func obter_level() -> int:
	return level


func obter_xp_necessario() -> int:
	return xp_necessario()
