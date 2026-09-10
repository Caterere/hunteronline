extends Node

# ============================================================
# HUNTER ONLINE — Arena PvP assíncrono (ghosts / Bestas de Nen)
# ============================================================

const ArenaGhostRegistry = preload("res://scripts/systems/arena/ArenaGhostRegistry.gd")

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 ARENA ASYNC PVP (GHOST / BESTA) SUITE")
	print("================================================================================")
	await get_tree().process_frame
	_test_registry_core()
	await _test_tower_async_spawn()
	print("\n================================================================================")
	print("🏆 RESULTADO: %d / %d" % [_passed, _total])
	if not _failures.is_empty():
		for f in _failures:
			print("   ❌ ", f)
	print("================================================================================\n")
	get_tree().quit(0 if _passed == _total else 1)


func _ok(cond: bool, label: String) -> void:
	_total += 1
	if cond:
		_passed += 1
		print("  ✅ ", label)
	else:
		_failures.append(label)
		print("  ❌ ", label)


func _test_registry_core() -> void:
	print("\n[1] ArenaGhostRegistry...")
	ArenaGhostRegistry.limpar()
	_ok(ArenaGhostRegistry.listar().is_empty(), "Lista limpa")
	_ok(ArenaGhostRegistry.deve_usar_oponente_async(5), "Andar 5 usa async")
	_ok(ArenaGhostRegistry.deve_usar_oponente_async(10), "Andar 10 usa async")
	_ok(not ArenaGhostRegistry.deve_usar_oponente_async(7), "Andar 7 não usa async")

	PlayerData.attributes["nome"] = "Gon Teste"
	PlayerData.attributes["nivel"] = 12
	PlayerData.attributes["vida_max"] = 180
	PlayerData.attributes["forca"] = 22
	PlayerData.attributes["defesa"] = 14
	PlayerData.despertou_nen = true

	var snap := ArenaGhostRegistry.capturar_do_jogador(8)
	_ok(snap.get("nome") == "Gon Teste", "Captura nome")
	_ok(int(snap.get("andar_origem", 0)) == 8, "Captura andar")
	_ok(int(snap.get("max_health", 0)) == 180, "Captura HP")
	ArenaGhostRegistry.registrar(snap)
	_ok(ArenaGhostRegistry.listar().size() == 1, "Ghost registrado")

	var rival := ArenaGhostRegistry.obter_oponente_async(10)
	_ok(str(rival.get("kind", "")) == "ghost", "Andar 10 puxa ghost local")
	_ok(str(rival.get("nome", "")) == "Gon Teste", "Ghost mantém nome")
	_ok(int(rival.get("max_health", 0)) >= 180, "Ghost escala com delta de andar")

	ArenaGhostRegistry.limpar()
	var proxy := ArenaGhostRegistry.obter_oponente_async(15)
	_ok(str(proxy.get("kind", "")) == "nen_beast", "Sem ghost → proxy besta")
	_ok(str(proxy.get("nome", "")).contains("Besta") or str(proxy.get("nome", "")).contains("Miragem") or str(proxy.get("nome", "")).contains("Projeção") or str(proxy.get("nome", "")).contains("Eco") or str(proxy.get("nome", "")).contains("Sombra"), "Proxy temático (%s)" % proxy.get("nome", ""))


func _test_tower_async_spawn() -> void:
	print("\n[2] CelestialTowerArena spawn async...")
	var MapScript = load("res://world/maps/CelestialTowerArena.gd")
	_ok(MapScript != null, "CelestialTowerArena.gd carrega")
	if MapScript == null:
		return

	ArenaGhostRegistry.limpar()
	# Sem Player node da cena — instancia só a lógica via new() e chama helpers.
	var torre = MapScript.new()
	torre.name = "TorreAsyncTest"
	# Não entra na árvore: evita _ready (precisa $Player da cena).
	torre.lbl_recompensa_info = Label.new()
	torre.lbl_andar_info = Label.new()

	torre._spawnar_desafiantes(5)
	await get_tree().process_frame
	var async_node = null
	for c in torre.get_children():
		if str(c.name).begins_with("AsyncRival_"):
			async_node = c
			break
	_ok(async_node != null, "Spawn AsyncRival no andar 5")
	_ok(torre._oponente_async_ativo == true, "Flag async ativa")
	if async_node != null:
		var sys = async_node.get_node_or_null("EnemySystem")
		_ok(sys != null, "EnemySystem no rival")
		if sys != null:
			_ok(sys.enemy_id == &"arena_nen_beast_proxy" or sys.enemy_id == &"arena_ghost", "enemy_id async (%s)" % sys.enemy_id)

	# Registrar ghost e re-spawnar
	ArenaGhostRegistry.registrar(ArenaGhostRegistry.capturar_do_jogador(5))
	for c in torre.get_children():
		if str(c.name).begins_with("AsyncRival_") or str(c.name).begins_with("Gladiador_"):
			c.free()
	torre._spawnar_desafiantes(10)
	await get_tree().process_frame
	var ghost_rival = null
	for c in torre.get_children():
		if str(c.name).begins_with("AsyncRival_ghost"):
			ghost_rival = c
			break
	_ok(ghost_rival != null, "Spawn ghost após registro")
	if ghost_rival != null:
		var gsys = ghost_rival.get_node_or_null("EnemySystem")
		_ok(gsys != null and gsys.enemy_id == &"arena_ghost", "enemy_id arena_ghost")

	torre.free()
	ArenaGhostRegistry.limpar()
	PlayerData.despertou_nen = false
