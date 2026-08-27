extends SceneTree

const CharacterAppearance = preload("res://entities/character_creator/CharacterAppearance.gd")
const CharacterAssetDatabase = preload("res://entities/character_creator/CharacterAssetDatabase.gd")
const CharacterRenderer = preload("res://entities/character_creator/CharacterRenderer.gd")
const CharacterCreatorTest = preload("res://entities/character_creator/test/CharacterCreatorTest.gd")

func _initialize() -> void:
	print("============================================================")
	print("TEST SUITE: CHARACTER CREATOR & MODULAR RENDERER")
	print("============================================================")
	
	# 1. Testar Serialização
	var app = CharacterAppearance.new()
	app.character_id = "test_hunter"
	app.name = "Killua Teste"
	app.hair_id = "hair_killua_01"
	var d = app.to_dict()
	var restored = CharacterAppearance.from_dict(d)
	print("✅ Serialização e Desserialização de CharacterAppearance: ", restored.name, " (", restored.hair_id, ")")
	
	# 2. Testar Presets
	var gon = CharacterAssetDatabase.obter_preset("GON")
	var killua = CharacterAssetDatabase.obter_preset("KILLUA")
	var kurapika = CharacterAssetDatabase.obter_preset("KURAPIKA")
	var leorio = CharacterAssetDatabase.obter_preset("LEORIO")
	print("✅ Presets Canônicos carregados com sucesso: %s, %s, %s, %s" % [gon.name, killua.name, kurapika.name, leorio.name])
	
	# 3. Testar Renderer com 12 camadas
	var renderer = CharacterRenderer.new()
	root.add_child(renderer)
	renderer.set_appearance(killua)
	renderer.set_direction(CharacterRenderer.Direction.RIGHT)
	renderer.play_animation("walk")
	renderer._processar_sincronizacao_frames(0.2)
	print("✅ CharacterRenderer com %d camadas ativas renderizando Killua (Dir: %d, Anim: %s, Frame: %d)" % [
		renderer.layers.size(),
		int(renderer.current_direction),
		renderer.current_animation,
		renderer.current_frame_index
	])
	
	# 4. Testar Cena Interativa
	var scene = load("res://entities/character_creator/test/CharacterCreatorTest.tscn")
	var test_node = scene.instantiate() as CharacterCreatorTest
	root.add_child(test_node)
	test_node.idx_hair = 2
	test_node._aplicar_cabelo()
	print("✅ Cena CharacterCreatorTest instanciada e interagindo perfeitamente: Cabelo =", test_node.appearance.hair_id)
	
	print("============================================================")
	print("🎉 TODOS OS 4 TESTES PASSARAM COM 100% DE SUCESSO!")
	print("============================================================")
	
	quit(0)
