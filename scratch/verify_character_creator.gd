extends Node2D

var total_testes: int = 0
var testes_passaram: int = 0
var testes_falharam: int = 0

func _ready() -> void:
	print("============================================================")
	print("TEST SUITE: CHARACTER CREATOR & MODULAR RENDERER (12 CAMADAS)")
	print("============================================================")
	
	_testar_character_appearance()
	_testar_presets_e_database()
	_testar_character_renderer()
	_testar_cena_character_creator_test()
	
	print("============================================================")
	print("RESULTADO FINAL: %d/%d TESTES PASSARAM (%d FALHAS)" % [testes_passaram, total_testes, testes_falharam])
	print("============================================================")
	
	if testes_falharam == 0:
		print("🎉 SISTEMA DE CRIAÇÃO E RENDERIZAÇÃO MODULAR VALIDADO COM 100% DE SUCESSO!")
	else:
		push_error("❌ ALGUNS TESTES FALHARAM!")
		
	await get_tree().process_frame
	get_tree().quit(0 if testes_falharam == 0 else 1)


func assert_true(condicao: bool, mensagem: String) -> void:
	total_testes += 1
	if condicao:
		testes_passaram += 1
		print("  ✅ [PASSOU] ", mensagem)
	else:
		testes_falharam += 1
		print("  ❌ [FALHOU] ", mensagem)


func _testar_character_appearance() -> void:
	print("\n--- [TESTE 1: CHARACTER APPEARANCE & SERIALIZAÇÃO] ---")
	
	var app = CharacterAppearance.new()
	app.character_id = "test_hunter"
	app.name = "Killua Teste"
	app.hair_id = "hair_killua_01"
	app.shirt_id = "shirt_tank_01"
	
	var dict = app.to_dict()
	assert_true(dict.has("hair_id") and dict["hair_id"] == "hair_killua_01", "to_dict() serializa propriedades corretamente")
	
	var app_restaurado = CharacterAppearance.from_dict(dict)
	assert_true(app_restaurado.name == "Killua Teste", "from_dict() restaura dados de aparência perfeitamente")
	assert_true(app_restaurado.hair_id == "hair_killua_01", "Propriedades modulares preservadas na desserialização")


func _testar_presets_e_database() -> void:
	print("\n--- [TESTE 2: PRESETS CANÔNICOS & DATABASE] ---")
	
	var gon = CharacterAssetDatabase.obter_preset("GON")
	assert_true(gon.name == "Gon Freecss" and gon.hair_id == "hair_gon_01", "Preset Gon carregado com sucesso")
	
	var killua = CharacterAssetDatabase.obter_preset("KILLUA")
	assert_true(killua.name == "Killua Zoldyck" and killua.hair_id == "hair_killua_01", "Preset Killua carregado com sucesso")
	
	var kurapika = CharacterAssetDatabase.obter_preset("KURAPIKA")
	assert_true(kurapika.name == "Kurapika" and kurapika.accessory_id == "acc_earring_kurta", "Preset Kurapika carregado com sucesso")
	
	var leorio = CharacterAssetDatabase.obter_preset("LEORIO")
	assert_true(leorio.name == "Leorio Paradinight" and leorio.accessory_id == "acc_sunglasses_01", "Preset Leorio carregado com sucesso")
	
	var rand_app = CharacterAssetDatabase.gerar_aparencia_aleatoria()
	assert_true(rand_app.character_id.begins_with("npc_"), "Gerador aleatório cria aparências válidas")


func _testar_character_renderer() -> void:
	print("\n--- [TESTE 3: CHARACTER RENDERER (12 CAMADAS SINCRONIZADAS)] ---")
	
	var renderer = CharacterRenderer.new()
	add_child(renderer)
	
	assert_true(renderer.layers.size() == 12, "Renderer constrói exatamente 12 camadas modulares")
	assert_true(renderer.layers.has("BaseSkin") and renderer.layers.has("HairFront"), "Camadas essenciais presentes")
	
	# Testar troca de direção
	renderer.set_direction(CharacterRenderer.Direction.RIGHT)
	assert_true(renderer.current_direction == CharacterRenderer.Direction.RIGHT, "Direção alterada para RIGHT")
	
	renderer.set_direction(CharacterRenderer.Direction.UP)
	assert_true(renderer.current_direction == CharacterRenderer.Direction.UP, "Direção alterada para UP (Costas)")
	
	# Testar animação
	renderer.play_animation("walk")
	assert_true(renderer.current_animation == "walk", "Animação alterada para WALK")
	
	renderer._processar_sincronizacao_frames(0.2)
	assert_true(renderer.current_frame_index > 0, "Sincronizador de frames avançou simultaneamente")
	
	renderer.queue_free()


func _testar_cena_character_creator_test() -> void:
	print("\n--- [TESTE 4: CENA INTERATIVA CHARACTER CREATOR TEST] ---")
	
	var scene = load("res://entities/character_creator/test/CharacterCreatorTest.tscn")
	assert_true(scene != null, "Cena CharacterCreatorTest.tscn carregada com sucesso")
	
	var inst = scene.instantiate() as CharacterCreatorTest
	add_child(inst)
	
	assert_true(inst.renderer != null, "CharacterRenderer instanciado e conectado na cena")
	assert_true(inst.appearance != null, "Aparência inicial configurada")
	
	# Simular mudança de cabelo
	inst.idx_hair = 1
	inst._aplicar_cabelo()
	assert_true(inst.appearance.hair_id == "hair_killua_01", "Troca interativa de cabelo executada com sucesso")
	
	inst.queue_free()
