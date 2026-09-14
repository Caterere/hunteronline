class_name SagaDistrictKit
extends RefCounted

# ============================================================
# HUNTER ONLINE — SAGA DISTRICT KIT
# Distritos jogáveis DENTRO do hub (sem .tscn fantasma):
# - fillers ambient
# - NPCs vivos com diálogo
# - placas de distrito
# - warps internos entre zonas (zona secundária navegável)
# - sensores Nen opcionais
# ============================================================

const ENEMY_SCENE := "res://scripts/systems/EnemySystem/Enemy.tscn"
const NPC_SCENE := "res://entities/npc/NPC.tscn"


static func densify_districts(mapa: Node2D, districts: Array) -> void:
	if mapa == null:
		return
	for d in districts:
		if typeof(d) != TYPE_DICTIONARY:
			continue
		_spawn_placard(mapa, d)
		_spawn_fillers(mapa, d.get("fillers", []))
		_spawn_ambient_npcs(mapa, d.get("npcs", []))
		_spawn_warp(mapa, d)


static func densify_saga(mapa: Node2D, saga_id: int) -> void:
	densify_districts(mapa, districts_for_saga(saga_id))
	_spawn_nen_sensors_for_saga(mapa, saga_id)
	EliteIdentityKit.densify_saga(mapa, saga_id)


static func districts_for_saga(saga_id: int) -> Array:
	match saga_id:
		1:
			return [
				{
					"id": "tunel",
					"placa": "PlacaDistritoTunel",
					"pos": Vector2(280, -90),
					"text": "📍 Zona A — Túnel de Zaban",
					"warp_name": "WarpTunel",
					"warp_pos": Vector2(120, 70),
					"warp_target": Vector2(1900, 70),
					"warp_label": "Atalho → Pantanal",
					"fillers": [
						{"name": "SabotadorAmbient_B", "pos": Vector2(900, 40), "id": "candidato_sabotador", "label": "Sabotador do Túnel"},
						{"name": "SabotadorAmbient_C", "pos": Vector2(1300, -30), "id": "candidato_sabotador", "label": "Candidato Hostil"},
					],
					"npcs": [
						{"name": "ExaminadorSatotzHint", "pos": Vector2(1500, -60), "npc": "Guia do Túnel", "fala": "Satotz espera na saída. Mantenha o ritmo — o pantanal come os lentos.", "ids": ["npc_viajante_scout"]},
					],
				},
				{
					"id": "pantanal",
					"placa": "PlacaDistritoPantanal",
					"pos": Vector2(2100, -90),
					"text": "📍 Zona B — Pantanal Numere (secundária)",
					"warp_name": "WarpPantanal",
					"warp_pos": Vector2(1700, 70),
					"warp_target": Vector2(4200, 70),
					"warp_label": "Atalho → Gourmet",
					"fillers": [
						{"name": "MacacoAmbient_B", "pos": Vector2(2300, 35), "id": "macaco_pantano", "label": "Macaco do Nevoeiro"},
						{"name": "MacacoAmbient_C", "pos": Vector2(2900, -25), "id": "macaco_pantano", "label": "Predador do Pantanal"},
					],
					"npcs": [
						{"name": "SobreviventePantanal", "pos": Vector2(2600, -70), "npc": "Candidato Ferido", "fala": "Hisoka caça no nevoeiro... não olhe para trás se ouvir cartas.", "ids": ["npc_viajante_scout"]},
					],
				},
				{
					"id": "gourmet",
					"placa": "PlacaDistritoGourmet",
					"pos": Vector2(4300, -90),
					"text": "📍 Zona C — Floresta Gourmet (secundária)",
					"warp_name": "WarpGourmet",
					"warp_pos": Vector2(3900, 70),
					"warp_target": Vector2(5600, 70),
					"warp_label": "Atalho → Portão Final",
					"fillers": [
						{"name": "JavaliAmbient_B", "pos": Vector2(4500, 40), "id": "javali_gourmet", "label": "Javali Gourmet"},
						{"name": "JavaliAmbient_C", "pos": Vector2(5000, -20), "id": "javali_gourmet", "label": "Javali Alpha"},
					],
					"npcs": [
						{"name": "AssistenteMenchi", "pos": Vector2(4700, -70), "npc": "Assistente Gourmet", "fala": "Menchi só aceita carne rara. Prove que você caça de verdade.", "ids": ["npc_viajante_scout"]},
					],
				},
				{
					"id": "torre",
					"placa": "PlacaDistritoTorre",
					"pos": Vector2(5600, -90),
					"text": "📍 Zona D — Torre / Ilha Zevil",
					"warp_name": "WarpTorre",
					"warp_pos": Vector2(5500, 70),
					"warp_target": Vector2(200, 70),
					"warp_label": "Atalho → Túnel",
					"fillers": [
						{"name": "CompetidorAmbient_A", "pos": Vector2(5800, 30), "id": "candidato_sabotador", "label": "Competidor de Zevil"},
					],
					"npcs": [
						{"name": "JuizFinalExame", "pos": Vector2(5950, -60), "npc": "Oficial do Exame", "fala": "Além deste portão só passa quem sobreviveu às 24 etapas.", "ids": ["npc_viajante_scout"]},
					],
				},
			]

		2:
			return [
				{"id": "portao", "placa": "PlacaDistritoPortao", "pos": Vector2(250, -100), "text": "📍 Distrito Portão da Testagem",
				 "warp_name": "WarpPortaoKuku", "warp_pos": Vector2(150, 60), "warp_target": Vector2(2400, 60), "warp_label": "Atalho → Mansão",
				 "fillers": [{"name": "MordomoAmbient_F", "pos": Vector2(500, 30), "id": "mordomo_zoldyck", "label": "Mordomo do Portão"}],
				 "npcs": [{"name": "ZebroHint", "pos": Vector2(320, -50), "npc": "Zebro", "fala": "O portão pesa toneladas. Prove força — ou peça ajuda.", "ids": ["npc_viajante_scout"]}]},
				{"id": "alameda", "placa": "PlacaDistritoAlameda", "pos": Vector2(1300, -100), "text": "📍 Distrito Alameda (secundária)",
				 "warp_name": "WarpAlameda", "warp_pos": Vector2(1200, 60), "warp_target": Vector2(3200, 60), "warp_label": "Atalho → Trono",
				 "fillers": [{"name": "MordomoAmbient_G", "pos": Vector2(1500, 25), "id": "mordomo_zoldyck", "label": "Mordomo da Alameda"}],
				 "npcs": [{"name": "CanaryHint", "pos": Vector2(1400, -55), "npc": "Canary", "fala": "Mike patrulha. Sem permissão, a alameda engole invasores.", "ids": ["npc_viajante_scout"]}]},
				{"id": "mansao", "placa": "PlacaDistritoMansao", "pos": Vector2(2500, -100), "text": "📍 Distrito Mansão dos Mordomos (secundária)",
				 "warp_name": "WarpMansao", "warp_pos": Vector2(2400, 60), "warp_target": Vector2(200, 60), "warp_label": "Atalho → Portão",
				 "fillers": [{"name": "MordomoAmbient_H", "pos": Vector2(2600, 20), "id": "mordomo_zoldyck", "label": "Elite Gotoh"}],
				 "npcs": [{"name": "GotohHint", "pos": Vector2(2550, -55), "npc": "Aprendiz de Gotoh", "fala": "Moedas no ar. Errou? Começa de novo.", "ids": ["npc_viajante_scout"]}]},
				{"id": "trono", "placa": "PlacaDistritoTrono", "pos": Vector2(3400, -100), "text": "📍 Distrito Sala do Trono",
				 "warp_name": "WarpTrono", "warp_pos": Vector2(3300, 60), "warp_target": Vector2(1300, 60), "warp_label": "Atalho → Alameda",
				 "fillers": [],
				 "npcs": [{"name": "KilluaHint", "pos": Vector2(3450, -50), "npc": "Killua", "fala": "Se veio me tirar daqui... prove que aguenta a família.", "ids": ["npc_viajante_scout"]}]},
			]
		3:
			return [
				{"id": "recepcao", "placa": "PlacaDistritoRecepcao", "pos": Vector2(200, -100), "text": "📍 Distrito Recepção Arena",
				 "warp_name": "WarpRecepcao", "warp_pos": Vector2(120, 60), "warp_target": Vector2(2000, 60), "warp_label": "Atalho → Andares Médios",
				 "fillers": [{"name": "LutadorAmbient_C", "pos": Vector2(500, 30), "id": "lutador_arena", "label": "Lutador Amador"}],
				 "npcs": [{"name": "RecepcionistaArenaHint", "pos": Vector2(280, -50), "npc": "Recepcionista", "fala": "Do 1º ao 199º é aquecimento. O Nen começa no 200º.", "ids": ["npc_viajante_scout"]}]},
				{"id": "dojo", "placa": "PlacaDistritoDojo", "pos": Vector2(1100, -100), "text": "📍 Distrito Dojo Wing (secundária)",
				 "warp_name": "WarpDojo", "warp_pos": Vector2(1000, 60), "warp_target": Vector2(3000, 60), "warp_label": "Atalho → 200º",
				 "fillers": [{"name": "LutadorAmbient_D", "pos": Vector2(1200, 25), "id": "lutador_arena", "label": "Aluno Shingen-ryu"}],
				 "npcs": [{"name": "ZushiHint", "pos": Vector2(1150, -55), "npc": "Zushi", "fala": "Wing ensina Ten e Zetsu aqui. Sem base, o 200º te esmaga.", "ids": ["npc_viajante_scout"]}]},
				{"id": "medios", "placa": "PlacaDistritoMedios", "pos": Vector2(2000, -100), "text": "📍 Distrito Andares Médios (secundária)",
				 "warp_name": "WarpMedios", "warp_pos": Vector2(1900, 60), "warp_target": Vector2(200, 60), "warp_label": "Atalho → Recepção",
				 "fillers": [{"name": "LutadorAmbient_E", "pos": Vector2(2100, 20), "id": "lutador_arena", "label": "Veterano do 100º"}],
				 "npcs": [{"name": "ApostadorArena", "pos": Vector2(2050, -55), "npc": "Apostador", "fala": "Gido e Kastro estão no 200º. Não suba sem Nen.", "ids": ["npc_viajante_scout"]}]},
				{"id": "topo200", "placa": "PlacaDistrito200", "pos": Vector2(3200, -100), "text": "📍 Distrito 200º Andar — Floor Masters",
				 "warp_name": "Warp200", "warp_pos": Vector2(3100, 60), "warp_target": Vector2(1100, 60), "warp_label": "Atalho → Dojo",
				 "fillers": [],
				 "npcs": [{"name": "FloorMasterHint", "pos": Vector2(3300, -50), "npc": "Floor Master", "fala": "Hisoka observa. Mostre Hatsu ou saia.", "ids": ["npc_viajante_scout"]}]},
			]
		4:
			return [
				{"id": "leilao", "placa": "PlacaDistritoLeilao", "pos": Vector2(350, -100), "text": "📍 Distrito Leilão Underground",
				 "warp_name": "WarpLeilao", "warp_pos": Vector2(200, 60), "warp_target": Vector2(2800, 60), "warp_label": "Atalho → Cemitério",
				 "fillers": [{"name": "MafiosoAmbient_D", "pos": Vector2(600, 30), "id": "mafioso_yorknew", "label": "Soldado do Leilão"}],
				 "npcs": [{"name": "LeiloeiroHint", "pos": Vector2(400, -50), "npc": "Leiloeiro", "fala": "Olhos Escarlates sobem o preço. A Trupe também.", "ids": ["npc_viajante_scout"]}]},
				{"id": "avenida", "placa": "PlacaDistritoAvenida", "pos": Vector2(1600, -100), "text": "📍 Distrito Avenida Central (secundária)",
				 "warp_name": "WarpAvenida", "warp_pos": Vector2(1500, 60), "warp_target": Vector2(3700, 60), "warp_label": "Atalho → Trupe",
				 "fillers": [{"name": "MafiosoAmbient_E", "pos": Vector2(1800, 25), "id": "mafioso_yorknew", "label": "Capanga da Avenida"}],
				 "npcs": [{"name": "InformanteMafia", "pos": Vector2(1700, -55), "npc": "Informante", "fala": "Uvogin sumiu. Kurapika está caçando aranhas.", "ids": ["npc_viajante_scout"]}]},
				{"id": "cemiterio", "placa": "PlacaDistritoCemiterio", "pos": Vector2(2800, -100), "text": "📍 Distrito Edifício Cemitério (secundária)",
				 "warp_name": "WarpCemiterio", "warp_pos": Vector2(2700, 60), "warp_target": Vector2(300, 60), "warp_label": "Atalho → Leilão",
				 "fillers": [{"name": "MafiosoAmbient_F", "pos": Vector2(3000, 20), "id": "mafioso_yorknew", "label": "Guarda do Cemitério"}],
				 "npcs": [{"name": "MelodyHint", "pos": Vector2(2850, -55), "npc": "Melody", "fala": "O coração da Trupe bate alto neste prédio.", "ids": ["npc_viajante_scout"]}]},
				{"id": "trupe", "placa": "PlacaDistritoTrupe", "pos": Vector2(3700, -100), "text": "📍 Distrito Zona da Trupe Fantasma",
				 "warp_name": "WarpTrupe", "warp_pos": Vector2(3600, 60), "warp_target": Vector2(1600, 60), "warp_label": "Atalho → Avenida",
				 "fillers": [],
				 "npcs": [{"name": "KurapikaHint", "pos": Vector2(3750, -50), "npc": "Kurapika", "fala": "Chrollo está perto. Chains prontas.", "ids": ["npc_viajante_scout"]}]},
			]
		5:
			return [
				{
					"id": "antokiba",
					"placa": "PlacaDistritoAntokiba",
					"pos": Vector2(250, -100),
					"text": "📍 Distrito Antokiba",
					"warp_name": "WarpAntokiba",
					"warp_pos": Vector2(150, 60),
					"warp_target": Vector2(2500, 60),
					"warp_label": "Atalho → Soufrabi",
					"fillers": [
						{"name": "MonstroAmbient_B", "pos": Vector2(500, 30), "id": "monstro_greed", "label": "Monstro de Antokiba"},
						{"name": "MonstroAmbient_C", "pos": Vector2(900, -20), "id": "monstro_greed", "label": "Card Mob"},
					],
					"npcs": [
						{"name": "JogadorAntokiba", "pos": Vector2(350, -50), "npc": "Jogador de Cartas", "fala": "Sem SPELL você não sobrevive a Soufrabi. Treine com Biscuit primeiro.", "ids": ["npc_viajante_scout"]},
					],
				},
				{
					"id": "desfiladeiro",
					"placa": "PlacaDistritoDesfiladeiro",
					"pos": Vector2(1500, -100),
					"text": "📍 Distrito Desfiladeiro — Treino Biscuit (secundária)",
					"warp_name": "WarpDesfiladeiro",
					"warp_pos": Vector2(1300, 60),
					"warp_target": Vector2(3600, 60),
					"warp_label": "Atalho → Castelo",
					"fillers": [
						{"name": "GolemPedraAmbient_A", "pos": Vector2(1700, 25), "id": "golem_pedra", "label": "Golem de Treino"},
					],
					"npcs": [
						{"name": "AlunoBiscuit", "pos": Vector2(1800, -60), "npc": "Aluno de Nen", "fala": "Ko, Ryu, Ken... Biscuit não aceita meia-medida.", "ids": ["npc_viajante_scout"]},
					],
				},
				{
					"id": "soufrabi",
					"placa": "PlacaDistritoSoufrabi",
					"pos": Vector2(2700, -100),
					"text": "📍 Distrito Soufrabi — Queimada de Razor (secundária)",
					"warp_name": "WarpSoufrabi",
					"warp_pos": Vector2(2500, 60),
					"warp_target": Vector2(200, 60),
					"warp_label": "Atalho → Antokiba",
					"fillers": [
						{"name": "DemonioRazorAmbient_A", "pos": Vector2(2900, 20), "id": "demonio_razor", "label": "Demônio de Nen"},
					],
					"npcs": [
						{"name": "PirataSoufrabi", "pos": Vector2(2650, -55), "npc": "Pirata de Soufrabi", "fala": "Razor não joga limpo. Leve aliados ou morra sozinho.", "ids": ["npc_viajante_scout"]},
					],
				},
				{
					"id": "castelo",
					"placa": "PlacaDistritoCastelo",
					"pos": Vector2(3700, -100),
					"text": "📍 Distrito Castelo — Premiação",
					"warp_name": "WarpCastelo",
					"warp_pos": Vector2(3600, 60),
					"warp_target": Vector2(1500, 60),
					"warp_label": "Atalho → Desfiladeiro",
					"fillers": [],
					"npcs": [
						{"name": "GuardaCasteloGI", "pos": Vector2(3800, -50), "npc": "Guarda do Castelo", "fala": "Só quem zera as 100 cartas entra na sala de premiação.", "ids": ["npc_viajante_scout"]},
					],
				},
			]
		6:
			return [
				{
					"id": "fronteira",
					"placa": "PlacaDistritoFronteiraNGL",
					"pos": Vector2(250, -100),
					"text": "📍 Distrito Fronteira NGL",
					"warp_name": "WarpFronteiraNGL",
					"warp_pos": Vector2(150, 60),
					"warp_target": Vector2(2500, 60),
					"warp_label": "Atalho → Palácio",
					"fillers": [
						{"name": "FormigaAmbient_C", "pos": Vector2(700, 30), "id": "formiga_soldado", "label": "Formiga Patrulha"},
					],
					"npcs": [
						{"name": "ScoutExterminio", "pos": Vector2(400, -55), "npc": "Scout do Extermínio", "fala": "Kite disse: se a rainha despertar, corram.", "ids": ["npc_viajante_scout"]},
					],
				},
				{
					"id": "fabrica",
					"placa": "PlacaDistritoFabrica",
					"pos": Vector2(1500, -100),
					"text": "📍 Distrito Fábrica D2 (secundária)",
					"warp_name": "WarpFabrica",
					"warp_pos": Vector2(1300, 60),
					"warp_target": Vector2(3600, 60),
					"warp_label": "Atalho → Tumba",
					"fillers": [
						{"name": "FormigaAmbient_D", "pos": Vector2(1700, 25), "id": "formiga_oficial", "label": "Formiga Oficial"},
					],
					"npcs": [
						{"name": "ResistenciaGorteau", "pos": Vector2(1600, -55), "npc": "Resistente de Gorteau", "fala": "Gyro destruiu este lugar. As formigas só terminaram o serviço.", "ids": ["npc_viajante_scout"]},
					],
				},
				{
					"id": "palacio",
					"placa": "PlacaDistritoPalacio",
					"pos": Vector2(2700, -100),
					"text": "📍 Distrito Palácio Peijin (secundária)",
					"warp_name": "WarpPalacio",
					"warp_pos": Vector2(2500, 60),
					"warp_target": Vector2(200, 60),
					"warp_label": "Atalho → Fronteira",
					"fillers": [
						{"name": "GuardaPeijinAmbient", "pos": Vector2(2900, 20), "id": "guarda_peijin", "label": "Guarda de Peijin"},
					],
					"npcs": [
						{"name": "SoldadoPeijin", "pos": Vector2(2750, -55), "npc": "Soldado de Peijin", "fala": "A Guarda Real não brinca. Youpi, Pouf e Pitou estão no trono.", "ids": ["npc_viajante_scout"]},
					],
				},
				{
					"id": "tumba",
					"placa": "PlacaDistritoTumba",
					"pos": Vector2(3700, -100),
					"text": "📍 Distrito Tumba Nuclear",
					"warp_name": "WarpTumba",
					"warp_pos": Vector2(3600, 60),
					"warp_target": Vector2(1500, 60),
					"warp_label": "Atalho → Fábrica",
					"fillers": [],
					"npcs": [
						{"name": "EcoNetero", "pos": Vector2(3750, -50), "npc": "Eco de Netero", "fala": "Meruem... prove que a humanidade ainda tem garras.", "ids": ["npc_viajante_scout"]},
					],
				},
			]
		7:
			return [
				{
					"id": "auditorio",
					"placa": "PlacaDistritoAuditorio",
					"pos": Vector2(250, -100),
					"text": "📍 Distrito Auditório Zodíaco",
					"warp_name": "WarpAuditorio",
					"warp_pos": Vector2(150, 60),
					"warp_target": Vector2(2500, 60),
					"warp_label": "Atalho → Rodovia",
					"fillers": [
						{"name": "AgenteAmbient_B", "pos": Vector2(600, 30), "id": "mordomo_perseguidor", "label": "Agente Ilícito"},
					],
					"npcs": [
						{"name": "AssistenteCheadle", "pos": Vector2(350, -55), "npc": "Assistente de Cheadle", "fala": "A eleição não espera. Vote — e proteja Gon.", "ids": ["npc_viajante_scout"]},
					],
				},
				{
					"id": "hospital",
					"placa": "PlacaDistritoHospital",
					"pos": Vector2(1500, -100),
					"text": "📍 Distrito Hospital Hunter (secundária)",
					"warp_name": "WarpHospital",
					"warp_pos": Vector2(1300, 60),
					"warp_target": Vector2(3600, 60),
					"warp_label": "Atalho → Plenário",
					"fillers": [],
					"npcs": [
						{"name": "MedicoHunter", "pos": Vector2(1600, -55), "npc": "Médico Hunter", "fala": "Só Nanika pode reverter isso. Killua sabe o caminho.", "ids": ["npc_viajante_scout"]},
					],
				},
				{
					"id": "rodovia",
					"placa": "PlacaDistritoRodovia",
					"pos": Vector2(2700, -100),
					"text": "📍 Distrito Rodovia — Emboscada Illumi (secundária)",
					"warp_name": "WarpRodovia",
					"warp_pos": Vector2(2500, 60),
					"warp_target": Vector2(200, 60),
					"warp_label": "Atalho → Auditório",
					"fillers": [
						{"name": "NeedleAmbient_C", "pos": Vector2(2900, 25), "id": "humano_agulha", "label": "Homem-Agulha"},
					],
					"npcs": [
						{"name": "MotoristaAssustado", "pos": Vector2(2650, -55), "npc": "Motorista Assustado", "fala": "Homens-agulha na pista! Illumi não brinca.", "ids": ["npc_viajante_scout"]},
					],
				},
				{
					"id": "plenario",
					"placa": "PlacaDistritoPlenario",
					"pos": Vector2(3700, -100),
					"text": "📍 Distrito Plenário da 13ª Eleição",
					"warp_name": "WarpPlenario",
					"warp_pos": Vector2(3600, 60),
					"warp_target": Vector2(1500, 60),
					"warp_label": "Atalho → Hospital",
					"fillers": [],
					"npcs": [
						{"name": "FiscalEleicao", "pos": Vector2(3750, -50), "npc": "Fiscal da Eleição", "fala": "Pariston sorri demais. Desconfie de cada cédula.", "ids": ["npc_viajante_scout"]},
					],
				},
			]
		8:
			return [
				{
					"id": "acampamento",
					"placa": "PlacaDistritoAcampamento",
					"pos": Vector2(250, -100),
					"text": "📍 Distrito Acampamento Beyond",
					"warp_name": "WarpAcampamento",
					"warp_pos": Vector2(150, 60),
					"warp_target": Vector2(2500, 60),
					"warp_label": "Atalho → Raízes",
					"fillers": [
						{"name": "CriaturaAmbient_B", "pos": Vector2(600, 30), "id": "criatura_primitiva", "label": "Criatura Primitiva"},
					],
					"npcs": [
						{"name": "ExpedicionarioBeyond", "pos": Vector2(350, -55), "npc": "Expedicionário", "fala": "Beyond quer o continente. Nós queremos sobreviver.", "ids": ["npc_viajante_scout"]},
					],
				},
				{
					"id": "brion",
					"placa": "PlacaDistritoBrion",
					"pos": Vector2(1500, -100),
					"text": "📍 Distrito Labirinto de Brion (secundária)",
					"warp_name": "WarpBrion",
					"warp_pos": Vector2(1300, 60),
					"warp_target": Vector2(3600, 60),
					"warp_label": "Atalho → Topo",
					"fillers": [
						{"name": "GuardaBrionAmbient_B", "pos": Vector2(1700, 25), "id": "guarda_brion", "label": "Guardião de Brion"},
					],
					"npcs": [
						{"name": "CartografoNegro", "pos": Vector2(1600, -55), "npc": "Cartógrafo", "fala": "Brion muda o labirinto. Marque cada curva.", "ids": ["npc_viajante_scout"]},
					],
				},
				{
					"id": "raizes",
					"placa": "PlacaDistritoRaizes",
					"pos": Vector2(2700, -100),
					"text": "📍 Distrito Raízes da Árvore do Mundo (secundária)",
					"warp_name": "WarpRaizes",
					"warp_pos": Vector2(2500, 60),
					"warp_target": Vector2(200, 60),
					"warp_label": "Atalho → Acampamento",
					"fillers": [
						{"name": "BestaAmbient_A", "pos": Vector2(2900, 20), "id": "hellbell_boss", "label": "Eco de Hellbell"},
					],
					"npcs": [
						{"name": "BotanicoExpedicao", "pos": Vector2(2750, -55), "npc": "Botânico", "fala": "As raízes comem aura. Suba com Zetsu.", "ids": ["npc_viajante_scout"]},
					],
				},
				{
					"id": "topo",
					"placa": "PlacaDistritoTopo",
					"pos": Vector2(3700, -100),
					"text": "📍 Distrito Topo — Ninho com Ging",
					"warp_name": "WarpTopo",
					"warp_pos": Vector2(3600, 60),
					"warp_target": Vector2(1500, 60),
					"warp_label": "Atalho → Brion",
					"fillers": [],
					"npcs": [
						{"name": "ObservadorGing", "pos": Vector2(3750, -50), "npc": "Observador", "fala": "Ging disse que o horizonte importa mais que o destino.", "ids": ["npc_viajante_scout"]},
					],
				},
			]
		9:
			return [
				{
					"id": "conves1",
					"placa": "PlacaDistritoConves1",
					"pos": Vector2(250, -100),
					"text": "📍 Distrito Convés 1 — Rainha Oito",
					"warp_name": "WarpConves1",
					"warp_pos": Vector2(150, 60),
					"warp_target": Vector2(2500, 60),
					"warp_label": "Atalho → Aposentos",
					"fillers": [
						{"name": "BestaParasitaAmbient_A", "pos": Vector2(600, 30), "id": "besta_parasita", "label": "Besta Parasita"},
					],
					"npcs": [
						{"name": "GuardiaoWoble", "pos": Vector2(350, -55), "npc": "Guarda de Woble", "fala": "Kurapika ativa Emperor Time. Proteja o bebê.", "ids": ["npc_viajante_scout"]},
					],
				},
				{
					"id": "conves3",
					"placa": "PlacaDistritoConves3",
					"pos": Vector2(1500, -100),
					"text": "📍 Distrito Convés 3 — Máfia Kakin (secundária)",
					"warp_name": "WarpConves3",
					"warp_pos": Vector2(1300, 60),
					"warp_target": Vector2(3600, 60),
					"warp_label": "Atalho → Porão",
					"fillers": [
						{"name": "AssassinoHeillyAmbient", "pos": Vector2(1700, 25), "id": "assassino_heilly", "label": "Assassino Heil-Ly"},
					],
					"npcs": [
						{"name": "InformanteXiYu", "pos": Vector2(1600, -55), "npc": "Informante Xi-Yu", "fala": "Heil-Ly move cadáveres. Xi-Yu move informação.", "ids": ["npc_viajante_scout"]},
					],
				},
				{
					"id": "aposentos",
					"placa": "PlacaDistritoAposentos",
					"pos": Vector2(2700, -100),
					"text": "📍 Distrito Aposentos Tserriednich (secundária)",
					"warp_name": "WarpAposentos",
					"warp_pos": Vector2(2500, 60),
					"warp_target": Vector2(200, 60),
					"warp_label": "Atalho → Convés 1",
					"fillers": [
						{"name": "BestaTserAmbient", "pos": Vector2(2900, 20), "id": "besta_tserriednich", "label": "Besta do Príncipe"},
					],
					"npcs": [
						{"name": "ServoPrincipe", "pos": Vector2(2750, -55), "npc": "Servo do Príncipe", "fala": "Tserriednich vê o futuro. Não erre o primeiro golpe.", "ids": ["npc_viajante_scout"]},
					],
				},
				{
					"id": "porao",
					"placa": "PlacaDistritoPorao",
					"pos": Vector2(3700, -100),
					"text": "📍 Distrito Conveses Profundos — Trupe vs Hisoka",
					"warp_name": "WarpPorao",
					"warp_pos": Vector2(3600, 60),
					"warp_target": Vector2(1500, 60),
					"warp_label": "Atalho → Convés 3",
					"fillers": [
						{"name": "CapangaMafiaAmbient", "pos": Vector2(3850, 25), "id": "assassino_mafia", "label": "Capanga da Máfia"},
					],
					"npcs": [
						{"name": "ObservadorTrupe", "pos": Vector2(3750, -50), "npc": "Observador", "fala": "Chrollo e Hisoka estão no mesmo navio. O porão vai sangrar.", "ids": ["npc_viajante_scout"]},
					],
				},
			]
		_:
			return []


static func _spawn_placard(mapa: Node2D, d: Dictionary) -> void:
	var n := str(d.get("placa", ""))
	if n.is_empty() or mapa.get_node_or_null(n) != null:
		return
	var marker := Node2D.new()
	marker.name = n
	marker.position = d.get("pos", Vector2.ZERO)
	var lbl := Label.new()
	lbl.text = str(d.get("text", ""))
	lbl.position = Vector2(-100, -10)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 5)
	lbl.add_theme_color_override("font_color", Color(0.85, 0.95, 0.55, 0.95))
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	marker.add_child(lbl)
	mapa.add_child(marker)


static func _spawn_fillers(mapa: Node2D, fillers: Array) -> void:
	var scn = load(ENEMY_SCENE)
	if scn == null:
		return
	for f in fillers:
		if typeof(f) != TYPE_DICTIONARY:
			continue
		var n := str(f.get("name", ""))
		if n.is_empty() or mapa.get_node_or_null(n) != null:
			continue
		var mob = scn.instantiate()
		mob.name = n
		mob.position = f.get("pos", Vector2.ZERO)
		mob.add_to_group("enemy")
		mob.add_to_group("enemies")
		var es = mob.get_node_or_null("EnemySystem")
		if es != null:
			if "is_mission_enemy" in es:
				es.is_mission_enemy = false
			if "enemy_id" in es:
				es.enemy_id = StringName(str(f.get("id", "inimigo_ambient")))
			if "enemy_name" in es:
				es.enemy_name = str(f.get("label", "Inimigo Ambient"))
		mapa.add_child(mob)


static func _spawn_ambient_npcs(mapa: Node2D, npcs: Array) -> void:
	var scn = load(NPC_SCENE)
	if scn == null:
		return
	for a in npcs:
		if typeof(a) != TYPE_DICTIONARY:
			continue
		var n := str(a.get("name", ""))
		if n.is_empty() or mapa.get_node_or_null(n) != null:
			continue
		var npc = scn.instantiate()
		npc.name = n
		npc.position = a.get("pos", Vector2.ZERO)
		npc.npc_name = str(a.get("npc", n))
		npc.fala_padrao = str(a.get("fala", ""))
		NpcSpriteBinder.aplicar(npc, a.get("ids", ["npc_viajante_scout"]))
		var living := LivingNPCBehavior.new()
		living.name = "LivingNPCBehavior"
		living.npc_nome = str(a.get("npc", n))
		living.tipo_marcador = "ambient"
		living.hierarchy = LivingNPCBehavior.NPCHierarchy.COMMON
		living.raio_patrulha = 48.0
		npc.add_child(living)
		mapa.add_child(npc)


static func _spawn_warp(mapa: Node2D, d: Dictionary) -> void:
	var n := str(d.get("warp_name", ""))
	if n.is_empty() or mapa.get_node_or_null(n) != null:
		return
	var warp := Area2D.new()
	warp.name = n
	warp.position = d.get("warp_pos", Vector2.ZERO)
	warp.collision_layer = 0
	warp.collision_mask = 1
	warp.monitoring = true
	warp.monitorable = false
	var col := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(40, 56)
	col.shape = box
	warp.add_child(col)
	var lbl := Label.new()
	lbl.text = "⏩ %s" % str(d.get("warp_label", "Atalho"))
	lbl.position = Vector2(-50, -36)
	lbl.add_theme_font_size_override("font_size", 5)
	lbl.add_theme_color_override("font_color", Color(0.55, 0.9, 1.0, 0.95))
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	warp.add_child(lbl)
	var target: Vector2 = d.get("warp_target", Vector2.ZERO)
	warp.set_meta("warp_target", target)
	warp.body_entered.connect(func(body: Node):
		if body == null or not body.is_in_group("player"):
			return
		if body.has_method("set_global_position"):
			body.global_position = target
		elif "global_position" in body:
			body.global_position = target
		var hud = mapa.get_tree().get_first_node_in_group("player_hud")
		if hud != null and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("⏩ Zona secundária: %s" % str(d.get("warp_label", "")))
	)
	mapa.add_child(warp)


static func _spawn_nen_sensors_for_saga(mapa: Node2D, saga_id: int) -> void:
	if mapa == null:
		return
	match saga_id:
		1:
			if PlayerData != null and PlayerData.despertou_nen:
				NenSensorFactory.criar_gyo(
					mapa, "GyoPistaTunelAura", Vector2(800, -20),
					&"exame_tunel_aura", "Aura de Sabotadores",
					"Resíduos de intenções hostis no túnel — candidatos desonestos.",
					"Intensificação", 1, Color(0.95, 0.7, 0.35, 0.9)
				)
				NenSensorFactory.criar_gyo(
					mapa, "GyoPistaPantanalHisoka", Vector2(2500, 20),
					&"exame_pantanal_hisoka", "Sede de Sangue no Nevoeiro",
					"Uma presença brinca com cartas no nevoeiro.",
					"Especialização", 2, Color(1.0, 0.35, 0.45, 0.9)
				)
				NenSensorFactory.criar_ko(
					mapa, "KoPedraGourmet", Vector2(4600, 30),
					"Pedra Selada Gourmet", &"pocao_aura"
				)
			NenSensorFactory.criar_zetsu(
				mapa, "ZetsuArbustoPantanal", Vector2(2200, -80),
				&"exame_arbusto_pantanal", "Arbusto do Nevoeiro",
				Vector2(150, 100), &"macaco_pantano", "Macaco Alertado"
			)
			NenSensorFactory.criar_zetsu(
				mapa, "ZetsuTrilhaGourmet", Vector2(4800, 80),
				&"exame_trilha_gourmet", "Trilha dos Javalis",
				Vector2(160, 110), &"javali_gourmet", "Javali Alertado"
			)
		5:
			if PlayerData != null and PlayerData.despertou_nen:
				NenSensorFactory.criar_gyo(
					mapa, "GyoPistaSoufrabiRazor", Vector2(2700, -30),
					&"greed_soufrabi_razor", "Pressão de Razor",
					"Aura densa do Game Master — a queimada começa aqui.",
					"Emissão", 2, Color(1.0, 0.4, 0.3, 0.9)
				)
			NenSensorFactory.criar_zetsu(
				mapa, "ZetsuDesfiladeiro", Vector2(1600, -70),
				&"greed_desfiladeiro", "Pedregulho Vigia",
				Vector2(140, 100), &"golem_pedra", "Golem Alertado"
			)
		6:
			if PlayerData != null and PlayerData.despertou_nen:
				NenSensorFactory.criar_gyo(
					mapa, "GyoPistaPalacioMeruem", Vector2(3000, -40),
					&"ngl_palacio_meruem", "Aura do Rei",
					"Pressão absoluta. Meruem está perto.",
					"Especialização", 3, Color(0.4, 1.0, 0.55, 0.9)
				)
			NenSensorFactory.criar_zetsu(
				mapa, "ZetsuFabricaFormiga", Vector2(1500, 70),
				&"ngl_fabrica_formiga", "Tubulação Contaminada",
				Vector2(150, 100), &"formiga_soldado", "Formiga Alertada"
			)
		_:
			pass
