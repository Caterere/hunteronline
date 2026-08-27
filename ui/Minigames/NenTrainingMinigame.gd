class_name NenTrainingMinigame
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - NEN TRAINING MINIGAMES (5 TÉCNICAS CANÔNICAS)
# ============================================================
#
# Minijogos especializados para treinamento intensivo de Nen:
# 1. TEN: Manter a aura estável (Manter medidor na zona de equilíbrio)
# 2. REN: Liberação de potência de aura (QTE de Ritmo de Teclas)
# 3. ZETSU: Supressão e Silêncio (Fechar nós de aura e zerar emissão)
# 4. GYO: Foco Visual e Precisão (Detecção rápida de pontos fracos de Nen)
# 5. RYU: Distribuição Dinâmica de Fluxo (Ajustar medidor % Ataque vs % Defesa)
#
# Ranks de Desempenho (D, C, B, A, S) multiplicam o ganho de XP de técnica e Aura!
# ============================================================

signal minigame_finished(tecnica: String, score: int)

enum ModoTreino { MENU, TEN, REN, ZETSU, GYO, RYU, RESULTADO }
var modo_atual: ModoTreino = ModoTreino.MENU

# UI Elements
var panel_main: PanelContainer
var lbl_titulo: Label
var lbl_instrucoes: Label
var lbl_status: Label
var lbl_pontos: Label
var lbl_tempo: Label
var progresso_bar: ProgressBar
var container_jogo: Control
var container_menu: VBoxContainer

# Game State
var active: bool = false
var score: int = 0
var tempo_restante: float = 0.0
var tecnica_selecionada: String = "TEN"

# Variáveis do TEN
var ten_posicao: float = 0.5
var ten_velocidade: float = 0.0

# Variáveis do REN
var ren_sequencia: Array[String] = []
var ren_indice_atual: int = 0
var ren_timer_tecla: float = 0.0

# Variáveis do ZETSU
var zetsu_aura_atual: float = 100.0
var zetsu_respiração_timer: float = 0.0
var zetsu_alvo_respiracao: bool = false

# Variáveis do GYO
var gyo_alvos: Array[Button] = []
var gyo_spawn_timer: float = 0.0

# Variáveis do RYU
var ryu_ataque_porcento: float = 50.0
var ryu_alvo_porcento: float = 80.0
var ryu_timer_troca: float = 0.0
var ryu_modo_nome: String = "OFENSIVO (80% ATQ / 20% DEF)"

# Cooldown de treino
static var ultimo_treino_tempo: float = -100.0
const COOLDOWN_TREINO := 15.0 # 15 segundos entre sessões de treino


func _ready() -> void:
	layer = 40
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_construir_ui()


func start_minigame() -> void:
	var tempo_decorrido = Time.get_ticks_msec() / 1000.0 - ultimo_treino_tempo
	if tempo_decorrido < COOLDOWN_TREINO:
		var restante = int(COOLDOWN_TREINO - tempo_decorrido)
		_mostrar_aviso_cooldown(restante)
		return

	visible = true
	get_tree().paused = true
	_abrir_menu_selecao()


func _mostrar_aviso_cooldown(segundos: int) -> void:
	visible = true
	get_tree().paused = true
	_limpar_conteudo()
	lbl_titulo.text = "DESCANSO DE AURA"
	lbl_instrucoes.text = "Seus nós de aura estão descansando!\nAguarde a recuperação natural para o próximo treino.\n\nTempo restante: %d segundos." % segundos
	lbl_status.text = "Recuperando energia..."
	
	var btn_sair = Button.new()
	btn_sair.text = "Entendido (Voltar)"
	btn_sair.add_theme_font_size_override("font_size", 4)
	btn_sair.pressed.connect(fechar)
	container_menu.add_child(btn_sair)


func fechar() -> void:
	active = false
	visible = false
	get_tree().paused = false


func _construir_ui() -> void:
	panel_main = PanelContainer.new()
	panel_main.position = Vector2(40, 20)
	panel_main.custom_minimum_size = Vector2(240, 140)
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.08, 0.14, 0.96)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.3, 0.8, 1.0, 1.0)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	panel_main.add_theme_stylebox_override("panel", style)
	add_child(panel_main)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel_main.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	margin.add_child(vbox)

	lbl_titulo = Label.new()
	lbl_titulo.text = "TREINAMENTO DE NEN"
	lbl_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_titulo.add_theme_font_size_override("font_size", 5)
	lbl_titulo.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))
	vbox.add_child(lbl_titulo)

	var hbox_info := HBoxContainer.new()
	vbox.add_child(hbox_info)

	lbl_pontos = Label.new()
	lbl_pontos.text = "Pontos: 0"
	lbl_pontos.add_theme_font_size_override("font_size", 3)
	lbl_pontos.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4, 1.0))
	lbl_pontos.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_info.add_child(lbl_pontos)

	lbl_tempo = Label.new()
	lbl_tempo.text = "Tempo: 0.0s"
	lbl_tempo.add_theme_font_size_override("font_size", 3)
	lbl_tempo.add_theme_color_override("font_color", Color(1.0, 0.6, 0.3, 1.0))
	hbox_info.add_child(lbl_tempo)

	lbl_instrucoes = Label.new()
	lbl_instrucoes.text = ""
	lbl_instrucoes.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_instrucoes.add_theme_font_size_override("font_size", 3)
	lbl_instrucoes.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
	vbox.add_child(lbl_instrucoes)

	progresso_bar = ProgressBar.new()
	progresso_bar.custom_minimum_size = Vector2(0, 6)
	progresso_bar.show_percentage = false
	vbox.add_child(progresso_bar)

	container_jogo = Control.new()
	container_jogo.custom_minimum_size = Vector2(220, 50)
	vbox.add_child(container_jogo)

	lbl_status = Label.new()
	lbl_status.text = ""
	lbl_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_status.add_theme_font_size_override("font_size", 4)
	lbl_status.add_theme_color_override("font_color", Color(0.2, 0.9, 1.0, 1.0))
	vbox.add_child(lbl_status)

	container_menu = VBoxContainer.new()
	container_menu.add_theme_constant_override("separation", 2)
	vbox.add_child(container_menu)


func _limpar_conteudo() -> void:
	for child in container_jogo.get_children():
		child.queue_free()
	for child in container_menu.get_children():
		child.queue_free()


func _abrir_menu_selecao() -> void:
	modo_atual = ModoTreino.MENU
	_limpar_conteudo()
	
	lbl_titulo.text = "🥋 ACADEMIA SHINGEN-RYU: ESCOLHA O TREINO"
	lbl_instrucoes.text = "Selecione a técnica fundamental que deseja aprimorar:"
	lbl_status.text = "Quanto maior sua pontuação, maior a maestria adquirida!"
	lbl_pontos.text = ""
	lbl_tempo.text = ""
	progresso_bar.visible = false
	
	var treinos = [
		{"id": "TEN", "nome": "1. TEN (Manter Aura Estável / Defesa)", "modo": ModoTreino.TEN},
		{"id": "REN", "nome": "2. REN (Liberar Output / Alcance)", "modo": ModoTreino.REN},
		{"id": "ZETSU", "nome": "3. ZETSU (Controle de Supressão / Cura)", "modo": ModoTreino.ZETSU},
		{"id": "GYO", "nome": "4. GYO (Precisão & Foco Visual / Crítico)", "modo": ModoTreino.GYO},
		{"id": "RYU", "nome": "5. RYU (Distribuição de Fluxo de Batalha)", "modo": ModoTreino.RYU},
	]

	for t in treinos:
		var btn = Button.new()
		btn.text = t["nome"]
		btn.add_theme_font_size_override("font_size", 3)
		btn.pressed.connect(func(): _iniciar_treino_especifico(t["id"], t["modo"]))
		container_menu.add_child(btn)

	var btn_sair = Button.new()
	btn_sair.text = "Fechar Menu"
	btn_sair.add_theme_font_size_override("font_size", 3)
	btn_sair.pressed.connect(fechar)
	container_menu.add_child(btn_sair)


func _iniciar_treino_especifico(id: String, modo: ModoTreino) -> void:
	tecnica_selecionada = id
	modo_atual = modo
	score = 0
	tempo_restante = 15.0
	active = true
	_limpar_conteudo()
	progresso_bar.visible = true

	match modo:
		ModoTreino.TEN:
			_setup_ten()
		ModoTreino.REN:
			_setup_ren()
		ModoTreino.ZETSU:
			_setup_zetsu()
		ModoTreino.GYO:
			_setup_gyo()
		ModoTreino.RYU:
			_setup_ryu()


# ============================================================
# 1. TEN: ESTABILIDADE DE AURA
# ============================================================
func _setup_ten() -> void:
	lbl_titulo.text = "🥋 TREINO DE TEN: ESTABILIDADE DE AURA"
	lbl_instrucoes.text = "Use [A]/[D] ou [ESQUERDA]/[DIREITA] para manter a aura na zona verde central!"
	ten_posicao = 0.5
	ten_velocidade = 0.0


func _process_ten(delta: float) -> void:
	# Influência física aleatória (oscilação de aura)
	ten_velocidade += randf_range(-0.8, 0.8) * delta
	
	if Input.is_action_pressed("move_left") or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		ten_velocidade -= 1.8 * delta
	elif Input.is_action_pressed("move_right") or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		ten_velocidade += 1.8 * delta
		
	ten_velocidade = clamp(ten_velocidade, -1.2, 1.2)
	ten_posicao = clamp(ten_posicao + ten_velocidade * delta, 0.0, 1.0)
	
	progresso_bar.value = ten_posicao * 100.0
	
	if ten_posicao >= 0.35 and ten_posicao <= 0.65:
		score += int(10 * delta * 60)
		lbl_status.text = "✨ Aura Perfeitamente Estável! (+PONTOS)"
		lbl_status.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
	else:
		lbl_status.text = "⚠️ Aura Vazando! Equilibre no centro!"
		lbl_status.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))


# ============================================================
# 2. REN: LIBERAÇÃO DE OUTPUT
# ============================================================
func _setup_ren() -> void:
	lbl_titulo.text = "🥋 TREINO DE REN: LIBERAÇÃO DE POTÊNCIA"
	lbl_instrucoes.text = "Pressione as teclas indicadas no ritmo para expandir seu poder!"
	_gerar_sequencia_ren()


func _gerar_sequencia_ren() -> void:
	var teclas_possiveis = ["W", "A", "S", "D", "SPACE"]
	ren_sequencia.clear()
	for i in range(4):
		ren_sequencia.append(teclas_possiveis[randi() % teclas_possiveis.size()])
	ren_indice_atual = 0
	_atualizar_display_ren()


func _atualizar_display_ren() -> void:
	var texto_seq = "SEQUÊNCIA: "
	for i in range(ren_sequencia.size()):
		if i == ren_indice_atual:
			texto_seq += "[%s] " % ren_sequencia[i]
		elif i < ren_indice_atual:
			texto_seq += "✓ "
		else:
			texto_seq += "%s " % ren_sequencia[i]
	lbl_status.text = texto_seq


func _unhandled_input(event: InputEvent) -> void:
	if not active or modo_atual != ModoTreino.REN:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var tecla_pressionada := ""
		if event.keycode == KEY_W or event.physical_keycode == KEY_W: tecla_pressionada = "W"
		elif event.keycode == KEY_A or event.physical_keycode == KEY_A: tecla_pressionada = "A"
		elif event.keycode == KEY_S or event.physical_keycode == KEY_S: tecla_pressionada = "S"
		elif event.keycode == KEY_D or event.physical_keycode == KEY_D: tecla_pressionada = "D"
		elif event.keycode == KEY_SPACE or event.physical_keycode == KEY_SPACE: tecla_pressionada = "SPACE"
		
		if tecla_pressionada != "":
			if tecla_pressionada == ren_sequencia[ren_indice_atual]:
				score += 25
				ren_indice_atual += 1
				if ren_indice_atual >= ren_sequencia.size():
					score += 50
					_gerar_sequencia_ren()
				else:
					_atualizar_display_ren()
			else:
				score = max(0, score - 15)
				_gerar_sequencia_ren()


# ============================================================
# 3. ZETSU: SUPRESSÃO & SILÊNCIO TOTAL
# ============================================================
func _setup_zetsu() -> void:
	lbl_titulo.text = "🥋 TREINO DE ZETSU: SUPRESSÃO & SILÊNCIO"
	lbl_instrucoes.text = "Pressione e SEGURE [ESPAÇO] quando a barra de pulsação estiver na zona calma!"
	zetsu_aura_atual = 100.0


func _process_zetsu(delta: float) -> void:
	zetsu_respiração_timer += delta
	var ciclo = sin(zetsu_respiração_timer * 3.0)
	zetsu_alvo_respiracao = (ciclo > 0.3)
	
	progresso_bar.value = (ciclo + 1.0) * 50.0
	
	var segurando_espaco = Input.is_key_pressed(KEY_SPACE)
	
	if segurando_espaco:
		if zetsu_alvo_respiracao:
			zetsu_aura_atual = max(0.0, zetsu_aura_atual - (35.0 * delta))
			score += int(12 * delta * 60)
			lbl_status.text = "🧘 Zetsu Silencioso! Nós Fechados: %d%%" % int(100.0 - zetsu_aura_atual)
			lbl_status.add_theme_color_override("font_color", Color(0.2, 0.9, 1.0))
		else:
			zetsu_aura_atual = min(100.0, zetsu_aura_atual + (20.0 * delta))
			lbl_status.text = "⚠️ Respiração Fora de Ritmo! Aura Vazando!"
			lbl_status.add_theme_color_override("font_color", Color(1.0, 0.4, 0.2))
	else:
		zetsu_aura_atual = min(100.0, zetsu_aura_atual + (15.0 * delta))
		lbl_status.text = "Segure [ESPAÇO] durante o pico do ciclo!"
		lbl_status.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))


# ============================================================
# 4. GYO: FOCO VISUAL & REFLEXO
# ============================================================
func _setup_gyo() -> void:
	lbl_titulo.text = "🥋 TREINO DE GYO: FOCO VISUAL & PRECISÃO"
	lbl_instrucoes.text = "Clique nos nós de aura que surgem antes que desapareçam!"
	gyo_spawn_timer = 0.0


func _process_gyo(delta: float) -> void:
	gyo_spawn_timer += delta
	if gyo_spawn_timer >= 0.8:
		gyo_spawn_timer = 0.0
		_spawn_alvo_gyo()


func _spawn_alvo_gyo() -> void:
	if container_jogo.get_child_count() > 4:
		return
		
	var btn := Button.new()
	btn.text = "👁️ NÓ"
	btn.add_theme_font_size_override("font_size", 3)
	var x = randf_range(10, 180)
	var y = randf_range(5, 35)
	btn.position = Vector2(x, y)
	btn.custom_minimum_size = Vector2(30, 14)
	
	btn.pressed.connect(func():
		score += 30
		btn.queue_free()
	)
	container_jogo.add_child(btn)
	
	# Desaparecer após 1.4s
	get_tree().create_timer(1.4).timeout.connect(func():
		if is_instance_valid(btn):
			btn.queue_free()
	)


# ============================================================
# 5. RYU: DISTRIBUIÇÃO DINÂMICA DE FLUXO
# ============================================================
func _setup_ryu() -> void:
	lbl_titulo.text = "🥋 TREINO DE RYU: DISTRIBUIÇÃO DE FLUXO"
	lbl_instrucoes.text = "Use [A]/[D] para ajustar a porcentagem de Ataque/Defesa solicitada!"
	ryu_ataque_porcento = 50.0
	_trocar_alvo_ryu()


func _trocar_alvo_ryu() -> void:
	var modos = [
		{"alvo": 80.0, "nome": "OFENSIVA TOTAL: 80% ATAQUE / 20% DEFESA"},
		{"alvo": 20.0, "nome": "BLINDAGEM PESADA: 20% ATAQUE / 80% DEFESA"},
		{"alvo": 50.0, "nome": "EQUILÍBRIO TÁTICO: 50% ATAQUE / 50% DEFESA"},
		{"alvo": 90.0, "nome": "GOLPE DECISIVO: 90% ATAQUE / 10% DEFESA"},
	]
	var m = modos[randi() % modos.size()]
	ryu_alvo_porcento = m["alvo"]
	ryu_modo_nome = m["nome"]
	ryu_timer_troca = 3.5


func _process_ryu(delta: float) -> void:
	ryu_timer_troca -= delta
	if ryu_timer_troca <= 0.0:
		_trocar_alvo_ryu()
		
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		ryu_ataque_porcento = max(0.0, ryu_ataque_porcento - (80.0 * delta))
	elif Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		ryu_ataque_porcento = min(100.0, ryu_ataque_porcento + (80.0 * delta))
		
	progresso_bar.value = ryu_ataque_porcento
	
	var dif = abs(ryu_ataque_porcento - ryu_alvo_porcento)
	if dif <= 8.0:
		score += int(12 * delta * 60)
		lbl_status.text = "⚖️ %s\nFluxo Perfeito! (+PONTOS)" % ryu_modo_nome
		lbl_status.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
	else:
		lbl_status.text = "⚖️ Alvo: %s\nAtual: %d%% ATQ" % [ryu_modo_nome, int(ryu_ataque_porcento)]
		lbl_status.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))


# ============================================================
# LOOP PRINCIPAL & FINALIZAÇÃO
# ============================================================
func _process(delta: float) -> void:
	if not active:
		return

	tempo_restante -= delta
	lbl_pontos.text = "Pontos: %d" % score
	lbl_tempo.text = "Tempo: %.1fs" % max(0.0, tempo_restante)

	match modo_atual:
		ModoTreino.TEN: _process_ten(delta)
		ModoTreino.ZETSU: _process_zetsu(delta)
		ModoTreino.GYO: _process_gyo(delta)
		ModoTreino.RYU: _process_ryu(delta)

	if tempo_restante <= 0.0:
		_finalizar_treino()


func _finalizar_treino() -> void:
	active = false
	modo_atual = ModoTreino.RESULTADO
	ultimo_treino_tempo = Time.get_ticks_msec() / 1000.0
	_limpar_conteudo()
	progresso_bar.visible = false

	# Calcular Rank de Desempenho
	var rank = "D"
	var mult_xp = 1.0
	if score >= 400:
		rank = "S (Lendário)"
		mult_xp = 3.0
	elif score >= 280:
		rank = "A (Mestre)"
		mult_xp = 2.2
	elif score >= 180:
		rank = "B (Veterano)"
		mult_xp = 1.6
	elif score >= 90:
		rank = "C (Adepto)"
		mult_xp = 1.2

	var xp_ganho: int = int(150 * mult_xp)
	var nen_xp_ganho: int = int(120 * mult_xp)

	# Aplicar XP ao Jogador
	var xp_sys = get_tree().get_first_node_in_group("xp_system") as XPSystem
	if xp_sys:
		xp_sys.adicionar_xp(xp_ganho, "Treino: " + tecnica_selecionada)

	var nen_sys = get_tree().get_first_node_in_group("nen_system") as NenSystem
	if nen_sys and nen_sys.has_method("adicionar_nen_xp"):
		nen_sys.adicionar_nen_xp(nen_xp_ganho)

	lbl_titulo.text = "🏆 RESULTADO DO TREINAMENTO DE NEN"
	lbl_instrucoes.text = "Técnica: %s\nPontuação Final: %d Pontos\nClassificação: RANK %s" % [
		tecnica_selecionada, score, rank
	]
	lbl_status.text = "Recompensas: +%d XP Geral | +%d XP de Nen | Maestria Aumentada!" % [xp_ganho, nen_xp_ganho]
	lbl_status.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))

	minigame_finished.emit(tecnica_selecionada, score)

	var btn_voltar = Button.new()
	btn_voltar.text = "Concluir Treino"
	btn_voltar.add_theme_font_size_override("font_size", 4)
	btn_voltar.pressed.connect(fechar)
	container_menu.add_child(btn_voltar)
