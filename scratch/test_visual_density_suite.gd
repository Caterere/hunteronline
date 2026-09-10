extends Node2D

## Smoke: densidade visual Kukuroo / Arena / Floresta / Estrada (sem PixelLab API).

var _ok := 0
var _fail := 0


func _ready() -> void:
	print("\n=== VISUAL DENSITY SMOKE ===")
	await _test_decorator_arena_kind()
	await _test_kukuroo()
	await _test_arena()
	await _test_floresta()
	await _test_estrada()
	print("=== RESULTADO %d ok / %d fail ===" % [_ok, _fail])
	await get_tree().process_frame
	get_tree().quit(0 if _fail == 0 else 1)


func _assert(cond: bool, msg: String) -> void:
	if cond:
		_ok += 1
		print("  OK  ", msg)
	else:
		_fail += 1
		print("  FAIL", msg)


func _test_decorator_arena_kind() -> void:
	print("[decorator]")
	_assert(MapAtmosphereDecorator.MapKind.ARENA >= 0, "MapKind.ARENA existe")
	var probe := Node2D.new()
	probe.name = "ProbeArena"
	add_child(probe)
	var dec := MapAtmosphereDecorator.attach(probe, MapAtmosphereDecorator.MapKind.ARENA)
	_assert(dec != null, "attach ARENA")
	await get_tree().process_frame
	_assert(probe.get_node_or_null("MapAtmosphereDecorator") != null, "decorator child")
	probe.queue_free()
	await get_tree().process_frame


func _test_kukuroo() -> void:
	print("[kukuroo]")
	var scn = load("res://world/maps/montanha_kukuroo.tscn")
	_assert(scn != null, "montanha_kukuroo.tscn")
	if scn == null:
		return
	var mapa = scn.instantiate()
	add_child(mapa)
	await get_tree().process_frame
	await get_tree().process_frame
	var fillers := 0
	for n in ["MordomoAmbient_A", "MordomoAmbient_B", "MordomoAmbient_C", "MordomoAmbient_D"]:
		if mapa.get_node_or_null(n) != null:
			fillers += 1
	_assert(fillers >= 4, "mordomos ambient >=4 (%d)" % fillers)
	_assert(mapa.get_node_or_null("PlacaKukuPortao") != null, "placa portão")
	_assert(mapa.get_node_or_null("PlacaKukuAlameda") != null, "placa alameda")
	_assert(mapa.get_node_or_null("ZetsuArbustoAlameda") != null, "zetsu alameda")
	_assert(mapa.get_node_or_null("JardineiroZoldyck") != null, "jardineiro vivo")
	_assert(
		mapa.get_node_or_null("MapAtmosphereDecorator/AtmosphereProps/LanternaPedraKuku_900") != null,
		"lanterna pedra PixelLab"
	)
	_assert(mapa.get_node_or_null("MordomoAmbient_E") != null, "mordomo ambient E")
	mapa.queue_free()
	await get_tree().process_frame


func _test_arena() -> void:
	print("[arena]")
	var scn = load("res://world/maps/arena_celestial.tscn")
	_assert(scn != null, "arena_celestial.tscn")
	if scn == null:
		return
	var mapa = scn.instantiate()
	add_child(mapa)
	await get_tree().process_frame
	await get_tree().process_frame
	_assert(mapa.get_node_or_null("MapAtmosphereDecorator") != null, "arena atmosphere")
	var rec = mapa.get_node_or_null("Recepcionista")
	_assert(rec != null, "recepcionista")
	if rec != null:
		var spr = rec.get_node_or_null("Sprite2D") as Sprite2D
		_assert(spr != null and spr.texture != null, "recepcionista texture")
		if spr != null and spr.texture != null:
			var path := str(spr.texture.resource_path)
			_assert(not path.ends_with("player.png"), "recepcionista não usa player.png (%s)" % path)
	_assert(mapa.get_node_or_null("LutadorAmbient_A") != null, "lutador ambient A")
	_assert(mapa.get_node_or_null("LutadorAmbient_E") != null, "lutador ambient E")
	_assert(mapa.get_node_or_null("PlacaAndar1") != null, "placa andar")
	mapa.queue_free()
	await get_tree().process_frame


func _test_floresta() -> void:
	print("[floresta]")
	var scn = load("res://world/maps/floresta_vestigios.tscn")
	_assert(scn != null, "floresta_vestigios.tscn")
	if scn == null:
		return
	var mapa = scn.instantiate()
	add_child(mapa)
	await get_tree().process_frame
	await get_tree().process_frame
	var arv = mapa.get_node_or_null("ArvoreMilenar")
	_assert(arv != null, "árvore milenar")
	if arv != null:
		var spr: Sprite2D = null
		for c in arv.get_children():
			if c is Sprite2D:
				spr = c
				break
		if spr != null and spr.texture != null:
			_assert(not str(spr.texture.resource_path).ends_with("player.png"), "árvore sem player.png")
	_assert(mapa.get_node_or_null("DetalhesClareira") != null, "detalhes clareira")
	mapa.queue_free()
	await get_tree().process_frame


func _test_estrada() -> void:
	print("[estrada]")
	var scn = load("res://world/maps/estrada_padokia.tscn")
	_assert(scn != null, "estrada_padokia.tscn")
	if scn == null:
		return
	var mapa = scn.instantiate()
	add_child(mapa)
	await get_tree().process_frame
	await get_tree().process_frame
	_assert(mapa.get_node_or_null("ViajantePatrulha") != null, "viajante vivo")
	_assert(mapa.get_node_or_null("GuardaItinerante") != null, "guarda itinerante")
	_assert(mapa.get_node_or_null("LanternasEstradaExtra") != null, "lanternas extras")
	mapa.queue_free()
	await get_tree().process_frame
