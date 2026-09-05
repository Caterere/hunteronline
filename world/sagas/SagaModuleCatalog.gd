class_name SagaModuleCatalog
extends RefCounted

# ============================================================
# HUNTER ONLINE — MODULAR SAGA ARCHITECTURE (SAGAS 1 TO 9)
# ============================================================
#
# Desacopla o conteúdo narrativo, bosses, mapas, reputações e
# eventos dinâmicos do motor central do jogo.
# Permite carregamento dinâmico sob demanda (on-demand streaming)
# para expansões modulares sem inchar a memória.
# ============================================================

const SAGAS: Dictionary = {
	1: {
		"saga_id": 1,
		"titulo": "287º Exame Hunter",
		"subtitulo": "A Prova dos Prodígios",
		"capitulos_total": 35,
		"mapas": [
			"res://world/maps/exame_maratona.tscn",
			"res://world/maps/pantano_numere.tscn",
			"res://world/maps/torre_truques.tscn",
			"res://world/maps/ilha_zevil.tscn"
		],
		"bosses": [
			{"id": "hisoka_exame", "nome": "Hisoka Morow (Examinador Falso)", "resource": "res://resource/status/enemies/boss_hisoka.tres"},
			{"id": "sedokan", "nome": "Sedokan (Criminoso da Torre dos Truques)", "tier": 3},
			{"id": "majitani", "nome": "Majitani (Blefador da Trupe)", "tier": 2},
			{"id": "geretta", "nome": "Geretta (Mestre dos Dardos Envenenados)", "tier": 3}
		],
		"eventos_dinamicos": [
			{"id": "nevoeiro_pantano", "titulo": "Nevoeiro Ilusório de Numere", "tipo": "CLIMA_E_EMBOSCADA"},
			{"id": "cacada_plaquetas", "titulo": "Disputa de Alvos na Ilha Zevil", "tipo": "PVP_SIMULADO"}
		],
		"faccoes_reputacao": ["associacao_hunter", "candidatos_exame"],
		"segredos_e_reliquias": ["reliquia_cacador_antigo", "mapa_secreto_zevil"]
	},
	2: {
		"saga_id": 2,
		"titulo": "Montanha Kukuroo",
		"subtitulo": "O Domínio dos Zoldyck",
		"capitulos_total": 20,
		"mapas": [
			"res://world/maps/montanha_kukuroo.tscn",
			"res://world/maps/mansao_zoldyck.tscn"
		],
		"bosses": [
			{"id": "mike_beast", "nome": "Mike (Cão de Guarda Zoldyck)", "tier": 3},
			{"id": "canary", "nome": "Canário (Aprendiz de Mordomo)", "tier": 3},
			{"id": "gotoh", "nome": "Gotoh (Chefe dos Mordomos)", "tier": 4}
		],
		"eventos_dinamicos": [
			{"id": "teste_portao_teste", "titulo": "Desafio do Portão da Verificação (16 Toneladas)", "tipo": "DESAFIO_FISICO"}
		],
		"faccoes_reputacao": ["familia_zoldyck", "mordomos_zoldyck"],
		"segredos_e_reliquias": ["moeda_gotoh_rara", "registro_genealogico_zoldyck"]
	},
	3: {
		"saga_id": 3,
		"titulo": "Arena Celestial",
		"subtitulo": "O Batismo de Nen",
		"capitulos_total": 30,
		"mapas": [
			"res://world/maps/arena_celestial.tscn",
			"res://world/maps/dojo_wing.tscn"
		],
		"bosses": [
			{"id": "gido", "nome": "Gido (Tops Dançantes de Nen)", "tier": 3},
			{"id": "riehlvelt", "nome": "Riehlvelt (Cadeira de Rodas Propulsora)", "tier": 3},
			{"id": "kastro", "nome": "Kastro (O Mestre do Clone Tiger Bite)", "tier": 4},
			{"id": "hisoka_200", "nome": "Hisoka (Duelo do 200º Andar)", "resource": "res://resource/status/enemies/boss_hisoka.tres"}
		],
		"eventos_dinamicos": [
			{"id": "torneio_mestres_andar", "titulo": "Noite de Duelos dos Floor Masters", "tipo": "TORNEIO_ARENA"}
		],
		"faccoes_reputacao": ["comissao_arena_celestial", "escola_shingen_ryu"],
		"segredos_e_reliquias": ["fita_iniciacao_shingen_ryu", "bilhete_vip_200_andar"]
	},
	4: {
		"saga_id": 4,
		"titulo": "Yorknew City & Trupe Fantasma",
		"subtitulo": "A Sinfonia das Sombras",
		"capitulos_total": 45,
		"mapas": [
			"res://world/maps/yorknew_city.tscn",
			"res://world/maps/leilao_subterraneo.tscn",
			"res://world/maps/cemiterio_edificio.tscn"
		],
		"bosses": [
			{"id": "uvogin", "nome": "Uvogin (Grande Impacto Big Bang)", "tier": 4},
			{"id": "nobunaga", "nome": "Nobunaga Hazama (Espadachim de En)", "tier": 4},
			{"id": "chrollo_lucilfer", "nome": "Chrollo Lucilfer (Skill Hunter)", "tier": 4}
		],
		"eventos_dinamicos": [
			{"id": "ataque_leilao_mafia", "titulo": "Toque de Recolher da Máfia das Seis Famílias", "tipo": "INVASAO_URBANA"},
			{"id": "bounty_aranhas", "titulo": "Caçada aos Membros da Aranha", "tipo": "BOUNTY_MUNDIAL"}
		],
		"faccoes_reputacao": ["mafia_yorknew", "trupe_fantasma", "associacao_guarda_costas"],
		"segredos_e_reliquias": ["par_olhos_escarlates_replica", "cartaz_procurado_ryodan"]
	},
	5: {
		"saga_id": 5,
		"titulo": "Greed Island",
		"subtitulo": "O Jogo Forjado em Nen",
		"capitulos_total": 40,
		"mapas": [
			"res://world/maps/greed_island.tscn",
			"res://world/maps/cidade_antokiba.tscn",
			"res://world/maps/costa_soufrabi.tscn"
		],
		"bosses": [
			{"id": "razor_boss", "nome": "Razor (Os 14 Demônios)", "resource": "res://resource/status/enemies/boss_razor.tres"},
			{"id": "genthru_bomber", "nome": "Genthru (O Bombardeiro Countdown)", "tier": 4},
			{"id": "sub_bara", "nome": "Sub & Bara (Cumplices do Bombardeiro)", "tier": 3}
		],
		"eventos_dinamicos": [
			{"id": "disputa_carta_000", "titulo": "Desafio Coletivo pelo Convite do Governante", "tipo": "RAID_COLETIVA"},
			{"id": "partida_queimada_razor", "titulo": "Partida de Queimada Mortal de Soufrabi", "tipo": "DESAFIO_ESPECIAL"}
		],
		"faccoes_reputacao": ["jogadores_greed_island", "alianca_anti_bomber"],
		"segredos_e_reliquias": ["carta_017_sopro_de_arcangel", "carta_084_pedra_azul_da_sorte"]
	},
	6: {
		"saga_id": 6,
		"titulo": "Formigas Chimera",
		"subtitulo": "O Apocalipse da Seleção Natural",
		"capitulos_total": 55,
		"mapas": [
			"res://world/maps/floresta_ngl.tscn",
			"res://world/maps/palacio_leste_gorteau.tscn",
			"res://world/maps/ninho_rainha.tscn"
		],
		"bosses": [
			{"id": "neferpitou", "nome": "Neferpitou (Terpsichora)", "tier": 4},
			{"id": "shaiapouf", "nome": "Shaiapouf (Beelzebub / Mensagem Espiritual)", "tier": 4},
			{"id": "menthuthuyoupi", "nome": "Menthuthuyoupi (Fúria Metamórfica)", "tier": 4},
			{"id": "rei_meruem", "nome": "Rei Meruem (O Ápice da Existência)", "resource": "res://resource/status/enemies/boss_meruem.tres"}
		],
		"eventos_dinamicos": [
			{"id": "invasao_quimeras", "titulo": "Invasão de Batedores e Soldados Quimera", "tipo": "ALERTA_CONTINENTAL"},
			{"id": "selecao_nacional", "titulo": "Processo de Seleção no Palácio Real", "tipo": "TEMPORIZADO_CRITICO"}
		],
		"faccoes_reputacao": ["equipe_exterminio_hunter", "resistencia_gorteau"],
		"segredos_e_reliquias": ["peca_gungi_meruem", "amostra_biologica_quimera"]
	},
	7: {
		"saga_id": 7,
		"titulo": "Eleição Hunter & Alluka",
		"subtitulo": "A Vontade do Presidente",
		"capitulos_total": 20,
		"mapas": [
			"res://world/maps/sede_associacao_hunter.tscn",
			"res://world/maps/hospital_central.tscn"
		],
		"bosses": [
			{"id": "illumi_zoldyck", "nome": "Illumi Zoldyck (Agulhas de Manipulação)", "tier": 4},
			{"id": "hisoka_emboscada", "nome": "Hisoka (O Brinquedo Solto)", "resource": "res://resource/status/enemies/boss_hisoka.tres"}
		],
		"eventos_dinamicos": [
			{"id": "votacao_zodiacos", "titulo": "Votação em Plenário dos Zodíacos", "tipo": "EVENTO_POLITICO"}
		],
		"faccoes_reputacao": ["zodiacos_hunter", "faccao_pariston"],
		"segredos_e_reliquias": ["cedula_voto_netero", "regra_secreta_nanika"]
	},
	8: {
		"saga_id": 8,
		"titulo": "Continente Negro",
		"subtitulo": "Além das Fronteiras Conhecidas",
		"capitulos_total": 30,
		"mapas": [
			"res://world/maps/costa_novo_mundo.tscn",
			"res://world/maps/labirinto_brion.tscn"
		],
		"bosses": [
			{"id": "calamidade_brion", "nome": "Brion (A Arma Botânica)", "tier": 4},
			{"id": "calamidade_hellbell", "nome": "Hellbell (A Serpente Homicida)", "tier": 4}
		],
		"eventos_dinamicos": [
			{"id": "tempestade_primordial", "titulo": "Tempestade Biológica do Mar Exterior", "tipo": "SOBREVIVENCIA"}
		],
		"faccoes_reputacao": ["equipe_expedicao_beyond", "v5_governo_mundial"],
		"segredos_e_reliquias": ["erva_imortalidade_fragmento", "pedra_energia_infinita"]
	},
	9: {
		"saga_id": 9,
		"titulo": "Guerra de Sucessão Kakin",
		"subtitulo": "O Navio Baleia Negra",
		"capitulos_total": 45,
		"mapas": [
			"res://world/maps/baleia_negra_nivel_1.tscn",
			"res://world/maps/baleia_negra_nivel_3.tscn",
			"res://world/maps/baleia_negra_nivel_5.tscn"
		],
		"bosses": [
			{"id": "benjamin_guard", "nome": "Guarda Privada de Benjamin", "tier": 3},
			{"id": "tserr_nen_beast", "nome": "Besta Espiritual de Tserriednich", "tier": 4},
			{"id": "camilla_cat", "nome": "Gato do Milhão de Ressurreições", "tier": 4}
		],
		"eventos_dinamicos": [
			{"id": "guerra_mafias_baleia", "titulo": "Guerra de Território entre Shuu, Ei-i e Cha-R", "tipo": "DISPUTA_FACCOES"}
		],
		"faccoes_reputacao": ["familia_kakin", "mafia_shuu", "mafia_ei_i"],
		"segredos_e_reliquias": ["urna_espiritual_semente", "grimorio_kakin"]
	}
}

static var _loaded_modules: Dictionary = {}


static func obter_modulo(saga_id: int) -> Dictionary:
	return SAGAS.get(saga_id, {})


static func obter_todos_modulos() -> Dictionary:
	return SAGAS


static func carregar_conteudo_saga(saga_id: int) -> Dictionary:
	if not SAGAS.has(saga_id):
		push_warning("[SagaModuleCatalog] Saga %d não catalogada!" % saga_id)
		return {}

	if _loaded_modules.has(saga_id):
		return _loaded_modules[saga_id]

	var mod: Dictionary = SAGAS[saga_id].duplicate(true)
	_loaded_modules[saga_id] = mod
	print("[SagaModuleCatalog] 📦 Módulo da Saga %d ('%s') carregado na memória." % [saga_id, mod.get("titulo", "")])
	return mod


static func descarregar_conteudo_saga(saga_id: int) -> void:
	if _loaded_modules.has(saga_id):
		_loaded_modules.erase(saga_id)
		print("[SagaModuleCatalog] 🧹 Módulo da Saga %d descarregado." % saga_id)


static func obter_bosses_saga(saga_id: int) -> Array:
	var mod := obter_modulo(saga_id)
	return mod.get("bosses", [])


static func obter_eventos_saga(saga_id: int) -> Array:
	var mod := obter_modulo(saga_id)
	return mod.get("eventos_dinamicos", [])
