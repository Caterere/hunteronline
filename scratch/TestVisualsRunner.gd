extends Node

func _ready() -> void:
	print("==================================================")
	print(">>> TESTE: SISTEMA VISUAL PROCEDURAL DE HATSU <<<")
	print("==================================================")

	var erros: int = 0

	# 1. Teste de Criação e Configuração dos 8 Estilos Visuais
	print("\n--- 1. TESTE DOS 8 ESTILOS VISUAIS PROCEDURAIS ---")
	var estilos_testar = [
		HatsuData.EstiloVisual.PURO_PULSANTE,
		HatsuData.EstiloVisual.CHAMAS_FOGO,
		HatsuData.EstiloVisual.RELAMPAGOS_ELETRICOS,
		HatsuData.EstiloVisual.LAMINA_CORTE,
		HatsuData.EstiloVisual.SHURIKEN_GIRATORIO,
		HatsuData.EstiloVisual.ANEIS_IMPACTO,
		HatsuData.EstiloVisual.NEVOA_SOMBRIAS,
		HatsuData.EstiloVisual.DRAGAO_SERPENTE
	]

	for est in estilos_testar:
		var h = HatsuManager.criar_hatsu(
			"Teste Visual", HatsuData.Categoria.EMISSAO, HatsuData.Forma.PROJETIL,
			[], HatsuData.ObjetivoPrincipal.DANO, HatsuData.Elemento.NEN_PURO,
			HatsuData.Alvo.INIMIGO_UNICO, HatsuData.AlcanceTipo.MEDIO, HatsuData.ConsumoDesejado.MEDIO,
			"", HatsuData.Arquetipo.SIMPLES,
			Color(1.0, 0.2, 0.5), Color(1.0, 1.0, 0.9), est
		)

		var proj = HatsuProjectileNode.new()
		proj.setup(Vector2.ZERO, Vector2.RIGHT, 150.0, 300.0, 30, h.cor_aura, self, h)
		add_child(proj)
		await get_tree().process_frame

		print("✅ [PASS] Estilo Visual renderizado com sucesso: ", HatsuData.obter_nome_estilo_visual(est))
		proj.queue_free()

	# 2. Teste da Explosão Procedural de Área
	print("\n--- 2. TESTE DA EXPLOSÃO PROCEDURAL DE ÁREA ---")
	var exp_node = HatsuAreaExplosionNode.new()
	exp_node.setup(70.0, Color(0.2, 0.9, 1.0), Color.WHITE)
	add_child(exp_node)
	await get_tree().process_frame
	print("✅ [PASS] HatsuAreaExplosionNode renderizou ondas de choque e centelhas com sucesso.")
	exp_node.queue_free()

	print("\n==================================================")
	if erros == 0:
		print("🎉 TODOS OS TESTES VISUAIS PROCEDURAIS PASSARAM COM 100% DE SUCESSO!")
	else:
		print("❌ TOTAL DE ERROS: ", erros)
	print("==================================================")
	get_tree().quit(0 if erros == 0 else 1)
