extends Node

## Demo visual: fundo colorido + HUD glass + combat log (opacidade legível).

func _ready() -> void:
	# Fundo com padrão para provar semi-transparência dos painéis
	var bg := ColorRect.new()
	bg.color = Color(0.28, 0.42, 0.32, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var layer_bg := CanvasLayer.new()
	layer_bg.layer = -10
	add_child(layer_bg)
	layer_bg.add_child(bg)
	for i in range(12):
		var stripe := ColorRect.new()
		stripe.color = Color(0.35, 0.55, 0.38, 0.55) if i % 2 == 0 else Color(0.22, 0.34, 0.26, 0.55)
		stripe.position = Vector2(0, i * 48)
		stripe.size = Vector2(2000, 48)
		layer_bg.add_child(stripe)

	await get_tree().process_frame
	var hud_script = load("res://ui/hud/PlayerHUD.gd")
	if hud_script == null:
		push_error("PlayerHUD missing")
		get_tree().quit(1)
		return
	var hud = hud_script.new()
	hud.name = "PlayerHUD"
	add_child(hud)
	await get_tree().process_frame
	await get_tree().create_timer(0.35).timeout

	if hud.chat_hud != null and hud.chat_hud.has_method("adicionar_sistema"):
		hud.chat_hud.adicionar_sistema("Gained 120 XP", Color(1.0, 0.92, 0.45))
		hud.chat_hud.adicionar_sistema("Gained 8 SP", Color(0.45, 0.78, 1.0))
		hud.chat_hud.adicionar_sistema("Looted Jenny x14", Color(1.0, 0.78, 0.25))
		hud.chat_hud.adicionar_sistema("Looted Spider Silk x1", Color(0.95, 0.9, 0.85))
	if EventBus != null:
		EventBus.jenny_changed.emit(100, 25)
		EventBus.item_obtained.emit("carne_javali", 2)

	print("[demo_mmo_hud] glass opacity demo ready")
