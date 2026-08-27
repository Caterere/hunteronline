extends Node

# ============================================================
# HUNTER ONLINE - FACTION & GUILD MANAGER (AUTOLOAD)
# ============================================================
#
# Gerencia a afiliação, ranks e recompensas exclusivas das 6 grandes
# organizações do universo de Hunter x Hunter:
# 1. 🕷️ Genei Ryodan (Trupe Fantasma)
# 2. ⚡ Clã Zoldyck (Família de Assassinos)
# 3. 🏛️ Associação Hunter & Zodíacos
# 4. 💼 Sindicato da Máfia das 10 Famílias (Yorknew)
# 5. 🍖 Guilda dos Hunters Gourmet
# 6. ⚖️ Caçadores da Lista Negra (Blacklist Hunters)
#
# ============================================================

signal faccao_ingressada(faccao_id: String, nome_faccao: String)
signal rank_promovido(novo_rank: int, titulo_rank: String)
signal recompensa_faccao_desbloqueada(nome_recompensa: String)

enum FaccaoID {
	NENHUMA,
	GENEI_RYODAN,
	CLAN_ZOLDYCK,
	ASSOCIACAO_HUNTER,
	MAFIA_YORKNEW,
	HUNTERS_GOURMET,
	BLACKLIST_HUNTERS
}

const DADOS_FACCOES: Dictionary = {
	"genei_ryodan": {
		"id": "genei_ryodan",
		"nome": "🕷️ Genei Ryodan (Trupe Fantasma)",
		"lider": "Chrollo Lucilfer",
		"descricao": "O infame bando de 13 ladrões de Meteor City. Não possuem regras exceto a lealdade absoluta à Aranha.",
		"requisito_nen": 10,
		"requisito_moral": "Sombra",
		"ranks": {
			1: {"nome": "Candidato da Aranha", "xp_req": 0, "titulo": "🕷️ Pata Recruta"},
			2: {"nome": "Pata Menor", "xp_req": 500, "titulo": "🕷️ Sombra de Meteor City"},
			3: {"nome": "Membro Titular (Nº 14)", "xp_req": 1500, "titulo": "🕷️ 14º Membro da Aranha"},
			4: {"nome": "Braço Direito de Chrollo", "xp_req": 3500, "titulo": "🕷️ Aranha Imperial"}
		},
		"perks": ["Acesso ao Mercado Clandestino", "Componente de Hatsu: Fios de Machi", "Hatsu Especial: Roubo de Habilidade"]
	},
	"zoldyck": {
		"id": "zoldyck",
		"nome": "⚡ Clã Zoldyck (Assassinos de Elite)",
		"lider": "Silva & Zeno Zoldyck",
		"descricao": "A lendária família de assassinos da Montanha Kukuroo. Mestres em tortura, assassinato silencioso e Nen elétrico.",
		"requisito_nen": 5,
		"requisito_moral": "Disciplina",
		"ranks": {
			1: {"nome": "Aprendiz do Portão", "xp_req": 0, "titulo": "⚡ Portão de 4 Toneladas"},
			2: {"nome": "Executor da Mansão", "xp_req": 500, "titulo": "⚡ Passo das Sombras (Rhythm Echo)"},
			3: {"nome": "Assassino da Família", "xp_req": 1500, "titulo": "⚡ Sombra de Kukuroo"},
			4: {"nome": "Herdeiro Zoldyck", "xp_req": 3500, "titulo": "⚡ Deus do Trovão (Narukami)"}
		},
		"perks": ["Resistência Máxima a Venenos", "Componente de Hatsu: Eletricidade Zoldyck", "Técnica: Garra Mortal"]
	},
	"associacao_hunter": {
		"id": "associacao_hunter",
		"nome": "🏛️ Associação Hunter Oficial",
		"lider": "Presidente Isaac Netero",
		"descricao": "A organização suprema de Caçadores licenciados, dedicada à exploração, proteção do mundo e preservação de espécies.",
		"requisito_nen": 1,
		"requisito_moral": "Honra",
		"ranks": {
			1: {"nome": "Hunter Licenciado", "xp_req": 0, "titulo": "🏹 Hunter Licenciado"},
			2: {"nome": "Hunter de 1 Estrela", "xp_req": 500, "titulo": "⭐ Hunter de 1 Estrela"},
			3: {"nome": "Hunter de 2 Estrelas", "xp_req": 1500, "titulo": "⭐⭐ Hunter de 2 Estrelas"},
			4: {"nome": "Candidato a Zodíaco", "xp_req": 3500, "titulo": "👑 Membro dos Zodíacos"}
		},
		"perks": ["Acesso a Todas as Zonas Proibidas", "Meditação do Bodhisattva (+20% Regen Aura)", "Contratos Governamentais"]
	},
	"mafia_yorknew": {
		"id": "mafia_yorknew",
		"nome": "💼 Sindicato da Máfia de Yorknew",
		"lider": "As 10 Famílias / Nostrade",
		"descricao": "A rede de controle financeiro e leilões clandestinos do submundo global.",
		"requisito_nen": 3,
		"requisito_moral": "Lucro",
		"ranks": {
			1: {"nome": "Segurança do Leilão", "xp_req": 0, "titulo": "💼 Guarda do Submundo"},
			2: {"nome": "Capo da Família", "xp_req": 500, "titulo": "💼 Cobrador Implacável"},
			3: {"nome": "Consigliere dos Chefões", "xp_req": 1500, "titulo": "💼 Mão Invisível de Yorknew"},
			4: {"nome": "Padrinho das 10 Famílias", "xp_req": 3500, "titulo": "💼 Rei do Submundo"}
		},
		"perks": ["+30% Desconto Geral em Lojas", "Recompensa de 500.000 Jenys", "Acesso aos Cofres do Leilão"]
	},
	"gourmet": {
		"id": "gourmet",
		"nome": "🍖 Guilda dos Hunters Gourmet",
		"lider": "Menchi & Buhara",
		"descricao": "Caçadores apaixonados que arriscam suas vidas nas regiões mais inóspitas para descobrir ingredientes mágicos lendários.",
		"requisito_nen": 2,
		"requisito_moral": "Culinária",
		"ranks": {
			1: {"nome": "Ajudante de Cozinha", "xp_req": 0, "titulo": "🍖 Cortador de Ingredientes"},
			2: {"nome": "Cozinheiro de Feras", "xp_req": 500, "titulo": "🍖 Caçador de Sabores"},
			3: {"nome": "Chef Lendário de Nen", "xp_req": 1500, "titulo": "🍖 Paladar Supremo"},
			4: {"nome": "Mestre Gourmet de 3 Estrelas", "xp_req": 3500, "titulo": "🍖 Banquete dos Deuses"}
		},
		"perks": ["Consumível: Banquete Mágico (+500 HP max / +200 Aura max)", "Receitas Secretas", "+15% Efeito de Poções"]
	},
	"blacklist": {
		"id": "blacklist",
		"nome": "⚖️ Caçadores da Lista Negra (Blacklist)",
		"lider": "Kurapika",
		"descricao": "Hunters implacáveis jurados a caçar os criminosos mais perigosos e restituir relíquias roubadas de povos extintos.",
		"requisito_nen": 8,
		"requisito_moral": "Justiça",
		"ranks": {
			1: {"nome": "Rastreador da Lei", "xp_req": 0, "titulo": "⚖️ Rastreador Implacável"},
			2: {"nome": "Investigador de Bounties", "xp_req": 500, "titulo": "⚖️ Olhos da Justiça"},
			3: {"nome": "Carrasco do Julgamento", "xp_req": 1500, "titulo": "⛓️ Juiz das Correntes"},
			4: {"nome": "Supremo Guardião Kurta", "xp_req": 3500, "titulo": "🩸 Olhos Escarlates"}
		},
		"perks": ["Componente de Hatsu: Correntes de Julgamento", "Juramento de Vow (+150% Dano contra Chefes)", "Rastreador GPS de Bounties"]
	}
}

# Dados salvos do jogador
var faccao_atual: String = ""
var faccao_xp: int = 0
var faccao_rank: int = 0
var missoes_faccao_concluidas: Array[String] = []


func _ready() -> void:
	add_to_group("faction_manager")
	print("=================================")
	print("[FactionManager] SISTEMA DE FACÇÕES E GUILDAS ATIVO")
	print("=================================")


func ingressar_faccao(id_faccao: String) -> bool:
	if not DADOS_FACCOES.has(id_faccao):
		push_error("[FactionManager] Facção não encontrada: " + id_faccao)
		return false
		
	var faccao_info = DADOS_FACCOES[id_faccao]
	var nivel_nen = PlayerData.attributes.get("nivel_nen", 0) if PlayerData else 0
	
	if nivel_nen < faccao_info["requisito_nen"]:
		print("[FactionManager] Nível de Nen insuficiente (%d < %d)" % [nivel_nen, faccao_info["requisito_nen"]])
		return false
		
	faccao_atual = id_faccao
	faccao_xp = 0
	faccao_rank = 1
	
	var rank_info = faccao_info["ranks"][1]
	var titulo = rank_info["titulo"]
	
	if PlayerData:
		PlayerData.faccao_atual = faccao_atual
		PlayerData.faccao_rank = faccao_rank
		PlayerData.desbloquear_titulo(titulo)
		PlayerData.equipar_titulo(titulo)
		
	faccao_ingressada.emit(id_faccao, faccao_info["nome"])
	rank_promovido.emit(1, rank_info["nome"])
	
	# Notificação no HUD
	var hud = get_tree().get_first_node_in_group("player_hud")
	if hud and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("⚜️ VOCÊ INGRESSOU NA FACÇÃO: %s!\nRank: %s" % [faccao_info["nome"], rank_info["nome"]])
		
	# Ajustar reputação
	_ajustar_reputacao_faccao(id_faccao)
	
	if GameState:
		GameState.salvar_jogo()
		
	return true


func adicionar_faccao_xp(qtd: int) -> void:
	if faccao_atual.is_empty() or not DADOS_FACCOES.has(faccao_atual):
		return
		
	faccao_xp += qtd
	var faccao_info = DADOS_FACCOES[faccao_atual]
	var proximo_rank = faccao_rank + 1
	
	if faccao_info["ranks"].has(proximo_rank):
		var req_xp = faccao_info["ranks"][proximo_rank]["xp_req"]
		if faccao_xp >= req_xp:
			faccao_rank = proximo_rank
			var novo_rank_info = faccao_info["ranks"][proximo_rank]
			var novo_titulo = novo_rank_info["titulo"]
			
			if PlayerData:
				PlayerData.faccao_rank = faccao_rank
				PlayerData.desbloquear_titulo(novo_titulo)
				PlayerData.equipar_titulo(novo_titulo)
				
			rank_promovido.emit(faccao_rank, novo_rank_info["nome"])
			
			var hud = get_tree().get_first_node_in_group("player_hud")
			if hud and hud.has_method("exibir_notificacao"):
				hud.exibir_notificacao("🎖️ PROMOÇÃO DE FACÇÃO!\nNovo Rank: %s\nTítulo Desbloqueado: %s" % [novo_rank_info["nome"], novo_titulo])
				
			if GameState:
				GameState.salvar_jogo()


func _ajustar_reputacao_faccao(id_faccao: String) -> void:
	if not ReputationSystem:
		return
		
	match id_faccao:
		"genei_ryodan":
			ReputationSystem.alterar_reputacao(ReputationSystem.Faccao.CRIMINOSOS, 400, "Ingresso na Aranha")
			ReputationSystem.alterar_reputacao(ReputationSystem.Faccao.MAFIA, -300, "Inimigo da Máfia")
			ReputationSystem.alterar_reputacao(ReputationSystem.Faccao.ASSOCIACAO_HUNTER, -150, "Membro da Trupe")
		"zoldyck":
			ReputationSystem.alterar_reputacao(ReputationSystem.Faccao.OUTROS_HUNTERS, 200, "Respeito Assassino")
			ReputationSystem.alterar_reputacao(ReputationSystem.Faccao.CIVIS, -100, "Temido pela População")
		"associacao_hunter":
			ReputationSystem.alterar_reputacao(ReputationSystem.Faccao.ASSOCIACAO_HUNTER, 350, "Lealdade à Associação")
			ReputationSystem.alterar_reputacao(ReputationSystem.Faccao.CIVIS, 200, "Herói dos Cidadãos")
		"mafia_yorknew":
			ReputationSystem.alterar_reputacao(ReputationSystem.Faccao.MAFIA, 450, "Contrato com as 10 Famílias")
			ReputationSystem.alterar_reputacao(ReputationSystem.Faccao.MERCADORES, 300, "Poder Comercial")
		"gourmet":
			ReputationSystem.alterar_reputacao(ReputationSystem.Faccao.CIVIS, 300, "Mestre da Gastronomia")
			ReputationSystem.alterar_reputacao(ReputationSystem.Faccao.MERCADORES, 250, "Comércio de Carnes Raras")
		"blacklist":
			ReputationSystem.alterar_reputacao(ReputationSystem.Faccao.ASSOCIACAO_HUNTER, 250, "Caçador de Criminosos")
			ReputationSystem.alterar_reputacao(ReputationSystem.Faccao.CRIMINOSOS, -500, "Terror dos Bandidos")


func obter_nome_faccao_atual() -> String:
	if faccao_atual.is_empty() or not DADOS_FACCOES.has(faccao_atual):
		return "Nenhuma (Caçador Independente)"
	return DADOS_FACCOES[faccao_atual]["nome"]


func obter_nome_rank_atual() -> String:
	if faccao_atual.is_empty() or not DADOS_FACCOES.has(faccao_atual):
		return "Sem Rank"
	var ranks = DADOS_FACCOES[faccao_atual]["ranks"]
	if ranks.has(faccao_rank):
		return ranks[faccao_rank]["nome"]
	return "Rank %d" % faccao_rank


func obter_perks_faccao_atual() -> Array:
	if faccao_atual.is_empty() or not DADOS_FACCOES.has(faccao_atual):
		return []
	return DADOS_FACCOES[faccao_atual]["perks"]
