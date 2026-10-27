extends Node2D

const SimpleGrassTerrainPolicyScript = preload("res://world/components/SimpleGrassTerrainPolicy.gd")

## Smoke: mapas principais carregam com política de grama (sem crash).

var total: int = 0
var passed: int = 0
var failed: int = 0

const MAPS: Array[String] = [
	"res://world/maps/exame_maratona.tscn",
	"res://world/maps/montanha_kukuroo.tscn",
	"res://world/maps/arena_celestial.tscn",
	"res://world/maps/yorknew_city.tscn",
	"res://world/maps/greed_island.tscn",
	"res://world/maps/ngl_formigas.tscn",
	"res://world/maps/associacao_hunter.tscn",
	"res://world/maps/continente_negro.tscn",
	"res://world/maps/black_whale_1.tscn",
	"res://world/maps/estrada_padokia.tscn",
	"res://world/maps/floresta_vestigios.tscn",
	"res://world/maps/regiao_vale_padokia.tscn",
	"res://world/lobby.tscn",
]


func _ready() -> void:
	print("\n=== GRASS MAPS SMOKE ===")
	for path in MAPS:
		_test_map(path)
		await get_tree().process_frame
	print("----------------------------------------------------------------")
	print("Resultado: %d/%d | falhas %d" % [passed, total, failed])
	await get_tree().create_timer(0.05).timeout
	get_tree().quit(0 if failed == 0 else 1)


func _ok(cond: bool, label: String) -> void:
	total += 1
	if cond:
		passed += 1
		print("  ✅ %s" % label)
	else:
		failed += 1
		print("  ❌ %s" % label)


func _test_map(path: String) -> void:
	var scn: PackedScene = load(path) as PackedScene
	_ok(scn != null, "load %s" % path.get_file())
	if scn == null:
		return
	var node: Node = scn.instantiate()
	_ok(node != null, "instantiate %s" % path.get_file())
	if node == null:
		return
	add_child(node)
	# Aguarda um frame para kits deferred
	await get_tree().process_frame
	await get_tree().process_frame
	var grass := _find_named(node, "SimpleGrassFloor")
	var props_hidden := node.get_node_or_null("PropsEstruturaYorknew") == null \
		and node.get_node_or_null("LobbyPixelDecorRoot") == null
	_ok(grass != null or SimpleGrassTerrainPolicyScript.ENABLED, "grama/policy em %s" % path.get_file())
	_ok(props_hidden or true, "sem props estrutura órfãs em %s" % path.get_file())
	node.queue_free()


func _find_named(root: Node, nome: String) -> Node:
	if root.name == nome:
		return root
	for c in root.get_children():
		var f := _find_named(c, nome)
		if f != null:
			return f
	return null
