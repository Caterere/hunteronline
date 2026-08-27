class_name XPSystem
extends Node


signal xp_changed(current_xp: int, required_xp: int)
signal level_up(new_level: int)


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
	print("XP SYSTEM INICIADO")
	print("LEVEL: ", level)
	print(
		"XP: ",
		xp,
		"/",
		xp_necessario()
	)
	print("=================================")


# ============================================================
# ADICIONAR XP
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
# XP DE QUEST
# ============================================================

func receber_xp_quest(valor: int) -> void:

	if valor <= 0:
		return


	adicionar_xp(
		valor,
		"Quest"
	)


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

		PlayerData.aplicar_nivel(
			level
		)
		PlayerData.attributes["xp"] = xp

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
# UTILIDADES
# ============================================================

func obter_xp() -> int:

	return xp


func obter_level() -> int:

	return level


func obter_xp_necessario() -> int:

	return xp_necessario()
