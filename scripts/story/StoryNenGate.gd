class_name StoryNenGate
extends RefCounted

# ============================================================
# HUNTER ONLINE — GATES DE NEN NA HISTÓRIA (FASE 2/3)
# ============================================================
#
# Desbloqueia técnicas canônicas em marcos de Wing / Biscuit
# sem exigir SP da árvore. Persiste em PlayerData.tecnicas_nen.
#
# ============================================================


## Desbloqueia uma técnica (ten/ren/zetsu/gyo/shu/ko/ken/ryu/en).
## Retorna true se acabou de liberar (false se já estava ou falhou).
static func garantir_tecnica(tree: SceneTree, tecnica_id: StringName) -> bool:
	var tid := StringName(str(tecnica_id).strip_edges().to_lower())
	if tid.is_empty():
		return false

	var nen: NenSystem = _obter_nen(tree)
	var ja_tinha := false
	if nen != null and nen.has_method("esta_desbloqueada"):
		ja_tinha = bool(nen.esta_desbloqueada(tid))
	elif PlayerData != null and PlayerData.tecnicas_nen is Dictionary:
		var info = PlayerData.tecnicas_nen.get(str(tid), {})
		if info is Dictionary:
			ja_tinha = bool(info.get("desbloqueada", false))

	if nen != null and nen.has_method("desbloquear_tecnica"):
		nen.desbloquear_tecnica(tid)

	_persistir_playerdata(tid)

	if not ja_tinha and EventBus != null and EventBus.has_method("emit_toast"):
		EventBus.emit_toast("✨ Nen liberado: %s" % str(tid).to_upper(), Color(0.45, 0.95, 0.7))
	return not ja_tinha


## Atalho: libera o pacote Ten→Ren→Zetsu→Gyo do dojo Wing (etapas 11–14).
static func garantir_pacote_wing(tree: SceneTree, ate_etapa: int) -> void:
	if ate_etapa >= 11:
		garantir_tecnica(tree, &"ten")
	if ate_etapa >= 12:
		garantir_tecnica(tree, &"ren")
	if ate_etapa >= 13:
		garantir_tecnica(tree, &"zetsu")
	if ate_etapa >= 14:
		garantir_tecnica(tree, &"gyo")


## Pacote avançado Biscuit (Ko/Shu/Ken/Ryu) em GI.
static func garantir_pacote_biscuit(tree: SceneTree, ate_etapa: int) -> void:
	if ate_etapa >= 7:
		garantir_tecnica(tree, &"ko")
	if ate_etapa >= 9:
		garantir_tecnica(tree, &"shu")
	if ate_etapa >= 10:
		garantir_tecnica(tree, &"ken")
	if ate_etapa >= 11:
		garantir_tecnica(tree, &"ryu")


## Conclui um treino do TrainingSystem se ainda não feito (marco de história).
static func concluir_treino_marco(tree: SceneTree, treino_id: String) -> bool:
	var ts: TrainingSystem = TrainingSystem.obter_ou_criar(tree)
	if ts == null:
		return false
	if ts.ja_concluiu_treino(treino_id):
		return false
	var resultado: Dictionary = ts.executar_sessao_treino(treino_id, tree)
	return bool(resultado.get("sucesso", false))


static func _obter_nen(tree: SceneTree) -> NenSystem:
	if tree == null:
		return null
	var player = tree.get_first_node_in_group("player")
	if player != null:
		var nen = player.get_node_or_null("NenSystem")
		if nen is NenSystem:
			return nen as NenSystem
	var qualquer = tree.get_first_node_in_group("nen_system")
	if qualquer is NenSystem:
		return qualquer as NenSystem
	return null


static func _persistir_playerdata(tecnica_id: StringName) -> void:
	if PlayerData == null:
		return
	if not (PlayerData.tecnicas_nen is Dictionary):
		PlayerData.tecnicas_nen = {}
	var key := str(tecnica_id).to_lower()
	var cur = PlayerData.tecnicas_nen.get(key, {})
	var nivel := 1
	var xp := 0
	if cur is Dictionary:
		nivel = maxi(1, int(cur.get("nivel", 1)))
		xp = int(cur.get("xp", 0))
	PlayerData.tecnicas_nen[key] = {
		"nivel": nivel,
		"xp": xp,
		"desbloqueada": true,
	}
