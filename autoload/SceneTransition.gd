class_name SceneTransitionClass
extends CanvasLayer

# ============================================================
# HUNTER ONLINE — CINEMATIC SCENE & MAP TRANSITION (AUTOLOAD)
# ============================================================
#
# Gerenciador global de transições suaves de mapa e cenas:
# - Fade-out / Fade-in cinematográfico em tela cheia (Overlay Preto).
# - Banner de Chegada de Mapa com animação deslizante e estilo HxH.
# - Integração com AudioManager para crossfade musical.
# - Resolução nativa 320x180.
#
# ============================================================

signal transicao_iniciada()
signal transicao_concluida()

var overlay: ColorRect
var banner_panel: PanelContainer
var lbl_banner_titulo: Label
var lbl_banner_subtitulo: Label

var em_transicao: bool = false
var banner_tween: Tween = null

const MAP_TITLES: Dictionary = {
	"res://world/lobby.tscn": {
		"titulo": "Capital dos Caçadores",
		"subtitulo": "Hunter Plaza — Hub Central"
	},
	"res://world/maps/exame_maratona.tscn": {
		"titulo": "287º Exame Hunter",
		"subtitulo": "Arco 1 — Túnel Subterrâneo & Pantanal Numere"
	},
	"res://world/maps/montanha_kukuroo.tscn": {
		"titulo": "Montanha Kukuroo",
		"subtitulo": "Arco 2 — Propriedade da Família Zoldyck"
	},
	"res://world/maps/arena_celestial.tscn": {
		"titulo": "Arena Celestial",
		"subtitulo": "Arco 3 — O Palco dos Mestres de Nen"
	},
	"res://world/maps/CelestialTowerArena.tscn": {
		"titulo": "Torre Celestial (200 Andares)",
		"subtitulo": "Desafio Solo & Batalha dos Mestres de Andar"
	},
	"res://world/maps/yorknew_city.tscn": {
		"titulo": "Yorknew City",
		"subtitulo": "Arco 4 — Leilão Subterrâneo & Trupe Fantasma"
	},
	"res://world/maps/greed_island.tscn": {
		"titulo": "Greed Island",
		"subtitulo": "Arco 5 — O Mundo Mágico dos Feitiços e Cartas"
	},
	"res://world/maps/ngl_formigas.tscn": {
		"titulo": "NGL — Ninho das Formigas Chimera",
		"subtitulo": "Arco 6 — Expedição de Extermínio & Palácio Real"
	},
	"res://world/maps/associacao_hunter.tscn": {
		"titulo": "Sede da Associação Hunter",
		"subtitulo": "Arco 7 — A 13ª Eleição do Presidente Hunter"
	},
	"res://world/maps/continente_negro.tscn": {
		"titulo": "O Continente Negro",
		"subtitulo": "Arco 8 — Território Inexplorado das 5 Calamidades"
	},
	"res://world/maps/black_whale_1.tscn": {
		"titulo": "Navio Black Whale 1",
		"subtitulo": "Arco 9 — Guerra de Sucessão dos Príncipes de Kakin"
	},
	"res://world/maps/PlayerHouse.tscn": {
		"titulo": "Residência Pessoal do Caçador",
		"subtitulo": "Distrito Residencial — Hunter Plaza"
	},
	"res://world/maps/parallel_quest_arena.tscn": {
		"titulo": "Fenda Temporal de Chrono",
		"subtitulo": "Arena das Missões Paralelas"
	}
}


func _ready() -> void:
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS
	_construir_ui()


func _construir_ui() -> void:
	# 1. Overlay Preto para Fade
	overlay = ColorRect.new()
	overlay.name = "FadeOverlay"
	overlay.color = Color(0, 0, 0, 0)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	# 2. Banner de Chegada no Topo
	banner_panel = PanelContainer.new()
	banner_panel.name = "ArrivalBanner"
	banner_panel.custom_minimum_size = Vector2(220, 26)
	banner_panel.position = Vector2(50, -40) # Começa escondido acima da tela
	banner_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.08, 0.14, 0.95)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 2
	style.border_color = Color(1.0, 0.80, 0.25, 1.0)
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	banner_panel.add_theme_stylebox_override("panel", style)
	add_child(banner_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 3)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 3)
	banner_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 1)
	margin.add_child(vbox)

	lbl_banner_titulo = Label.new()
	lbl_banner_titulo.text = "📍 CAPITAL DOS CAÇADORES"
	lbl_banner_titulo.add_theme_font_size_override("font_size", 5)
	lbl_banner_titulo.add_theme_color_override("font_color", Color(1.0, 0.88, 0.3, 1.0))
	lbl_banner_titulo.add_theme_color_override("font_shadow_color", Color.BLACK)
	lbl_banner_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_banner_titulo)

	lbl_banner_subtitulo = Label.new()
	lbl_banner_subtitulo.text = "Hunter Plaza — Hub Central"
	lbl_banner_subtitulo.add_theme_font_size_override("font_size", 3)
	lbl_banner_subtitulo.add_theme_color_override("font_color", Color(0.6, 0.85, 1.0, 1.0))
	lbl_banner_subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_banner_subtitulo)


func mudar_cena(caminho_cena: String, nome_mapa: String = "", subtitulo: String = "", duracao: float = 0.35, spawn_id: StringName = &"default", spawn_pos: Vector2 = Vector2.ZERO) -> void:
	if em_transicao:
		return
	em_transicao = true
	transicao_iniciada.emit()

	var wpm = get_node_or_null("/root/WorldProgressionManager")
	if wpm != null and wpm.has_method("definir_destino_spawn"):
		wpm.definir_destino_spawn(spawn_id, spawn_pos)
		wpm.limpar_spawn_points()

	# Travar controles do jogador durante a transição
	var player = get_tree().get_first_node_in_group("player")
	if player != null and player.has_method("travar_controles"):
		player.travar_controles(true)

	overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	# 1. Fade-out suave (Tela escurece)
	var tween_out := create_tween()
	tween_out.tween_property(overlay, "color:a", 1.0, duracao)
	await tween_out.finished

	# 2. Tocar música do novo mapa
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("tocar_musica_por_cena"):
		audio_mgr.tocar_musica_por_cena(caminho_cena)

	# 3. Mudar cena
	get_tree().change_scene_to_file(caminho_cena)
	await get_tree().process_frame
	await get_tree().process_frame

	# 4. Posicionar o jogador no SpawnPoint correto do novo mapa
	var novo_player = get_tree().get_first_node_in_group("player")
	if novo_player != null and is_instance_valid(novo_player):
		if wpm != null and wpm.has_method("posicionar_player_no_spawn"):
			wpm.posicionar_player_no_spawn(novo_player)
		if novo_player.has_method("travar_controles"):
			novo_player.travar_controles(false)

	# 5. Fade-in suave (Tela clareia)
	var tween_in := create_tween()
	tween_in.tween_property(overlay, "color:a", 0.0, duracao)
	await tween_in.finished

	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	em_transicao = false
	transicao_concluida.emit()

	# 6. Exibir Banner de Chegada do Mapa
	if nome_mapa.is_empty():
		if wpm != null:
			var reg_info = wpm.obter_info_regiao_por_cena(caminho_cena)
			if not reg_info.is_empty():
				nome_mapa = reg_info.get("nome", "")
				subtitulo = reg_info.get("subtitulo", "")
		if nome_mapa.is_empty() and MAP_TITLES.has(caminho_cena):
			nome_mapa = MAP_TITLES[caminho_cena]["titulo"]
			subtitulo = MAP_TITLES[caminho_cena]["subtitulo"]

	if not nome_mapa.is_empty():
		exibir_banner_mapa(nome_mapa, subtitulo)


func exibir_banner_mapa(nome_mapa: String, subtitulo: String = "") -> void:
	if lbl_banner_titulo == null or banner_panel == null:
		return

	if banner_tween != null and banner_tween.is_valid():
		banner_tween.kill()

	lbl_banner_titulo.text = "📍 " + nome_mapa.to_upper()
	lbl_banner_subtitulo.text = subtitulo
	lbl_banner_subtitulo.visible = not subtitulo.is_empty()

	banner_panel.position.y = -40.0
	banner_panel.modulate.a = 1.0

	banner_tween = create_tween()
	# Deslizar para dentro da tela suavemente
	banner_tween.tween_property(banner_panel, "position:y", 6.0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Ficar visível por 2.4 segundos
	banner_tween.tween_interval(2.4)
	# Desvanecer suavemente
	banner_tween.tween_property(banner_panel, "modulate:a", 0.0, 0.5)
	banner_tween.chain().tween_callback(func():
		banner_panel.position.y = -40.0
	)
