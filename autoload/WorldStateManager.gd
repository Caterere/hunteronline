class_name WorldStateManagerClass
extends Node

# ============================================================
# HUNTER ONLINE - WORLD STATE ENGINE (FASE G — TASK 4.1)
# ============================================================
#
# Coordena e unifica os 6 sub-sistemas do Mundo Vivo:
# ├── Time (Dia / Entardecer / Noite) via TimeManager
# ├── Weather (Limpo, Chuva, Neblina, Tempestade de Aura)
# ├── Region State (Nível de perigo, ocupação, segurança) via WorldState
# ├── NPC Schedule (Rotinas de trabalho, descanso, abrigo)
# ├── Events (Eventos temporários ativados por gatilhos) via WorldEventManager
# └── Story State (Progresso global das sagas) via StoryManager
# ============================================================

enum Clima {
	LIMPO,
	CHUVA,
	NEBLINA,
	TEMPESTADE_AURA
}

signal clima_alterado(novo_clima: Clima, nome_clima: String)
signal rotina_npc_atualizada(fase_tempo: int, clima: Clima)
signal alerta_mundial_emitido(titulo: String, mensagem: String, cor: Color)
signal evento_organico_iniciado(evento_id: String, dados: Dictionary)
signal evento_organico_finalizado(evento_id: String, sucesso: bool)

var clima_atual: Clima = Clima.LIMPO
var duracao_clima_timer: float = 0.0
var proxima_mudanca_clima_horas: float = 8.0

var evento_invasao_ativo: bool = false
var invasao_regiao_id: String = ""

func _ready() -> void:
	add_to_group("world_state_manager")
	_conectar_sub_sistemas()
	print("=================================")
	print("[WorldStateManager] WORLD STATE ENGINE UNIFICADO ATIVO (FASE G)")
	print("=================================")


func _conectar_sub_sistemas() -> void:
	if EventBus != null and EventBus.has_signal("time_hour_ticked"):
		EventBus.time_hour_ticked.connect(_on_time_hour_ticked)
	if EventBus != null and EventBus.has_signal("time_phase_changed"):
		EventBus.time_phase_changed.connect(_on_time_phase_changed)


# ============================================================
# GESTÃO DE CLIMA (WEATHER SYSTEM)
# ============================================================

func obter_clima_atual() -> Clima:
	return clima_atual


func obter_nome_clima(c: Clima = clima_atual) -> String:
	match c:
		Clima.LIMPO: return "Céu Limpo"
		Clima.CHUVA: return "Chuva Torrencial"
		Clima.NEBLINA: return "Neblina Densa"
		Clima.TEMPESTADE_AURA: return "Tempestade de Aura"
	return "Indefinido"


func definir_clima(novo_clima: Clima) -> void:
	if clima_atual == novo_clima:
		return
	clima_atual = novo_clima
	var nome = obter_nome_clima(clima_atual)
	clima_alterado.emit(clima_atual, nome)

	if EventBus != null:
		var cor_alerta = Color(0.3, 0.7, 1.0) if novo_clima == Clima.CHUVA else (Color(0.8, 0.4, 1.0) if novo_clima == Clima.TEMPESTADE_AURA else Color.WHITE)
		EventBus.emit_toast("🌦️ Mudança Climática: %s" % nome, cor_alerta)

	# Atualizar rotinas de NPCs de acordo com o novo clima
	var fase_atual = TimeManager.current_phase if TimeManager != null else 1
	rotina_npc_atualizada.emit(fase_atual, clima_atual)
	print("[WorldStateManager] Clima alterado para: %s" % nome)


func sortear_clima_aleatorio() -> void:
	var roll = randf()
	if roll < 0.50:
		definir_clima(Clima.LIMPO)
	elif roll < 0.75:
		definir_clima(Clima.CHUVA)
	elif roll < 0.90:
		definir_clima(Clima.NEBLINA)
	else:
		definir_clima(Clima.TEMPESTADE_AURA)


func _on_time_hour_ticked(_hour: int, _minute: int) -> void:
	proxima_mudanca_clima_horas -= 1.0
	if proxima_mudanca_clima_horas <= 0.0:
		proxima_mudanca_clima_horas = randf_range(6.0, 14.0)
		sortear_clima_aleatorio()


func _on_time_phase_changed(_nome_fase: String) -> void:
	var fase_num = TimeManager.current_phase if TimeManager != null else 1
	rotina_npc_atualizada.emit(fase_num, clima_atual)


# ============================================================
# CONSULTA UNIFICADA DO ESTADO DO MUNDO (TASK 4.1)
# ============================================================

func obter_estado_mundo_completo() -> Dictionary:
	var info_tempo := {
		"hora": TimeManager.current_hour if TimeManager != null else 8,
		"minuto": TimeManager.current_minute if TimeManager != null else 0,
		"fase_id": TimeManager.current_phase if TimeManager != null else 1,
		"fase_nome": TimeManager.get_phase_name() if TimeManager != null else "DAY"
	}

	var mod_visao: float = 1.0
	match clima_atual:
		Clima.CHUVA: mod_visao = 0.75
		Clima.NEBLINA: mod_visao = 0.50
		Clima.TEMPESTADE_AURA: mod_visao = 0.85

	var info_clima := {
		"clima_id": int(clima_atual),
		"clima_nome": obter_nome_clima(clima_atual),
		"modificador_visao": mod_visao,
		"aura_regen_mult": 1.35 if clima_atual == Clima.TEMPESTADE_AURA else 1.0
	}

	var info_regioes: Dictionary = WorldState.world_data.get("regions", {}) if WorldState != null else {}
	var info_eventos: Dictionary = WorldEventManager.active_world_events if WorldEventManager != null else {}

	var info_story: Dictionary = {
		"saga": (StoryManager.get_current_saga_id() if StoryManager.has_method("get_current_saga_id") else StoryManager.current_saga) if StoryManager != null else 1,
		"capitulo": (StoryManager.get_current_chapter_index() if StoryManager.has_method("get_current_chapter_index") else StoryManager.current_chapter) if StoryManager != null else 1
	}

	return {
		"time": info_tempo,
		"weather": info_clima,
		"region_state": info_regioes,
		"events": info_eventos,
		"story_state": info_story,
		"invasao_bestas_ativa": evento_invasao_ativo
	}


# ============================================================
# EVENTO ORGÂNICO MUNDIAL: INVASÃO DE BESTAS MÁGICAS (TASK 4.3)
# ============================================================

func iniciar_evento_invasao_bestas(regiao_id: String = "pantanal_numelle") -> void:
	if evento_invasao_ativo:
		return

	evento_invasao_ativo = true
	invasao_regiao_id = regiao_id

	# 1. Altera estado regional no WorldState
	if WorldState != null:
		WorldState.adicionar_flag_regional(regiao_id, "invasao_bestas_ativa")
		WorldState.alterar_seguranca_regional(regiao_id, -30)
		WorldState.adicionar_efeito_temporario("invasao_bestas_" + regiao_id, 36.0, {
			"regiao": regiao_id,
			"perigo": "ALTO"
		})

	# 2. Transmite Alerta Oficial da Associação Hunter
	var msg_alerta = "🚨 COMUNICADO OFICIAL DA ASSOCIAÇÃO HUNTER: Invasão de Bestas Mágicas detectada em %s! Alerta de Nível 3 emitido para todos os Hunters da região." % regiao_id.capitalize()
	alerta_mundial_emitido.emit("INVASÃO DE BESTAS MÁGICAS", msg_alerta, Color(1.0, 0.3, 0.2))

	if EventBus != null:
		EventBus.emit_toast(msg_alerta, Color(1.0, 0.25, 0.2))

	# 3. Notifica WorldEventManager
	if WorldEventManager != null:
		WorldEventManager.iniciar_evento(
			"invasao_bestas_" + regiao_id,
			"Invasão de Bestas Mágicas",
			"Uma horda de predadores mutantes rompeu os limites da floresta. Elimine o Líder da Matilha para restaurar a segurança.",
			regiao_id,
			36.0,
			70
		)

	evento_organico_iniciado.emit("invasao_bestas", {
		"regiao": regiao_id,
		"mini_boss": "Líder da Matilha Quimera",
		"duracao_horas": 36.0
	})
	print("[WorldStateManager] Evento Mundial: Invasão de Bestas Mágicas iniciada em %s" % regiao_id)


func finalizar_evento_invasao_bestas(sucesso: bool) -> void:
	if not evento_invasao_ativo:
		return

	evento_invasao_ativo = false
	var regiao = invasao_regiao_id
	invasao_regiao_id = ""

	if WorldState != null:
		if WorldState.tem_flag_regional(regiao, "invasao_bestas_ativa"):
			# Remove flag e restaura segurança
			var flags: Array = WorldState.world_data["regions"][regiao].get("flags", [])
			flags.erase("invasao_bestas_ativa")
			WorldState.world_data["regions"][regiao]["flags"] = flags

		if sucesso:
			WorldState.alterar_seguranca_regional(regiao, +35)
			WorldState.alterar_prosperidade_regional(regiao, +25)
			WorldState.alterar_notoriedade_nen(+40)
			WorldState.registrar_marco_historico("venceu_invasao_bestas_" + regiao, {
				"data_ticks": Time.get_ticks_msec()
			})
		else:
			WorldState.alterar_seguranca_regional(regiao, -10)

	var msg_final = "📢 COMUNICADO DA ASSOCIAÇÃO HUNTER: A crise de Bestas Mágicas em %s foi neutralizada com sucesso. A paz foi restaurada!" % regiao.capitalize() if sucesso else "⚠️ As Bestas Mágicas causaram estragos em %s antes de recuarem." % regiao.capitalize()

	if EventBus != null:
		EventBus.emit_toast(msg_final, Color(0.3, 0.9, 0.4) if sucesso else Color(1.0, 0.4, 0.2))

	if WorldEventManager != null:
		WorldEventManager.resolver_evento_jogador("invasao_bestas_" + regiao, sucesso)

	evento_organico_finalizado.emit("invasao_bestas", sucesso)
	print("[WorldStateManager] Evento Mundial: Invasão de Bestas Mágicas finalizada (Sucesso: %s)" % str(sucesso))
