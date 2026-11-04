class_name ProgressionSystemsPrimer
extends RefCounted

# ============================================================
# HUNTER ONLINE — GUIA DE SISTEMAS (SSOT de falas didáticas)
# ============================================================
# Usado por Mestre Wing e pelo Training Wing (Vale/Arena).
# Explica nível, Nen, Nen Tree e Hatsu sem inventar sistemas novos.
# ============================================================

const SPEAKER_DEFAULT := "Mestre Wing"


static func topicos(speaker: String = SPEAKER_DEFAULT) -> Array[Dictionary]:
	return [
		{"id": "nivel", "label": "📖 Nível, XP e Skill Points", "falas": falas_nivel(speaker)},
		{"id": "nen", "label": "📖 Nen — técnicas ativas e passivas", "falas": falas_nen(speaker)},
		{"id": "nen_tree", "label": "📖 Nen Tree (Constelação)", "falas": falas_nen_tree(speaker)},
		{"id": "hatsu", "label": "📖 Hatsu — criação, slots e mastery", "falas": falas_hatsu(speaker)},
		{"id": "combate", "label": "📖 Combate — combo, heavy, guarda", "falas": falas_combate(speaker)},
		{"id": "votos", "label": "📖 Votos, juramentos e mastery", "falas": falas_votos(speaker)},
		{"id": "controles", "label": "📖 Controles rápidos", "falas": falas_controles(speaker)},
		{"id": "ordem", "label": "📖 Ordem recomendada (não pule)", "falas": falas_ordem(speaker)},
	]


## Subconjunto íntimo pra Biscuit (Conversar / forja).
static func topicos_biscuit() -> Array[Dictionary]:
	var sp := "Biscuit Krueger"
	return [
		{"id": "hatsu", "label": "✨ Hatsu — slots e forja", "falas": falas_hatsu(sp)},
		{"id": "votos", "label": "🔗 Votos e juramentos", "falas": falas_votos(sp)},
		{"id": "combate", "label": "⚔️ Combate — Ko no punish", "falas": falas_combate(sp)},
		{"id": "nen", "label": "📖 Nen avançado (Ko/Shu/Ken/Ryu)", "falas": falas_nen(sp)},
	]


static func falas_nivel(speaker: String = SPEAKER_DEFAULT) -> Array[Dictionary]:
	return [
		{"falante": speaker, "texto": "Seu NÍVEL sobe com XP: derrotas, missões, treinos e bounties. Cada level-up fortalece vida/força/defesa e concede +1 Skill Point (SP)."},
		{"falante": speaker, "texto": "Há soft-cap por saga: se você subir demais antes da história, o XP rende menos. Siga o arco — o GPS marca o objetivo certo."},
		{"falante": speaker, "texto": "Nível do personagem ≠ nível de Nen. O Nen desperta comigo (Teste da Água). Antes disso a Constelação fica bloqueada, mas os SP acumulam."},
		{"falante": speaker, "texto": "Jenny (ouro) não sobe nível. Serve para loja, forge de Hatsu e sinks. No early, foque XP + SP — não farm infinito."},
	]


static func falas_nen(speaker: String = SPEAKER_DEFAULT) -> Array[Dictionary]:
	return [
		{"falante": speaker, "texto": "Nen é o fluxo de aura. Depois do despertar, Ten e Ren passam a proteger e reforçar você de forma PASSIVA — não precisa apertar tecla."},
		{"falante": speaker, "texto": "Ativas no mundo e combate: [Z] Zetsu (esconde aura / emboscada), [G] Gyo (vê pistas e fraquezas), [X] En (radar de presença). Use fora da briga também."},
		{"falante": speaker, "texto": "Ko, Shu, Ken e Ryu avançam pela Constelação e pelo treino. Ko quebra guarda; Shu reveste arma; Ken é blindagem passiva (Ren no corpo inteiro); Ryu equilibra ofensa/defesa."},
		{"falante": speaker, "texto": "Aura gasta em técnicas e Hatsu. Sem aura, você vira carne. Recupere com tempo, Perfect Dodge e itens Pedra de Aura / Gourmet — sem poções clássicas."},
	]


static func falas_nen_tree(speaker: String = SPEAKER_DEFAULT) -> Array[Dictionary]:
	return [
		{"falante": speaker, "texto": "Abra [TAB] → Nen Tree (Constelação). Cada SP investido em um CLUSTER forma sua identidade de build: Fortaleza, Lutador, Nen, Hatsu, Velocidade…"},
		{"falante": speaker, "texto": "Ordem clássica de iniciante: Ten → Ren → Zetsu no ramo de Nen. Depois escolha um caminho — não espalhe SP em tudo."},
		{"falante": speaker, "texto": "Quando um cluster lidera com margem, o jogo te avisa: “você está virando X”. Isso é identidade, não só número."},
		{"falante": speaker, "texto": "A árvore só abre após despertar Nen. Até lá, suba de nível normalmente — os pontos esperam por você."},
	]


static func falas_hatsu(speaker: String = SPEAKER_DEFAULT) -> Array[Dictionary]:
	return [
		{"falante": speaker, "texto": "Hatsu é a habilidade pessoal. Slots [1][2][3][4] disparam o que estiver equipado. Consome muita aura — não spam."},
		{"falante": speaker, "texto": "Fundamentos comigo; criação avançada com Biscuit (após requisitos de arco / Greed Island). Forge custa Jenny e tem cooldown longo."},
		{"falante": speaker, "texto": "Mastery sobe usando o Hatsu contra alvos relevantes. A cada marco (~10) o poder e a eficiência melhoram. Votos/restrições aumentam o poder com risco."},
		{"falante": speaker, "texto": "Momentos Hatsu no mapa (clareiras) são janelas para sentir o peso da habilidade. Elite e boss pedem Hatsu + Nen, não só leve."},
	]


static func falas_combate(speaker: String = SPEAKER_DEFAULT) -> Array[Dictionary]:
	return [
		{"falante": speaker, "texto": "Leve em três tempos: hit, hit, finisher. O terceiro pesa mais — você sente no corpo do inimigo."},
		{"falante": speaker, "texto": "Heavy: segure o ataque ou use o botão direito. Quebra a barra de guarda. Quando ela cair, punish com tudo — janela curta, ×1.8 de dano."},
		{"falante": speaker, "texto": "Perfect Dodge no telegraph (flash/círculo/cor de afinidade). Na janela certa você contra-ataca. [Shift] ou clique direito pra esquivar."},
		{"falante": speaker, "texto": "Ko concentra aura no golpe decisivo. Hatsu [1]–[4] entra no espaço depois do punish — aura cara, sem spam."},
	]


static func falas_votos(speaker: String = SPEAKER_DEFAULT) -> Array[Dictionary]:
	return [
		{"falante": speaker, "texto": "Votos e juramentos amarram sua alma ao Hatsu. Quanto mais severo o risco, maior o poder — e maior a conta se você falhar."},
		{"falante": speaker, "texto": "Na criação, leia o tradeoff no HUD antes de confirmar. Não assine o que seu corpo não aguenta ainda."},
		{"falante": speaker, "texto": "Mastery sobe usando o Hatsu contra alvos relevantes. A cada ~10 pontos o impacto e o residual ficam mais densos. Farm em fraco rende pouco."},
		{"falante": speaker, "texto": "Seu Hatsu é quem você é sob pressão. Não copie outro Hunter. Forje o que ressoa com a sua afinidade."},
	]


static func falas_controles(speaker: String = SPEAKER_DEFAULT) -> Array[Dictionary]:
	return [
		{"falante": speaker, "texto": "Mover: WASD/setas. Ataque leve: [Espaço]/clique esquerdo. Pesado: segure. Esquiva: [Shift]/direito — Perfect Dodge na janela do telegraph inimigo."},
		{"falante": speaker, "texto": "Menus: [TAB] inventário/Nen Tree/Hatsu · [I] inventário · GPS segue o objetivo da missão (não o portal errado). [E] interage com NPCs e portais."},
		{"falante": speaker, "texto": "Nen ativo: [Z] Zetsu · [G] Gyo · [X] En. Hatsu: [1]–[4]. Se travar a história, fale comigo de novo ou com Elena no Lobby."},
	]


static func falas_ordem(speaker: String = SPEAKER_DEFAULT) -> Array[Dictionary]:
	return [
		{"falante": speaker, "texto": "Ordem Steam early — um de cada vez: 1) Exame/Lobby. 2) Desperte Nen (Teste da Água). 3) Gaste SP na Nen Tree."},
		{"falante": speaker, "texto": "4) Tutorial Gyo→Zetsu→Ko no Vale. 5) Estrada → Floresta → Ruínas (Guardião). 6) Só depois force Hatsu avançado com Biscuit."},
		{"falante": speaker, "texto": "Se o GPS apontar portal errado, volte e fale comigo / reabra a missão. O objetivo local da floresta não manda você entrar e sair do mesmo portal."},
	]


## Modal com botões de tópico. `ao_falar` recebe Array[Dictionary] de falas.
## `lista_topicos` opcional: subset (ex. topicos_biscuit()).
static func abrir_menu_guia(
	host: Node,
	ao_falar: Callable,
	ao_fechar: Callable = Callable(),
	titulo: String = "🥋 GUIA DE PROGRESSÃO",
	subtitulo: String = "Nível · Nen · Nen Tree · Hatsu · Combate · Votos",
	lista_topicos: Array = []
) -> CanvasLayer:
	if host == null:
		return null
	var existing := host.get_node_or_null("ProgressionSystemsPrimerMenu")
	if existing != null:
		existing.queue_free()

	var modal := CanvasLayer.new()
	modal.name = "ProgressionSystemsPrimerMenu"
	modal.layer = 26
	modal.process_mode = Node.PROCESS_MODE_ALWAYS
	host.add_child(modal)
	if host.get_tree() != null:
		host.get_tree().paused = true

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.72)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal.add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(320, 240)
	if HunterUIStyle != null:
		panel.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_painel_principal(HunterUIStyle.COLOR_BORDER_GOLD, 4))
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	margin.add_child(vbox)

	var lbl_t := Label.new()
	lbl_t.text = titulo
	lbl_t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_t.add_theme_font_size_override("font_size", 10)
	if HunterUIStyle != null:
		lbl_t.add_theme_color_override("font_color", HunterUIStyle.COLOR_GOLD_LIGHT)
	vbox.add_child(lbl_t)

	var lbl_s := Label.new()
	lbl_s.text = subtitulo
	lbl_s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_s.add_theme_font_size_override("font_size", 7)
	if HunterUIStyle != null:
		lbl_s.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
	vbox.add_child(lbl_s)

	vbox.add_child(HSeparator.new())

	var fechar := func() -> void:
		if is_instance_valid(modal):
			modal.queue_free()
		if host.get_tree() != null:
			host.get_tree().paused = false
		if ao_fechar.is_valid():
			ao_fechar.call()

	var lista: Array = lista_topicos if not lista_topicos.is_empty() else topicos()
	for topico in lista:
		var falas: Array = topico.get("falas", []) if topico is Dictionary else []
		var label: String = str(topico.get("label", "Tópico")) if topico is Dictionary else "Tópico"
		var btn := Button.new()
		btn.text = label
		btn.add_theme_font_size_override("font_size", 8)
		btn.custom_minimum_size = Vector2(0, 22)
		if HunterUIStyle != null:
			HunterUIStyle.aplicar_estilo_botao(btn, HunterUIStyle.COLOR_BORDER_GREEN)
		btn.pressed.connect(func():
			fechar.call()
			if ao_falar.is_valid():
				ao_falar.call(falas)
		)
		vbox.add_child(btn)

	var btn_close := Button.new()
	btn_close.text = "❌ Fechar [ESC]"
	btn_close.add_theme_font_size_override("font_size", 8)
	btn_close.custom_minimum_size = Vector2(0, 22)
	if HunterUIStyle != null:
		HunterUIStyle.aplicar_estilo_botao(btn_close, HunterUIStyle.COLOR_BORDER_SUBTLE)
	btn_close.pressed.connect(fechar)
	vbox.add_child(btn_close)

	return modal
