extends Node

# ============================================================
# HUNTER ONLINE - SURPRISE QUEST & RUMOR SYSTEM (AUTOLOAD)
# ============================================================
#
# Gerencia encontros surpresas, mensageiros misteriosos, pegadinhas
# e boatos no Lobby e no mundo:
# 1. 🧃 O Refrigerante Batizado de Tonpa (Interação com Gyo)
# 2. ✉️ Cartas Seladas de Mensageiros Misteriosos
# 3. 🙏 Meditação dos 10.000 Socos de Gratidão de Netero
# 4. 🪙 O Jogo da Moeda Supersônica de Gotoh
# 5. 🗣️ Rede de Rumores da Taverna e dos Caçadores
#
# ============================================================

signal evento_surpresa_disparado(id_evento: String, titulo: String, descricao: String)
signal carta_mensageiro_entregue(remetente: String, texto: String)
signal rumor_revelado(rumor_texto: String)
signal segredo_descoberto(id_segredo: String, titulo: String, recompensa_texto: String)

const RUMORES_LOBBY: Array[String] = [
	"💬 Dizem que nas noites sem lua, Chrollo Lucilfer observa os novatos perto do Distrito Dimensional...",
	"💬 Se você usar Gyo na estátua do Presidente Netero, sentirá o calor de milhares de socos de gratidão.",
	"💬 Tonpa anda oferecendo bebidas grátis para novatos... Cuidado! O estômago de muitos caçadores não resistiu.",
	"💬 Gotoh na mansão Zoldyck tem um jogo de adivinhar a moeda. Quem vence 5 vezes ganha uma moeda forjada em aço negro.",
	"💬 Kurapika está pagando quantias absurdas por qualquer pista sobre itens do leilão clandestino de Yorknew.",
	"💬 Menchi e Buhara estão procurando alguém com coragem para caçar o Grande Javali da Floresta Biska.",
	"💬 Existe uma fita cassete gravada por Ging Freecss escondida em algum lugar do Distrito Dimensional..."
]

var timer_rumor: float = 60.0
var cartas_lidas: Array[String] = []


func _ready() -> void:
	add_to_group("surprise_quest_system")
	print("=================================")
	print("[SurpriseQuestSystem] SISTEMA DE QUESTS SURPRESAS E RUMORES ATIVO")
	print("=================================")


func _process(delta: float) -> void:
	timer_rumor -= delta
	if timer_rumor <= 0.0:
		timer_rumor = randf_range(120.0, 240.0)
		_emitir_rumor_aleatorio()


func _emitir_rumor_aleatorio() -> void:
	var rumor = RUMORES_LOBBY[randi() % RUMORES_LOBBY.size()]
	rumor_revelado.emit(rumor)
	
	var hud = get_tree().get_first_node_in_group("player_hud")
	if hud and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("🗣️ RUMOR DE CAÇADORES:\n" + rumor)


func obter_rumor_aleatorio() -> String:
	return RUMORES_LOBBY[randi() % RUMORES_LOBBY.size()]


# ------------------------------------------------------------
# 1. EVENTO DO REFRIGERANTE DE TONPA
# ------------------------------------------------------------
func processar_interacao_tonpa(usou_gyo: bool) -> Dictionary:
	if usou_gyo:
		PlayerData.registrar_segredo("tonpa_desmascarado")
		PlayerData.desbloquear_titulo("👁️ Imune a Trapaças")
		if ReputationSystem:
			ReputationSystem.alterar_reputacao(ReputationSystem.Faccao.CIVIS, 50, "Desmascarou Tonpa")
		return {
			"sucesso": true,
			"mensagem": "Com o Gyo ativo, você enxerga as partículas de laxante mortal e veneno paralisante na lata! Você recusa a bebida e encara Tonpa!",
			"recompensa": "Título [👁️ Imune a Trapaças] e +50 Reputação!"
		}
	else:
		PlayerData.registrar_segredo("tonpa_envenenado")
		return {
			"sucesso": false,
			"mensagem": "Você bebe o refrigerante alegremente... 10 segundos depois seu estômago queima como fogo! Você corre para a enfermaria!",
			"recompensa": "Resistência a Veneno levemente aumentada."
		}


# ------------------------------------------------------------
# 2. MEDITAÇÃO DE NETERO (10.000 SOCOS)
# ------------------------------------------------------------
func meditar_estatua_netero() -> Dictionary:
	if not PlayerData:
		return {}
		
	PlayerData.socos_netero_contador += 1000
	var total = PlayerData.socos_netero_contador
	
	if total >= 10000 and not PlayerData.segredos_descobertos.has("netero_10k_socos"):
		PlayerData.registrar_segredo("netero_10k_socos")
		PlayerData.desbloquear_titulo("🙏 Punho da Gratidão")
		PlayerData.attributes["aura_max"] += 200
		PlayerData.attributes["aura"] = PlayerData.attributes["aura_max"]
		
		segredo_descoberto.emit("netero_10k", "🙏 Iluminação dos 10.000 Socos", "+200 Aura Máxima e Título Lendário!")
		return {
			"atingiu_meta": true,
			"total": total,
			"texto": "BÊNÇÃO SUPREMA DE NETERO! Você completou 10.000 socos de pura gratidão! O seu Nen agora brilha com uma chama dourada!",
			"recompensa": "Título [🙏 Punho da Gratidão] e +200 Aura Máxima Permanente!"
		}
	else:
		return {
			"atingiu_meta": false,
			"total": total,
			"texto": "Você reza em silêncio e executa 1.000 socos de gratidão... (Total acumulado: %d / 10.000)" % total,
			"recompensa": "+50 Nen XP"
		}


# ------------------------------------------------------------
# 3. ENTREGA DE CARTA MISTERIOSA
# ------------------------------------------------------------
func entregar_carta_mensageiro(remetente: String, texto: String) -> void:
	if cartas_lidas.has(remetente):
		return
	cartas_lidas.append(remetente)
	carta_mensageiro_entregue.emit(remetente, texto)
	
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue and visual_dialogue.has_method("exibir_sequencia_falas"):
		var falas: Array[Dictionary] = [
			{"falante": "Mensageiro Encapuzado", "texto": "Psst... Caçador! Tenho uma correspondência confidencial selada com cera para você de: " + remetente},
			{"falante": "Carta de " + remetente, "texto": texto}
		]
		visual_dialogue.exibir_sequencia_falas(falas)
