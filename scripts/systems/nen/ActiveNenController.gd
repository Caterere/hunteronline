class_name ActiveNenController
extends RefCounted

# ============================================================
# HUNTER ONLINE — ACTIVE NEN CONTROLLER
# ============================================================
#
# Gerencia as 3 Técnicas Ativas Especiais de Nen:
# 1. Zetsu (Stealth Real / Ocultação de Presença)
# 2. En    (Detecção Espacial + Intimidação em Área)
# 3. Gyo   (Percepção / Revelação de Segredos Multi-Tier)
#
# Possuem botões de ativação (Toggle ON/OFF via InputMap).
# Obedecem à Matriz Canônica de Conflitos:
# - Zetsu é incompatível com En e com Gyo.
# - En e Gyo podem coexistir.
# ============================================================

signal zetsu_alterado(ativo: bool)
signal en_alterado(ativo: bool, raio: float)
signal gyo_alterado(ativo: bool, nivel_percepcao: int)
signal conflito_resolvido(tecnica_cancelada: String, motivo: String)

var zetsu_ativo: bool = false
var en_ativo: bool = false
var gyo_ativo: bool = false

var en_timer_pulso: float = 0.0
const INTERVALO_PULSO_EN: float = 0.5


# ============================================================
# ZETSU (STEALTH REAL)
# ============================================================

func toggle_zetsu() -> bool:
	if zetsu_ativo:
		desativar_zetsu()
		return false
	else:
		return ativar_zetsu()


func ativar_zetsu() -> bool:
	if PlayerData == null or not PlayerData.despertou_nen:
		return false

	# Resolução de Conflito: Zetsu fecha os poros corporais; En e Gyo são incompatíveis
	if en_ativo:
		desativar_en()
		conflito_resolvido.emit("En", "Zetsu extinguiu a expansão de aura.")

	if gyo_ativo:
		desativar_gyo()
		conflito_resolvido.emit("Gyo", "Zetsu fechou o fluxo de aura dos olhos.")

	zetsu_ativo = true
	zetsu_alterado.emit(true)
	print("[ActiveNenController] 🍃 ZETSU ATIVADO (Modo Stealth Ativo | Fator: %.0f%%)" % (obter_fator_stealth_zetsu() * 100.0))
	return true


func desativar_zetsu() -> void:
	if not zetsu_ativo:
		return
	zetsu_ativo = false
	zetsu_alterado.emit(false)
	print("[ActiveNenController] 🍃 ZETSU DESATIVADO")


func obter_fator_stealth_zetsu() -> float:
	if not zetsu_ativo or PlayerData == null:
		return 0.0
	# Base: 20% de redução no raio de detecção de inimigos
	# Bônus da Skill Tree: de +15% até +65% (teto de 85% de furtividade)
	var mod_stealth: float = float(PlayerData.obter_modificador_total("zetsu_stealth"))
	return clampf(0.20 + mod_stealth, 0.20, 0.85)


func quebrar_stealth_combate() -> void:
	if zetsu_ativo:
		print("[ActiveNenController] ⚠️ Zetsu interrompido por ação de combate!")
		desativar_zetsu()


# ============================================================
# EN (DETECÇÃO + INTIMIDAÇÃO)
# ============================================================

func toggle_en() -> bool:
	if en_ativo:
		desativar_en()
		return false
	else:
		return ativar_en()


func ativar_en() -> bool:
	if PlayerData == null or not PlayerData.despertou_nen:
		return false

	# Resolução de Conflito: En requer expansão massiva de aura; cancela Zetsu
	if zetsu_ativo:
		desativar_zetsu()
		conflito_resolvido.emit("Zetsu", "En expandiu a presença vital do caçador.")

	en_ativo = true
	en_alterado.emit(true, obter_raio_en())
	print("[ActiveNenController] 🌐 EN ATIVADO (Raio: %.0fpx | Intimidação: -%.0f%% Def)" % [obter_raio_en(), obter_reducao_defesa_en() * 100.0])
	return true


func desativar_en() -> void:
	if not en_ativo:
		return
	en_ativo = false
	en_alterado.emit(false, 0.0)
	print("[ActiveNenController] 🌐 EN DESATIVADO")


func obter_raio_en() -> float:
	if PlayerData == null:
		return 120.0
	# Base: 120px + modificadores de en_range da Skill Tree (até 450px)
	var mod_raio: float = float(PlayerData.obter_modificador_total("en_range"))
	return clampf(120.0 + mod_raio, 120.0, 500.0)


func obter_reducao_defesa_en() -> float:
	if PlayerData == null:
		return 0.05
	# Base: -5% de defesa do inimigo + modificadores da Skill Tree (até -30%)
	var mod_int: float = float(PlayerData.obter_modificador_total("en_intimidation_defense_reduction"))
	return clampf(0.05 + mod_int, 0.05, 0.35)


func processar_pulso_en(delta: float, centro_pos: Vector2, tree: SceneTree) -> void:
	if not en_ativo or tree == null:
		return

	en_timer_pulso += delta
	if en_timer_pulso < INTERVALO_PULSO_EN:
		return

	en_timer_pulso = 0.0
	var raio := obter_raio_en()
	var red_def := obter_reducao_defesa_en()

	var inimigos = tree.get_nodes_in_group("enemies")
	for inimigo in inimigos:
		if not is_instance_valid(inimigo) or not (inimigo is Node2D):
			continue
		var dist: float = centro_pos.distance_to(inimigo.global_position)
		if dist <= raio:
			# Aplicar debuff de Intimidação
			var ai = inimigo.get_node_or_null("EnemyAI")
			if ai != null and ai.has_method("aplicar_intimidacao_en"):
				ai.aplicar_intimidacao_en(red_def, 1.2)


# ============================================================
# GYO (PERCEPÇÃO / DESCOBERTA MULTI-TIER)
# ============================================================

func toggle_gyo(tree: SceneTree = null) -> bool:
	if gyo_ativo:
		desativar_gyo(tree)
		return false
	else:
		return ativar_gyo(tree)


func ativar_gyo(tree: SceneTree = null) -> bool:
	if PlayerData == null or not PlayerData.despertou_nen:
		return false

	# Resolução de Conflito: Gyo foca aura nos olhos; cancela Zetsu
	if zetsu_ativo:
		desativar_zetsu()
		conflito_resolvido.emit("Zetsu", "Gyo focou a aura sensorial nos olhos.")

	gyo_ativo = true
	var nivel := obter_nivel_percepcao_gyo()
	gyo_alterado.emit(true, nivel)
	_notificar_nos_gyo(true, nivel, tree)
	print("[ActiveNenController] 👁️ GYO ATIVADO (Nível de Percepção: %d)" % nivel)
	return true


func desativar_gyo(tree: SceneTree = null) -> void:
	if not gyo_ativo:
		return
	gyo_ativo = false
	gyo_alterado.emit(false, 0)
	_notificar_nos_gyo(false, 0, tree)
	print("[ActiveNenController] 👁️ GYO DESATIVADO")


func obter_nivel_percepcao_gyo() -> int:
	if PlayerData == null:
		return 1
	# Base: 1 (Segredos Fáceis) + bônus da Skill Tree (até 5: Revelação Total)
	var mod_gyo: int = int(PlayerData.obter_modificador_total("gyo_perception_level"))
	return clampi(1 + mod_gyo, 1, 5)


func _notificar_nos_gyo(ativo: bool, nivel_percepcao: int, tree: SceneTree) -> void:
	if tree == null:
		return
	var nos = tree.get_nodes_in_group("gyo_inspectable")
	for no in nos:
		if is_instance_valid(no) and no.has_method("atualizar_estado_gyo_com_nivel"):
			no.atualizar_estado_gyo_com_nivel(ativo, nivel_percepcao)
		elif is_instance_valid(no) and no.has_method("atualizar_estado_gyo"):
			no.atualizar_estado_gyo(ativo)


# ============================================================
# CUSTO DE MANUTENÇÃO CONTÍNUO
# ============================================================

func calcular_dreno_aura_por_segundo() -> float:
	var dreno: float = 0.0
	if en_ativo:
		dreno += 2.5 # Custo de sustentar cúpula de En
	if gyo_ativo:
		dreno += 1.0 # Custo de manter foco ocular de Gyo
	# Zetsu não gasta aura (fecha os poros)
	return dreno
