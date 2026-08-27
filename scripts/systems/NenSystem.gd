class_name NenSystem
extends Node

# ============================================================
# HUNTER ONLINE - NEN SYSTEM
# ============================================================
#
# SISTEMAS:
#
# 1. NEN LEVEL GERAL
# 2. NEN XP GERAL
# 3. AURA
# 4. TÉCNICAS INDIVIDUAIS
# 5. XP DAS TÉCNICAS
# 6. TEN
# 7. REN
# 8. GYO
# 9. KO
#
# ============================================================
# PROGRESSÃO
# ============================================================
#
# LEVEL NORMAL:
#
# XPSystem
# ↓
# Level normal
# ↓
# Vida / Força / Defesa / Velocidade
#
#
# NEN LEVEL:
#
# Missões / Inimigos
# ↓
# Nen XP
# ↓
# Nen Level
# ↓
# Aura Máxima
#
#
# TÉCNICAS:
#
# Tempo de uso
# ↓
# XP individual
# ↓
# Level individual
#
# ============================================================
#
# IMPORTANTE:
#
# O PlayerData é a fonte oficial dos dados de:
#
# - nivel_nen
# - xp_nen
# - aura
# - aura_max
#
# O NenSystem apenas controla a lógica.
#
# ============================================================


# ============================================================
# TÉCNICAS
# ============================================================

enum Tecnica {
	TEN,
	REN,
	ZETSU,
	GYO,
	SHU,
	KO,
	EN,
	KEN,
	RYU
}

signal tecnica_ativada(tecnica: Tecnica)
signal tecnica_desativada(tecnica: Tecnica)

func esta_em_gyo() -> bool:
	return tecnica_ativa(Tecnica.GYO)

func esta_em_zetsu() -> bool:
	return tecnica_ativa(Tecnica.ZETSU)

func esta_em_ren() -> bool:
	return tecnica_ativa(Tecnica.REN)

func esta_em_ten() -> bool:
	return tecnica_ativa(Tecnica.TEN)

func esta_em_ko() -> bool:
	return tecnica_ativa(Tecnica.KO)

func esta_em_en() -> bool:
	return tecnica_ativa(Tecnica.EN)

# Aliases canônicos de utilidade
func gyo_ativo() -> bool: return esta_em_gyo()
func ko_ativo() -> bool: return esta_em_ko()
func zetsu_ativo() -> bool: return esta_em_zetsu()
func en_ativo() -> bool: return esta_em_en()
func ten_ativo() -> bool: return esta_em_ten()
func ren_ativo() -> bool: return esta_em_ren()





# ============================================================
# REFERÊNCIA AO PLAYER
# ============================================================

var owner_body: CharacterBody2D = null


# ============================================================
# CONFIGURAÇÃO DO NEN LEVEL
# ============================================================

@export_category("Nen Level")

# XP necessário para o primeiro nível.
#
# Nen Lv.0 → Lv.1 = 100 XP
#
@export var nen_xp_base: int = 100


# Crescimento da XP.
#
# Fórmula:
#
# XP = base × (level + 1)²
#
# Exemplos:
#
# Lv.0 → Lv.1 = 100
# Lv.1 → Lv.2 = 400
# Lv.2 → Lv.3 = 900
# Lv.3 → Lv.4 = 1600
#
@export var nen_xp_growth: float = 2.0


# Aura máxima ganha por nível.
#
# Lv.0 = 0
# Lv.1 = 100
# Lv.2 = 200
# Lv.3 = 300
#
@export var aura_por_nen_level: float = 100.0


# ============================================================
# CONFIGURAÇÃO GERAL
# ============================================================

@export_category("Nen")

@export var aura_regen_por_segundo: float = 5.0


# ============================================================
# XP DAS TÉCNICAS
# ============================================================

@export_category("Technique XP")

# XP necessário para:
#
# Lv.0 → Lv.1 = 100
# Lv.1 → Lv.2 = 200
# Lv.2 → Lv.3 = 300
#
@export var xp_por_nivel: int = 100


# ============================================================
# TEN
# ============================================================

@export_category("TEN")

# Lv.1 = 5% de redução
@export var ten_reducao_nivel_1: float = 0.05

# Lv.1 = 1% da Aura Máxima por segundo
@export var ten_custo_percentual: float = 0.01


# ============================================================
# REN
# ============================================================

@export_category("REN")

# Lv.1 = +10% de alcance
@export var ren_alcance_nivel_1: float = 0.10

# Lv.1 = 2% da Aura Máxima por segundo
@export var ren_custo_percentual: float = 0.02


# ============================================================
# GYO
# ============================================================

@export_category("GYO")

# Lv.1 = +5% na duração efetiva da esquiva
@export var gyo_esquiva_nivel_1: float = 0.05

# Lv.1 = 1% da Aura Máxima por segundo
@export var gyo_custo_percentual: float = 0.01


# ============================================================
# KO
# ============================================================

@export_category("KO")

# Lv.1 = +25% de dano
@export var ko_dano_nivel_1: float = 0.25

# Lv.1 = 3% da Aura Máxima por ataque
@export var ko_custo_percentual: float = 0.03


# ============================================================
# DADOS DAS TÉCNICAS
# ============================================================

var tecnicas: Dictionary = {

	Tecnica.TEN: {
		"nivel": 0,
		"xp": 0,
		"ativo": false,
		"desbloqueada": false
	},

	Tecnica.REN: {
		"nivel": 0,
		"xp": 0,
		"ativo": false,
		"desbloqueada": false
	},

	Tecnica.ZETSU: {
		"nivel": 0,
		"xp": 0,
		"ativo": false,
		"desbloqueada": false
	},

	Tecnica.GYO: {
		"nivel": 0,
		"xp": 0,
		"ativo": false,
		"desbloqueada": false
	},

	Tecnica.SHU: {
		"nivel": 0,
		"xp": 0,
		"ativo": false,
		"desbloqueada": false
	},

	Tecnica.KO: {
		"nivel": 0,
		"xp": 0,
		"ativo": false,
		"desbloqueada": false
	},

	Tecnica.EN: {
		"nivel": 0,
		"xp": 0,
		"ativo": false,
		"desbloqueada": false
	},

	Tecnica.KEN: {
		"nivel": 0,
		"xp": 0,
		"ativo": false,
		"desbloqueada": false
	},

	Tecnica.RYU: {
		"nivel": 0,
		"xp": 0,
		"ativo": false,
		"desbloqueada": false
	}
}



# ============================================================
# TIMER DE XP DAS TÉCNICAS
# ============================================================

var xp_timer: float = 0.0


# ============================================================
# CONTROLE DO INPUT DO KO
# ============================================================

var _ko_input_bloqueado: bool = false


# ============================================================
# READY
# ============================================================

func _ready() -> void:

	# --------------------------------------------------------
	# Garante que os dados do PlayerData estejam corretos.
	# --------------------------------------------------------

	sincronizar_nen_com_player_data()


	print("=================================")
	print("NEN SYSTEM INICIADO")
	print("NEN LEVEL: ", obter_nen_level())
	print(
		"NEN XP: ",
		obter_nen_xp(),
		"/",
		obter_nen_xp_necessario()
	)
	print(
		"AURA: ",
		obter_aura(),
		"/",
		obter_aura_maxima()
	)
	print("=================================")


# ============================================================
# SETUP
# ============================================================

func setup(body: CharacterBody2D) -> void:

	owner_body = body


# ============================================================
# PROCESS
# ============================================================

func _process(delta: float) -> void:

	_processar_input()

	_processar_tecnicas(delta)

	_processar_xp(delta)

	regenerar_aura(delta)


# ============================================================
# SINCRONIZAR NEN COM PLAYER DATA
# ============================================================
#
# PlayerData é a fonte oficial.
#
# Essa função garante que a Aura Máxima esteja de acordo
# com o Nen Level.
#
# ============================================================

func sincronizar_nen_com_player_data() -> void:

	var nivel_nen: int = int(
		PlayerData.attributes["nivel_nen"]
	)


	var aura_maxima_correta: float = (
		float(nivel_nen)
		*
		aura_por_nen_level
	)


	PlayerData.attributes["aura_max"] = (
		aura_maxima_correta
	)


	# --------------------------------------------------------
	# Se ainda não tiver Aura, mantém em 0.
	#
	# Se já tiver Aura, garante que não ultrapasse o máximo.
	# --------------------------------------------------------

	var aura_atual: float = float(
		PlayerData.attributes["aura"]
	)


	aura_atual = clamp(
		aura_atual,
		0.0,
		aura_maxima_correta
	)


	PlayerData.attributes["aura"] = aura_atual

	# --------------------------------------------------------
	# Sincronizar Níveis e Desbloqueios das Técnicas (Ten, Ren, Gyo, Ko, etc.)
	# --------------------------------------------------------
	if PlayerData.tecnicas_nen is Dictionary and not PlayerData.tecnicas_nen.is_empty():
		for tec_str in PlayerData.tecnicas_nen.keys():
			var tec_enum = _string_para_tecnica(StringName(tec_str.to_lower()))
			if tec_enum != null:
				var info = PlayerData.tecnicas_nen[tec_str]
				if info is Dictionary:
					tecnicas[tec_enum]["nivel"] = int(info.get("nivel", 0))
					tecnicas[tec_enum]["xp"] = int(info.get("xp", 0))
					tecnicas[tec_enum]["desbloqueada"] = bool(info.get("desbloqueada", true))
				elif info is int or info is float:
					tecnicas[tec_enum]["nivel"] = int(info)
					tecnicas[tec_enum]["desbloqueada"] = true


# ============================================================
# INPUT
# ============================================================
#
# TEN  → segurar T
# REN  → segurar R
# GYO  → segurar G
# KO   → apertar K
#
# ============================================================

func _processar_input() -> void:
	if owner_body == null or not PlayerData.despertou_nen:
		return


	# ========================================================
	# TEN
	# ========================================================

	if Input.is_key_pressed(KEY_T):

		if not tecnica_ativa(Tecnica.TEN):

			ativar_tecnica(
				Tecnica.TEN
			)

	else:

		if tecnica_ativa(Tecnica.TEN):

			desativar_tecnica(
				Tecnica.TEN
			)


	# ========================================================
	# REN
	# ========================================================

	if Input.is_key_pressed(KEY_R):

		if not tecnica_ativa(Tecnica.REN):

			ativar_tecnica(
				Tecnica.REN
			)

	else:

		if tecnica_ativa(Tecnica.REN):

			desativar_tecnica(
				Tecnica.REN
			)


	# ========================================================
	# GYO
	# ========================================================

	if Input.is_key_pressed(KEY_G):

		if not tecnica_ativa(Tecnica.GYO):

			ativar_tecnica(
				Tecnica.GYO
			)

	else:

		if tecnica_ativa(Tecnica.GYO):

			desativar_tecnica(
				Tecnica.GYO
			)


	# ========================================================
	# KO
	# ========================================================

	if Input.is_key_pressed(KEY_K):

		if not _ko_input_bloqueado:

			_ko_input_bloqueado = true

			toggle_ko()

	else:

		_ko_input_bloqueado = false


	# ========================================================
	# EN (Radar de Aura - Tecla E ou Menu)
	# ========================================================

	if Input.is_key_pressed(KEY_E) and not get_tree().paused:

		if not tecnica_ativa(Tecnica.EN):

			ativar_tecnica(Tecnica.EN)

	else:

		if tecnica_ativa(Tecnica.EN):

			desativar_tecnica(Tecnica.EN)


	# ========================================================
	# SHU (Tecla 6)
	# ========================================================

	if Input.is_key_pressed(KEY_6):

		if not tecnica_ativa(Tecnica.SHU):

			ativar_tecnica(Tecnica.SHU)

	# ========================================================
	# KEN (Tecla 7)
	# ========================================================

	if Input.is_key_pressed(KEY_7):

		if not tecnica_ativa(Tecnica.KEN):

			ativar_tecnica(Tecnica.KEN)

	# ========================================================
	# RYU (Tecla 8 para Ativar, TAB para Alternar Módulo)
	# ========================================================

	if Input.is_key_pressed(KEY_8):

		if not tecnica_ativa(Tecnica.RYU):

			ativar_tecnica(Tecnica.RYU)

	if Input.is_action_just_pressed("ui_focus_next") or Input.is_key_pressed(KEY_TAB):

		if tecnica_ativa(Tecnica.RYU):

			alternar_modulo_ryu()




# ============================================================
# PROCESSAR TÉCNICAS
# ============================================================

func _processar_tecnicas(delta: float) -> void:

	var tecnicas_continuas: Array[Tecnica] = [
		Tecnica.TEN,
		Tecnica.REN,
		Tecnica.GYO
	]


	for tecnica in tecnicas_continuas:

		if not tecnica_ativa(tecnica):
			continue


		var custo: float = obter_custo_por_segundo(
			tecnica
		)


		var gasto: float = custo * delta


		if not gastar_aura_float(gasto):

			desativar_tecnica(
				tecnica
			)


# ============================================================
# XP PASSIVO DAS TÉCNICAS
# ============================================================
#
# IMPORTANTE:
#
# O tempo de uso das técnicas NÃO dá Nen XP geral.
#
# O tempo de uso dá apenas XP para a própria técnica.
#
# Exemplo:
#
# Segurar TEN:
#
# TEN +1 XP
#
# NÃO:
#
# Nen +1 XP
#
# ============================================================

func _processar_xp(delta: float) -> void:
	if not PlayerData.despertou_nen:
		return

	xp_timer += delta


	if xp_timer < 1.0:
		return


	xp_timer -= 1.0


	for tecnica in tecnicas:

		if tecnica_ativa(tecnica):

			adicionar_xp_tecnica(
				tecnica,
				1
			)


# ============================================================
# NEN LEVEL
# ============================================================

func obter_nen_level() -> int:

	return int(
		PlayerData.attributes["nivel_nen"]
	)


# ============================================================
# NEN XP
# ============================================================

func obter_nen_xp() -> int:

	return int(
		PlayerData.attributes["xp_nen"]
	)


# ============================================================
# XP NECESSÁRIO PARA NEN LEVEL
# ============================================================
#
# Fórmula:
#
# XP = base × (level + 1)^growth
#
# Lv.0 → Lv.1 = 100
# Lv.1 → Lv.2 = 400
# Lv.2 → Lv.3 = 900
# Lv.3 → Lv.4 = 1600
#
# ============================================================

func obter_nen_xp_necessario() -> int:

	return int(
		nen_xp_base
		*
		pow(
			obter_nen_level() + 1,
			nen_xp_growth
		)
	)


# ============================================================
# ADICIONAR XP DE NEN
# ============================================================
#
# USADO POR:
#
# - Inimigos
# - NPCs
# - Missões
# - Eventos
# - Outras fontes de progressão
#
# ============================================================

func adicionar_xp_nen(
	valor: int
) -> void:

	if valor <= 0 or not PlayerData.despertou_nen:
		return

	if obter_nen_level() >= 100:
		PlayerData.attributes["nivel_nen"] = 100
		PlayerData.attributes["xp_nen"] = obter_nen_xp_necessario()
		return

	var multiplicador = PlayerData.potencial * PlayerData.obter_multiplicador_dificuldade()["xp"]
	var valor_final = int(valor * multiplicador)
	
	if valor_final <= 0:
		valor_final = 1

	var xp_atual: int = obter_nen_xp()

	xp_atual += valor_final


	PlayerData.attributes["xp_nen"] = xp_atual


	print(
		"NEN XP RECEBIDO: +",
		valor_final,
		" | ",
		obter_nen_xp(),
		"/",
		obter_nen_xp_necessario()
	)


	_verificar_nen_level_up()


# ============================================================
# VERIFICAR LEVEL UP DO NEN
# ============================================================

func _verificar_nen_level_up() -> void:
	if obter_nen_level() >= 100:
		PlayerData.attributes["nivel_nen"] = 100
		PlayerData.attributes["xp_nen"] = obter_nen_xp_necessario()
		return

	while (
		obter_nen_xp()
		>=
		obter_nen_xp_necessario()
	):

		var xp_necessario_atual: int = (
			obter_nen_xp_necessario()
		)


		var xp_restante: int = (
			obter_nen_xp()
			-
			xp_necessario_atual
		)


		PlayerData.attributes["xp_nen"] = (
			xp_restante
		)


		var novo_nivel: int = (
			obter_nen_level()
			+
			1
		)

		if novo_nivel >= 100:
			novo_nivel = 100
			PlayerData.attributes["nivel_nen"] = 100
			PlayerData.attributes["xp_nen"] = obter_nen_xp_necessario()
			break

		PlayerData.attributes["nivel_nen"] = (
			novo_nivel
		)


		# ----------------------------------------------------
		# AURA MÁXIMA
		# ----------------------------------------------------

		var nova_aura_maxima: float = (
			float(novo_nivel)
			*
			aura_por_nen_level
		)


		PlayerData.attributes["aura_max"] = (
			nova_aura_maxima
		)


		# ----------------------------------------------------
		# Recupera a Aura para a nova capacidade.
		# ----------------------------------------------------

		PlayerData.attributes["aura"] = (
			nova_aura_maxima
		)


		print("=================================")
		print("NEN LEVEL UP!")
		print(
			"NOVO NEN LEVEL: ",
			novo_nivel
		)
		print(
			"NEN XP: ",
			obter_nen_xp(),
			"/",
			obter_nen_xp_necessario()
		)
		print(
			"NOVA AURA MÁXIMA: ",
			nova_aura_maxima
		)
		print("=================================")


# ============================================================
# ATIVAR TÉCNICA
# ============================================================

func ativar_tecnica(
	tecnica: Tecnica
) -> bool:

	# --------------------------------------------------------
	# Precisa ter Nen despertado.
	# --------------------------------------------------------

	if obter_aura_maxima() <= 0.0:

		print(
			"Personagem ainda não despertou Nen."
		)

		return false


	# --------------------------------------------------------
	# Precisa ter Aura.
	# --------------------------------------------------------

	if obter_aura() <= 0.0:

		print(
			"Aura insuficiente."
		)

		return false


	# --------------------------------------------------------
	# Verificar bloqueio por Juramentos ou Zetsu Forçado de Hatsu
	# --------------------------------------------------------
	var hatsu_sys = owner_body.get_node_or_null("HatsuSystem") if owner_body != null else (get_parent().get_node_or_null("HatsuSystem") if get_parent() != null else null)
	if hatsu_sys != null and tecnica != Tecnica.ZETSU:
		if hatsu_sys.has_method("zetsu_forcado_ativo") and hatsu_sys.zetsu_forcado_ativo():
			print("Nen bloqueado por estado forçado de Zetsu pós-uso!")
			return false
		if hatsu_sys.has_method("nen_bloqueado") and hatsu_sys.nen_bloqueado():
			print("Nen bloqueado por sobreaquecimento de juramento!")
			return false


	# --------------------------------------------------------
	# Já está ativa.
	# --------------------------------------------------------

	if tecnica_ativa(tecnica):
		return true

	tecnicas[tecnica]["ativo"] = true
	tecnica_ativada.emit(tecnica)

	if tecnica == Tecnica.GYO:
		_notificar_nos_gyo(true)

	print(
		"NEN ATIVADO: ",
		nome_tecnica(tecnica)
	)

	return true


# ============================================================
# DESATIVAR TÉCNICA
# ============================================================

func desativar_tecnica(
	tecnica: Tecnica
) -> void:
	if not tecnicas.has(tecnica):
		return

	if not tecnica_ativa(tecnica):
		return

	tecnicas[tecnica]["ativo"] = false
	tecnica_desativada.emit(tecnica)

	if tecnica == Tecnica.GYO:
		_notificar_nos_gyo(false)

	print(
		"NEN DESATIVADO: ",
		nome_tecnica(tecnica)
	)


# ============================================================
# DESATIVAR TODAS
# ============================================================

func desativar_todas() -> void:
	desativar_todas_tecnicas()

func desativar_todas_tecnicas() -> void:
	var tinha_gyo = tecnica_ativa(Tecnica.GYO)

	for tecnica in tecnicas:
		if tecnicas[tecnica]["ativo"]:
			tecnicas[tecnica]["ativo"] = false
			tecnica_desativada.emit(tecnica)

	if tinha_gyo:
		_notificar_nos_gyo(false)


func _notificar_nos_gyo(ativo: bool) -> void:
	var tree = get_tree()
	if tree != null:
		var nos = tree.get_nodes_in_group("gyo_inspectable")
		for no in nos:
			if no.has_method("atualizar_estado_gyo"):
				no.atualizar_estado_gyo(ativo)



# ============================================================
# KO TOGGLE
# ============================================================

func toggle_ko() -> void:

	if tecnica_ativa(Tecnica.KO):

		desativar_tecnica(
			Tecnica.KO
		)

	else:

		ativar_tecnica(
			Tecnica.KO
		)


# ============================================================
# VERIFICAR TÉCNICA
# ============================================================

func tecnica_ativa(
	tecnica: Tecnica
) -> bool:

	return bool(
		tecnicas[tecnica]["ativo"]
	)


# ============================================================
# AURA ATUAL
# ============================================================

func obter_aura() -> float:

	return float(
		PlayerData.attributes["aura"]
	)


# ============================================================
# AURA MÁXIMA
# ============================================================

func obter_aura_maxima() -> float:

	return float(
		PlayerData.attributes["aura_max"]
	)


# ============================================================
# GASTAR AURA
# ============================================================

func gastar_aura(
	valor: float
) -> bool:

	return gastar_aura_float(
		valor
	)


# ============================================================
# GASTAR AURA FLOAT
# ============================================================

func gastar_aura_float(
	valor: float
) -> bool:

	if valor <= 0.0:
		return true


	var aura: float = obter_aura()


	if aura < valor:

		PlayerData.attributes["aura"] = 0.0

		desativar_todas_tecnicas()

		print(
			"AURA ESGOTADA!"
		)

		return false


	aura -= valor


	aura = max(
		aura,
		0.0
	)


	PlayerData.attributes["aura"] = aura


	if aura <= 0.0:

		PlayerData.attributes["aura"] = 0.0

		desativar_todas_tecnicas()


	return true


# ============================================================
# RECUPERAR AURA
# ============================================================

func recuperar_aura(
	valor: float
) -> void:

	if valor <= 0.0:
		return


	var aura: float = obter_aura()

	var aura_maxima: float = obter_aura_maxima()


	aura += valor


	aura = min(
		aura,
		aura_maxima
	)


	PlayerData.attributes["aura"] = aura


# ============================================================
# REGENERAÇÃO DE AURA
# ============================================================

func regenerar_aura(
	delta: float
) -> void:

	if obter_aura_maxima() <= 0.0:
		return

	if obter_aura() >= obter_aura_maxima():
		return

	# Se Zetsu está ativo, regeneração é acelerada (10%/s)
	if tecnica_ativa(Tecnica.ZETSU):
		recuperar_aura(obter_aura_maxima() * 0.10 * delta)
		# Regenerar HP levemente durante Zetsu
		var hp_atual = float(PlayerData.attributes.get("vida", 100))
		var hp_max = float(PlayerData.attributes.get("vida_max", 100))
		if hp_atual < hp_max:
			PlayerData.attributes["vida"] = min(hp_max, hp_atual + (hp_max * 0.02 * delta))
		return

	var tecnica_drenando: bool = false
	if tecnica_ativa(Tecnica.TEN) or tecnica_ativa(Tecnica.REN) or tecnica_ativa(Tecnica.GYO):
		tecnica_drenando = true

	if tecnica_drenando:
		return

	# Taxa base: 5% fora de combate (ou 3% se houver inimigo próximo)
	var taxa_regen: float = 0.05
	var inimigos = get_tree().get_nodes_in_group("enemy")
	if not inimigos.is_empty():
		taxa_regen = 0.03

	recuperar_aura(obter_aura_maxima() * taxa_regen * delta)


# ============================================================
# CUSTO POR SEGUNDO
# ============================================================

func obter_custo_por_segundo(
	tecnica: Tecnica
) -> float:

	var nivel: int = obter_nivel_tecnica(
		tecnica
	)


	var reducao: float = 1.0 / (
		1.0
		+
		(float(nivel) * 0.15)
	)


	var percentual: float = 0.0


	match tecnica:

		Tecnica.TEN:
			percentual = ten_custo_percentual

		Tecnica.REN:
			percentual = ren_custo_percentual

		Tecnica.GYO:
			percentual = gyo_custo_percentual

		_:
			percentual = 0.0


	return (
		obter_aura_maxima()
		*
		percentual
		*
		reducao
	)


# ============================================================
# DANO DO NEN
# ============================================================

func calcular_dano(
	forca: float
) -> float:

	if obter_aura() <= 0.0:
		return 0.0


	if obter_aura_maxima() <= 0.0:
		return 0.0


	var poder_nen: float = obter_poder_nen()


	var dano: float = (
		forca
		*
		poder_nen
	)


	if tecnica_ativa(Tecnica.KO):

		dano *= (
			1.0
			+
			obter_bonus_ko()
		)


	return dano


# ============================================================
# PODER DO NEN
# ============================================================

func obter_poder_nen() -> float:

	if obter_aura() <= 0.0:
		return 0.0


	var aura_maxima: float = obter_aura_maxima()


	if aura_maxima <= 0.0:
		return 0.0


	return (
		aura_maxima / 100.0
	)


# ============================================================
# KO NO ATAQUE
# ============================================================

func aplicar_ko_no_ataque() -> float:

	if not tecnica_ativa(Tecnica.KO):

		return 1.0


	var nivel: int = obter_nivel_tecnica(
		Tecnica.KO
	)


	var custo_percentual: float = (
		ko_custo_percentual
		/
		(
			1.0
			+
			(
				float(nivel)
				*
				0.15
			)
		)
	)


	var custo: float = (
		obter_aura_maxima()
		*
		custo_percentual
	)


	if not gastar_aura_float(custo):

		desativar_tecnica(
			Tecnica.KO
		)

		return 1.0


	# --------------------------------------------------------
	# XP DA TÉCNICA
	# --------------------------------------------------------

	adicionar_xp_tecnica(
		Tecnica.KO,
		2
	)


	return (
		1.0
		+
		obter_bonus_ko()
	)


# ============================================================
# BÔNUS KO
# ============================================================

func obter_bonus_ko() -> float:

	var nivel: int = obter_nivel_tecnica(
		Tecnica.KO
	)


	return (
		ko_dano_nivel_1
		*
		float(nivel)
	)


# ============================================================
# TEN
# ============================================================

func aplicar_ten_no_dano(
	dano: float
) -> float:

	if not tecnica_ativa(Tecnica.TEN):

		return dano


	var nivel: int = obter_nivel_tecnica(
		Tecnica.TEN
	)


	var reducao: float = (
		ten_reducao_nivel_1
		*
		float(nivel)
	)


	reducao = min(
		reducao,
		0.80
	)


	return (
		dano
		*
		(
			1.0
			-
			reducao
		)
	)


# ============================================================
# COMPATIBILIDADE
# ============================================================

func calcular_dano_recebido(
	dano: float
) -> int:

	return max(
		int(
			round(
				aplicar_ten_no_dano(
					dano
				)
			)
		),
		0
	)


# ============================================================
# REN
# ============================================================

func obter_bonus_alcance_ren() -> float:

	if not tecnica_ativa(Tecnica.REN):

		return 0.0


	var nivel: int = obter_nivel_tecnica(
		Tecnica.REN
	)


	return (
		ren_alcance_nivel_1
		*
		float(nivel)
	)


# ============================================================
# APLICAR REN NO ALCANCE
# ============================================================

func aplicar_ren_no_alcance(
	alcance: float
) -> float:

	return (
		alcance
		*
		(
			1.0
			+
			obter_bonus_alcance_ren()
		)
	)


# ============================================================
# GYO
# ============================================================

func obter_bonus_esquiva_gyo() -> float:

	if not tecnica_ativa(Tecnica.GYO):

		return 0.0


	var nivel: int = obter_nivel_tecnica(
		Tecnica.GYO
	)


	return (
		gyo_esquiva_nivel_1
		*
		float(nivel)
	)


# ============================================================
# XP DAS TÉCNICAS
# ============================================================

func adicionar_xp_tecnica(
	tecnica: Tecnica,
	valor: int
) -> void:

	if valor <= 0:
		return


	var dados: Dictionary = tecnicas[tecnica]


	var xp_atual: int = int(
		dados["xp"]
	)


	xp_atual += valor


	dados["xp"] = xp_atual


	var xp_necessario: int = (
		obter_xp_necessario_tecnica(
			tecnica
		)
	)


	while xp_atual >= xp_necessario:

		xp_atual -= xp_necessario


		var nivel_atual: int = int(
			dados["nivel"]
		)


		nivel_atual += 1


		dados["nivel"] = nivel_atual
		var nome_str := nome_tecnica(tecnica).to_lower()
		PlayerData.tecnicas_nen[nome_str] = {
			"nivel": nivel_atual,
			"xp": xp_atual,
			"desbloqueada": true
		}

		print(
			"NEN TECHNIQUE LEVEL UP: ",
			nome_tecnica(tecnica),
			" → Lv.",
			nivel_atual
		)

		xp_necessario = (
			obter_xp_necessario_tecnica(
				tecnica
			)
		)

	dados["xp"] = xp_atual
	var nome_final_str := nome_tecnica(tecnica).to_lower()
	if PlayerData.tecnicas_nen.has(nome_final_str):
		PlayerData.tecnicas_nen[nome_final_str]["xp"] = xp_atual


# ============================================================
# XP NECESSÁRIO DA TÉCNICA
# ============================================================

func obter_xp_necessario_tecnica(
	tecnica: Tecnica
) -> int:

	var nivel: int = obter_nivel_tecnica(
		tecnica
	)


	return (
		xp_por_nivel
		*
		(nivel + 1)
	)


# ============================================================
# NÍVEL DA TÉCNICA
# ============================================================

func obter_nivel_tecnica(
	tecnica: Tecnica
) -> int:

	var dados: Dictionary = tecnicas[tecnica]


	return int(
		dados["nivel"]
	)


# ============================================================
# XP DA TÉCNICA
# ============================================================

func obter_xp_tecnica(
	tecnica: Tecnica
) -> int:

	var dados: Dictionary = tecnicas[tecnica]


	return int(
		dados["xp"]
	)


# ============================================================
# NOME DA TÉCNICA
# ============================================================

func nome_tecnica(
	tecnica: Tecnica
) -> String:

	match tecnica:

		Tecnica.TEN:
			return "TEN"

		Tecnica.REN:
			return "REN"

		Tecnica.ZETSU:
			return "ZETSU"

		Tecnica.GYO:
			return "GYO"

		Tecnica.SHU:
			return "SHU"

		Tecnica.KO:
			return "KO"

		Tecnica.EN:
			return "EN"

		Tecnica.KEN:
			return "KEN"

		Tecnica.RYU:
			return "RYU"



	return "DESCONHECIDA"


# ============================================================
# DESBLOQUEAR TÉCNICA
# ============================================================

func desbloquear_tecnica(
	tecnica_id: StringName
) -> void:

	var tecnica_enum = _string_para_tecnica(tecnica_id)

	if tecnica_enum == null:

		push_error(
			"Técnica desconhecida: ",
			tecnica_id
		)

		return

	if tecnicas[tecnica_enum]["desbloqueada"]:

		print(
			"[NenSystem] Técnica já desbloqueada: ",
			tecnica_id
		)

		return

	tecnicas[tecnica_enum]["desbloqueada"] = true

	print(
		"[NenSystem] Técnica desbloqueada: ",
		tecnica_id
	)


# ============================================================
# VERIFICAR SE TÉCNICA ESTÁ DESBLOQUEADA
# ============================================================

func esta_desbloqueada(
	tecnica_id: StringName
) -> bool:

	var tecnica_enum = _string_para_tecnica(tecnica_id)

	if tecnica_enum == null:

		return false

	return tecnicas[tecnica_enum]["desbloqueada"]


# ============================================================
# CONVERTER STRING PARA ENUM
# ============================================================

func _string_para_tecnica(
	tecnica_id: StringName
):

	match tecnica_id:

		&"ten":
			return Tecnica.TEN

		&"ren":
			return Tecnica.REN

		&"zetsu":
			return Tecnica.ZETSU

		&"gyo":
			return Tecnica.GYO

		&"shu":
			return Tecnica.SHU

		&"ko":
			return Tecnica.KO

		&"en":
			return Tecnica.EN

		&"ken":
			return Tecnica.KEN

		&"ryu":
			return Tecnica.RYU


		_:
			return null


# ============================================================
# CÁLCULOS AVANÇADOS: SHU, KEN, RYU
# ============================================================

enum ModuloRyu { ATAQUE, DEFESA }
var modulo_ryu: ModuloRyu = ModuloRyu.ATAQUE


func alternar_modulo_ryu() -> void:
	if modulo_ryu == ModuloRyu.ATAQUE:
		modulo_ryu = ModuloRyu.DEFESA
		print("[RYU] Foco alterado para: DEFESA (20/80)")
	else:
		modulo_ryu = ModuloRyu.ATAQUE
		print("[RYU] Foco alterado para: ATAQUE (80/20)")


func aplicar_shu_no_dano(dano_base: float) -> float:
	if not tecnica_ativa(Tecnica.SHU):
		return dano_base
	return dano_base * 1.35


func aplicar_ken_no_dano(dano_recebido: float) -> float:
	if not tecnica_ativa(Tecnica.KEN):
		return dano_recebido
	return dano_recebido * 0.50


func aplicar_ryu_no_dano_ataque(dano_base: float) -> float:
	if not tecnica_ativa(Tecnica.RYU):
		return dano_base
	if modulo_ryu == ModuloRyu.ATAQUE:
		return dano_base * 1.60
	else:
		return dano_base * 0.60


func aplicar_ryu_no_dano_defesa(dano_recebido: float) -> float:
	if not tecnica_ativa(Tecnica.RYU):
		return dano_recebido
	if modulo_ryu == ModuloRyu.DEFESA:
		return dano_recebido * 0.30
	else:
		return dano_recebido * 1.30
