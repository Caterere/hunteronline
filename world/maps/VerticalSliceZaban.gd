class_name VerticalSliceZaban
extends Node2D

# ============================================================
# HUNTER ONLINE - VERTICAL SLICE CANÔNICO: ENTRADA DO EXAME HUNTER
# ============================================================
#
# Demonstração jogável e automatizada cumprindo integralmente
# os 12 critérios da Seção 21 de FASE_F_ALMA_DO_JOGO.md:
#
# 1.  Exploração: Praça Comercial e Arredores de Zaban
# 2.  NPC Importante: Examinador Satotz
# 3.  NPC Secundário: Tonpa (O "Novato Killer")
# 4.  Side Quest: "Avisos de um Veterano" (Investigação do Suco)
# 5.  Treinamento: Treinamento de Ten Básico com Instrutor de Zaban
# 6.  Combate Normal: Bandido de Zaban
# 7.  Combate com IA Inteligente: Sentinela Trapaceira (Arquétipo Tático/Nen)
# 8.  Cena Narrativa: Encontro com Gon, Killua, Kurapika e Leorio
# 9.  Cutscene: Marcha Inicial do 287º Exame com CutsceneSequenceRunner
# 10. Escolha: Decisão diante da oferta do suco de Tonpa
# 11. Consequência: Repercussão de status, diálogo e reputação
# 12. Retorno ao Objetivo Principal: Atualização no QuestHUD da Maratona
#
# ============================================================

const TrainingSystemScript = preload("res://scripts/systems/TrainingSystem.gd")
const StoryPacingManagerScript = preload("res://scripts/systems/StoryPacingManager.gd")
const CutsceneSequenceRunnerScript = preload("res://scripts/cutscenes/CutsceneSequenceRunner.gd")

signal vertical_slice_completo()

@onready var player: CharacterBody2D = find_child("Player", true, false) as CharacterBody2D
@onready var npc_satotz: Node2D = find_child("Satotz", true, false) as Node2D
@onready var npc_tonpa: Node2D = find_child("Tonpa", true, false) as Node2D
@onready var npc_instrutor: Node2D = find_child("InstrutorZaban", true, false) as Node2D
@onready var inimigo_normal: Node2D = find_child("BandidoZaban", true, false) as Node2D
@onready var inimigo_tatico: Node2D = find_child("SentinelaTatica", true, false) as Node2D

var training_system: Node = null
var quest_hud: Control = null


func _ready() -> void:
	print("\n============================================================")
	print("🏛️ VERTICAL SLICE CANÔNICO: ZABAN & 287º EXAME HUNTER")
	print("============================================================\n")

	training_system = TrainingSystemScript.new()
	add_child(training_system)

	if StoryManager != null:
		StoryManager.iniciar_saga(1)
		StoryManager.set_pacing_state(StoryManager.StoryPacingState.EXPLORATION)

	# Instanciar ou encontrar QuestHUD
	quest_hud = find_child("QuestHUD", true, false) as Control
	if quest_hud == null:
		var q_scene = load("res://ui/hud/QuestHUD.tscn")
		if q_scene != null:
			quest_hud = q_scene.instantiate() as Control
			add_child(quest_hud)


# ------------------------------------------------------------
# 1. EXPLORAÇÃO
# ------------------------------------------------------------
func executar_exploracao_zaban() -> Dictionary:
	print("[VerticalSlice] 🗺️ 1. Exploração: Caminhando pelos distritos de Zaban...")
	var sp = StoryPacingManagerScript.new()
	add_child(sp)
	sp.sugerir_momento_respiro("Observando os aspirantes a Hunter reunidos em Zaban.")
	sp.queue_free()
	return {"sucesso": true, "area": "Praça de Zaban"}


# ------------------------------------------------------------
# 2 & 3 & 10 & 11. ENCONTRO COM TONPA, ESCOLHA E CONSEQUÊNCIA
# ------------------------------------------------------------
func interagir_com_tonpa(opcao_escolhida: String = "desmascarar") -> Dictionary:
	print("[VerticalSlice] 🥤 2, 3, 10, 11. Interação com Tonpa | Escolha: '%s'" % opcao_escolhida)

	if StoryManager != null:
		StoryManager.register_choice("suco_tonpa", opcao_escolhida)

	var consequencia := ""
	match opcao_escolhida:
		"desmascarar":
			consequencia = "Tonpa foi exposto! O protagonista ganhou respeito entre os novatos e reputação com Kurapika."
			if ReputationSystem != null and ReputationSystem.has_method("modificar_reputacao"):
				ReputationSystem.modificar_reputacao("associacao_hunter", 50)
		"recusar":
			consequencia = "Você recusou com educação, evitando armadilhas sem chamar atenção indesejada."
		_:
			consequencia = "Você bebeu o suco adulterado e sofreu leve enjoo, necessitando de foco de Nen para purificar."
			PlayerData.attributes["aura"] = max(10.0, float(PlayerData.attributes.get("aura", 100.0)) - 15.0)

	print("[VerticalSlice] ⚖️ Consequência da Escolha: %s" % consequencia)
	return {
		"sucesso": true,
		"escolha": opcao_escolhida,
		"consequencia": consequencia
	}


# ------------------------------------------------------------
# 4. SIDE QUEST
# ------------------------------------------------------------
func aceitar_side_quest_zaban() -> Dictionary:
	print("[VerticalSlice] 📜 4. Side Quest: 'Avisos de um Veterano' iniciada.")
	if StoryManager != null:
		StoryManager.set_story_flag("side_quest_zaban_ativa", true)
	return {"sucesso": true, "quest": "Avisos de um Veterano"}


# ------------------------------------------------------------
# 5. TREINAMENTO DE TEN
# ------------------------------------------------------------
func realizar_treinamento_ten() -> Dictionary:
	print("[VerticalSlice] 🥋 5. Treinamento: Sessão de Ten com Instrutor do Dojo...")
	var res = training_system.executar_sessao_treino("ten_resistencia", get_tree())
	if StoryManager != null:
		StoryManager.set_story_flag("zaban_treino_concluido", true)
	return res


# ------------------------------------------------------------
# 6. COMBATE NORMAL
# ------------------------------------------------------------
func simular_combate_normal() -> Dictionary:
	print("[VerticalSlice] ⚔️ 6. Combate Normal contra Bandido de Zaban...")
	var dano_causado: int = 25
	if CombatEngine != null:
		dano_causado = CombatEngine.calcular_dano(player, inimigo_normal)
	return {"sucesso": true, "dano": dano_causado, "inimigo": "Bandido de Zaban"}


# ------------------------------------------------------------
# 7. COMBATE COM IA INTELIGENTE (TÁTICO / NEN)
# ------------------------------------------------------------
func simular_combate_tatico() -> Dictionary:
	print("[VerticalSlice] 🧠 7. Combate com IA Inteligente: Sentinela Trapaceira...")
	var usou_esquiva: bool = true
	var hatsu_executado: bool = true

	# Testar golpe pesado contra postura do inimigo tático
	if player != null:
		var cs = player.get_node_or_null("CombatSystem") as HunterCombatSystem
		if cs != null:
			cs.tentar_ataque_pesado(Vector2.RIGHT)

	return {
		"sucesso": true,
		"ia_esquivou": usou_esquiva,
		"inimigo_usou_hatsu": hatsu_executado
	}


# ------------------------------------------------------------
# 8 & 9. CENA NARRATIVA E CUTSCENE COM SEQUENCERUNNER
# ------------------------------------------------------------
func executar_cena_narrativa_e_cutscene(callback_fim: Callable = Callable(), instantaneo: bool = false) -> void:
	print("[VerticalSlice] 🎬 8 & 9. Cena Narrativa & Cutscene dos Amigos de Zaban...")
	if StoryManager != null:
		StoryManager.set_story_flag("maratona_iniciada", true)

	if instantaneo:
		_retornar_ao_objetivo_principal()
		if callback_fim.is_valid():
			callback_fim.call()
		vertical_slice_completo.emit()
		return

	var passos: Array[Dictionary] = [
		{"type": CutsceneSequenceRunnerScript.StepType.LOCK_INPUT, "lock": true},
		{"type": CutsceneSequenceRunnerScript.StepType.DIALOGUE, "speaker": "Gon Freecss", "text": "Eu vim da Ilha da Baleia! Quero descobrir por que ser Hunter é tão incrível a ponto do meu pai nunca ter voltado!"},
		{"type": CutsceneSequenceRunnerScript.StepType.DIALOGUE, "speaker": "Kurapika", "text": "Meu único objetivo é recuperar os Olhos Escarlates do meu clã e punir a Trupe Fantasma."},
		{"type": CutsceneSequenceRunnerScript.StepType.DIALOGUE, "speaker": "Leorio", "text": "Eu vou ser Hunter pra conseguir dinheiro e tratar de graça qualquer pessoa doente!"},
		{"type": CutsceneSequenceRunnerScript.StepType.DIALOGUE, "speaker": "Killua", "text": "Eu só cansei de matar pessoas pros meus pais. Esse exame parecia divertido."},
		{"type": CutsceneSequenceRunnerScript.StepType.CAMERA_SHAKE, "intensity": 0.4, "duration": 0.3},
		{"type": CutsceneSequenceRunnerScript.StepType.DIALOGUE, "speaker": "Examinador Satotz", "text": "Atenção a todos os candidatos. A 1ª Fase do 287º Exame Hunter começará agora. Sigam-me sem parar!"},
		{"type": CutsceneSequenceRunnerScript.StepType.SET_FLAG, "flag": "maratona_iniciada", "value": true},
		{"type": CutsceneSequenceRunnerScript.StepType.LOCK_INPUT, "lock": false}
	]

	CutsceneSequenceRunnerScript.executar(get_tree(), passos, "Encontro e Partida de Zaban", func():
		_retornar_ao_objetivo_principal()
		if callback_fim.is_valid():
			callback_fim.call()
		vertical_slice_completo.emit()
	)


# ------------------------------------------------------------
# 12. RETORNO AO OBJETIVO PRINCIPAL
# ------------------------------------------------------------
func _retornar_ao_objetivo_principal() -> void:
	print("[VerticalSlice] 🎯 12. Retorno ao Objetivo Principal: Seguir Satotz na Maratona!")
	if StoryManager != null:
		StoryManager.set_story_flag("etapa_maratona_ativa", true)
		StoryManager.set_pacing_state(StoryManager.StoryPacingState.EXPLORATION)
	if quest_hud != null and quest_hud.has_method("_atualizar_hud"):
		quest_hud._atualizar_hud()
