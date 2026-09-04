class_name TrainingSystem
extends Node

# ============================================================
# HUNTER ONLINE - TRAINING SYSTEM (SISTEMA DE TREINAMENTO)
# ============================================================
#
# Permite ao jogador progredir e fortalecer seu personagem através de
# sessões de treinamento estruturadas com Mestres (Wing, Biscuit, Dojos),
# com propósito canônico (Aura, Defesa, Vigor, Maestria) além do farm de XP.
#
# ============================================================

signal treino_iniciado(treino_id: String, instrutor: String)
signal treino_concluido(treino_id: String, recompensa_desc: String)

const CATALOGO_TREINOS: Dictionary = {
	"ten_resistencia": {
		"nome": "Meditação e Sustentação de Ten",
		"instrutor": "Mestre Wing",
		"descricao": "Fecha os microporos para impedir o vazamento contínuo de aura.",
		"requisito_nivel": 1,
		"recompensa_aura_max": 25.0,
		"recompensa_nen_points": 1,
		"texto_recompensa": "+25 Aura Máxima e +1 Ponto de Nen Skill Tree"
	},
	"fortalecimento_fisico": {
		"nome": "Condicionamento Físico de Caçador",
		"instrutor": "Treinador de Zaban",
		"descricao": "Flexões, corrida pesada e endurecimento muscular.",
		"requisito_nivel": 1,
		"recompensa_defesa": 4,
		"recompensa_vida_max": 30,
		"texto_recompensa": "+4 Defesa e +30 Vida Máxima permanente"
	},
	"ren_intensificacao": {
		"nome": "Expansão Explosiva de Ren",
		"instrutor": "Biscuit Krueger",
		"descricao": "Canaliza a vontade de combate para multiplicar a densidade da aura.",
		"requisito_nivel": 15,
		"recompensa_forca": 6,
		"recompensa_aura_max": 40.0,
		"texto_recompensa": "+6 Força e +40 Aura Máxima"
	},
	"fluxo_ko": {
		"nome": "Concentração Extrema de Ko",
		"instrutor": "Mestre Shingen-ryu",
		"descricao": "Direciona 100% da aura para um único ponto de impacto.",
		"requisito_nivel": 30,
		"recompensa_nen_points": 2,
		"recompensa_forca": 10,
		"texto_recompensa": "+2 Pontos de Nen e +10 Força"
	}
}

var treinos_concluidos: Array[String] = []


func _ready() -> void:
	add_to_group("training_system")


func pode_iniciar_treino(treino_id: String) -> Dictionary:
	if not CATALOGO_TREINOS.has(treino_id):
		return {"pode": false, "motivo": "Treino não registrado no catálogo."}

	var dados = CATALOGO_TREINOS[treino_id]
	var lvl_jogador: int = int(PlayerData.attributes.get("nivel", 1))
	if lvl_jogador < int(dados.get("requisito_nivel", 1)):
		return {"pode": false, "motivo": "Nível insuficiente (requer Nível %d)." % dados.get("requisito_nivel", 1)}

	return {"pode": true, "motivo": "Apto para iniciar"}


func executar_sessao_treino(treino_id: String, tree: SceneTree = null) -> Dictionary:
	var check = pode_iniciar_treino(treino_id)
	if not check.get("pode", false):
		return {"sucesso": false, "mensagem": check.get("motivo", "")}

	var dados = CATALOGO_TREINOS[treino_id]
	var nome_treino: String = dados.get("nome", "")
	var instrutor: String = dados.get("instrutor", "")
	var desc_recompensa: String = dados.get("texto_recompensa", "")

	treino_iniciado.emit(treino_id, instrutor)
	print("[TrainingSystem] 🥋 TREINAMENTO INICIADO: %s com %s" % [nome_treino, instrutor])

	# Aplicar recompensas ao PlayerData
	if dados.has("recompensa_aura_max"):
		PlayerData.attributes["aura_max"] = float(PlayerData.attributes.get("aura_max", 100.0)) + float(dados["recompensa_aura_max"])
		PlayerData.attributes["aura"] = PlayerData.attributes["aura_max"]

	if dados.has("recompensa_vida_max"):
		PlayerData.attributes["vida_max"] = int(PlayerData.attributes.get("vida_max", 100)) + int(dados["recompensa_vida_max"])
		PlayerData.attributes["vida"] = PlayerData.attributes["vida_max"]

	if dados.has("recompensa_defesa"):
		PlayerData.attributes["defesa"] = int(PlayerData.attributes.get("defesa", 10)) + int(dados["recompensa_defesa"])

	if dados.has("recompensa_forca"):
		PlayerData.attributes["forca"] = int(PlayerData.attributes.get("forca", 10)) + int(dados["recompensa_forca"])

	if dados.has("recompensa_nen_points"):
		PlayerData.nen_skill_points += int(dados["recompensa_nen_points"])

	if not treinos_concluidos.has(treino_id):
		treinos_concluidos.append(treino_id)

	if StoryManager != null:
		StoryManager.set_story_flag("treino_" + treino_id, true)
		StoryManager.set_pacing_state(StoryManager.StoryPacingState.EXPLORATION)

	treino_concluido.emit(treino_id, desc_recompensa)
	print("[TrainingSystem] 🏆 TREINAMENTO CONCLUÍDO: %s! (%s)" % [nome_treino, desc_recompensa])

	return {
		"sucesso": true,
		"treino": nome_treino,
		"recompensa": desc_recompensa
	}


func ja_concluiu_treino(treino_id: String) -> bool:
	return treinos_concluidos.has(treino_id) or (StoryManager != null and StoryManager.get_story_flag("treino_" + treino_id, false))
