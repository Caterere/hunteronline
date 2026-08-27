class_name EstatuaNetero
extends StaticBody2D

# ============================================================
# HUNTER ONLINE - MONUMENTO: ESTÁTUA DE ISAAC NETERO
# ============================================================
#
# Monumento em homenagem ao 12º Presidente da Associação Hunter.
# Ao rezar/interagir, restaura 100% da vida e aura e acumula
# a provação dos 10.000 Socos de Gratidão de Netero.
#
# ============================================================

@onready var interaction: InteractionComponent = $InteractionComponent as InteractionComponent


func _ready() -> void:
	if interaction != null:
		interaction.interaction_text = "[E] Orar & Meditar na Estátua de Netero"
		if not interaction.interacted.is_connected(_on_interacted):
			interaction.interacted.connect(_on_interacted)


func _on_interacted(_player: CharacterBody2D) -> void:
	var hp_max: int = int(PlayerData.attributes.get("vida_max", 100))
	var aura_max: float = float(PlayerData.attributes.get("aura_max", 0.0))
	PlayerData.attributes["vida"] = hp_max
	PlayerData.attributes["aura"] = aura_max

	var res_meditacao = SurpriseQuestSystem.meditar_estatua_netero() if SurpriseQuestSystem else {}
	var texto_progresso = res_meditacao.get("texto", "Você medita e presta seus respeitos a Isaac Netero.")
	var recompensa = res_meditacao.get("recompensa", "+100% Vida e Aura Restauradas!")

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null:
		var falas: Array[Dictionary] = [
			{"falante": "Estátua de Isaac Netero", "texto": "“A verdadeira força nasce da gratidão diária.”"},
			{"falante": "Bênção de Netero", "texto": "✨ %s\nRecompensa: %s" % [texto_progresso, recompensa]}
		]
		visual_dialogue.exibir_sequencia_falas(falas)
	else:
		print("[EstatuaNetero] ", texto_progresso)
