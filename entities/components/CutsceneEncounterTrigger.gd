class_name CutsceneEncounterTrigger
extends Node2D

# ============================================================
# HUNTER ONLINE - CUTSCENE ENCOUNTER TRIGGER (GATILHO DE PROXIMIDADE)
# ============================================================
#
# Detecta a aproximação do jogador em relação ao personagem do mangá
# e aciona a cutscene cinematográfica de entrada automaticamente
# sem necessidade de pressionar 'E'.
#
# ============================================================

@export var character_id: String = ""
@export var trigger_distance: float = 95.0
@export var trigger_once: bool = true

var parent_node: Node = null


func _ready() -> void:
	parent_node = get_parent()
	if character_id.is_empty() and parent_node != null:
		var p_name: String = parent_node.name.to_lower()
		if "hisoka" in p_name: character_id = "hisoka"
		elif "chrollo" in p_name: character_id = "chrollo"
		elif "netero" in p_name: character_id = "netero"
		elif "illumi" in p_name: character_id = "illumi"
		elif "uvogin" in p_name: character_id = "uvogin"
		elif "feitan" in p_name: character_id = "feitan"
		elif "pitou" in p_name: character_id = "pitou"
		elif "meruem" in p_name: character_id = "meruem"
		elif "genthru" in p_name: character_id = "genthru"
		elif "razor" in p_name: character_id = "razor"
		elif "wing" in p_name: character_id = "wing"
		elif "biscuit" in p_name: character_id = "biscuit"
		elif "kurapika" in p_name: character_id = "kurapika"
		elif "killua" in p_name: character_id = "killua"
		else: character_id = p_name


func _process(_delta: float) -> void:
	if CinematicManager.em_cutscene: return
	if character_id.is_empty(): return

	var chave: String = "cutscene_vista_" + character_id
	if trigger_once and PlayerData.quest_states.get(chave, false):
		return

	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty(): return

	var player = players[0] as Node2D
	if not is_instance_valid(player): return

	var dist: float = global_position.distance_to(player.global_position)
	if dist <= trigger_distance:
		print("[CutsceneEncounterTrigger] Jogador aproximou-se de '%s' (Dist: %.1fpx) -> Disparando Cutscene!" % [character_id, dist])
		CinematicManager.tocar_entrada_personagem(character_id, parent_node)
