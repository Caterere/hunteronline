class_name CinematicManagerClass
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - CINEMATIC MANAGER (CUTSCENES & ENTRADAS DE MANGÁ)
# ============================================================
#
# Gerenciador global de cutscenes de entrada e transições cinematográficas:
# - Barras pretas de Letterbox de Cinema (topo e base).
# - Manga Splash Card deslizante com tipografia e cores temáticas de Nen.
# - Sequência de balões de diálogo temáticos de quadrinho.
# - Trava e restauração suave dos controles do jogador.
# - Resolução nativa 320x180.
#
# ============================================================

signal cutscene_iniciada(personagem_id: String)
signal cutscene_finalizada(personagem_id: String)

var bar_top: ColorRect
var bar_bottom: ColorRect
var splash_panel: PanelContainer
var lbl_nome: Label
var lbl_subtitulo: Label
var color_accent: ColorRect

var em_cutscene: bool = false
var pulou_cutscene: bool = false
var player_bloqueado: Node = null

# Catálogo Canônico de Perfis para Entradas de Mangá
const PERFIS_MANGA: Dictionary = {
	"hisoka": {
		"nome": "HISOKA MOROW",
		"subtitulo": "O Mágico Sádico — Nº 4 da Genei Ryodan",
		"cor": Color(1.0, 0.35, 0.75),
		"falas": [
			"♠️ Ora ora... Que presença intrigante temos aqui.",
			"♦️ Mostre-me se sua aura já está madura para ser colhida..."
		]
	},
	"chrollo": {
		"nome": "CHROLLO LUCILFER",
		"subtitulo": "Líder da Genei Ryodan — A Aranha de 12 Patas",
		"cor": Color(0.7, 0.25, 1.0),
		"falas": [
			"📖 A morte não é o fim... É apenas a contemplação do destino.",
			"🕷️ Seus olhos carregam uma determinação interessante."
		]
	},
	"netero": {
		"nome": "ISAAC NETERO",
		"subtitulo": "12º Presidente da Associação Hunter",
		"cor": Color(1.0, 0.85, 0.2),
		"falas": [
			"🙏 Ho ho ho! Um jovem aspirante cheio de vigor!",
			"✨ O verdadeiro poder nasce do coração que nunca para de agradecer."
		]
	},
	"illumi": {
		"nome": "ILLUMI ZOLDYCK",
		"subtitulo": "Assassino Profissional da Família Zoldyck",
		"cor": Color(0.95, 0.85, 0.3),
		"falas": [
			"📍 Amigos são desnecessários para um assassino profissional.",
			"Se você interferir na minha família, terei que matá-lo."
		]
	},
	"uvogin": {
		"nome": "UVOGIN",
		"subtitulo": "Nº 11 da Genei Ryodan — O Destruidor",
		"cor": Color(1.0, 0.65, 0.1),
		"falas": [
			"💥 Hahaha! Quer enfrentar o cara mais forte da Trupe?!",
			"Vou transformar seu corpo em poeira com um único soco!"
		]
	},
	"feitan": {
		"nome": "FEITAN PORTOR",
		"subtitulo": "O Interrogador da Genei Ryodan",
		"cor": Color(1.0, 0.25, 0.2),
		"falas": [
			"Você fala demais... Eu odeio pessoas barulhentas.",
			"☀️ Espero que seu corpo aguente a dor que está por vir."
		]
	},
	"pitou": {
		"nome": "NEFERPITOU",
		"subtitulo": "Guarda Real das Formigas Quimera",
		"cor": Color(1.0, 0.15, 0.25),
		"falas": [
			"🐱 Nyaaa! Que cheiro delicioso de Nen humano!",
			"Você vai ser um ótimo brinquedo para a minha Terpsichora..."
		]
	},
	"meruem": {
		"nome": "MERUEM",
		"subtitulo": "O Rei Supremo de Todas as Espécies",
		"cor": Color(0.2, 0.9, 0.4),
		"falas": [
			"👑 Criatura insolente... Você ousa respirar na presença do Rei?",
			"Curvar-se diante da evolução é o seu único destino."
		]
	},
	"genthru": {
		"nome": "GENTHRU",
		"subtitulo": "O Bombardeiro de Greed Island",
		"cor": Color(1.0, 0.45, 0.1),
		"falas": [
			"💣 Vocês caíram direto na minha armadilha.",
			"A contagem regressiva já começou... Liberem!"
		]
	},
	"razor": {
		"nome": "RAZOR",
		"subtitulo": "Mestre de Emissão & Game Master de Greed Island",
		"cor": Color(0.9, 0.2, 0.2),
		"falas": [
			"🏐 Bem-vindo à quadra de Greed Island.",
			"Segure este arremesso se quiser provar seu valor!"
		]
	},
	"wing": {
		"nome": "MESTRE WING",
		"subtitulo": "Mestre Shingen-ryu de Nen",
		"cor": Color(0.3, 0.8, 1.0),
		"falas": [
			"Controle o fluxo dos seus microporos antes de liberar sua energia.",
			"O Nen é uma espada de dois gumes... Use-o com sabedoria."
		]
	},
	"biscuit": {
		"nome": "BISCUIT KRUEGER",
		"subtitulo": "Mestra Shingen-ryu — Hunter de Duas Estrelas",
		"cor": Color(1.0, 0.3, 0.7),
		"falas": [
			"💖 Hora do treinamento infernal, seus moleques preguiçosos!",
			"Se não aguentarem 500 flexões de Nen, vão voltar chorando!"
		]
	},
	"kurapika": {
		"nome": "KURAPIKA",
		"subtitulo": "Último Sobrevivente do Clã Kurta",
		"cor": Color(0.9, 0.1, 0.1),
		"falas": [
			"⛓️ A dor da perda nunca cicatriza... Ela se transforma em corrente.",
			"Se você tem ligação com as Aranhas, prepare-se."
		]
	},
	"killua": {
		"nome": "KILLUA ZOLDYCK",
		"subtitulo": "Herdeiro Prodígio dos Zoldyck",
		"cor": Color(0.2, 0.9, 1.0),
		"falas": [
			"⚡ Se você fizer um movimento brusco, eu corto sua garganta.",
			"Mas se você é amigo do Gon... Relaxa, vamos nessa."
		]
	}
}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 64
	visible = false
	_construir_elementos_ui()


func _input(event: InputEvent) -> void:
	if not em_cutscene: return
	if event is InputEventKey and event.pressed:
		if event.keycode in [KEY_SPACE, KEY_ENTER, KEY_ESCAPE]:
			pulou_cutscene = true
			get_viewport().set_input_as_handled()


func _construir_elementos_ui() -> void:
	# Barra de cinema Superior
	bar_top = ColorRect.new()
	bar_top.color = Color(0, 0, 0, 1)
	bar_top.position = Vector2(0, -100)
	bar_top.size = Vector2(640, 44)
	add_child(bar_top)

	# Barra de cinema Inferior
	bar_bottom = ColorRect.new()
	bar_bottom.color = Color(0, 0, 0, 1)
	bar_bottom.position = Vector2(0, 500)
	bar_bottom.size = Vector2(640, 44)
	add_child(bar_bottom)

	# Painel do Splash Card de Entrada (Central Superior)
	splash_panel = PanelContainer.new()
	splash_panel.custom_minimum_size = Vector2(300, 48)
	splash_panel.position = Vector2(170, -100)
	splash_panel.modulate.a = 0.0

	var st_splash := StyleBoxFlat.new()
	st_splash.bg_color = Color(0.05, 0.05, 0.08, 0.94)
	st_splash.border_width_bottom = 2
	st_splash.border_color = Color(1.0, 0.85, 0.3)
	st_splash.corner_radius_top_left = 4
	st_splash.corner_radius_top_right = 4
	st_splash.corner_radius_bottom_right = 4
	st_splash.corner_radius_bottom_left = 4
	splash_panel.add_theme_stylebox_override("panel", st_splash)
	add_child(splash_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 5)
	splash_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	margin.add_child(vbox)

	lbl_nome = Label.new()
	lbl_nome.text = "NOME DO PERSONAGEM"
	lbl_nome.add_theme_font_size_override("font_size", 7)
	lbl_nome.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	lbl_nome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_nome)

	lbl_subtitulo = Label.new()
	lbl_subtitulo.text = "Subtítulo / Título de Mangá"
	lbl_subtitulo.add_theme_font_size_override("font_size", 4)
	lbl_subtitulo.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
	lbl_subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_subtitulo)


func tocar_entrada_personagem(personagem_id: String, entidade_no: Node = null) -> void:
	if em_cutscene: return

	var id_chave: String = personagem_id.to_lower()
	var perfil: Dictionary = PERFIS_MANGA.get(id_chave, {})
	if perfil.is_empty():
		perfil = {
			"nome": personagem_id.to_upper(),
			"subtitulo": "Guerreiro de Nen do Mundo Hunter",
			"cor": Color(0.3, 0.8, 1.0),
			"falas": ["Uma nova presença se aproxima..."]
		}

	# Gravar que a cutscene foi vista em PlayerData
	PlayerData.quest_states["cutscene_vista_" + id_chave] = true

	em_cutscene = true
	pulou_cutscene = false
	visible = true
	cutscene_iniciada.emit(id_chave)

	# Ajustar dimensões ao viewport atual
	var vp_size: Vector2 = get_viewport().get_visible_rect().size if get_viewport() != null else Vector2(640, 360)
	if vp_size.x <= 0: vp_size = Vector2(640, 360)

	var bar_h: float = clamp(vp_size.y * 0.12, 24.0, 48.0)
	bar_top.size = Vector2(vp_size.x, bar_h)
	bar_top.position = Vector2(0, -bar_h)

	bar_bottom.size = Vector2(vp_size.x, bar_h)
	bar_bottom.position = Vector2(0, vp_size.y)

	var splash_w: float = min(320.0, vp_size.x * 0.85)
	splash_panel.custom_minimum_size = Vector2(splash_w, 44)
	splash_panel.position = Vector2((vp_size.x - splash_w) * 0.5, -80)

	# Bloquear movimento do jogador
	_bloquear_jogador(true)

	# Atualizar dados visuais do Splash Card
	lbl_nome.text = perfil.get("nome", "PERSONAGEM")
	lbl_nome.add_theme_color_override("font_color", perfil.get("cor", Color.WHITE))
	lbl_subtitulo.text = perfil.get("subtitulo", "")

	# 1. Animar Entrada do Letterbox e do Splash Card
	var tw := create_tween().set_parallel(true)
	tw.tween_property(bar_top, "position:y", 0.0, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(bar_bottom, "position:y", vp_size.y - bar_h, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(splash_panel, "position:y", bar_h + 8.0, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(splash_panel, "modulate:a", 1.0, 0.35)
	await tw.finished

	# 2. Executar Sequência de Balões de Fala
	var falas: Array = perfil.get("falas", [])
	var alvo_fala: Node = entidade_no if entidade_no != null else self

	for f in falas:
		if pulou_cutscene: break
		if is_instance_valid(alvo_fala):
			var ComicBalloon = load("res://scripts/ui/ComicBalloon.gd")
			if ComicBalloon != null:
				ComicBalloon.mostrar(alvo_fala, f, 2.4, -42.0)
		
		var tempo_restante: float = 2.4
		while tempo_restante > 0.0 and not pulou_cutscene:
			await get_tree().create_timer(0.1).timeout
			tempo_restante -= 0.1

	# 3. Animar Saída do Letterbox e Splash Card
	var tw_out := create_tween().set_parallel(true)
	tw_out.tween_property(bar_top, "position:y", -bar_h - 10.0, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw_out.tween_property(bar_bottom, "position:y", vp_size.y + 10.0, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw_out.tween_property(splash_panel, "position:y", -100.0, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw_out.tween_property(splash_panel, "modulate:a", 0.0, 0.25)
	await tw_out.finished

	# 4. Restaurar jogador e finalizar
	_bloquear_jogador(false)
	visible = false
	em_cutscene = false
	cutscene_finalizada.emit(id_chave)
	print("[CinematicManager] Cutscene de entrada de '%s' finalizada com sucesso!" % perfil.get("nome"))


func _bloquear_jogador(bloquear: bool) -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty(): return
	var p = players[0]
	if is_instance_valid(p):
		if bloquear:
			if p is CharacterBody2D: p.velocity = Vector2.ZERO
			var movement = p.get_node_or_null("PlayerMovement")
			if movement != null: movement.set_process(false)
		else:
			var movement = p.get_node_or_null("PlayerMovement")
			if movement != null: movement.set_process(true)
