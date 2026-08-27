class_name ParallelQuestCatalog
extends Resource

# ============================================================
# HUNTER ONLINE - PARALLEL QUEST CATALOG (50 MISSÕES WHAT-IF & BALANCEAMENTO FINAL)
# ============================================================
#
# Catálogo balanceado dos 50 Desafios Dimensionais:
# - Progressão suave de Tier 1 (Iniciante / 1k a 10k HP) até Tier 5 (End-Game / 100k a 400.000 HP).
# - O Boss Rush Supremo (PQ 50) e Chefes de Fim de Jogo possuem 400k HP para desafio lendário mesmo no Lv.100.
#
# ============================================================

static func obter_todas_missoes() -> Array[Dictionary]:
	var lista: Array[Dictionary] = []

	# =========================================================
	# TIER 1: EXAME HUNTER & MONTANHA KUKUROO (PQs 01 a 10)
	# =========================================================
	lista.append({
		"id": 1, "title": "PQ 01: O Duelo Real do Túnel", "saga_nome": "Exame Hunter", "arco_requerido": 1, "stars": 1,
		"subtitulo": "What-If: Exame Hunter",
		"what_if_lore": "E se Gon e Killua decidissem lutar com tudo no meio da maratona para testar quem é o novato mais forte do Exame?",
		"inimigos_descricao": "2x Ilusão de Gon, 2x Ilusão de Killua",
		"waves": [
			{"nome": "Ilusão de Gon", "hp": 450, "defesa": 10, "forca": 18, "xp": 400, "count": 2, "cor": Color(0.2, 0.9, 0.3)},
			{"nome": "Ilusão de Killua", "hp": 420, "defesa": 8, "forca": 22, "xp": 500, "count": 2, "cor": Color(0.3, 0.8, 1.0)}
		],
		"reward_xp": 2500, "reward_gold": 20000, "reward_items": [{"id": "pocao_hp", "qtd": 3}],
		"reward_materials": [{"id": "tecido_hunter", "nome": "Tecido do Exame Hunter", "qtd": 2}]
	})
	lista.append({
		"id": 2, "title": "PQ 02: O Banquete Sombrio de Hisoka", "saga_nome": "Exame Hunter", "arco_requerido": 1, "stars": 2,
		"subtitulo": "What-If: Pantanal Numere",
		"what_if_lore": "E se Hisoka perdesse o controle no meio do nevoeiro e decidisse caçar todos os candidatos restantes simultaneamente?",
		"inimigos_descricao": "4x Bestas Vorazes do Pantanal, 1x Hisoka Sombrio (Boss)",
		"waves": [
			{"nome": "Besta Voraz do Nevoeiro", "hp": 600, "defesa": 12, "forca": 22, "xp": 600, "count": 4, "cor": Color(0.6, 0.3, 0.8)},
			{"nome": "Hisoka Sombrio", "hp": 3500, "defesa": 22, "forca": 35, "xp": 1800, "count": 1, "is_boss": true, "cor": Color(1.0, 0.2, 0.6)}
		],
		"reward_xp": 4200, "reward_gold": 35000, "reward_items": [{"id": "fragmento_nen", "qtd": 2}],
		"reward_materials": [{"id": "goma_hisoka", "nome": "Fragmento de Goma Elástica", "qtd": 1}]
	})
	lista.append({
		"id": 3, "title": "PQ 03: A Fúria Gourmet de Menchi", "saga_nome": "Exame Hunter", "arco_requerido": 1, "stars": 2,
		"subtitulo": "What-If: Floresta Biska",
		"what_if_lore": "E se a Examinadora Gourmet Menchi reprovasse todos os candidatos e decidisse lutar com suas cutelos gigantes?",
		"inimigos_descricao": "6x Javalis Vorazes da Floresta, 1x Examinadora Menchi",
		"waves": [
			{"nome": "Javali Voraz com Presas", "hp": 750, "defesa": 14, "forca": 24, "xp": 700, "count": 6, "cor": Color(0.8, 0.4, 0.2)},
			{"nome": "Examinadora Menchi (Cutelos Gêmeos)", "hp": 4200, "defesa": 24, "forca": 38, "xp": 2200, "count": 1, "is_boss": true, "cor": Color(0.9, 0.3, 0.5)}
		],
		"reward_xp": 5000, "reward_gold": 45000, "reward_items": [{"id": "pocao_hp", "qtd": 4}],
		"reward_materials": [{"id": "cutelo_gourmet", "nome": "Aço de Cutelo Gourmet", "qtd": 2}]
	})
	lista.append({
		"id": 4, "title": "PQ 04: A Provação dos Prisioneiros de Trick Tower", "saga_nome": "Exame Hunter", "arco_requerido": 1, "stars": 2,
		"subtitulo": "What-If: Torre dos Truques",
		"what_if_lore": "E se Bendotto, Sedokan, Majtani e Johness o Estripador lutassem juntos no mesmo ringue de votação majoritária?",
		"inimigos_descricao": "1x Bendotto, 1x Sedokan, 1x Johness o Estripador (Boss)",
		"waves": [
			{"nome": "Bendotto o Especialista Militar", "hp": 900, "defesa": 18, "forca": 28, "xp": 900, "count": 1, "cor": Color(0.4, 0.5, 0.3)},
			{"nome": "Sedokan o Mestre das Chamas", "hp": 950, "defesa": 16, "forca": 30, "xp": 950, "count": 1, "cor": Color(0.9, 0.5, 0.1)},
			{"nome": "Johness o Estripador", "hp": 5500, "defesa": 28, "forca": 42, "xp": 2600, "count": 1, "is_boss": true, "cor": Color(0.7, 0.1, 0.1)}
		],
		"reward_xp": 6200, "reward_gold": 55000, "reward_items": [{"id": "pocao_hp_grande", "qtd": 2}],
		"reward_materials": [{"id": "garras_johness", "nome": "Garras Rasgadoras de Johness", "qtd": 1}]
	})
	lista.append({
		"id": 5, "title": "PQ 05: A Caçada de Placas na Ilha Zevil", "saga_nome": "Exame Hunter", "arco_requerido": 1, "stars": 3,
		"subtitulo": "What-If: Ilha Zevil",
		"what_if_lore": "E se Gittarackur (Illumi), Hisoka e Hanzo formassem um trio de caçadores no meio da densa floresta da Ilha Zevil?",
		"inimigos_descricao": "4x Competidores de Elite, 1x Gittarackur das Agulhas",
		"waves": [
			{"nome": "Competidor Veterano de Zevil", "hp": 1200, "defesa": 20, "forca": 32, "xp": 1000, "count": 4, "cor": Color(0.3, 0.6, 0.4)},
			{"nome": "Gittarackur (Disfarce de Illumi)", "hp": 7500, "defesa": 32, "forca": 48, "xp": 3500, "count": 1, "is_boss": true, "cor": Color(0.5, 0.2, 0.6)}
		],
		"reward_xp": 8500, "reward_gold": 75000, "reward_items": [{"id": "fragmento_nen", "qtd": 3}],
		"reward_materials": [{"id": "placa_hunter_zevil", "nome": "Placa de Caçador de Zevil", "qtd": 2}]
	})
	lista.append({
		"id": 6, "title": "PQ 06: Invasão dos Mordomos Zoldyck", "saga_nome": "Montanha Kukuroo", "arco_requerido": 2, "stars": 3,
		"subtitulo": "What-If: Família Zoldyck",
		"what_if_lore": "E se Gotoh, Canary e toda a guarda da mansão Zoldyck recebessem ordens de impedir a saída de Killua a todo custo?",
		"inimigos_descricao": "6x Mordomos de Combate, 2x Cães de Guarda Mike",
		"waves": [
			{"nome": "Mordomo de Combate", "hp": 1500, "defesa": 24, "forca": 36, "xp": 1100, "count": 6, "cor": Color(0.2, 0.2, 0.2)},
			{"nome": "Fera de Guarda Mike", "hp": 8500, "defesa": 35, "forca": 52, "xp": 3800, "count": 2, "is_boss": true, "cor": Color(0.7, 0.1, 0.1)}
		],
		"reward_xp": 10500, "reward_gold": 95000, "reward_items": [{"id": "pocao_hp_grande", "qtd": 2}],
		"reward_materials": [{"id": "aco_zoldyck", "nome": "Liga de Aço Zoldyck", "qtd": 2}]
	})
	lista.append({
		"id": 7, "title": "PQ 07: O Desafio de Moedas de Alta Tensão", "saga_nome": "Montanha Kukuroo", "arco_requerido": 2, "stars": 3,
		"subtitulo": "What-If: Mordomos Zoldyck",
		"what_if_lore": "E se as moedas de Gotoh fossem carregadas com Nen destrutivo com disparos em metralhadora contínua?",
		"inimigos_descricao": "4x Mordomos Aprendizes, 1x Mordomo Gotoh Furioso",
		"waves": [
			{"nome": "Mordomo Aprendiz", "hp": 1800, "defesa": 26, "forca": 38, "xp": 1200, "count": 4, "cor": Color(0.3, 0.3, 0.3)},
			{"nome": "Gotoh (Disparador de Moedas Metralhadora)", "hp": 10000, "defesa": 38, "forca": 55, "xp": 4500, "count": 1, "is_boss": true, "cor": Color(0.6, 0.6, 0.2)}
		],
		"reward_xp": 13000, "reward_gold": 120000, "reward_items": [{"id": "fragmento_nen", "qtd": 3}],
		"reward_materials": [{"id": "moeda_pesada_gotoh", "nome": "Moeda de Chumbo de Gotoh", "qtd": 2}]
	})
	lista.append({
		"id": 8, "title": "PQ 08: A Fúria Materna de Kikyo Zoldyck", "saga_nome": "Montanha Kukuroo", "arco_requerido": 2, "stars": 3,
		"subtitulo": "What-If: Mansão Zoldyck",
		"what_if_lore": "E se Kikyo e Milluki Zoldyck soltassem seu esquadrão de drones assassinos e sentinelas automáticas nos jardins?",
		"inimigos_descricao": "8x Drones Explosivos de Milluki, 1x Kikyo com Visor de Laser",
		"waves": [
			{"nome": "Drone Explosivo de Milluki", "hp": 1600, "defesa": 25, "forca": 40, "xp": 1150, "count": 8, "cor": Color(0.8, 0.2, 0.5)},
			{"nome": "Kikyo Zoldyck (Laser Eletrônico)", "hp": 12000, "defesa": 40, "forca": 58, "xp": 5000, "count": 1, "is_boss": true, "cor": Color(0.9, 0.1, 0.7)}
		],
		"reward_xp": 15000, "reward_gold": 140000, "reward_items": [{"id": "elixir_aura", "qtd": 2}],
		"reward_materials": [{"id": "circuito_kikyo", "nome": "Microchip do Visor de Kikyo", "qtd": 2}]
	})
	lista.append({
		"id": 9, "title": "PQ 09: O Treino Pesado de Zebro e Seaquant", "saga_nome": "Montanha Kukuroo", "arco_requerido": 2, "stars": 3,
		"subtitulo": "What-If: Casa de Guarda",
		"what_if_lore": "E se as vassouras e xícaras de 20kg fossem transformadas em armas de impacto em um teste de resistência muscular extrema?",
		"inimigos_descricao": "6x Homens de Guarda de Padokia, 1x Guarda Zebro (Modo Titan)",
		"waves": [
			{"nome": "Guarda de Padokia", "hp": 2200, "defesa": 30, "forca": 42, "xp": 1300, "count": 6, "cor": Color(0.5, 0.4, 0.3)},
			{"nome": "Zebro (Força Muscular Desperta)", "hp": 14000, "defesa": 45, "forca": 62, "xp": 5500, "count": 1, "is_boss": true, "cor": Color(0.6, 0.5, 0.2)}
		],
		"reward_xp": 17000, "reward_gold": 160000, "reward_items": [{"id": "pocao_hp_grande", "qtd": 3}],
		"reward_materials": [{"id": "ferro_pesado_portao", "nome": "Fragmento do Portão de 4 Toneladas", "qtd": 2}]
	})
	lista.append({
		"id": 10, "title": "PQ 10: O Retorno de Canary e o Clã Meteor", "saga_nome": "Montanha Kukuroo", "arco_requerido": 2, "stars": 3,
		"subtitulo": "What-If: Cidade Meteoro",
		"what_if_lore": "E se lutadores nativos da Cidade Meteoro viessem resgatar Canary no portão da montanha?",
		"inimigos_descricao": "6x Combatentes da Cidade Meteoro, 1x Canary com Bastão de Fúria",
		"waves": [
			{"nome": "Combatente de Meteoro", "hp": 2500, "defesa": 32, "forca": 44, "xp": 1400, "count": 6, "cor": Color(0.4, 0.4, 0.5)},
			{"nome": "Canary (Bastão de Combate Mortal)", "hp": 16000, "defesa": 48, "forca": 65, "xp": 6000, "count": 1, "is_boss": true, "cor": Color(0.8, 0.5, 0.3)}
		],
		"reward_xp": 19000, "reward_gold": 180000, "reward_items": [{"id": "fragmento_nen", "qtd": 3}],
		"reward_materials": [{"id": "madeira_bastao_canary", "nome": "Madeira do Bastão de Canary", "qtd": 2}]
	})

	# =========================================================
	# TIER 2: ARENA CELESTIAL & YORKNEW CITY (PQs 11 a 20)
	# =========================================================
	lista.append({
		"id": 11, "title": "PQ 11: O Teste dos 200 Andares", "saga_nome": "Arena Celestial", "arco_requerido": 3, "stars": 4,
		"subtitulo": "What-If: Arena Celestial",
		"what_if_lore": "E se os lutadores trapaceiros Kastro, Gido e Riehlvelt formassem uma aliança nos corredores do 200º andar?",
		"inimigos_descricao": "4x Piões Vivos de Gido, 1x Kastro Ilusório, 1x Riehlvelt Cadeira Elétrica",
		"waves": [
			{"nome": "Pião Voador de Gido", "hp": 2800, "defesa": 30, "forca": 45, "xp": 1500, "count": 4, "cor": Color(0.9, 0.6, 0.2)},
			{"nome": "Kastro Ilusório", "hp": 18000, "defesa": 52, "forca": 68, "xp": 6500, "count": 1, "is_boss": true, "cor": Color(0.4, 0.7, 1.0)},
			{"nome": "Riehlvelt Elétrico", "hp": 15000, "defesa": 48, "forca": 64, "xp": 6000, "count": 1, "is_boss": true, "cor": Color(1.0, 0.9, 0.1)}
		],
		"reward_xp": 23000, "reward_gold": 220000, "reward_items": [{"id": "fragmento_nen", "qtd": 4}],
		"reward_materials": [{"id": "trofeu_arena", "nome": "Emblema dos 200 Andares", "qtd": 2}]
	})
	lista.append({
		"id": 12, "title": "PQ 12: A Tempestade de Piões Furiosos de Gido", "saga_nome": "Arena Celestial", "arco_requerido": 3, "stars": 4,
		"subtitulo": "What-If: 200º Andar",
		"what_if_lore": "E se Gido multiplicasse seus piões em 20 unidades simultâneas cobrindo todo o ringue da Arena Celestial?",
		"inimigos_descricao": "12x Piões Giratórios com Shu, 1x Mestre Gido com Tornado de Nen",
		"waves": [
			{"nome": "Pião Blindado com Shu", "hp": 3000, "defesa": 34, "forca": 48, "xp": 1400, "count": 12, "cor": Color(0.8, 0.6, 0.1)},
			{"nome": "Gido (Tornado de Piões)", "hp": 22000, "defesa": 55, "forca": 72, "xp": 7000, "count": 1, "is_boss": true, "cor": Color(0.9, 0.7, 0.2)}
		],
		"reward_xp": 25000, "reward_gold": 240000, "reward_items": [{"id": "elixir_aura", "qtd": 3}],
		"reward_materials": [{"id": "madeira_piao_shu", "nome": "Aço de Pião Encantado", "qtd": 2}]
	})
	lista.append({
		"id": 13, "title": "PQ 13: O Duplo Perfeito de Kastro: Garra do Tigre", "saga_nome": "Arena Celestial", "arco_requerido": 3, "stars": 4,
		"subtitulo": "What-If: Duelo dos Mestres",
		"what_if_lore": "E se Kastro não sofresse desgaste mental de conjuração e invocasse três clones perfeitos no ringue?",
		"inimigos_descricao": "3x Clones Duplos de Kastro, 1x Kastro Original (Mordida do Tigre)",
		"waves": [
			{"nome": "Clone Ilusório de Kastro", "hp": 8000, "defesa": 42, "forca": 58, "xp": 2800, "count": 3, "cor": Color(0.3, 0.6, 0.9)},
			{"nome": "Kastro (Garra do Tigre Devastadora)", "hp": 26000, "defesa": 60, "forca": 78, "xp": 8000, "count": 1, "is_boss": true, "cor": Color(0.2, 0.5, 1.0)}
		],
		"reward_xp": 28000, "reward_gold": 280000, "reward_items": [{"id": "fragmento_nen", "qtd": 4}],
		"reward_materials": [{"id": "garra_tigre_kastro", "nome": "Emblema da Garra do Tigre", "qtd": 2}]
	})
	lista.append({
		"id": 14, "title": "PQ 14: A Provação dos Mestres de Andar (Floor Masters)", "saga_nome": "Arena Celestial", "arco_requerido": 3, "stars": 4,
		"subtitulo": "What-If: Batalha pelo Trono",
		"what_if_lore": "E se os 5 maiores Mestres de Andar da Arena Celestial decidissem testar o novo postulante em sequência?",
		"inimigos_descricao": "4x Campeões Veteranos, 1x Mestre Supremo da Torre",
		"waves": [
			{"nome": "Campeão dos 210 Andares", "hp": 4500, "defesa": 40, "forca": 56, "xp": 2000, "count": 4, "cor": Color(0.7, 0.3, 0.6)},
			{"nome": "Floor Master Supremo", "hp": 32000, "defesa": 65, "forca": 84, "xp": 9500, "count": 1, "is_boss": true, "cor": Color(0.9, 0.8, 0.2)}
		],
		"reward_xp": 32000, "reward_gold": 330000, "reward_items": [{"id": "pocao_hp_grande", "qtd": 4}],
		"reward_materials": [{"id": "cinturao_floor_master", "nome": "Fivela Dourada de Mestre de Andar", "qtd": 2}]
	})
	lista.append({
		"id": 15, "title": "PQ 15: A Noite Carmesim da Trupe Fantasma", "saga_nome": "Yorknew City", "arco_requerido": 4, "stars": 4,
		"subtitulo": "What-If: Yorknew City",
		"what_if_lore": "E se Uvogin, Machi, Nobunaga e Feitan atacassem o leilão subterrâneo juntos sem esperar pelo resto da Aranha?",
		"inimigos_descricao": "6x Mafiosos das 10 Famílias, 1x Uvogin Furioso (Boss)",
		"waves": [
			{"nome": "Mafioso Guarda-Costas", "hp": 4000, "defesa": 35, "forca": 50, "xp": 1800, "count": 6, "cor": Color(0.3, 0.3, 0.4)},
			{"nome": "Uvogin Furioso", "hp": 40000, "defesa": 75, "forca": 92, "xp": 11000, "count": 1, "is_boss": true, "cor": Color(0.8, 0.2, 0.1)}
		],
		"reward_xp": 36000, "reward_gold": 380000, "reward_items": [{"id": "elixir_aura", "qtd": 3}],
		"reward_materials": [{"id": "aco_negro_uvogin", "nome": "Fragmento de Impacto de Uvogin", "qtd": 2}]
	})
	lista.append({
		"id": 16, "title": "PQ 16: O Duelo dos Mestres Assassinos: Zoldyck vs Chrollo", "saga_nome": "Yorknew City", "arco_requerido": 4, "stars": 5,
		"subtitulo": "What-If: Zoldyck vs Genei Ryodan",
		"what_if_lore": "E se Silva e Zeno Zoldyck decidissem levar a luta contra Chrollo Lucifer até as últimas consequências?",
		"inimigos_descricao": "2x Clones de Nen da Trupe, 1x Chrollo Lucifer (Boss)",
		"waves": [
			{"nome": "Clone de Nen de Feitan", "hp": 6500, "defesa": 44, "forca": 62, "xp": 2800, "count": 2, "cor": Color(0.5, 0.1, 0.4)},
			{"nome": "Chrollo Lucifer (Boss)", "hp": 48000, "defesa": 80, "forca": 98, "xp": 13000, "count": 1, "is_boss": true, "cor": Color(0.4, 0.1, 0.7)}
		],
		"reward_xp": 42000, "reward_gold": 460000, "reward_items": [{"id": "fragmento_nen", "qtd": 5}],
		"reward_materials": [{"id": "pagina_skill_hunter", "nome": "Página do Segredo do Roubo", "qtd": 2}]
	})
	lista.append({
		"id": 17, "title": "PQ 17: As Bestas Sombrias (Shadow Beasts) da Máfia", "saga_nome": "Yorknew City", "arco_requerido": 4, "stars": 5,
		"subtitulo": "What-If: Shadow Beasts",
		"what_if_lore": "E se todas as 10 Bestas Sombrias da Máfia emboscassem a Trupe Fantasma em formação perfeita?",
		"inimigos_descricao": "1x Rabid Dog, 1x Worm, 1x Porcupine, 1x Leech (Bosses)",
		"waves": [
			{"nome": "Worm (Verme Subterrâneo)", "hp": 8500, "defesa": 46, "forca": 65, "xp": 3200, "count": 1, "cor": Color(0.6, 0.5, 0.2)},
			{"nome": "Rabid Dog (Dentes Venenosos)", "hp": 9000, "defesa": 44, "forca": 70, "xp": 3500, "count": 1, "cor": Color(0.7, 0.2, 0.2)},
			{"nome": "Porcupine & Leech (Líderes das Bestas Sombrias)", "hp": 42000, "defesa": 75, "forca": 90, "xp": 11500, "count": 1, "is_boss": true, "cor": Color(0.3, 0.6, 0.3)}
		],
		"reward_xp": 46000, "reward_gold": 520000, "reward_items": [{"id": "pocao_hp_grande", "qtd": 3}],
		"reward_materials": [{"id": "espinhos_porcupine", "nome": "Espinhos Blindados de Porcupine", "qtd": 2}]
	})
	lista.append({
		"id": 18, "title": "PQ 18: A Vingança das Lâminas de Nobunaga & Machi", "saga_nome": "Yorknew City", "arco_requerido": 4, "stars": 5,
		"subtitulo": "What-If: Genei Ryodan",
		"what_if_lore": "E se Nobunaga usasse seu En de 4 metros e Machi seus fios invisíveis para proteger o leilão com 100% de precisão?",
		"inimigos_descricao": "6x Fios de Nen Armadilha, 1x Nobunaga da Katana, 1x Machi dos Fios",
		"waves": [
			{"nome": "Boneco de Fio de Machi", "hp": 5500, "defesa": 38, "forca": 58, "xp": 2200, "count": 6, "cor": Color(0.9, 0.3, 0.7)},
			{"nome": "Nobunaga Hazama (Espadachim do En)", "hp": 38000, "defesa": 72, "forca": 94, "xp": 9500, "count": 1, "is_boss": true, "cor": Color(0.8, 0.5, 0.2)},
			{"nome": "Machi (Mestra dos Fios de Nen)", "hp": 35000, "defesa": 70, "forca": 88, "xp": 9000, "count": 1, "is_boss": true, "cor": Color(1.0, 0.4, 0.8)}
		],
		"reward_xp": 50000, "reward_gold": 580000, "reward_items": [{"id": "elixir_aura", "qtd": 4}],
		"reward_materials": [{"id": "fio_costura_machi", "nome": "Carretel de Fios de Nen de Machi", "qtd": 2}]
	})
	lista.append({
		"id": 19, "title": "PQ 19: O Sol Incandescente de Feitan", "saga_nome": "Yorknew City", "arco_requerido": 4, "stars": 5,
		"subtitulo": "What-If: Pain Packer Extremo",
		"what_if_lore": "E se Feitan fosse levado ao limite por invasores e conjurasse múltiplos mini-sóis na câmara blindada?",
		"inimigos_descricao": "4x Chamas Vivas de Transmutação, 1x Feitan com Traje Pain Packer",
		"waves": [
			{"nome": "Chama Viva de Transmutação", "hp": 7000, "defesa": 42, "forca": 66, "xp": 2600, "count": 4, "cor": Color(1.0, 0.5, 0.1)},
			{"nome": "Feitan (Armadura Pain Packer Sol Nascente)", "hp": 55000, "defesa": 85, "forca": 105, "xp": 14000, "count": 1, "is_boss": true, "cor": Color(0.9, 0.1, 0.1)}
		],
		"reward_xp": 55000, "reward_gold": 650000, "reward_items": [{"id": "fragmento_nen", "qtd": 5}],
		"reward_materials": [{"id": "tecido_ignifugo_feitan", "nome": "Tecido Resistente a Fogo de Feitan", "qtd": 2}]
	})
	lista.append({
		"id": 20, "title": "PQ 20: A Batalha na Chuva: Kurapika vs Genei Ryodan", "saga_nome": "Yorknew City", "arco_requerido": 4, "stars": 5,
		"subtitulo": "What-If: Olhos Escarlates",
		"what_if_lore": "E se Kurapika ativasse o Emperor Time definitivo e desafiasse 4 membros da Trupe Fantasma sob a chuva torrencial?",
		"inimigos_descricao": "1x Phinks dos Giros, 1x Franklin das Balas de Dedo, 1x Bonolenov da Dança",
		"waves": [
			{"nome": "Franklin (Canhões de Dedo)", "hp": 30000, "defesa": 68, "forca": 85, "xp": 6000, "count": 1, "cor": Color(0.4, 0.4, 0.6)},
			{"nome": "Phinks (Soco Ripper Cyclotron)", "hp": 32000, "defesa": 74, "forca": 92, "xp": 6500, "count": 1, "cor": Color(0.7, 0.6, 0.2)},
			{"nome": "Bonolenov (Dançarino de Batalha)", "hp": 60000, "defesa": 90, "forca": 108, "xp": 15000, "count": 1, "is_boss": true, "cor": Color(0.6, 0.3, 0.7)}
		],
		"reward_xp": 62000, "reward_gold": 750000, "reward_items": [{"id": "elixir_aura", "qtd": 4}],
		"reward_materials": [{"id": "anel_kurapika_corrente", "nome": "Elo da Corrente da Vingança", "qtd": 2}]
	})

	# =========================================================
	# TIER 3: GREED ISLAND & FORMIGAS CHIMERA (PQs 21 a 35)
	# =========================================================
	lista.append({
		"id": 21, "title": "PQ 21: O Jogo Mortal de Queimada de Razor", "saga_nome": "Greed Island", "arco_requerido": 5, "stars": 5,
		"subtitulo": "What-If: Greed Island",
		"what_if_lore": "E se Razor decidisse usar 100% de sua aura na partida de queimada sem nenhuma restrição de regras?",
		"inimigos_descricao": "6x Demônios de Emissão de Razor, 1x Mestre Razor",
		"waves": [
			{"nome": "Demônio de Emissão #1 a #6", "hp": 8500, "defesa": 45, "forca": 65, "xp": 2500, "count": 6, "cor": Color(0.9, 0.4, 0.1)},
			{"nome": "Mestre Razor (Emissor Supremo)", "hp": 75000, "defesa": 95, "forca": 115, "xp": 18000, "count": 1, "is_boss": true, "cor": Color(0.9, 0.2, 0.2)}
		],
		"reward_xp": 68000, "reward_gold": 850000, "reward_items": [{"id": "carta_greed_island_001", "qtd": 1}],
		"reward_materials": [{"id": "esfera_nen_razor", "nome": "Esfera de Emissão de Razor", "qtd": 2}]
	})
	lista.append({
		"id": 22, "title": "PQ 22: O Terror dos Bombardeiros de Genthru", "saga_nome": "Greed Island", "arco_requerido": 5, "stars": 5,
		"subtitulo": "What-If: Greed Island",
		"what_if_lore": "E se Genthru, Sub e Bara atacassem a base de Gon antes que a armadilha de pedras estivesse pronta?",
		"inimigos_descricao": "1x Sub, 1x Bara, 1x Genthru o Bombardeiro (Boss)",
		"waves": [
			{"nome": "Sub (Transmutador)", "hp": 25000, "defesa": 65, "forca": 80, "xp": 5000, "count": 1, "cor": Color(0.8, 0.6, 0.1)},
			{"nome": "Bara (Intensificador)", "hp": 28000, "defesa": 72, "forca": 86, "xp": 5500, "count": 1, "cor": Color(0.7, 0.3, 0.1)},
			{"nome": "Genthru o Bombardeiro", "hp": 82000, "defesa": 98, "forca": 120, "xp": 20000, "count": 1, "is_boss": true, "cor": Color(1.0, 0.3, 0.0)}
		],
		"reward_xp": 75000, "reward_gold": 920000, "reward_items": [{"id": "carta_greed_island_002", "qtd": 1}],
		"reward_materials": [{"id": "polvora_nen_genthru", "nome": "Pólvora de Transmutação", "qtd": 2}]
	})
	lista.append({
		"id": 23, "title": "PQ 23: A Provação da Mestra Biscuit Krueger", "saga_nome": "Greed Island", "arco_requerido": 5, "stars": 6,
		"subtitulo": "What-If: Treinamento Extremo",
		"what_if_lore": "E se Biscuit decidisse lutar em sua Forma Real de 57 anos para testar se você realmente domina o Hatsu?",
		"inimigos_descricao": "4x Estátuas de Rocha Shingen-ryu, 1x Biscuit Forma Real",
		"waves": [
			{"nome": "Golem de Treino de Shingen-ryu", "hp": 12000, "defesa": 58, "forca": 74, "xp": 3200, "count": 4, "cor": Color(0.6, 0.6, 0.7)},
			{"nome": "Biscuit Krueger (Forma Real de Batalha)", "hp": 95000, "defesa": 110, "forca": 130, "xp": 22000, "count": 1, "is_boss": true, "cor": Color(1.0, 0.6, 0.8)}
		],
		"reward_xp": 82000, "reward_gold": 1050000, "reward_items": [{"id": "carta_greed_island_003", "qtd": 1}],
		"reward_materials": [{"id": "diamante_shingen", "nome": "Diamante de Shingen-ryu", "qtd": 2}]
	})
	lista.append({
		"id": 24, "title": "PQ 24: O Torneio da Cidade do Amor: Aishy", "saga_nome": "Greed Island", "arco_requerido": 5, "stars": 6,
		"subtitulo": "What-If: Feitiços de Greed",
		"what_if_lore": "E se gangues de jogadores utilizassem cartas de ataque simultâneas para roubar o Binder dos novatos?",
		"inimigos_descricao": "8x Ladrões de Cartas de Greed Island, 2x Campeões de Feitiço",
		"waves": [
			{"nome": "Ladrão de Cartas com Feitiço", "hp": 10000, "defesa": 52, "forca": 70, "xp": 2800, "count": 8, "cor": Color(0.5, 0.2, 0.8)},
			{"nome": "Campeão das 99 Cartas", "hp": 55000, "defesa": 90, "forca": 110, "xp": 14000, "count": 2, "is_boss": true, "cor": Color(0.3, 0.8, 0.6)}
		],
		"reward_xp": 90000, "reward_gold": 1150000, "reward_items": [{"id": "carta_greed_island_017", "qtd": 1}],
		"reward_materials": [{"id": "pergaminho_magico_greed", "nome": "Pergaminho de Feitiço de Greed", "qtd": 2}]
	})
	lista.append({
		"id": 25, "title": "PQ 25: O Desafio dos 11 Criadores (G.R.E.E.D. I.S.L.A.N.D.)", "saga_nome": "Greed Island", "arco_requerido": 5, "stars": 6,
		"subtitulo": "What-If: Criadores do Jogo",
		"what_if_lore": "E se Elena, Eta, Dwun e List convocassem os guardiões lendários para proteger a Carta Secreta nº 000?",
		"inimigos_descricao": "6x Guardiões Mágicos de Ging, 1x Guardião do Trono de Greed",
		"waves": [
			{"nome": "Guardião Mágico de Ging", "hp": 15000, "defesa": 65, "forca": 82, "xp": 3800, "count": 6, "cor": Color(0.2, 0.7, 0.9)},
			{"nome": "Avatar Guardião da Carta 000", "hp": 115000, "defesa": 115, "forca": 140, "xp": 26000, "count": 1, "is_boss": true, "cor": Color(0.9, 0.9, 0.2)}
		],
		"reward_xp": 100000, "reward_gold": 1300000, "reward_items": [{"id": "carta_greed_island_000", "qtd": 1}],
		"reward_materials": [{"id": "nucleo_magico_ging", "nome": "Núcleo de Criação de Ging", "qtd": 2}]
	})
	lista.append({
		"id": 26, "title": "PQ 26: O Retorno dos Exterminadores de Chimera", "saga_nome": "Formigas Chimera", "arco_requerido": 6, "stars": 6,
		"subtitulo": "What-If: NGL & Chimera",
		"what_if_lore": "E se Morel, Knov, Knuckle e Shoot tivessem que invadir a fortaleza de Peijin sozinhos?",
		"inimigos_descricao": "8x Soldados Formiga de Elite, 2x Oficiais Líderes de Esquadrão",
		"waves": [
			{"nome": "Formiga Soldado Mutante", "hp": 14000, "defesa": 58, "forca": 78, "xp": 3400, "count": 8, "cor": Color(0.3, 0.7, 0.3)},
			{"nome": "Oficial Leol (Líder de Esquadrão)", "hp": 65000, "defesa": 88, "forca": 112, "xp": 13500, "count": 1, "is_boss": true, "cor": Color(0.2, 0.5, 0.8)},
			{"nome": "Oficial Cheetu (Velocidade Relâmpago)", "hp": 60000, "defesa": 82, "forca": 118, "xp": 13000, "count": 1, "is_boss": true, "cor": Color(0.9, 0.8, 0.1)}
		],
		"reward_xp": 110000, "reward_gold": 1450000, "reward_items": [{"id": "pocao_hp_grande", "qtd": 4}],
		"reward_materials": [{"id": "tecido_fumaca_morel", "nome": "Tecido de Fumaça de Morel", "qtd": 2}]
	})
	lista.append({
		"id": 27, "title": "PQ 27: A Fúria Devastadora de Menthuthuyoupi", "saga_nome": "Formigas Chimera", "arco_requerido": 6, "stars": 7,
		"subtitulo": "What-If: Palácio Real",
		"what_if_lore": "E se Youpi atingisse sua forma definitiva de Centauro de Fogo antes que Knuckle e Morel pudessem escapar?",
		"inimigos_descricao": "4x Tentáculos Titânicos de Youpi, 1x Youpi Centauro Furioso",
		"waves": [
			{"nome": "Tentáculo Titânico de Youpi", "hp": 20000, "defesa": 72, "forca": 95, "xp": 4500, "count": 4, "cor": Color(0.8, 0.2, 0.2)},
			{"nome": "Menthuthuyoupi (Centauro Supremo)", "hp": 145000, "defesa": 125, "forca": 155, "xp": 30000, "count": 1, "is_boss": true, "cor": Color(0.9, 0.1, 0.1)}
		],
		"reward_xp": 125000, "reward_gold": 1650000, "reward_items": [{"id": "elixir_aura", "qtd": 5}],
		"reward_materials": [{"id": "quitina_youpi", "nome": "Quitina Titânica de Youpi", "qtd": 2}]
	})
	lista.append({
		"id": 28, "title": "PQ 28: As Escamas Espirituais de Shaiapouf", "saga_nome": "Formigas Chimera", "arco_requerido": 6, "stars": 7,
		"subtitulo": "What-If: Hipnose em Massa",
		"what_if_lore": "E se as escamas hipnóticas de Shaiapouf cobrissem toda a capital, transformando todos os cidadãos em marionetes?",
		"inimigos_descricao": "10x Marionetes de Nen de Pouf, 1x Shaiapouf Alado",
		"waves": [
			{"nome": "Marionete de Nen de Pouf", "hp": 16000, "defesa": 60, "forca": 82, "xp": 3600, "count": 10, "cor": Color(0.6, 0.2, 0.7)},
			{"nome": "Shaiapouf (Escamas Espirituais)", "hp": 135000, "defesa": 120, "forca": 145, "xp": 28000, "count": 1, "is_boss": true, "cor": Color(0.8, 0.7, 0.1)}
		],
		"reward_xp": 120000, "reward_gold": 1600000, "reward_items": [{"id": "pocao_hp_grande", "qtd": 4}],
		"reward_materials": [{"id": "escama_pouf", "nome": "Pó de Escama Espiritual de Pouf", "qtd": 2}]
	})
	lista.append({
		"id": 29, "title": "PQ 29: O Duelo na Sala do Trono: Neferpitou", "saga_nome": "Formigas Chimera", "arco_requerido": 6, "stars": 7,
		"subtitulo": "What-If: Terpsichora Letal",
		"what_if_lore": "E se Neferpitou ativasse a marionete de guerra Terpsichora com 100% de sua sede de sangue contra os invasores?",
		"inimigos_descricao": "2x Bonecos Doutor Blythe, 1x Neferpitou (Terpsichora Ativada)",
		"waves": [
			{"nome": "Projeção Médica Blythe", "hp": 25000, "defesa": 75, "forca": 92, "xp": 5000, "count": 2, "cor": Color(0.9, 0.3, 0.5)},
			{"nome": "Neferpitou (Terpsichora Sanguinária)", "hp": 165000, "defesa": 130, "forca": 165, "xp": 36000, "count": 1, "is_boss": true, "cor": Color(0.9, 0.1, 0.4)}
		],
		"reward_xp": 140000, "reward_gold": 1900000, "reward_items": [{"id": "fragmento_nen", "qtd": 6}],
		"reward_materials": [{"id": "fio_terpsichora", "nome": "Fio de Marionete de Pitou", "qtd": 2}]
	})
	lista.append({
		"id": 30, "title": "PQ 30: A Provação do Rei Supremo Meruem", "saga_nome": "Formigas Chimera", "arco_requerido": 6, "stars": 8,
		"subtitulo": "What-If: O Ápice da Evolução",
		"what_if_lore": "E se o Rei Meruem alcançasse a consciência divina antes do ataque da Rosa e desafiasse a humanidade inteira?",
		"inimigos_descricao": "3x Guardas Reais Sombrios, 1x Rei Meruem (Ápice da Evolução)",
		"waves": [
			{"nome": "Guarda Real Sombrio", "hp": 45000, "defesa": 95, "forca": 135, "xp": 9000, "count": 3, "cor": Color(0.4, 0.1, 0.5)},
			{"nome": "Rei Meruem (O Ápice da Evolução)", "hp": 220000, "defesa": 150, "forca": 195, "xp": 50000, "count": 1, "is_boss": true, "cor": Color(0.2, 0.8, 0.5)}
		],
		"reward_xp": 175000, "reward_gold": 2400000, "reward_items": [{"id": "elixir_aura", "qtd": 6}],
		"reward_materials": [{"id": "fragmento_aura_meruem", "nome": "Fragmento da Coroa Real de Meruem", "qtd": 2}]
	})
	lista.append({
		"id": 31, "title": "PQ 31: O Desafio dos 100 Braços de Netero", "saga_nome": "Formigas Chimera", "arco_requerido": 6, "stars": 8,
		"subtitulo": "What-If: Maestria Divina",
		"what_if_lore": "E se Isaac Netero criasse uma arena para testar se algum caçador moderno é capaz de desviar de seus 100 Braços?",
		"inimigos_descricao": "6x Palmas Celestiais de Guanyin, 1x Isaac Netero",
		"waves": [
			{"nome": "Palma de Nen de Guanyin", "hp": 22000, "defesa": 82, "forca": 115, "xp": 5500, "count": 6, "cor": Color(1.0, 0.85, 0.2)},
			{"nome": "Isaac Netero (12º Presidente)", "hp": 195000, "defesa": 145, "forca": 180, "xp": 45000, "count": 1, "is_boss": true, "cor": Color(1.0, 0.9, 0.3)}
		],
		"reward_xp": 160000, "reward_gold": 2200000, "reward_items": [{"id": "fragmento_nen", "qtd": 6}],
		"reward_materials": [{"id": "reliquia_guanyin", "nome": "Flor de Lótus de Guanyin", "qtd": 2}]
	})
	lista.append({
		"id": 32, "title": "PQ 32: O Despertar Furioso de Gon Adulto", "saga_nome": "Formigas Chimera", "arco_requerido": 6, "stars": 8,
		"subtitulo": "What-If: Sacrifício Supremo",
		"what_if_lore": "E se a projeção de Gon Adulto (Vow & Limitation) desafiasse a Guarda Real simultaneamente?",
		"inimigos_descricao": "1x Projeção de Gon Adulto (Jajanken Destruidor de Montanhas)",
		"waves": [
			{"nome": "Gon Adulto (Contrato do Fim)", "hp": 240000, "defesa": 155, "forca": 210, "xp": 55000, "count": 1, "is_boss": true, "cor": Color(0.1, 0.1, 0.1)}
		],
		"reward_xp": 190000, "reward_gold": 2800000, "reward_items": [{"id": "elixir_aura", "qtd": 6}],
		"reward_materials": [{"id": "essencia_juramento_gon", "nome": "Cabelo de Aura do Juramento", "qtd": 2}]
	})
	lista.append({
		"id": 33, "title": "PQ 33: A Fuga Elétrica de Killua Godspeed", "saga_nome": "Formigas Chimera", "arco_requerido": 6, "stars": 8,
		"subtitulo": "What-If: Velocidade Divina",
		"what_if_lore": "E se Killua utilizasse seu Kanmuru com carga de eletricidade infinita para aniquilar batalhões inteiros de formigas?",
		"inimigos_descricao": "8x Soldados Relâmpago Mutantes, 1x Killua Godspeed",
		"waves": [
			{"nome": "Soldado Formiga Eletrificado", "hp": 18000, "defesa": 68, "forca": 98, "xp": 4200, "count": 8, "cor": Color(0.3, 0.8, 1.0)},
			{"nome": "Killua (Kanmuru Infinito)", "hp": 160000, "defesa": 125, "forca": 168, "xp": 38000, "count": 1, "is_boss": true, "cor": Color(0.2, 0.9, 1.0)}
		],
		"reward_xp": 155000, "reward_gold": 2100000, "reward_items": [{"id": "fragmento_nen", "qtd": 5}],
		"reward_materials": [{"id": "cristal_eletrico_zoldyck", "nome": "Cristal de Relâmpago Zoldyck", "qtd": 2}]
	})
	lista.append({
		"id": 34, "title": "PQ 34: O Bloqueio de Fumaça de Morel & Knov", "saga_nome": "Formigas Chimera", "arco_requerido": 6, "stars": 7,
		"subtitulo": "What-If: Infiltração Perfeita",
		"what_if_lore": "E se os portais de Knov e a fumaça de Morel prendessem a Guarda Real em dimensões de bolso separadas?",
		"inimigos_descricao": "12x Clones de Fumaça Deep Purple, 1x Mestre Morel com Cachimbo",
		"waves": [
			{"nome": "Soldado de Fumaça Reforçado", "hp": 15000, "defesa": 62, "forca": 88, "xp": 3600, "count": 12, "cor": Color(0.6, 0.4, 0.7)},
			{"nome": "Morel (Capacidade Pulmonar Máxima)", "hp": 140000, "defesa": 120, "forca": 150, "xp": 32000, "count": 1, "is_boss": true, "cor": Color(0.7, 0.5, 0.8)}
		],
		"reward_xp": 145000, "reward_gold": 2000000, "reward_items": [{"id": "pocao_hp_grande", "qtd": 5}],
		"reward_materials": [{"id": "cinzas_cachimbo_morel", "nome": "Cinzas Mágicas do Cachimbo", "qtd": 2}]
	})
	lista.append({
		"id": 35, "title": "PQ 35: A Provação do Juros de APR de Knuckle", "saga_nome": "Formigas Chimera", "arco_requerido": 6, "stars": 7,
		"subtitulo": "What-If: Hakoware Falência",
		"what_if_lore": "E se Knuckle ativasse seu boneco Potclean acumulando 100.000 de aura em juros no oponente?",
		"inimigos_descricao": "4x Cães de Guarda de Peijin, 1x Knuckle o Lutador de Rua",
		"waves": [
			{"nome": "Fera Guardiã de Peijin", "hp": 18000, "defesa": 70, "forca": 96, "xp": 4400, "count": 4, "cor": Color(0.5, 0.3, 0.4)},
			{"nome": "Knuckle Bine (Potclean Invencível)", "hp": 150000, "defesa": 130, "forca": 158, "xp": 34000, "count": 1, "is_boss": true, "cor": Color(0.9, 0.3, 0.3)}
		],
		"reward_xp": 150000, "reward_gold": 2050000, "reward_items": [{"id": "elixir_aura", "qtd": 5}],
		"reward_materials": [{"id": "emblema_potclean", "nome": "Emblema de Juros de Potclean", "qtd": 2}]
	})

	# =========================================================
	# TIER 4: ELEIÇÃO HUNTER & CONTINENTE NEGRO (PQs 36 a 45)
	# =========================================================
	lista.append({
		"id": 36, "title": "PQ 36: As Agulhas Sinistras de Illumi", "saga_nome": "Eleição Hunter", "arco_requerido": 7, "stars": 7,
		"subtitulo": "What-If: Guerra dos Zoldyck",
		"what_if_lore": "E se Illumi usasse seu exército de marionetes com agulha para sitiar a sede da Associação Hunter?",
		"inimigos_descricao": "12x Humanos Manipulados por Agulha, 1x Illumi Zoldyck",
		"waves": [
			{"nome": "Pessoa Agulha Manipulada", "hp": 22000, "defesa": 72, "forca": 105, "xp": 4800, "count": 12, "cor": Color(0.7, 0.2, 0.3)},
			{"nome": "Illumi Zoldyck (Manipulador Assassino)", "hp": 170000, "defesa": 135, "forca": 172, "xp": 38000, "count": 1, "is_boss": true, "cor": Color(0.3, 0.1, 0.4)}
		],
		"reward_xp": 165000, "reward_gold": 2350000, "reward_items": [{"id": "pocao_hp_grande", "qtd": 5}],
		"reward_materials": [{"id": "agulha_ouro_illumi", "nome": "Agulha de Nen de Illumi", "qtd": 2}]
	})
	lista.append({
		"id": 37, "title": "PQ 37: A Revolta dos 12 Zodíacos", "saga_nome": "Eleição Hunter", "arco_requerido": 7, "stars": 8,
		"subtitulo": "What-If: Associação Hunter",
		"what_if_lore": "E se Pariston Hill manipulasse os 12 Zodíacos para uma batalha campal interna pelo controle da Associação?",
		"inimigos_descricao": "4x Caçadores Triplo-Estrela de Elite, 1x Mizaistom, 1x Botobai o Dragão",
		"waves": [
			{"nome": "Caçador Guarda Triplo-Estrela", "hp": 30000, "defesa": 88, "forca": 120, "xp": 6500, "count": 4, "cor": Color(0.2, 0.4, 0.8)},
			{"nome": "Mizaistom (Zodíaco Boi)", "hp": 110000, "defesa": 130, "forca": 150, "xp": 22000, "count": 1, "is_boss": true, "cor": Color(0.9, 0.8, 0.2)},
			{"nome": "Botobai (Zodíaco Dragão Supremo)", "hp": 210000, "defesa": 155, "forca": 195, "xp": 45000, "count": 1, "is_boss": true, "cor": Color(0.9, 0.3, 0.1)}
		],
		"reward_xp": 195000, "reward_gold": 2900000, "reward_items": [{"id": "elixir_aura", "qtd": 6}],
		"reward_materials": [{"id": "emblema_zodiaco", "nome": "Insígnia dos 12 Zodíacos", "qtd": 2}]
	})
	lista.append({
		"id": 38, "title": "PQ 38: O Golpe Remoto de Leorio no Auditório", "saga_nome": "Eleição Hunter", "arco_requerido": 7, "stars": 7,
		"subtitulo": "What-If: Discurso de Leorio",
		"what_if_lore": "E se Leorio despertasse seu Soco Remoto em escala colossal para derrubar todos os opositores no auditório?",
		"inimigos_descricao": "8x Políticos Corruptos da Associação, 1x Leorio Enfurecido",
		"waves": [
			{"nome": "Político da Associação", "hp": 24000, "defesa": 70, "forca": 102, "xp": 4600, "count": 8, "cor": Color(0.4, 0.4, 0.5)},
			{"nome": "Leorio (Punho de Emissão Furioso)", "hp": 175000, "defesa": 130, "forca": 175, "xp": 40000, "count": 1, "is_boss": true, "cor": Color(0.2, 0.6, 0.9)}
		],
		"reward_xp": 170000, "reward_gold": 2450000, "reward_items": [{"id": "pocao_hp_grande", "qtd": 5}],
		"reward_materials": [{"id": "estetoscopio_leorio", "nome": "Estetoscópio de Médico Hunter", "qtd": 2}]
	})
	lista.append({
		"id": 39, "title": "PQ 39: O Segredo de Nanika: Desejos Ilimitados", "saga_nome": "Eleição Hunter", "arco_requerido": 7, "stars": 8,
		"subtitulo": "What-If: Entidade de Ai",
		"what_if_lore": "E se a entidade espiritual de Nanika concedesse poder incomensurável a guardiões dimensionais?",
		"inimigos_descricao": "4x Projeções Espirituais de Nanika, 1x Avatar de Ai",
		"waves": [
			{"nome": "Projeção Espiritual de Desejo", "hp": 35000, "defesa": 92, "forca": 130, "xp": 7500, "count": 4, "cor": Color(0.6, 0.2, 0.9)},
			{"nome": "Avatar Guardião de Nanika", "hp": 230000, "defesa": 145, "forca": 200, "xp": 52000, "count": 1, "is_boss": true, "cor": Color(0.2, 0.1, 0.4)}
		],
		"reward_xp": 215000, "reward_gold": 3200000, "reward_items": [{"id": "elixir_aura", "qtd": 6}],
		"reward_materials": [{"id": "essencia_gasosa_ai", "nome": "Gás Espiritual de Ai", "qtd": 2}]
	})
	lista.append({
		"id": 40, "title": "PQ 40: As 5 Calamidades: A Besta Brion", "saga_nome": "Continente Negro", "arco_requerido": 8, "stars": 8,
		"subtitulo": "What-If: Continente Negro",
		"what_if_lore": "E se a arma biológica botânica Brion tomasse conta das ruínas da cidade antiga e multiplicasse seus guardiões?",
		"inimigos_descricao": "6x Guardiões Botânicos de Brion, 1x Núcleo Ancestral de Brion",
		"waves": [
			{"nome": "Guardião da Esfera Brion", "hp": 40000, "defesa": 98, "forca": 138, "xp": 8200, "count": 6, "cor": Color(0.2, 0.7, 0.4)},
			{"nome": "Calamidade Brion (Núcleo Botânico)", "hp": 260000, "defesa": 160, "forca": 215, "xp": 60000, "count": 1, "is_boss": true, "cor": Color(0.1, 0.8, 0.3)}
		],
		"reward_xp": 240000, "reward_gold": 3600000, "reward_items": [{"id": "fragmento_nen", "qtd": 7}],
		"reward_materials": [{"id": "madeira_ancestral_brion", "nome": "Madeira Botânica de Brion", "qtd": 2}]
	})
	lista.append({
		"id": 41, "title": "PQ 41: As 5 Calamidades: O Terror de Hellbell", "saga_nome": "Continente Negro", "arco_requerido": 8, "stars": 8,
		"subtitulo": "What-If: Continente Negro",
		"what_if_lore": "E se a Serpente de Duas Caudas Hellbell liberasse seu veneno sonoro e alucinógeno no acampamento da expedição?",
		"inimigos_descricao": "4x Serpentes de Sangue, 1x Calamidade Hellbell",
		"waves": [
			{"nome": "Víbora de Sangue do Continente", "hp": 42000, "defesa": 102, "forca": 142, "xp": 8800, "count": 4, "cor": Color(0.8, 0.1, 0.3)},
			{"nome": "Calamidade Hellbell (Serpente do Terror)", "hp": 280000, "defesa": 165, "forca": 225, "xp": 65000, "count": 1, "is_boss": true, "cor": Color(0.9, 0.0, 0.2)}
		],
		"reward_xp": 260000, "reward_gold": 4000000, "reward_items": [{"id": "elixir_aura", "qtd": 7}],
		"reward_materials": [{"id": "veneno_hellbell", "nome": "Veneno Primordial de Hellbell", "qtd": 2}]
	})
	lista.append({
		"id": 42, "title": "PQ 42: As 5 Calamidades: O Horror Imortal Zobae", "saga_nome": "Continente Negro", "arco_requerido": 8, "stars": 9,
		"subtitulo": "What-If: Doença Zobae",
		"what_if_lore": "E se a doença da imortalidade desesperadora Zobae infectasse uma legião inteira de caçadores?",
		"inimigos_descricao": "8x Caçadores Imortais de Zobae, 1x Portador Ancestral de Zobae",
		"waves": [
			{"nome": "Infectado Imortal de Zobae", "hp": 45000, "defesa": 105, "forca": 145, "xp": 9000, "count": 8, "cor": Color(0.4, 0.8, 0.3)},
			{"nome": "Portador Primordial de Zobae", "hp": 300000, "defesa": 170, "forca": 230, "xp": 70000, "count": 1, "is_boss": true, "cor": Color(0.2, 0.9, 0.2)}
		],
		"reward_xp": 280000, "reward_gold": 4500000, "reward_items": [{"id": "fragmento_nen", "qtd": 7}],
		"reward_materials": [{"id": "celula_imortal_zobae", "nome": "Célula Imortal de Zobae", "qtd": 2}]
	})
	lista.append({
		"id": 43, "title": "PQ 43: As 5 Calamidades: O Alimentador Papu", "saga_nome": "Continente Negro", "arco_requerido": 8, "stars": 9,
		"subtitulo": "What-If: Besta Papu",
		"what_if_lore": "E se a besta Papu (a Besta que Troca Prazer por Vida) criasse uma névoa eufórica irresistível?",
		"inimigos_descricao": "6x Criaturas Alimentadoras de Papu, 1x Besta Titânica Papu",
		"waves": [
			{"nome": "Criatura Alimentadora de Papu", "hp": 48000, "defesa": 110, "forca": 150, "xp": 9500, "count": 6, "cor": Color(0.8, 0.3, 0.7)},
			{"nome": "Besta Ancestral Papu", "hp": 320000, "defesa": 175, "forca": 235, "xp": 75000, "count": 1, "is_boss": true, "cor": Color(0.9, 0.2, 0.8)}
		],
		"reward_xp": 300000, "reward_gold": 5000000, "reward_items": [{"id": "elixir_aura", "qtd": 8}],
		"reward_materials": [{"id": "seiva_vital_papu", "nome": "Seiva de Prazer de Papu", "qtd": 2}]
	})
	lista.append({
		"id": 44, "title": "PQ 44: A Provação de Ging Freecss no Topo do Mundo", "saga_nome": "Continente Negro", "arco_requerido": 8, "stars": 9,
		"subtitulo": "What-If: Ging Freecss",
		"what_if_lore": "E se Ging Freecss usasse sua capacidade de copiar qualquer técnica física de Nen para testar seu domínio total?",
		"inimigos_descricao": "4x Ecos de Aura Ancestral, 1x Ging Freecss (Top 5 Usuários de Nen)",
		"waves": [
			{"nome": "Eco de Aura de Ging", "hp": 52000, "defesa": 115, "forca": 155, "xp": 10000, "count": 4, "cor": Color(0.3, 0.7, 0.5)},
			{"nome": "Ging Freecss (Gênio do Nen)", "hp": 340000, "defesa": 180, "forca": 240, "xp": 80000, "count": 1, "is_boss": true, "cor": Color(0.2, 0.8, 0.4)}
		],
		"reward_xp": 330000, "reward_gold": 5600000, "reward_items": [{"id": "fragmento_nen", "qtd": 8}],
		"reward_materials": [{"id": "diario_ging_freecss", "nome": "Anotações do Novo Mundo de Ging", "qtd": 2}]
	})
	lista.append({
		"id": 45, "title": "PQ 45: A Expedição de Beyond Netero", "saga_nome": "Continente Negro", "arco_requerido": 8, "stars": 9,
		"subtitulo": "What-If: O Filho de Netero",
		"what_if_lore": "E se Beyond Netero e seus mercenários de elite partissem sem autorização através do portão dos Guardiões?",
		"inimigos_descricao": "6x Mercenários de Elite de Beyond, 1x Beyond Netero",
		"waves": [
			{"nome": "Mercenário de Beyond", "hp": 55000, "defesa": 118, "forca": 158, "xp": 10500, "count": 6, "cor": Color(0.6, 0.5, 0.3)},
			{"nome": "Beyond Netero (O Explorador Proibido)", "hp": 350000, "defesa": 185, "forca": 245, "xp": 85000, "count": 1, "is_boss": true, "cor": Color(0.8, 0.6, 0.2)}
		],
		"reward_xp": 360000, "reward_gold": 6200000, "reward_items": [{"id": "elixir_aura", "qtd": 8}],
		"reward_materials": [{"id": "mapa_continente_negro", "nome": "Carta Náutica do Novo Mundo", "qtd": 2}]
	})

	# =========================================================
	# TIER 5: GUERRA DE SUCESSÃO & BOSS RUSH SUPREMO (PQs 46 a 50)
	# =========================================================
	lista.append({
		"id": 46, "title": "PQ 46: A Noite de Sangue no Black Whale 1", "saga_nome": "Black Whale 1", "arco_requerido": 9, "stars": 9,
		"subtitulo": "What-If: Guerra de Sucessão",
		"what_if_lore": "E se a máfia Heil-Ly de Morena Prudo infectasse centenas de passageiros com seu vírus contagioso?",
		"inimigos_descricao": "12x Infectados pelo Contágio de Morena, 2x Assassinos Nível 50",
		"waves": [
			{"nome": "Contagiado de Nen Heil-Ly", "hp": 50000, "defesa": 112, "forca": 148, "xp": 9500, "count": 12, "cor": Color(0.7, 0.1, 0.4)},
			{"nome": "Assassino Heil-Ly Nível 50", "hp": 180000, "defesa": 160, "forca": 210, "xp": 45000, "count": 2, "is_boss": true, "cor": Color(0.8, 0.2, 0.6)}
		],
		"reward_xp": 380000, "reward_gold": 6800000, "reward_items": [{"id": "pocao_hp_grande", "qtd": 6}],
		"reward_materials": [{"id": "virus_nen_morena", "nome": "Frasco de Contágio de Morena", "qtd": 2}]
	})
	lista.append({
		"id": 47, "title": "PQ 47: O Julgamento de Benjamin e Camilla", "saga_nome": "Black Whale 1", "arco_requerido": 9, "stars": 9,
		"subtitulo": "What-If: Príncipes de Kakin",
		"what_if_lore": "E se o 1º Príncipe Benjamin atacasse a fortaleza da 2ª Princesa Camilla com toda a guarda imperial?",
		"inimigos_descricao": "6x Soldados da Guarda Pessoal de Benjamin, 1x Besta Guardiã de Benjamin",
		"waves": [
			{"nome": "Guarda de Elite de Benjamin", "hp": 60000, "defesa": 125, "forca": 165, "xp": 11500, "count": 6, "cor": Color(0.8, 0.7, 0.2)},
			{"nome": "Besta Guardiã de Benjamin", "hp": 360000, "defesa": 190, "forca": 250, "xp": 90000, "count": 1, "is_boss": true, "cor": Color(0.9, 0.8, 0.1)}
		],
		"reward_xp": 420000, "reward_gold": 7600000, "reward_items": [{"id": "elixir_aura", "qtd": 8}],
		"reward_materials": [{"id": "brasao_imperial_benjamin", "nome": "Brasão de Ouro de Kakin", "qtd": 2}]
	})
	lista.append({
		"id": 48, "title": "PQ 48: O Despertar Monstruoso de Tserriednich", "saga_nome": "Black Whale 1", "arco_requerido": 9, "stars": 10,
		"subtitulo": "What-If: 4º Príncipe",
		"what_if_lore": "E se Tserriednich dominasse Zetsu Paralelo e o futuro de 10 segundos para assassinar todos os guardas?",
		"inimigos_descricao": "2x Bestas Parasitas Faciais, 1x Tserriednich (Visão Temporal)",
		"waves": [
			{"nome": "Besta Parasita Facial", "hp": 120000, "defesa": 155, "forca": 195, "xp": 25000, "count": 2, "cor": Color(0.6, 0.1, 0.8)},
			{"nome": "Tserriednich (Futuro Paralelo)", "hp": 380000, "defesa": 200, "forca": 260, "xp": 110000, "count": 1, "is_boss": true, "cor": Color(0.4, 0.0, 0.6)}
		],
		"reward_xp": 480000, "reward_gold": 9000000, "reward_items": [{"id": "fragmento_nen", "qtd": 10}],
		"reward_materials": [{"id": "olhos_escarlates_arte", "nome": "Relíquia Sagrada de Kakin", "qtd": 2}]
	})
	lista.append({
		"id": 49, "title": "PQ 49: O Duelo de Titãs: Kurapika vs Chrollo no Navio", "saga_nome": "Guerra de Sucessão", "arco_requerido": 9, "stars": 10,
		"subtitulo": "What-If: Vingança Final",
		"what_if_lore": "E se Kurapika encontrasse Chrollo Lucifer no nível mais profundo do navio sem a proteção de nenhum guarda?",
		"inimigos_descricao": "1x Chrollo (Livro Aberto Completo), 1x Kurapika Sombrio (Emperor Time Infinito)",
		"waves": [
			{"nome": "Chrollo Lucifer (Modo Letal)", "hp": 350000, "defesa": 195, "forca": 255, "xp": 80000, "count": 1, "is_boss": true, "cor": Color(0.3, 0.1, 0.6)},
			{"nome": "Kurapika (Correntes da Vingança)", "hp": 380000, "defesa": 200, "forca": 265, "xp": 90000, "count": 1, "is_boss": true, "cor": Color(0.9, 0.2, 0.2)}
		],
		"reward_xp": 550000, "reward_gold": 12000000, "reward_items": [{"id": "elixir_aura", "qtd": 10}],
		"reward_materials": [{"id": "corrente_julgamento_aco", "nome": "Elo da Corrente do Julgamento", "qtd": 3}]
	})
	lista.append({
		"id": 50, "title": "PQ 50: O BOSS RUSH SUPREMO DOS 5 GRANDES MESTRES", "saga_nome": "Desafio Supremo", "arco_requerido": 9, "stars": 10,
		"subtitulo": "What-If: O Pináculo do Nen",
		"what_if_lore": "A maior provação de toda a história Hunter! Derrote em sequência os 5 seres mais poderosos que já caminharam pelo mundo.",
		"inimigos_descricao": "Onda 1: Hisoka & Chrollo | Onda 2: Silva Zoldyck | Onda 3: Isaac Netero | Onda 4: Rei Meruem Divino (400.000 HP)",
		"waves": [
			{"nome": "Hisoka Supremo", "hp": 250000, "defesa": 170, "forca": 220, "xp": 60000, "count": 1, "is_boss": true, "cor": Color(1.0, 0.2, 0.6)},
			{"nome": "Chrollo Lucifer Supremo", "hp": 280000, "defesa": 180, "forca": 235, "xp": 70000, "count": 1, "is_boss": true, "cor": Color(0.4, 0.1, 0.7)},
			{"nome": "Silva Zoldyck", "hp": 320000, "defesa": 190, "forca": 250, "xp": 85000, "count": 1, "is_boss": true, "cor": Color(0.9, 0.8, 0.2)},
			{"nome": "Isaac Netero (Guanyin Máximo)", "hp": 380000, "defesa": 210, "forca": 270, "xp": 120000, "count": 1, "is_boss": true, "cor": Color(1.0, 0.9, 0.3)},
			{"nome": "Rei Meruem (Poder Divino)", "hp": 400000, "defesa": 220, "forca": 280, "xp": 200000, "count": 1, "is_boss": true, "cor": Color(0.2, 0.9, 0.6)}
		],
		"reward_xp": 1000000, "reward_gold": 25000000, "reward_items": [{"id": "titulo_cassador_supremo", "qtd": 1}, {"id": "elixir_aura", "qtd": 15}],
		"reward_materials": [{"id": "coroa_deus_nen", "nome": "Coroa do Deus do Nen", "qtd": 3}]
	})

	return lista


static func obter_missao_por_id(id: int) -> Dictionary:
	for m in obter_todas_missoes():
		if m.get("id", -1) == id:
			return m
	return {}


static func esta_desbloqueada(id: int, max_arco: int) -> bool:
	var m := obter_missao_por_id(id)
	if m.is_empty():
		return false
	var req: int = m.get("arco_requerido", 1)
	return max_arco >= req
