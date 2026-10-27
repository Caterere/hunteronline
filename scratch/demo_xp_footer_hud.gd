extends Node2D
## Demo visual: HUD só com footer XP (sem barra ornamentada no card).

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.25, 0.55, 0.28)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var layer := CanvasLayer.new()
	layer.layer = -10
	add_child(layer)
	layer.add_child(bg)

	var hud_scene: PackedScene = load("res://ui/hud/HUD.tscn")
	var hud: CanvasLayer = hud_scene.instantiate()
	add_child(hud)

	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.35).timeout

	var img: Image = get_viewport().get_texture().get_image()
	img.save_png("/opt/cursor/artifacts/xp_footer_hud_demo.png")
	print("DEMO_SHOT_SAVED bar_xp=", hud.bar_xp, " footer=", hud.get_node_or_null("XpFooterBar") != null)
	await get_tree().process_frame
	get_tree().quit(0)
