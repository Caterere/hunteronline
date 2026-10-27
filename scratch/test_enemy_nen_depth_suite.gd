extends Node2D

## Profundidade HxH: arquétipos, resistências, Hatsus e tags no dano do jogador.

const Kit = preload("res://scripts/systems/EnemySystem/EnemyNenKit.gd")

var total: int = 0
var passed: int = 0
var failed: int = 0


func _ready() -> void:
	print("\n=== ENEMY NEN DEPTH / BALANCE ===")
	_test_profiles_enrich()
	_test_named_hatsus()
	_test_defense_tags()
	_test_ai_hatsu_dispatch()
	_test_datamanager_bestiary()
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


func _test_profiles_enrich() -> void:
	print("\n[1] Enrich perfil + balance")
	var ed := EnemyData.new()
	ed.enemy_id = &"sentinela_pedra"
	ed.enemy_name = "Sentinela"
	ed.max_health = 160
	ed.strength = 18
	ed.defense = 10
	ed.xp_reward = 120
	ed.role = "bruiser"
	Kit.enrich(ed)
	_ok(ed.role == "tank", "sentinela → role tank")
	_ok(ed.hatsu_name == "Muralha de Pedra", "hatsu muralha")
	_ok(ed.weakness_tags.has("ko") or ed.weakness_tags.has("blunt"), "fraqueza ko/blunt")
	_ok(ed.resistance_tags.has("slashing"), "resiste slashing")
	_ok(ed.max_health > 160, "HP balanceado para cima")
	_ok(Kit.move_speed_mult(ed) < 1.0, "tank mais lento")
	_ok(Kit.attack_pattern(ed) == "guard_bash", "padrão guard_bash")

	var formiga := EnemyData.new()
	formiga.enemy_id = &"formiga_soldado"
	formiga.enemy_name = "Formiga"
	formiga.max_health = 2000
	formiga.strength = 95
	formiga.defense = 50
	Kit.enrich(formiga)
	_ok(formiga.hatsu_name == "Garras Quimera", "formiga tem Garras Quimera")
	_ok(formiga.nen_type == Kit.NEN_INTENSIFICACAO, "nen Intensificação")
	_ok(Kit.move_speed_mult(formiga) > 1.0, "formiga rápida")


func _test_named_hatsus() -> void:
	print("\n[2] Hatsu sintético por nome")
	var ed := EnemyData.new()
	ed.enemy_id = &"iniciado_nen_sombrio"
	ed.enemy_name = "Iniciado"
	ed.level = 6
	ed.strength = 20
	ed.hatsu_name = "Sombra Drenante"
	var h: HatsuData = Kit.build_named_hatsu(ed)
	_ok(h != null and h.nome == "Sombra Drenante", "build sombra drenante")
	_ok(h.categoria == HatsuData.Categoria.MANIPULACAO, "categoria Manipulação")
	_ok(h.tags.has("nen"), "tags incluem nen")

	ed.hatsu_name = "Garras Quimera"
	var h2: HatsuData = Kit.build_named_hatsu(ed)
	_ok(h2 != null and h2.categoria == HatsuData.Categoria.INTENSIFICACAO, "garras = Intensificação")

	ed.obter_hatsu_real()
	_ok(ed.modular_hatsu != null, "obter_hatsu_real preenche modular_hatsu")


func _test_defense_tags() -> void:
	print("\n[3] Tags no dano de Hatsu do jogador")
	var ed := EnemyData.new()
	ed.enemy_id = &"golem_pedra"
	ed.enemy_name = "Golem"
	Kit.enrich(ed)
	var h_slash := HatsuData.new()
	h_slash.categoria = HatsuData.Categoria.CONJURACAO # → piercing tags
	h_slash.forma = HatsuData.Forma.TOQUE
	var r1: Dictionary = Kit.apply_defense_tags(100.0, ed, h_slash)
	_ok(bool(r1.get("is_resisted", false)) or float(r1.get("dano", 100)) < 100.0, "golem resiste piercing/conjuração")

	var h_ko := HatsuData.new()
	h_ko.categoria = HatsuData.Categoria.INTENSIFICACAO # blunt+ko
	h_ko.forma = HatsuData.Forma.TOQUE
	var r2: Dictionary = Kit.apply_defense_tags(100.0, ed, h_ko)
	_ok(bool(r2.get("is_weakness", false)) or float(r2.get("dano", 0)) > 100.0, "golem fraco a ko/blunt")

	var meruem := EnemyData.new()
	meruem.enemy_id = &"boss_meruem"
	meruem.enemy_name = "Meruem"
	Kit.enrich(meruem)
	var h_poison := HatsuData.new()
	h_poison.tags = ["poison"]
	h_poison.categoria = HatsuData.Categoria.TRANSFORMACAO
	var r3: Dictionary = Kit.apply_defense_tags(100.0, meruem, h_poison)
	_ok(bool(r3.get("is_immune", false)) or float(r3.get("dano", 1)) == 0.0, "Meruem imune a poison")


func _test_ai_hatsu_dispatch() -> void:
	print("\n[4] AI dispara Hatsus de arquétipo")
	# Instancia mínima sem depender da cena Enemy completa
	var body := CharacterBody2D.new()
	body.name = "TestEnemyBody"
	add_child(body)
	body.global_position = Vector2(140, 100)
	var player_proxy := CharacterBody2D.new()
	player_proxy.name = "PlayerProxy"
	player_proxy.add_to_group("player")
	add_child(player_proxy)
	player_proxy.global_position = Vector2(100, 100)

	var es := EnemySystem.new()
	body.add_child(es)
	var ai := EnemyAI.new()
	body.add_child(ai)
	ai.enemy_body = body
	ai.enemy_system = es
	ai.player = player_proxy

	var cases := [
		{"id": "guardiao_elite", "name": "Guardião Elite", "needle": "muralha"},
		{"id": "formiga_soldado", "name": "Formiga Chimera Soldado", "needle": "garras"},
		{"id": "iniciado_nen_sombrio", "name": "Iniciado Nen", "needle": "sombra"},
	]
	for c in cases:
		var data := EnemyData.new()
		data.enemy_id = StringName(str(c["id"]))
		data.enemy_name = str(c["name"])
		data.max_health = 200
		data.strength = 20
		data.defense = 8
		Kit.enrich(data)
		es.enemy_data = data
		es.enemy_name = data.enemy_name
		es.strength = data.strength
		es.max_health = data.max_health
		es.health = data.max_health
		var ok_name := ai._tentar_hatsu_por_nome(Vector2.RIGHT, str(data.hatsu_name))
		_ok(ok_name, "AI hatsu '%s' via nome" % str(c["needle"]))
		ai.executar_hatsu_inimigo()
		_ok(true, "executar_hatsu_inimigo sem crash (%s)" % c["id"])

	body.queue_free()
	player_proxy.queue_free()


func _test_datamanager_bestiary() -> void:
	print("\n[5] DataManager bestiário enriquecido")
	if DataManager == null:
		_ok(false, "DataManager ausente")
		return
	var sent = DataManager.get_enemy(&"sentinela_pedra") as EnemyData
	_ok(sent != null, "sentinela no registry")
	if sent != null:
		_ok(not sent.resistance_tags.is_empty() or not sent.weakness_tags.is_empty(), "tags presentes após get_enemy")
		_ok(not sent.hatsu_name.is_empty() or sent.role == "tank", "perfil aplicado")
	var ini = DataManager.get_enemy(&"iniciado_nen_sombrio") as EnemyData
	_ok(ini != null and ini.npc_tier >= 2, "iniciado tier ≥ 2")
