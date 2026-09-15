class_name TrainingSystem
extends Node

# ============================================================
# HUNTER ONLINE - TRAINING SYSTEM (SISTEMA DE TREINAMENTO)
# ============================================================
#
# Sessões com mestres (Wing, Biscuit, Dojos). Recompensas permanentes
# via StatModifier (sobrevivem a recalcular_todos_atributos + save/load
# através de flags StoryManager + reaplicar_mods_progressao).
#
# ============================================================

signal treino_iniciado(treino_id: String, instrutor: String)
signal treino_concluido(treino_id: String, recompensa_desc: String)

const CATALOGO_TREINOS: Dictionary = {
	"ten_resistencia": {
		"nome": "Meditação e Sustentação de Ten",
		"instrutor": "Mestre Wing",
		"instrutor_ids": ["wing", "mestre wing"],
		"descricao": "Fecha os microporos para impedir o vazamento contínuo de aura.",
		"requisito_nivel": 1,
		"requer_nen": true,
		"recompensa_aura_max": 25.0,
		"recompensa_nen_points": 1,
		"texto_recompensa": "+25 Aura Máxima e +1 Ponto de Nen Skill Tree",
	},
	"fortalecimento_fisico": {
		"nome": "Condicionamento Físico de Caçador",
		"instrutor": "Treinador de Zaban",
		"instrutor_ids": ["treinador", "instrutor", "zaban", "dojo"],
		"descricao": "Flexões, corrida pesada e endurecimento muscular.",
		"requisito_nivel": 1,
		"requer_nen": false,
		"recompensa_defesa": 4.0,
		"recompensa_vida_max": 30.0,
		"texto_recompensa": "+4 Defesa e +30 Vida Máxima permanente",
	},
	"ren_intensificacao": {
		"nome": "Expansão Explosiva de Ren",
		"instrutor": "Biscuit Krueger",
		"instrutor_ids": ["biscuit"],
		"descricao": "Canaliza a vontade de combate para multiplicar a densidade da aura.",
		"requisito_nivel": 15,
		"requer_nen": true,
		"recompensa_forca": 6.0,
		"recompensa_aura_max": 40.0,
		"texto_recompensa": "+6 Força e +40 Aura Máxima",
	},
	"fluxo_ko": {
		"nome": "Concentração Extrema de Ko",
		"instrutor": "Mestre Shingen-ryu",
		"instrutor_ids": ["biscuit", "wing", "shingen"],
		"descricao": "Direciona 100% da aura para um único ponto de impacto.",
		"requisito_nivel": 30,
		"requer_nen": true,
		"recompensa_nen_points": 2,
		"recompensa_forca": 10.0,
		"texto_recompensa": "+2 Pontos de Nen e +10 Força",
	},
}

var treinos_concluidos: Array[String] = []


func _ready() -> void:
	add_to_group("training_system")
	_sincronizar_com_flags()


static func obter_ou_criar(tree: SceneTree = null) -> TrainingSystem:
	var t: SceneTree = tree
	if t == null and Engine.get_main_loop() is SceneTree:
		t = Engine.get_main_loop() as SceneTree
	if t == null:
		return null
	var existing: Node = t.get_first_node_in_group("training_system")
	if existing is TrainingSystem:
		return existing as TrainingSystem
	var script_ref: GDScript = load("res://scripts/systems/TrainingSystem.gd") as GDScript
	if script_ref == null:
		return null
	var ts: TrainingSystem = script_ref.new() as TrainingSystem
	ts.name = "TrainingSystem"
	t.root.add_child(ts)
	return ts


func _sincronizar_com_flags() -> void:
	treinos_concluidos.clear()
	for treino_id in CATALOGO_TREINOS.keys():
		if StoryManager != null and StoryManager.get_story_flag("treino_" + str(treino_id), false):
			treinos_concluidos.append(str(treino_id))


func listar_treinos_do_instrutor(instrutor_key: String) -> Array[String]:
	var key: String = instrutor_key.strip_edges().to_lower()
	var out: Array[String] = []
	for treino_id in CATALOGO_TREINOS.keys():
		var dados: Dictionary = CATALOGO_TREINOS[treino_id]
		var ids: Array = dados.get("instrutor_ids", [])
		for idv in ids:
			if str(idv).to_lower() == key or key.find(str(idv).to_lower()) >= 0:
				out.append(str(treino_id))
				break
	return out


func pode_iniciar_treino(treino_id: String) -> Dictionary:
	if not CATALOGO_TREINOS.has(treino_id):
		return {"pode": false, "motivo": "Treino não registrado no catálogo."}

	if ja_concluiu_treino(treino_id):
		return {"pode": false, "motivo": "Você já concluiu este treinamento."}

	var dados: Dictionary = CATALOGO_TREINOS[treino_id]
	var lvl_jogador: int = int(PlayerData.attributes.get("nivel", 1))
	if lvl_jogador < int(dados.get("requisito_nivel", 1)):
		return {"pode": false, "motivo": "Nível insuficiente (requer Nível %d)." % int(dados.get("requisito_nivel", 1))}

	if bool(dados.get("requer_nen", false)) and not PlayerData.despertou_nen:
		return {"pode": false, "motivo": "Desperte o Nen com o Mestre Wing antes deste treino."}

	return {"pode": true, "motivo": "Apto para iniciar"}


func executar_sessao_treino(treino_id: String, _tree: SceneTree = null) -> Dictionary:
	var check: Dictionary = pode_iniciar_treino(treino_id)
	if not check.get("pode", false):
		if EventBus != null:
			EventBus.emit_toast(str(check.get("motivo", "Treino indisponível")), Color(1.0, 0.45, 0.35))
		return {"sucesso": false, "mensagem": check.get("motivo", "")}

	var dados: Dictionary = CATALOGO_TREINOS[treino_id]
	var nome_treino: String = str(dados.get("nome", ""))
	var instrutor: String = str(dados.get("instrutor", ""))
	var desc_recompensa: String = str(dados.get("texto_recompensa", ""))

	var stats_antes: Dictionary = _snapshot_stats()

	treino_iniciado.emit(treino_id, instrutor)
	print("[TrainingSystem] TREINAMENTO INICIADO: %s com %s" % [nome_treino, instrutor])

	_aplicar_recompensas_modificadores(treino_id, dados)

	if dados.has("recompensa_nen_points"):
		PlayerData.nen_skill_points += int(dados["recompensa_nen_points"])

	if not treinos_concluidos.has(treino_id):
		treinos_concluidos.append(treino_id)

	if StoryManager != null:
		StoryManager.set_story_flag("treino_" + treino_id, true)
		StoryManager.set_pacing_state(StoryManager.StoryPacingState.EXPLORATION)

	var stats_depois: Dictionary = _snapshot_stats()
	var delta_txt: String = _formatar_deltas(stats_antes, stats_depois)
	if not delta_txt.is_empty():
		desc_recompensa = "%s (%s)" % [desc_recompensa, delta_txt]

	treino_concluido.emit(treino_id, desc_recompensa)
	print("[TrainingSystem] TREINAMENTO CONCLUÍDO: %s! (%s)" % [nome_treino, desc_recompensa])

	if EventBus != null:
		EventBus.emit_toast("🥋 %s" % desc_recompensa, Color(0.45, 1.0, 0.65))
	if AudioManager != null and AudioManager.has_method("tocar_sfx_tipo"):
		AudioManager.tocar_sfx_tipo("level_up", 1.05)
	if SaveManager != null:
		SaveManager.salvar_jogo()

	return {
		"sucesso": true,
		"treino": nome_treino,
		"recompensa": desc_recompensa,
		"deltas": delta_txt,
	}


func ja_concluiu_treino(treino_id: String) -> bool:
	if treinos_concluidos.has(treino_id):
		return true
	if StoryManager != null and StoryManager.get_story_flag("treino_" + treino_id, false):
		return true
	return false


## Reaplica mods de todos os treinos concluídos (após load / reset de modifiers).
func reaplicar_mods_concluidos() -> void:
	_sincronizar_com_flags()
	for treino_id in treinos_concluidos:
		if not CATALOGO_TREINOS.has(treino_id):
			continue
		_aplicar_recompensas_modificadores(str(treino_id), CATALOGO_TREINOS[treino_id], false)


func _aplicar_recompensas_modificadores(treino_id: String, dados: Dictionary, curar: bool = true) -> void:
	var fonte: String = "treino_%s" % treino_id
	var mapa: Dictionary = {
		"recompensa_aura_max": &"aura_max",
		"recompensa_vida_max": &"vida_max",
		"recompensa_defesa": &"defesa",
		"recompensa_forca": &"forca",
		"recompensa_velocidade": &"velocidade",
	}
	for chave in mapa.keys():
		if not dados.has(chave):
			continue
		var stat: StringName = mapa[chave]
		var valor: float = float(dados[chave])
		var mod_id: StringName = StringName("treino_%s_%s" % [treino_id, String(stat)])
		PlayerData.adicionar_modificador(StatModifier.new(mod_id, stat, StatModifier.Type.FLAT, valor, -1.0, fonte))

	if curar:
		PlayerData.attributes["vida"] = PlayerData.attributes.get("vida_max", 100)
		if PlayerData.despertou_nen:
			PlayerData.attributes["aura"] = PlayerData.attributes.get("aura_max", 0.0)


func _snapshot_stats() -> Dictionary:
	return {
		"vida_max": int(PlayerData.attributes.get("vida_max", 0)),
		"forca": int(PlayerData.attributes.get("forca", 0)),
		"defesa": int(PlayerData.attributes.get("defesa", 0)),
		"velocidade": int(PlayerData.attributes.get("velocidade", 0)),
		"aura_max": int(PlayerData.attributes.get("aura_max", 0)),
		"nen_sp": int(PlayerData.nen_skill_points),
	}


func _formatar_deltas(antes: Dictionary, depois: Dictionary) -> String:
	var partes: PackedStringArray = []
	for k in ["vida_max", "forca", "defesa", "velocidade", "aura_max", "nen_sp"]:
		var d: int = int(depois.get(k, 0)) - int(antes.get(k, 0))
		if d != 0:
			var label: String = str(k).replace("_", " ")
			partes.append("%s %+d" % [label, d])
	return ", ".join(partes)
