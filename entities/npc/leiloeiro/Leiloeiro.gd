class_name LeiloeiroNPC
extends NPC

# Leiloeiro do Underground de Yorknew — abre AuctionHouseUI.

var ui_instance: CanvasLayer = null


func _ready() -> void:
	npc_name = "Leiloeiro do Underground"
	fala_padrao = "Bem-vindo ao leilão de Yorknew. Escrow garantido pela casa — taxa de 5% na listagem."
	super()


func _on_interacted(player: CharacterBody2D) -> void:
	super(player)
	if ui_instance == null:
		var scene = load("res://ui/Auction/AuctionHouseUI.tscn")
		if scene:
			ui_instance = scene.instantiate()
		else:
			var UiScript = load("res://ui/Auction/AuctionHouseUI.gd")
			ui_instance = UiScript.new()
		get_tree().root.add_child(ui_instance)
	if ui_instance.has_method("abrir"):
		ui_instance.abrir()
