class_name TutorialManagerClass
extends Node

# ============================================================
# HUNTER ONLINE - TUTORIAL, ONBOARDING & KNOWLEDGE MANAGER (AUTOLOAD)
# ============================================================
#
# Gerenciador Mestre de Tutorial Guiado, Onboarding, Tutoriais Contextuais
# e Enciclopédia de Conhecimentos (Hunter Guide).
#
# FLUXO ARQUITETURAL CANÔNICO:
# MAIN_MENU -> SAVE_SELECTION -> NEW GAME -> CHARACTER_CREATION
# -> CHARACTER_CONFIRMATION -> TUTORIAL GUIADO -> TUTORIAL CONCLUÍDO
# -> STORY INTRO (PORTAL EXAME HUNTER) -> GAMEPLAY NORMAL
#
# ============================================================

enum Step {
	INATIVO = -1,
	INTRODUCAO = 0,    # Apresentação e Boas-Vindas de Elena
	MOVIMENTO = 1,     # Caminhar pelo cenário [WASD]
	INTERACAO = 2,     # Interagir com Elena [E]
	MENUS = 3,         # Abrir o Hunter Menu [TAB]
	INVENTARIO = 4,    # Inspecionar itens e consumíveis na aba Inventário [I]
	COMBATE = 5,       # Desferir 3 socos rápidos [J] e praticar esquiva [SHIFT/K]
	STATUS = 6,        # Inspecionar atributos primários na aba Status [C]
	NEN_CONCEITO = 7,  # Compreender a teoria de Aura e Mestres no Dojo com Elena
	CONCLUSAO = 8      # Conclusão oficial, premiação e liberação do Portal do Exame Hunter
}

enum StepState {
	PENDENTE = 0,
	EM_ANDAMENTO = 1,
	CONCLUIDO = 2
}

signal etapa_iniciada(etapa_id: String, titulo: String, instrutor: String, instrucao: String)
signal etapa_progresso(etapa_id: String, atual: float, meta: float, texto_acao: String)
signal etapa_concluida(etapa_id: String, conhecimento_id: String)
signal tutorial_finalizado()
signal tutorial_pulado()
signal tutorial_contextual_disparado(tipo: String, titulo: String, mensagem: String)

var etapa_atual: Step = Step.INATIVO
var estado_etapa_atual: StepState = StepState.PENDENTE
var em_tutorial: bool = false
var _transicao_bloqueada: bool = false

# Rastreamento de métricas em tempo real
var distancia_percorrida: float = 0.0
var ataques_desferidos: int = 0
var esquivas_realizadas: int = 0
var tempo_etapa_atual: float = 0.0

const ETAPAS_INFO: Dictionary = {
	Step.INTRODUCAO: {
		"id": "introducao",
		"titulo": "Treinamento Inicial de Caçador",
		"instrutor": "Recepcionista Elena",
		"objetivo": "Falar com a Recepcionista Elena no saguão para iniciar o treinamento",
		"instrucao": "Saudações, novato! Antes de enfrentar o Exame Hunter, você precisa dominar os comandos fundamentais de sobrevivência.",
		"acao": "Ouça as instruções da Recepcionista Elena [E].",
		"meta": 1.0,
		"conhecimento": "mundo_associacao_hunter"
	},
	Step.MOVIMENTO: {
		"id": "movimento",
		"titulo": "1. Movimentação & Exploração",
		"instrutor": "Recepcionista Elena",
		"objetivo": "Caminhar pelo menos 40 passos no saguão",
		"instrucao": "Use as teclas [W, A, S, D] ou [Setas] para movimentar seu personagem pelo cenário.",
		"acao": "Caminhe pelo saguão",
		"meta": 40.0,
		"conhecimento": "movimento_exploracao"
	},
	Step.INTERACAO: {
		"id": "interacao",
		"titulo": "2. Interação com o Mundo",
		"instrutor": "Recepcionista Elena",
		"objetivo": "Aproximar-se da Recepcionista Elena e pressionar [E]",
		"instrucao": "Aproxime-se de mim (Recepcionista Elena) e pressione [E] ou [Barra de Espaço] para interagir.",
		"acao": "Interaja com a Recepcionista Elena [E].",
		"meta": 1.0,
		"conhecimento": "interacao_npcs"
	},
	Step.MENUS: {
		"id": "menus",
		"titulo": "3. Hunter Menu Consolidado",
		"instrutor": "Recepcionista Elena",
		"objetivo": "Pressionar [TAB] para abrir o Hunter Menu",
		"instrucao": "Pressione a tecla [TAB] para abrir seu Menu Principal unificado de Caçador.",
		"acao": "Abra o Hunter Menu [TAB].",
		"meta": 1.0,
		"conhecimento": "menus_sistema"
	},
	Step.INVENTARIO: {
		"id": "inventario",
		"titulo": "4. Inventário & Suprimentos",
		"instrutor": "Recepcionista Elena",
		"objetivo": "Acessar a aba de Inventário ou inspecionar suprimentos",
		"instrucao": "Acesse a aba de Inventário no Menu [TAB] (ou use [I]) para inspecionar seus itens iniciais.",
		"acao": "Abra a aba Inventário [I].",
		"meta": 1.0,
		"conhecimento": "inventario_suprimentos"
	},
	Step.COMBATE: {
		"id": "combate",
		"titulo": "5. Combate Físico & Esquiva",
		"instrutor": "Recepcionista Elena",
		"objetivo": "Desferir 3 ataques físicos [J] ou esquivar com [SHIFT/K]",
		"instrucao": "Desfira 3 socos rápidos pressionando [J] ou [Botão Esquerdo] e pratique a esquiva com [ESPAÇO/SHIFT].",
		"acao": "Desfira ataques físicos [J]",
		"meta": 3.0,
		"conhecimento": "combate_basico"
	},
	Step.STATUS: {
		"id": "status",
		"titulo": "6. Atributos & Nível",
		"instrutor": "Recepcionista Elena",
		"objetivo": "Visualizar a aba de Status para entender Vida (HP), Força, Defesa e Velocidade",
		"instrucao": "Abra a aba de Status no Menu [TAB] (ou use [C]) para conferir sua Vida (HP), Força, Defesa e Velocidade.",
		"acao": "Visualize a aba de Status [C].",
		"meta": 1.0,
		"conhecimento": "atributos_vitalidade"
	},
	Step.NEN_CONCEITO: {
		"id": "nen_conceito",
		"titulo": "7. O Conceito de Aura e Nen",
		"instrutor": "Recepcionista Elena",
		"objetivo": "Ouvir a explicação sobre Aura e os Mestres de Nen com Elena",
		"instrucao": "Aura é a energia vital de todos os seres. Caçadores de elite aprendem a controlá-la para despertar o Nen. Avance na história para iniciar o treinamento com Mestre Wing!",
		"acao": "Fale com Elena [E] sobre Aura e Nen.",
		"meta": 1.0,
		"conhecimento": "aura_energia_vital"
	},
	Step.CONCLUSAO: {
		"id": "conclusao",
		"titulo": "Treinamento Concluído!",
		"instrutor": "Recepcionista Elena",
		"objetivo": "Dirigir-se ao Portal Hunter a Leste para o 287º Exame Hunter",
		"instrucao": "Parabéns! Você concluiu todos os fundamentos com excelência. O Portal para o 287º Exame Hunter a Leste está liberado!",
		"acao": "Siga para o Portal Hunter a Leste.",
		"meta": 1.0,
		"conhecimento": "mundo_exame_hunter"
	}
}

# Catálogo Enciclopédico do Hunter Guide
const CATALOGO_CONHECIMENTOS: Dictionary = {
	"mundo_associacao_hunter": {
		"titulo": "A Associação Hunter",
		"categoria": "Mundo",
		"icone": "🏛️",
		"conteudo": "A Associação Hunter é uma organização global que licencia especialistas de elite para exploração de áreas perigosas, preservação de espécies e manutenção da paz. Ser aprovado no Exame Hunter concede a cobiçada Licença Hunter de 1 Estrela."
	},
	"mundo_capital_hunter": {
		"titulo": "Hunter Plaza (Capital dos Caçadores)",
		"categoria": "Mundo",
		"icone": "🌆",
		"conteudo": "A metrópole central que abriga os 4 grandes distritos: Praça Central (Netero), Distrito dos Mestres (Wing e Biscuit), Distrito Comercial (Ferreiro e Casa) e Distrito Dimensional (Torre Celestial e Portal Hunter)."
	},
	"movimento_exploracao": {
		"titulo": "Movimentação & Exploração",
		"categoria": "Controles",
		"icone": "👟",
		"conteudo": "Use as teclas [W, A, S, D] ou [Setas] para movimentação. Segure [Shift] para correr aumentando sua velocidade com base no atributo de Velocidade."
	},
	"interacao_npcs": {
		"titulo": "Interação com o Mundo",
		"categoria": "Controles",
		"icone": "💬",
		"conteudo": "Aproxime-se de cidadãos, mestres, portas ou baús de tesouro e pressione a tecla [E] ou [Barra de Espaço] para interagir e aceitar missões."
	},
	"menus_sistema": {
		"titulo": "O Hunter Menu Unificado",
		"categoria": "Interface",
		"icone": "📜",
		"conteudo": "Pressione a tecla [TAB] para acessar seu menu central consolidado contendo: Status, Inventário, Nen Tree, Hatsu, Licença Hunter, Facções, Guia e Aparência."
	},
	"inventario_suprimentos": {
		"titulo": "Inventário & Consumíveis",
		"categoria": "Itens",
		"icone": "🎒",
		"conteudo": "Gerencie Poções de Cura, Elixires de Aura, Armaduras e sua Licença Hunter. Clique em consumíveis para recuperar Vida e Aura instantaneamente."
	},
	"combate_basico": {
		"titulo": "Combate Físico & Esquiva",
		"categoria": "Combate",
		"icone": "🥊",
		"conteudo": "Pressione [J] ou [Botão Esquerdo do Mouse] para golpear. Use a tecla [K] ou [Shift] no momento exato do golpe inimigo para executar o 'PERFECT DODGE', esquivando de 100% do dano e recuperando Aura."
	},
	"atributos_vitalidade": {
		"titulo": "Atributos Primários do Caçador",
		"categoria": "Personagem",
		"icone": "❤️",
		"conteudo": "• Vida (HP): Sua resistência a dano.\n• Aura: Energia gasta ao utilizar técnicas de Nen e Hatsu.\n• Força: Aumenta o dano dos golpes físicos.\n• Defesa: Reduz o dano recebido.\n• Velocidade: Diminui o tempo de recarga dos ataques e acelera a corrida."
	},
	"aura_energia_vital": {
		"titulo": "Aura: A Força Vital",
		"categoria": "Aura & Nen",
		"icone": "⚡",
		"conteudo": "Aura é a energia que escapa continuamente dos poros do corpo humano. Usuários treinados conseguem reter, concentrar e projetar essa energia vital através do Nen."
	},
	"nen_4_principios": {
		"titulo": "Os 4 Grandes Princípios do Nen",
		"categoria": "Aura & Nen",
		"icone": "🥋",
		"conteudo": "1. TEN (Envolver): Mantém a aura no corpo para defesa.\n2. ZETSU (Suprimir): Fecha os poros para regeneração rápida e furtividade.\n3. REN (Expandir): Emite uma quantidade explosiva de aura.\n4. HATSU (Liberar): A expressão pessoal única e personalizada da aura."
	},
	"nen_tecnica_ten": {
		"titulo": "Técnica: TEN (Manto Protetor)",
		"categoria": "Aura & Nen",
		"icone": "🛡️",
		"conteudo": "Ao ativar o Ten [N], uma película densa de aura reveste o corpo, concedendo até +40% de redução de dano físico contra ataques inimigos."
	},
	"nen_tecnica_ren": {
		"titulo": "Técnica: REN (Expansão de Alcance)",
		"categoria": "Aura & Nen",
		"icone": "💥",
		"conteudo": "O Ren expande a aura para fora dos punhos, dobrando a área e o alcance de acerto de todos os seus ataques básicos."
	},
	"nen_tecnica_zetsu": {
		"titulo": "Técnica: ZETSU (Silêncio Furtivo)",
		"categoria": "Aura & Nen",
		"icone": "🌿",
		"conteudo": "O Zetsu fecha completamente o fluxo de aura, acelerando a regeneração natural de Vida e permitindo infligir Dano Crítico x3 ao golpear inimigos pelas costas."
	},
	"nen_tecnica_gyo": {
		"titulo": "Técnica: GYO (Visão Reveladora)",
		"categoria": "Aura & Nen",
		"icone": "👁️",
		"conteudo": "Concentra a aura nos olhos para revelar armadilhas invisíveis e aumentar a taxa de acerto crítico em +35%."
	},
	"nen_tecnica_ko": {
		"titulo": "Técnica: KO (Concentração Máxima)",
		"categoria": "Aura & Nen",
		"icone": "👊",
		"conteudo": "Concentra 100% da aura em um único punho. Concede +75% de poder de impacto e o efeito 'Guard Break', quebrando defesas impenetráveis."
	},
	"nen_tecnica_ken": {
		"titulo": "Técnica: KEN (Blindagem Geral)",
		"categoria": "Aura & Nen",
		"icone": "🧱",
		"conteudo": "Manter o Ren por todo o corpo em estado de defesa contínua. Protege contra golpes surpresa durante combates prolongados."
	},
	"nen_tecnica_ryu": {
		"titulo": "Técnica: RYU (Fluxo Dinâmico)",
		"categoria": "Aura & Nen",
		"icone": "🌊",
		"conteudo": "Distribui a aura em tempo real (ex: 80% no punho atacante e 20% no corpo defensivo), dominando a técnica avançada ensinada por Biscuit."
	},
	"nen_tecnica_en": {
		"titulo": "Técnica: EN (Percepção Total)",
		"categoria": "Aura & Nen",
		"icone": "🌐",
		"conteudo": "Expande a aura em formato esférico de dezenas de metros, detectando instantaneamente a presença e a intenção de qualquer inimigo na área."
	},
	"nen_tecnica_shu": {
		"titulo": "Técnica: SHU (Revestimento de Objetos)",
		"categoria": "Aura & Nen",
		"icone": "🗡️",
		"conteudo": "Estende sua aura sobre armas ou objetos empunhados (como pás, espadas ou cartas de baralho), transformando-os em lâminas letais."
	},
	"mundo_exame_hunter": {
		"titulo": "O 287º Exame Hunter",
		"categoria": "Mundo",
		"icone": "⛩️",
		"conteudo": "A prova mais implacável do mundo. Dividido em múltiplas fases (Maratona de Zaban, Pantanal Numere, Floresta Doki, Torre Celestial e Batalhas Finais) com Gon, Killua, Kurapika e Leorio."
	}
}


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	_conectar_eventos()
	print("=================================")
	print("[TutorialManager] SISTEMA DE ONBOARDING & HUNTER GUIDE ATIVO")
	print("=================================")


func _process(delta: float) -> void:
	if em_tutorial and etapa_atual != Step.INATIVO:
		tempo_etapa_atual += delta


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return

	# Debug Shortcuts para Onboarding
	match event.keycode:
		KEY_F6:
			print("[Tutorial Debug] F6: Avançando etapa do tutorial...")
			avancar_etapa()
			get_viewport().set_input_as_handled()
		KEY_F7:
			print("[Tutorial Debug] F7: Concluindo etapa atual...")
			concluir_etapa_atual("DEBUG_KEY_F7")
			get_viewport().set_input_as_handled()
		KEY_F8:
			print("[Tutorial Debug] F8: Resetando tutorial...")
			resetar_tutorial()
			get_viewport().set_input_as_handled()
		KEY_F9:
			print("[Tutorial Debug] F9: Forçando início do tutorial...")
			iniciar_tutorial_inicial()
			get_viewport().set_input_as_handled()


func _conectar_eventos() -> void:
	if EventBus != null:
		EventBus.menu_opened.connect(_on_menu_opened)
		EventBus.item_used.connect(_on_item_used)


# ============================================================
# 1. CONTROLE DE FLUXO E MÁQUINA DE ESTADOS DO TUTORIAL
# ============================================================

func iniciar_tutorial_inicial() -> void:
	if PlayerData != null and PlayerData.tutorial_concluido:
		print("[TutorialManager] Tutorial já consta como concluído para este perfil.")
		return

	em_tutorial = true
	_transicao_bloqueada = false
	distancia_percorrida = 0.0
	ataques_desferidos = 0
	esquivas_realizadas = 0
	tempo_etapa_atual = 0.0

	if GameManager != null:
		GameManager.set_flow_state(GameManager.GameFlowState.TUTORIAL)
	if InputContextManager != null:
		InputContextManager.set_context("TUTORIAL")

	iniciar_etapa(Step.INTRODUCAO)

	if EventBus != null:
		EventBus.tutorial_started.emit("tutorial_inicial")


func iniciar_etapa(step: Step) -> void:
	etapa_atual = step
	estado_etapa_atual = StepState.EM_ANDAMENTO
	tempo_etapa_atual = 0.0
	_transicao_bloqueada = false

	var info = ETAPAS_INFO.get(step, {})
	var etapa_id: String = info.get("id", "desconhecido")
	var titulo: String = info.get("titulo", "")
	var instrutor: String = info.get("instrutor", "Recepcionista Elena")
	var instrucao: String = info.get("instrucao", "")

	print("[TutorialManager] 🚀 INICIANDO ETAPA %d: %s (ID: %s)" % [int(step), titulo, etapa_id])

	etapa_iniciada.emit(etapa_id, titulo, instrutor, instrucao)
	if EventBus != null:
		EventBus.tutorial_step_started.emit(etapa_id, int(step))


func atualizar_progresso(atual: float, meta: float, texto_acao: String) -> void:
	if not em_tutorial or etapa_atual == Step.INATIVO:
		return
	var info = ETAPAS_INFO.get(etapa_atual, {})
	var etapa_id: String = info.get("id", "")
	etapa_progresso.emit(etapa_id, min(atual, meta), meta, texto_acao)


func concluir_etapa_atual(origem_motivo: String = "") -> void:
	if not em_tutorial or etapa_atual == Step.INATIVO:
		return

	if _transicao_bloqueada:
		return

	_transicao_bloqueada = true
	estado_etapa_atual = StepState.CONCLUIDO

	var info = ETAPAS_INFO.get(etapa_atual, {})
	var etapa_id: String = info.get("id", "")
	var conhecimento: String = info.get("conhecimento", "")

	print("[TutorialManager] ✅ ETAPA %d CONCLUÍDA: %s | Motivo: %s | Tempo: %.2fs" % [
		int(etapa_atual),
		info.get("titulo", ""),
		origem_motivo if not origem_motivo.is_empty() else "Ação Realizada",
		tempo_etapa_atual
	])

	if PlayerData != null:
		PlayerData.concluir_etapa_tutorial(etapa_id)
		if not conhecimento.is_empty():
			PlayerData.desbloquear_conhecimento(conhecimento)

	etapa_concluida.emit(etapa_id, conhecimento)
	if EventBus != null:
		EventBus.tutorial_step_completed.emit(etapa_id, int(etapa_atual))
		EventBus.emit_toast("✅ %s Concluído!" % info.get("titulo", ""), Color(0.3, 1.0, 0.4))

	# Avançar deterministamente para a próxima etapa
	avancar_etapa()


func avancar_etapa() -> void:
	if not em_tutorial:
		return

	var proximo_int: int = int(etapa_atual) + 1
	if proximo_int >= Step.CONCLUSAO:
		etapa_atual = Step.CONCLUSAO
		finalizar_tutorial()
	else:
		iniciar_etapa(proximo_int as Step)


func finalizar_tutorial() -> void:
	em_tutorial = false
	etapa_atual = Step.INATIVO
	estado_etapa_atual = StepState.CONCLUIDO
	_transicao_bloqueada = false

	if PlayerData != null:
		PlayerData.tutorial_concluido = true
		PlayerData.tour_lobby_concluido = true
		PlayerData.concluir_etapa_tutorial("tutorial_inicial_concluido")
		PlayerData.desbloquear_conhecimento("mundo_exame_hunter")
		PlayerData.desbloquear_conhecimento("mundo_capital_hunter")

	if GameManager != null:
		GameManager.set_flow_state(GameManager.GameFlowState.STORY_INTRO)
		GameManager.change_state(GameManager.GameState.IN_GAME)
	if InputContextManager != null:
		InputContextManager.set_context("GAMEPLAY")

	print("=================================")
	print("[TutorialManager] 🎓 TUTORIAL INICIAL CONCLUÍDO COM SUCESSO!")
	print("=================================")

	tutorial_finalizado.emit()
	if EventBus != null:
		EventBus.tutorial_completed.emit("tutorial_inicial")
		EventBus.emit_toast("🎓 Treinamento Concluído! O Portal Hunter a Leste está aberto!", Color(0.3, 1.0, 0.4))


func pular_tutorial() -> void:
	em_tutorial = false
	etapa_atual = Step.INATIVO
	estado_etapa_atual = StepState.CONCLUIDO
	_transicao_bloqueada = false

	if PlayerData != null:
		PlayerData.tutorial_concluido = true
		PlayerData.tour_lobby_concluido = true
		PlayerData.tutorial_data["tutorial_inicial_concluido"] = true
		PlayerData.tutorial_data["introducao"] = true
		PlayerData.tutorial_data["movimento"] = true
		PlayerData.tutorial_data["interacao"] = true
		PlayerData.tutorial_data["menus"] = true
		PlayerData.tutorial_data["inventario"] = true
		PlayerData.tutorial_data["combate"] = true
		PlayerData.tutorial_data["status"] = true
		PlayerData.tutorial_data["nen_conceito"] = true

		# Desbloquear conhecimentos fundamentais do guia
		PlayerData.desbloquear_conhecimento("mundo_associacao_hunter")
		PlayerData.desbloquear_conhecimento("mundo_capital_hunter")
		PlayerData.desbloquear_conhecimento("movimento_exploracao")
		PlayerData.desbloquear_conhecimento("interacao_npcs")
		PlayerData.desbloquear_conhecimento("menus_sistema")
		PlayerData.desbloquear_conhecimento("inventario_suprimentos")
		PlayerData.desbloquear_conhecimento("combate_basico")
		PlayerData.desbloquear_conhecimento("atributos_vitalidade")
		PlayerData.desbloquear_conhecimento("aura_energia_vital")
		PlayerData.desbloquear_conhecimento("mundo_exame_hunter")

		# Garantir RIGOROSAMENTE que Hatsus continuam vazios
		PlayerData.hatsu_criados.clear()
		PlayerData.hatsu_slots = [-1, -1, -1, -1]

	if GameManager != null:
		GameManager.set_flow_state(GameManager.GameFlowState.STORY_INTRO)
		GameManager.change_state(GameManager.GameState.IN_GAME)
	if InputContextManager != null:
		InputContextManager.set_context("GAMEPLAY")

	print("[TutorialManager] ⏭️ Tutorial pulado pelo jogador. Conhecimentos registrados no Guia.")
	tutorial_pulado.emit()
	if EventBus != null:
		EventBus.tutorial_skipped.emit("tutorial_inicial")
		EventBus.emit_toast("⏭️ Tutorial pulado. Consulte o Guia Hunter no menu [TAB].", Color(0.8, 0.8, 1.0))


func resetar_tutorial() -> void:
	if PlayerData != null:
		PlayerData.tutorial_concluido = false
		PlayerData.tour_lobby_concluido = false
		PlayerData.tutorial_data.clear()
	iniciar_tutorial_inicial()


# ============================================================
# 2. DETECTORES DE AÇÃO DO JOGADOR
# ============================================================

func notificar_movimento(delta_dist: float) -> void:
	if not em_tutorial or etapa_atual != Step.MOVIMENTO or _transicao_bloqueada:
		return
	distancia_percorrida += delta_dist
	var meta: float = ETAPAS_INFO[Step.MOVIMENTO]["meta"]
	atualizar_progresso(distancia_percorrida, meta, "Caminhe pelo saguão [WASD]")
	if distancia_percorrida >= meta:
		concluir_etapa_atual("Movimento Concluído")


func notificar_interacao(_npc_nome: String = "") -> void:
	if not em_tutorial or _transicao_bloqueada:
		return
	if etapa_atual == Step.INTRODUCAO:
		concluir_etapa_atual("Diálogo de Boas-Vindas")
	elif etapa_atual == Step.INTERACAO:
		concluir_etapa_atual("Interação Realizada")
	elif etapa_atual == Step.NEN_CONCEITO:
		concluir_etapa_atual("Teoria de Nen Aprendida")


func notificar_menu_aberto(menu_nome: String = "") -> void:
	if not em_tutorial or _transicao_bloqueada:
		return
	if etapa_atual == Step.MENUS:
		concluir_etapa_atual("Menu %s Aberto" % menu_nome)


func notificar_aba_inventario_aberta() -> void:
	if not em_tutorial or _transicao_bloqueada:
		return
	if etapa_atual == Step.INVENTARIO or etapa_atual == Step.MENUS:
		concluir_etapa_atual("Aba Inventário Aberta")


func notificar_item_usado(_item_id: String = "") -> void:
	if not em_tutorial or _transicao_bloqueada:
		return
	if etapa_atual == Step.INVENTARIO:
		concluir_etapa_atual("Item Consumido")


func notificar_ataque_executado() -> void:
	if not em_tutorial or etapa_atual != Step.COMBATE or _transicao_bloqueada:
		return
	ataques_desferidos += 1
	var meta: float = ETAPAS_INFO[Step.COMBATE]["meta"]
	atualizar_progresso(float(ataques_desferidos), meta, "Desfira ataques físicos [J]")
	if ataques_desferidos >= int(meta):
		concluir_etapa_atual("Combate Físico Dominado")


func notificar_esquiva_executada() -> void:
	if not em_tutorial or _transicao_bloqueada:
		return
	esquivas_realizadas += 1
	if etapa_atual == Step.COMBATE:
		concluir_etapa_atual("Esquiva Praticada")


func notificar_aba_status_aberta() -> void:
	if not em_tutorial or _transicao_bloqueada:
		return
	if etapa_atual == Step.STATUS or etapa_atual == Step.MENUS:
		concluir_etapa_atual("Aba Status Inspecionada")


func notificar_guia_aberto() -> void:
	if not em_tutorial or _transicao_bloqueada:
		return


func _on_menu_opened(menu_nome: String) -> void:
	notificar_menu_aberto(menu_nome)


func _on_item_used(item_id: String) -> void:
	notificar_item_usado(item_id)


# ============================================================
# 3. CONSTRUTOR DE DIÁLOGOS DE ELENA (FONTE ÚNICA DE VERDADE)
# ============================================================

func obter_dialogo_elena() -> Array[Dictionary]:
	var falas: Array[Dictionary] = []
	var nome_p = PlayerData.nome_personagem if PlayerData != null else "Hunter"

	match etapa_atual:
		Step.INTRODUCAO:
			falas.append({"falante": "Recepcionista Elena", "texto": "Olá, %s! Seja muito bem-vindo à Capital dos Caçadores da Associação Hunter!" % nome_p})
			falas.append({"falante": "Recepcionista Elena", "texto": "Antes de enfrentar os perigos extremos do 287º Exame Hunter, vamos praticar os comandos fundamentais de sobrevivência."})
			falas.append({"falante": "Recepcionista Elena", "texto": "👟 Lição 1: Movimentação! Use as teclas [W, A, S, D] ou as [Setas] para caminhar pelo saguão."})
		Step.MOVIMENTO:
			falas.append({"falante": "Recepcionista Elena", "texto": "Continue se movimentando pelo saguão com [W, A, S, D]! Complete 40 passos para dominar o ritmo de exploração."})
		Step.INTERACAO:
			falas.append({"falante": "Recepcionista Elena", "texto": "Excelente! A tecla [E] ou [Espaço] é sua chave de interação no mundo: use-a para falar com cidadãos, aceitar missões e abrir baús."})
			falas.append({"falante": "Recepcionista Elena", "texto": "📜 Lição 2: O Hunter Menu! Pressione a tecla [TAB] para abrir seu Menu Principal unificado de Caçador."})
		Step.MENUS:
			falas.append({"falante": "Recepcionista Elena", "texto": "Pressione a tecla [TAB] no teclado para abrir seu Hunter Menu!"})
		Step.INVENTARIO:
			falas.append({"falante": "Recepcionista Elena", "texto": "No menu [TAB], clique na aba 'Inventário' (ou use a tecla [I]) para inspecionar seus suprimentos e poções!"})
		Step.COMBATE:
			falas.append({"falante": "Recepcionista Elena", "texto": "⚔️ Lição 3: Combate Físico! Feche o menu [ESC/TAB] e desfira 3 socos rápidos com [J] ou [Botão Esquerdo], e pratique sua esquiva com [SHIFT] ou [K]!"})
		Step.STATUS:
			falas.append({"falante": "Recepcionista Elena", "texto": "❤️ Lição 4: Atributos! Abra o menu [TAB] e clique na aba 'Status' (ou use [C]) para conferir sua Vida (HP), Força, Defesa e Velocidade."})
		Step.NEN_CONCEITO:
			falas.append({"falante": "Recepcionista Elena", "texto": "🔥 Lição Final: A Teoria de Aura e Nen!"})
			falas.append({"falante": "Recepcionista Elena", "texto": "Aura é a energia vital emitida por todos os seres vivos. Quem aprende a canalizá-la desperta o temido e supremo NEN!"})
			falas.append({"falante": "Recepcionista Elena", "texto": "Todo novato inicia sua jornada com 0 Nível de Nen e 0 Hatsus. Suas 9 técnicas de Nen (Ten, Ren, Zetsu, Gyo...) serão aprendidas com Mestre Wing no Dojo!"})
			falas.append({"falante": "Recepcionista Elena", "texto": "E suas habilidades exclusivas de Hatsu serão desenvolvidas com Biscuit Krueger após você provar seu valor no Exame Hunter!"})
			falas.append({"falante": "Recepcionista Elena", "texto": "🎓 Parabéns! Você concluiu o Treinamento Básico com louvor! Você recebeu 500 Jenny, Poções de Vida e o Guia Hunter no menu [TAB]!"})
		_:
			falas.append({"falante": "Recepcionista Elena", "texto": "Parabéns por concluir seu treinamento! Dirija-se ao Portal Hunter no Distrito Dimensional a Leste para iniciar o Exame Hunter!"})

	return falas


func obter_fala_lembrete_elena() -> String:
	match etapa_atual:
		Step.MOVIMENTO:
			return "Use [W, A, S, D] para caminhar pelo saguão!"
		Step.MENUS:
			return "Pressione [TAB] para abrir o Hunter Menu!"
		Step.INVENTARIO:
			return "Abra a aba Inventário [I] no menu [TAB]!"
		Step.COMBATE:
			return "Desfira 3 socos rápidos com [J] ou esquive com [SHIFT]!"
		Step.STATUS:
			return "Abra a aba Status [C] no menu [TAB]!"
		_:
			return "Fale comigo para continuar seu treinamento!"


# ============================================================
# 4. TUTORIAIS CONTEXTUAIS & HUNTER GUIDE
# ============================================================

func disparar_tutorial_contextual(tipo: String) -> void:
	var tipo_clean: String = tipo.to_lower()
	var titulo := "Dica Hunter"
	var msg := ""

	match tipo_clean:
		"nen_despertar":
			titulo = "🥋 DESPERTAR DE NEN"
			msg = "Você abriu seus poros de Nen! Use a tecla [N] para alternar entre Ten (Defesa), Ren (Ataque) e Zetsu (Cura e Furtividade)."
			PlayerData.desbloquear_conhecimento("nen_4_principios")
		"perfect_dodge":
			titulo = "⚡ PERFECT DODGE"
			msg = "Esquivar no momento exato do impacto concede imunidade total e recarrega instantaneamente 30% da sua Aura!"
			PlayerData.desbloquear_conhecimento("combate_basico")
		"hatsu_desbloqueio":
			titulo = "✨ CRIAÇÃO DE HATSU"
			msg = "Hatsu é sua habilidade suprema personalizada! Equipe suas técnicas nos slots 1 a 4 e use-as com sabedoria em batalha."
			PlayerData.desbloquear_conhecimento("nen_tecnica_ko")
		_:
			return

	tutorial_contextual_disparado.emit(tipo_clean, titulo, msg)
	if EventBus != null:
		EventBus.tutorial_contextual_requested.emit(tipo_clean, titulo, msg)


func exibir_tutorial_contextual(tipo: String) -> void:
	disparar_tutorial_contextual(tipo)


func obter_catalogo_completo() -> Dictionary:
	return CATALOGO_CONHECIMENTOS


func obter_artigo(artigo_id: String) -> Dictionary:
	return CATALOGO_CONHECIMENTOS.get(artigo_id, {})