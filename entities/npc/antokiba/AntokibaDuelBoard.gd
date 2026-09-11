class_name AntokibaDuelBoard
extends NPC

# Quadro de Antokiba — abre duelo de cartas GI (S4).

var duel_ui: CanvasLayer = null


func _ready() -> void:
	npc_name = "Quadro de Antokiba"
	fala_padrao = "Quer um duelo de cartas? Mostre seu Book — as regras de Antokiba valem aqui!"
	super()


func _on_interacted(player: CharacterBody2D) -> void:
	super(player)
	if duel_ui == null:
		var scene = load("res://ui/GreedIsland/CardDuelUI.tscn")
		if scene:
			duel_ui = scene.instantiate()
		else:
			var UiScript = load("res://ui/GreedIsland/CardDuelUI.gd")
			duel_ui = UiScript.new()
		get_tree().root.add_child(duel_ui)
	if duel_ui.has_method("abrir"):
		duel_ui.abrir("antokiba")
