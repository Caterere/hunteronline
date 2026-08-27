extends NPC

# ============================================================
# HUNTER ONLINE - NPC: EXAMINADOR CHRONO (MISSÕES PARALELAS)
# ============================================================
#
# NPC dimensional do Lobby que gerencia as Missões Paralelas (What-Ifs
# e Áreas de Farm) estilo Dragon Ball Xenoverse.
#
# ============================================================

var pqui_instancia: CanvasLayer = null


func _ready() -> void:
	super()
	npc_name = "Examinador Chrono"
	fala_padrao = "Saudações, Hunter! As fendas temporais de Nen revelam batalhas paralelas e cenários alternativos (What-Ifs) para você treinar e farmar!"
	
	# Se a UI não existir na árvore, instanciar
	call_deferred("_garantir_ui")


func _garantir_ui() -> void:
	var root = get_tree().root
	var ui = root.find_child("ParallelQuestUI", true, false)
	if ui != null and ui is CanvasLayer:
		pqui_instancia = ui
	else:
		var scene = load("res://ui/ParallelQuest/ParallelQuestUI.tscn")
		if scene:
			pqui_instancia = scene.instantiate()
			root.add_child(pqui_instancia)


func _on_interacted(_player: CharacterBody2D) -> void:
	print("[ParallelQuestNPC] Abrindo Fendas Dimensionais de Nen...")
	falar_balao("Selecione uma Fenda Temporal (What-If) para desafiar!", 2.5, Color(0.2, 0.8, 1.0, 1.0), Color(0.3, 0.9, 1.0, 1.0))
	
	if pqui_instancia == null or not is_instance_valid(pqui_instancia):
		_garantir_ui()
		
	if pqui_instancia != null and is_instance_valid(pqui_instancia):
		pqui_instancia.call("abrir")
