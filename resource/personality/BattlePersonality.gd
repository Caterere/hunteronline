class_name BattlePersonality
extends Resource

# ============================================================
# HUNTER ONLINE — BATTLE PERSONALITY ARCHITECTURE (FASE G)
# ============================================================
#
# Governa o temperamento, reatividade psicológica, diálogos e
# reações de combate de NPCs (Tiers 2, 3 e 4):
#
# ├── Intro (entrada e fala inicial)
# ├── Taunts (provocações durante o combate)
# ├── Attack Lines (falas contextuais por habilidade)
# ├── Hatsu Lines (grito/ativação de técnica)
# ├── Damage Reactions (reações a dano pesado ou acertos críticos)
# ├── Low HP Reactions (desespero, foco ou postura defensiva)
# ├── Player Hatsu Reactions (ex.: "Então esse é o seu tipo de Nen...")
# ├── Phase Transitions (mudança de postura, efeito ou animação)
# ├── Victory (fala e animação de vitória)
# └── Defeat (fala, animação de colapso ou fuga narrativa)
# ============================================================

@export_category("Identity")
@export var character_name: String = "Inimigo"
@export var archetype: String = "Orgulhoso" # "Orgulhoso", "Frio", "Sádico", "Honrado", "Bestial", "Calculista"

@export_category("Dialogue Triggers")
@export var intro_lines: Array = []
@export var taunt_lines: Array = []
@export var attack_lines: Dictionary = {} # skill_name -> Array
@export var generic_attack_lines: Array = []
@export var hatsu_lines: Array = []
@export var damage_reactions: Array = []
@export var low_hp_reactions: Array = []
@export var player_hatsu_reactions: Array = []
@export var phase_transition_lines: Array = []
@export var victory_lines: Array = []
@export var defeat_lines: Array = []

@export_category("Parameters")
@export var taunt_interval_min: float = 7.0
@export var taunt_interval_max: float = 14.0
@export var reads_player_nen: bool = true
@export var balloon_color_bg: Color = Color(0.08, 0.08, 0.12, 0.95)
@export var balloon_color_border: Color = Color(1.0, 0.85, 0.25, 1.0)


# ============================================================
# CONSULTAS DE FALAS CONTEXTUAIS
# ============================================================

func obter_intro() -> String:
	return _sortear(intro_lines)


func obter_taunt() -> String:
	return _sortear(taunt_lines)


func obter_fala_ataque(skill_name: String = "") -> String:
	if not skill_name.is_empty() and attack_lines.has(skill_name):
		var arr: Array = attack_lines[skill_name]
		if not arr.is_empty():
			return arr.pick_random()
	return _sortear(generic_attack_lines)


func obter_fala_hatsu() -> String:
	return _sortear(hatsu_lines)


func obter_reacao_dano_pesado() -> String:
	return _sortear(damage_reactions)


func obter_reacao_hp_baixo() -> String:
	return _sortear(low_hp_reactions)


func obter_reacao_vida_baixa() -> String:
	return obter_reacao_hp_baixo()


func obter_reacao_player_hatsu(hatsu_nome: String = "", categoria_nome: String = "") -> String:
	if not player_hatsu_reactions.is_empty():
		var line = player_hatsu_reactions.pick_random()
		if "%s" in line:
			return line % (hatsu_nome if not hatsu_nome.is_empty() else "Nen")
		return line

	# Fallbacks canônicos se a lista estiver vazia
	if not categoria_nome.is_empty():
		return "Um usuário de %s... Interessante!" % categoria_nome
	return "Entendo... Então essa é a essência do seu Hatsu!"


func obter_transicao_fase(fase_idx: int) -> String:
	if fase_idx < phase_transition_lines.size():
		return phase_transition_lines[fase_idx]
	return _sortear(phase_transition_lines)


func obter_vitoria() -> String:
	return _sortear(victory_lines)


func obter_derrota() -> String:
	return _sortear(defeat_lines)


func _sortear(lista: Array) -> String:
	if lista.is_empty():
		return ""
	return str(lista.pick_random())


# ============================================================
# FÁBRICAS PRÉ-CONFIGURADAS DE PERSONAGENS ICÔNICOS (TASK 2.3)
# ============================================================

static func _criar_instancia() -> Resource:
	var s = load("res://resource/personality/BattlePersonality.gd")
	return s.new()


static func criar_hisoka() -> Resource:
	var p = _criar_instancia()
	p.character_name = "Hisoka Morow"
	p.archetype = "Sádico"
	p.balloon_color_bg = Color(0.12, 0.04, 0.10, 0.95)
	p.balloon_color_border = Color(1.0, 0.25, 0.65, 1.0) # Rosa Bungee Gum

	p.intro_lines = [
		"♠ Schwing~! Que olhar afiado... Você parece um fruto delicioso para colher. ♦",
		"♥ Não se contenha. Quero sentir a textura da sua intenção assassina! ♣"
	]
	p.taunt_lines = [
		"♠ Muito lento... Já está sem ar? ♦",
		"♥ Você sabia que minha Bungee Gum possui propriedades da borracha E do chiclete? ♣",
		"♦ Uma dança tão descuidada... Você está prestes a quebrar. ♠",
		"♣ O truque de um mágico nunca se repete da mesma forma... ♥"
	]
	p.generic_attack_lines = [
		"♠ Olhe as cartas voando! ♦",
		"♥ Peguei você! ♣"
	]
	p.hatsu_lines = [
		"♥ BUNGEE GUM! Agora estamos conectados pelo destino... e pela borracha! ♣",
		"♠ TEXTURA ENGANOSA! O que você vê já não existe mais! ♦"
	]
	p.damage_reactions = [
		"♥ Ahh... Essa dor... É tão excitante! Mais! ♠",
		"♦ Nada mal... O fruto tem espinhos afiados afinal. ♣"
	]
	p.low_hp_reactions = [
		"♠ Que esplêndido! É no limite da morte que a aura brilha com mais apetite! ♦",
		"♥ Não pare agora... Vamos transformar essa arena em uma obra de arte carmesim! ♣"
	]
	p.player_hatsu_reactions = [
		"♠ Schwing~! Então esse é o seu Hatsu? Um brinquedo tão fascinante! ♦",
		"♥ Uma técnica adorável... Mas ela consegue esticar tanto quanto a minha? ♣"
	]
	p.phase_transition_lines = [
		"♣ Acabou a preliminar... Hora de colher você por inteiro! ♠",
		"♦ Schwing~! A verdadeira performance começa agora! ♥"
	]
	p.victory_lines = [
		"♠ Um fruto colhido antes de amadurecer por completo... Que pena. ♦",
		"♥ Durma bem... Foi uma dança razoavelmente divertida. ♣"
	]
	p.defeat_lines = [
		"♦ Incrível... Você superou minhas expectativas. Guardarei sua colheita para o futuro... ♠",
		"♥ Schwing~! Que golpe maravilhoso... Nos veremos novamente no topo! ♣"
	]
	return p


static func criar_razor() -> Resource:
	var p = _criar_instancia()
	p.character_name = "Razor"
	p.archetype = "Honrado"
	p.balloon_color_bg = Color(0.08, 0.08, 0.08, 0.95)
	p.balloon_color_border = Color(1.0, 0.55, 0.15, 1.0) # Laranja Emissão

	p.intro_lines = [
		"🏐 Esta quadra de Greed Island não perdoa fraqueza. Prepare-se para receber o saque!",
		"🏐 Um caçador precisa de pés firmes e aura inabalável. Mostre-me sua convicção!"
	]
	p.taunt_lines = [
		"🏐 Está com medo de uma bola de Nen? Segure firme com Ryu!",
		"🏐 Mantenha o foco! Meus 14 demônios de emissão cobrem cada centímetro da quadra!",
		"🏐 Postura fraca! Concentre Ten em todo o corpo se quiser sobreviver!"
	]
	p.generic_attack_lines = [
		"🏐 SAQUE EMISSO DE 300 KM/H!",
		"🏐 RECEBA ESTE CORTE!"
	]
	p.hatsu_lines = [
		"🏐 14 DEMÔNIOS DE EMISSÃO! Bloqueiem todas as rotas de escape!",
		"🏐 ARREMESSO DE IMPACTO MÁXIMO! CONCENTREM RYU NAS DUAS MÃOS!"
	]
	p.damage_reactions = [
		"Hmph! Um impacto sólido... Você tem força nos punhos!",
		"Belo golpe! Mas vai precisar de muito mais para quebrar minha guarda!"
	]
	p.low_hp_reactions = [
		"Excelente... Ging escolheu bem os seus companheiros. Vamos com tudo até o apito final!",
		"Nem pense que vou diminuir a velocidade. Este é o meu último e mais pesado saque!"
	]
	p.player_hatsu_reactions = [
		"Uma técnica afiada! Você sincronizou perfeitamente a saída da sua aura!",
		"Belo Hatsu! Mas poder bruto não adianta sem controle absoluto de Ryu!"
	]
	p.phase_transition_lines = [
		"🏐 É hora da decisão! Reúnam-se, Demônios Nº 1 ao Nº 14!",
		"Chega de aquecimento. Este próximo arremesso vai atravessar a quadra inteira!"
	]
	p.victory_lines = [
		"🏐 PONTO E JOGO! Volte quando aprender a interceptar uma bola de verdade.",
		"Sua determinação é boa, mas sua aura cedeu sob a pressão."
	]
	p.defeat_lines = [
		"🏐 ... OUT! Que recepção espetacular. Ging... seu legado está em boas mãos.",
		"Uma vitória limpa e inquestionável. Greed Island reconhece sua força!"
	]
	return p


static func criar_meruem() -> Resource:
	var p = _criar_instancia()
	p.character_name = "Meruem (Rei Chimera)"
	p.archetype = "Calculista"
	p.balloon_color_bg = Color(0.04, 0.08, 0.06, 0.95)
	p.balloon_color_border = Color(0.3, 0.95, 0.45, 1.0) # Verde Real Imperial

	p.intro_lines = [
		"👑 Vocês, criaturas inferiores, nasceram para rastejar perante o ápice da evolução.",
		"👑 Mostre-me o que sua espécie chama de 'poder'. Para mim, cada movimento seu é um livro aberto."
	]
	p.taunt_lines = [
		"👑 Inútil. Eu li sua trajetória antes mesmo dos seus músculos se contraírem.",
		"👑 Essa velocidade... É o máximo que um humano consegue alcançar?",
		"👑 O tabuleiro já está decidido. Você está em xeque-mate há dez lances.",
		"👑 Sua técnica não possui ritmo. É desprovida de elegância."
	]
	p.generic_attack_lines = [
		"👑 Desapareça.",
		"👑 Golpe de cauda fulminante."
	]
	p.hatsu_lines = [
		"👑 SÍNTESE DE AURA! Toda a energia que você libera apenas me torna mais forte!",
		"👑 AVANÇO FOTÔNICO! Para onde você pensa que está olhando?"
	]
	p.damage_reactions = [
		"...! Um acerto direto? Como uma criatura inferior encontrou uma brecha?",
		"Interessante... Esse golpe teve o peso do sacrifício humano."
	]
	p.low_hp_reactions = [
		"Komugi... É este o sentimento de ser encurralado no tabuleiro de Gungi?",
		"Admirável. Pela primeira vez reconheço o valor de um adversário. Venha com tudo!"
	]
	p.player_hatsu_reactions = [
		"👑 Então essa é a síntese da sua alma? Uma técnica engenhosa... porém previsível.",
		"👑 Um Hatsu moldado pelo intelecto humano... Mas a biologia do Rei é inalcançável."
	]
	p.phase_transition_lines = [
		"👑 Chega de simulação. Eu vi através de cada um dos seus hábitos. Morra.",
		"👑 EN METAMÓRFICO! Cada molécula de luz neste espaço pertence a mim!"
	]
	p.victory_lines = [
		"👑 Xeque-mate. Você jogou uma boa partida, humano.",
		"👑 Como previsto. O destino da sua espécie sempre foi a submissão."
	]
	p.defeat_lines = [
		"👑 ... Komugi... Você está aí...? Eu... fui derrotado...",
		"👑 Incrível... A força da humanidade não reside na biologia... mas no coração..."
	]
	return p


static func criar_padrao(nome: String, tipo_arquetipo: String = "Orgulhoso") -> Resource:
	var p = _criar_instancia()
	p.character_name = nome
	p.archetype = tipo_arquetipo
	p.intro_lines = [
		"Você cometeu um erro ao cruzar meu caminho!",
		"Prepare-se! Não terei misericórdia!"
	]
	p.taunt_lines = [
		"Isso é tudo o que você tem?",
		"Patético! Nem precisei usar minha aura ao máximo!",
		"Você não vai passar daqui!"
	]
	p.generic_attack_lines = ["Tome isso!", "Ataque frontal!"]
	p.hatsu_lines = ["LIBERAÇÃO DE NEN! Sinta o impacto!"]
	p.damage_reactions = ["Guh! Maldito...", "Como você acertou isso?!"]
	p.low_hp_reactions = ["Ainda não acabou! Não serei derrotado tão fácil!"]
	p.player_hatsu_reactions = ["Que tipo de técnica é essa?!"]
	p.phase_transition_lines = ["Agora você vai ver meu verdadeiro poder!"]
	p.victory_lines = ["Como esperado... Fraco demais."]
	p.defeat_lines = ["Não pode ser... Fui superado..."]
	return p


static func criar_guardiao_ancestral() -> Resource:
	var p = _criar_instancia()
	p.character_name = "Guardião Ancestral de Zaban"
	p.archetype = "Honrado"
	p.balloon_color_bg = Color(0.08, 0.08, 0.12, 0.95)
	p.balloon_color_border = Color(0.95, 0.75, 0.20, 1.0) # Dourado Ancestral

	p.intro_lines = [
		"🏛️ Intruso... Nenhum mortal profanará o Santuário Ancestral de Zaban impunemente.",
		"⚡ Sinta a densidade da pedra esculpida há milênios pela aura pura!"
	]
	p.taunt_lines = [
		"🏛️ Sua força vacila diante da eternidade da rocha!",
		"⚡ Apenas mestres de Ren e Ko podem aspirar quebrar este elmo!",
		"🏛️ A terra treme ao comando dos antigos caçadores!"
	]
	p.generic_attack_lines = [
		"🏛️ GOLPE ESMAGADOR DA TERRA!",
		"⚡ FISSURA TELÚRICA!"
	]
	p.hatsu_lines = [
		"🏛️ IMPACTO TELÚRICO ANCESTRAL! Tremam sob meus punhos!",
		"⚡ ONDA DE CHOQUE DO SANTUÁRIO!"
	]
	p.damage_reactions = [
		"Mgh! Uma fissura na minha blindagem de pedra...!",
		"Um golpe concentrado formidável... mas insuficiente!"
	]
	p.low_hp_reactions = [
		"A chama antiga... não se apagará enquanto eu permanecer de pé!",
		"Pedra e aura são um só... Não cederei!"
	]
	p.player_hatsu_reactions = [
		"🏛️ Um Hatsu humano... mas quão refinado ele realmente é contra a rocha milenar?"
	]
	p.phase_transition_lines = [
		"🏛️ FRENESI ANCESTRAL! Despertem, Sentinelas da Terra!",
		"⚡ SOBRECARGA TELÚRICA! A rocha se parte para liberar todo o poder guardado!"
	]
	p.victory_lines = [
		"🏛️ Como os invasores de eras passadas... reduzido a pó perante o Santuário.",
		"O segredo dos ancestrais permanece inviolado."
	]
	p.defeat_lines = [
		"🏛️ Impressionante... Vossa aura é digna dos grandes Caçadores... O Santuário... agora vos pertence...",
		"A rocha se aquieta... Descanse em glória, novo guardião..."
	]
	return p


static func criar_lider_quimera() -> Resource:
	var p = _criar_instancia()
	p.character_name = "Líder da Matilha Quimera"
	p.archetype = "Bestial"
	p.balloon_color_bg = Color(0.12, 0.04, 0.04, 0.95)
	p.balloon_color_border = Color(0.9, 0.2, 0.2, 1.0) # Vermelho Bestial

	p.intro_lines = [
		"🐺 ROOOAAR! A presa finalmente adentrou o território da alcateia!",
		"🐺 *Olhos escarlates fixam em você enquanto a matilha rosna*"
	]
	p.taunt_lines = [
		"🐺 Grrrr... Meus dentes atravessarão qualquer barreira!",
		"🐺 Uivo que rasga o vento da floresta!",
		"🐺 *Circulando a presa em velocidade vertiginosa*"
	]
	p.generic_attack_lines = [
		"🐺 BOTE FULMINANTE!",
		"🐺 MORDIDA DILACERADORA!"
	]
	p.hatsu_lines = [
		"🐺 UIVO DA ALCATEIA! LACAIOS, ATAQUEM!",
		"🐺 EMBESTIDA SELVAGEM!"
	]
	p.damage_reactions = [
		"Grraaargh! Sangue quente... apenas atiça a caçada!",
		"Krrrgh!"
	]
	p.low_hp_reactions = [
		"🐺 *Fúria assassina consome a besta enquanto seus músculos inflam*",
		"ROOOAAAR! LUTA ATÉ O FIM!"
	]
	p.player_hatsu_reactions = [
		"🐺 *Rosnado desconfiado sentindo o cheiro da sua técnica de Nen*"
	]
	p.phase_transition_lines = [
		"🐺 *Uivo ensurdecedor conclama as bestas da floresta!*",
		"ROOOAR! FÚRIA TOTAL!"
	]
	p.victory_lines = [
		"🐺 *O líder festeja a caçada bem sucedida com um uivo triunfal*"
	]
	p.defeat_lines = [
		"🐺 Grrr... A presa... era um caçador...",
		"Whimper... *o monstro tomba na mata*"
	]
	return p

