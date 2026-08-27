class_name AudioManagerClass
extends Node

# ============================================================
# HUNTER ONLINE — AUDIO & MUSIC MANAGER (AUTOLOAD SINGLETON)
# ============================================================
#
# Gerenciador global de áudio e trilhas sonoras oficiais de Hunter x Hunter.
# Recursos:
# - Crossfade suave e progressivo entre faixas com dois AudioStreamPlayers.
# - Rotação e seleção de músicas do início do anime para o Lobby e Menus.
# - Mapeamento canônico das OSTs para cada um dos 9 Arcos do Modo História.
# - Mapeamento temático e dramático para cada uma das 50 Missões Paralelas.
# - Troca dinâmica de música ao entrar na onda do Chefe (Boss).
# - Auto-detecção de transições de cena/mapas.
# - Controle independente de volume de Música, SFX e Master.
#
# ============================================================

signal musica_alterada(track_id: String, track_name: String)

var player_a: AudioStreamPlayer
var player_b: AudioStreamPlayer
var active_player_is_a: bool = true

var current_track_id: String = ""
var current_track_path: String = ""
var is_fading: bool = false
var fade_tween: Tween = null

var music_volume_linear: float = 0.85 # 0.0 a 1.0
var sfx_volume_linear: float = 1.0
var master_volume_linear: float = 1.0

var lobby_playlist_index: int = 0
var last_detected_scene_path: String = ""

# Dicionário de caminhos oficiais das faixas da pasta osts/
const TRACKS: Dictionary = {
	"the_world_of_adventurers": {
		"title": "The World of Adventurers",
		"path": "res://osts/The World of Adventurers (Kanzenban) - Yoshihisa Hirano.mp3"
	},
	"kujirato_yori": {
		"title": "Kujirato Yori (Ilha da Baleia)",
		"path": "res://osts/Kujirato Yori - Yoshihisa Hirano.mp3"
	},
	"no_no_haru": {
		"title": "No no Haru (Primavera no Campo)",
		"path": "res://osts/No no Haru - Yoshihisa Hirano.mp3"
	},
	"tomodachi_ni_narouyo": {
		"title": "Tomodachi ni Narouyo (Vamos Ser Amigos)",
		"path": "res://osts/Hunter x Hunter (2011) OST - Tomodachi ni Narouyo - Anime Content.mp3"
	},
	"hashire": {
		"title": "Hashire! (Corra!)",
		"path": "res://osts/Hashire! - Yoshihisa Hirano.mp3"
	},
	"ginpatsu_no_shonen": {
		"title": "Ginpatsu no Shonen (Tema de Killua)",
		"path": "res://osts/Ginpatsu no Shonen - Yoshihisa Hirano.mp3"
	},
	"legend_of_the_martial_artist": {
		"title": "Legend of the Martial Artist",
		"path": "res://osts/Legend of the Martial Artist - Yoshihisa Hirano.mp3"
	},
	"auras": {
		"title": "Auras (Despertar de Nen)",
		"path": "res://osts/[HQ] Hunter x Hunter (2011) OST 2 - Auras - GonDonOOO.mp3"
	},
	"requiem_aranea": {
		"title": "Requiem Aranea (Tema da Trupe)",
		"path": "res://osts/Requiem Aranea - Yoshihisa Hirano.mp3"
	},
	"lacrimosa": {
		"title": "Lacrimosa (Réquiem de Chrollo)",
		"path": "res://osts/Mozart - Lacrimosa - Rosa Music.mp3"
	},
	"hiiro_no_hitomi_no_aika": {
		"title": "Hiiro no Hitomi no Aika (Olhos Escarlates)",
		"path": "res://osts/Hiiro no Hitomi no Aika - Yoshihisa Hirano.mp3"
	},
	"dirge_from_dark_side": {
		"title": "Dirge from Dark Side (Submundo)",
		"path": "res://osts/Dirge from Dark Side - Yoshihisa Hirano.mp3"
	},
	"kinpatsu_no_gankou": {
		"title": "Kinpatsu no Gankou (Olhar do Jovem Loiro)",
		"path": "res://osts/[HQ] Hunter x Hunter (2011) OST 2 - Kinpatsu no Gankou - GonDonOOO.mp3"
	},
	"try_your_luck": {
		"title": "Try Your Luck (Greed Island)",
		"path": "res://osts/[HQ] Hunter x Hunter (2011) OST 2 - Try Your Luck - GonDonOOO.mp3"
	},
	"latent_power": {
		"title": "Latent Power (Poder Oculto)",
		"path": "res://osts/Latent Power - Yoshihisa Hirano.mp3"
	},
	"kingdom_of_predators": {
		"title": "Kingdom of Predators (Reino dos Predadores)",
		"path": "res://osts/Hunter x Hunter 2011 OST 3 - 1 - Kingdom of Predators - DMPlace.mp3"
	},
	"in_the_palace_agitato": {
		"title": "In the Palace (Agitato)",
		"path": "res://osts/In the Palace (Agitato) - Yoshihisa Hirano.mp3"
	},
	"in_the_palace_suite": {
		"title": "In the Palace (Lamentoso / Agitato)",
		"path": "res://osts/Hunter x Hunter OST  In The Palace~Lamentoso_In The Palace~Agitato - Ank Sun Amunn.mp3"
	},
	"riot": {
		"title": "Riot (Rebelião / Fúria de Batalha)",
		"path": "res://osts/Hunter X Hunter (2011) Ost 3 - Riot (Quality Extended) - ServerArchive.mp3"
	},
	"elegy_of_the_dynast": {
		"title": "Elegy of the Dynast",
		"path": "res://osts/Elegy of the Dynast - Yoshihisa Hirano.mp3"
	},
	"invaders": {
		"title": "Invaders (Invasores)",
		"path": "res://osts/Invaders - Yoshihisa Hirano.mp3"
	},
	"new_mutation": {
		"title": "New Mutation (Nova Mutação)",
		"path": "res://osts/New Mutation - Yoshihisa Hirano.mp3"
	},
	"scariness": {
		"title": "Scariness (Pavor Sinistro)",
		"path": "res://osts/Hunter x Hunter 2011 OST 3 - 19 - Scariness - DMPlace.mp3"
	},
	"restriction_and_pledge": {
		"title": "Restriction and Pledge (Juramento de Gon)",
		"path": "res://osts/Restriction And Pledge - Yoshihisa Hirano.mp3"
	},
	"nowhere_to_escape": {
		"title": "Nowhere to Escape (Sem Escapatória)",
		"path": "res://osts/Nowhere to Escape - Yoshihisa Hirano.mp3"
	},
	"concentration": {
		"title": "Concentration (Foco Estratégico)",
		"path": "res://osts/Concentration - Yoshihisa Hirano.mp3"
	},
	"the_last_mission": {
		"title": "The Last Mission (A Última Missão)",
		"path": "res://osts/The Last Mission - Yoshihisa Hirano.mp3"
	}
}

# Músicas calmas e nostálgicas do início do anime para o Lobby e Hub Central
const LOBBY_TRACKS: Array[String] = [
	"the_world_of_adventurers",
	"kujirato_yori",
	"no_no_haru",
	"tomodachi_ni_narouyo"
]

# Mapeamento oficial dos 9 Arcos do Modo História
const ARC_TRACKS: Dictionary = {
	1: "hashire",                      # Arco 1: Exame Hunter (Maratona)
	2: "ginpatsu_no_shonen",            # Arco 2: Montanha Kukuroo (Família Zoldyck)
	3: "legend_of_the_martial_artist",  # Arco 3: Arena Celestial (Heavens Arena)
	4: "requiem_aranea",                # Arco 4: Yorknew City (Trupe Fantasma)
	5: "try_your_luck",                 # Arco 5: Greed Island
	6: "kingdom_of_predators",          # Arco 6: Formigas Chimera
	7: "scariness",                     # Arco 7: Eleição Hunter (Illumi / Zodíacos)
	8: "concentration",                 # Arco 8: Continente Negro
	9: "the_last_mission"               # Arco 9: Black Whale 1 (Guerra de Sucessão)
}

# Mapeamento por Caminho de Cena
const SCENE_TRACKS: Dictionary = {
	"res://ui/CharacterSelection/CharacterSelectionUI.tscn": "the_world_of_adventurers",
	"res://ui/CharacterCreation/CharacterCreationUI.tscn": "tomodachi_ni_narouyo",
	"res://world/lobby.tscn": "the_world_of_adventurers",
	"res://world/maps/PlayerHouse.tscn": "kujirato_yori",
	"res://world/maps/CelestialTowerArena.tscn": "legend_of_the_martial_artist",
	"res://world/maps/exame_maratona.tscn": "hashire",
	"res://world/maps/montanha_kukuroo.tscn": "ginpatsu_no_shonen",
	"res://world/maps/arena_celestial.tscn": "legend_of_the_martial_artist",
	"res://world/maps/yorknew_city.tscn": "requiem_aranea",
	"res://world/maps/greed_island.tscn": "try_your_luck",
	"res://world/maps/ngl_formigas.tscn": "kingdom_of_predators",
	"res://world/maps/associacao_hunter.tscn": "scariness",
	"res://world/maps/continente_negro.tscn": "concentration",
	"res://world/maps/black_whale_1.tscn": "the_last_mission"
}

# Mapeamento Temático Específico das 50 Missões Paralelas (PQs)
const PARALLEL_QUEST_TRACKS: Dictionary = {
	# Tier 1: Exame Hunter & Kukuroo (1 a 10)
	1: "hashire",                      # PQ 01: O Duelo Real do Túnel (Gon & Killua)
	2: "scariness",                    # PQ 02: O Banquete Sombrio de Hisoka (Pantanal)
	3: "the_world_of_adventurers",     # PQ 03: A Fúria Gourmet de Menchi
	4: "dirge_from_dark_side",         # PQ 04: A Provação de Trick Tower (Johness)
	5: "hashire",                      # PQ 05: A Caçada de Placas na Ilha Zevil
	6: "ginpatsu_no_shonen",           # PQ 06: Invasão dos Mordomos Zoldyck
	7: "ginpatsu_no_shonen",           # PQ 07: O Desafio de Moedas de Gotoh
	8: "nowhere_to_escape",            # PQ 08: A Fúria Materna de Kikyo Zoldyck
	9: "the_world_of_adventurers",     # PQ 09: O Treino Pesado de Zebro (Portão de 4t)
	10: "ginpatsu_no_shonen",          # PQ 10: O Retorno de Canary e o Clã Meteor
	
	# Tier 2: Arena Celestial & Yorknew City (11 a 20)
	11: "legend_of_the_martial_artist", # PQ 11: O Teste dos 200 Andares
	12: "auras",                        # PQ 12: A Tempestade de Piões de Gido
	13: "legend_of_the_martial_artist", # PQ 13: O Duplo Perfeito de Kastro
	14: "legend_of_the_martial_artist", # PQ 14: A Provação dos Floor Masters
	15: "requiem_aranea",               # PQ 15: A Noite Carmesim da Trupe Fantasma
	16: "lacrimosa",                    # PQ 16: Zoldyck vs Chrollo Lucifer
	17: "dirge_from_dark_side",         # PQ 17: As Bestas Sombrias (Shadow Beasts)
	18: "requiem_aranea",               # PQ 18: A Vingança de Nobunaga & Machi
	19: "riot",                         # PQ 19: O Sol Incandescente de Feitan (Pain Packer)
	20: "hiiro_no_hitomi_no_aika",      # PQ 20: Kurapika vs Genei Ryodan (Chuva)
	
	# Tier 3: Greed Island & Formigas Chimera (21 a 35)
	21: "try_your_luck",                # PQ 21: O Jogo Mortal de Queimada de Razor
	22: "latent_power",                 # PQ 22: O Terror dos Bombardeiros de Genthru
	23: "latent_power",                 # PQ 23: A Provação da Mestra Biscuit Krueger
	24: "try_your_luck",                # PQ 24: O Torneio da Cidade do Amor: Aishy
	25: "the_world_of_adventurers",     # PQ 25: O Desafio dos 11 Criadores
	26: "invaders",                     # PQ 26: O Retorno dos Exterminadores de Chimera
	27: "riot",                         # PQ 27: A Fúria Devastadora de Menthuthuyoupi
	28: "in_the_palace_agitato",        # PQ 28: As Escamas Espirituais de Shaiapouf
	29: "in_the_palace_suite",          # PQ 29: Neferpitou (Terpsichora Sanguinária)
	30: "kingdom_of_predators",         # PQ 30: A Provação do Rei Supremo Meruem
	31: "elegy_of_the_dynast",          # PQ 31: O Desafio dos 100 Braços de Netero
	32: "restriction_and_pledge",       # PQ 32: O Despertar Furioso de Gon Adulto
	33: "riot",                         # PQ 33: A Fuga Elétrica de Killua Godspeed
	34: "invaders",                     # PQ 34: O Bloqueio de Fumaça de Morel & Knov
	35: "legend_of_the_martial_artist", # PQ 35: A Provação do Juros de APR de Knuckle
	
	# Tier 4: Eleição Hunter & Continente Negro (36 a 45)
	36: "scariness",                    # PQ 36: As Agulhas Sinistras de Illumi
	37: "concentration",                # PQ 37: A Revolta dos 12 Zodíacos
	38: "the_world_of_adventurers",     # PQ 38: O Golpe Remoto de Leorio
	39: "restriction_and_pledge",       # PQ 39: O Segredo de Nanika (Ai)
	40: "new_mutation",                 # PQ 40: As 5 Calamidades: A Besta Brion
	41: "scariness",                    # PQ 41: As 5 Calamidades: O Terror de Hellbell
	42: "dirge_from_dark_side",         # PQ 42: As 5 Calamidades: O Horror Imortal Zobae
	43: "new_mutation",                 # PQ 43: As 5 Calamidades: O Alimentador Papu
	44: "concentration",                # PQ 44: A Provação de Ging Freecss no Topo
	45: "the_last_mission",             # PQ 45: A Expedição de Beyond Netero
	
	# Tier 5: Guerra de Sucessão & Boss Rush (46 a 50)
	46: "dirge_from_dark_side",         # PQ 46: Noite de Sangue no Black Whale 1 (Morena)
	47: "the_last_mission",             # PQ 47: Julgamento de Benjamin e Camilla
	48: "nowhere_to_escape",            # PQ 48: O Santuário de Tserriednich
	49: "requiem_aranea",               # PQ 49: A Vingança da Trupe Fantasma
	50: "the_last_mission"              # PQ 50: O Boss Rush Supremo (Ápice dos Caçadores)
}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Inicializar os dois canais de áudio para crossfade suave
	player_a = AudioStreamPlayer.new()
	player_a.name = "MusicPlayer_A"
	player_a.bus = "Master"
	add_child(player_a)

	player_b = AudioStreamPlayer.new()
	player_b.name = "MusicPlayer_B"
	player_b.bus = "Master"
	add_child(player_b)
	
	player_a.finished.connect(_on_musica_finalizada)
	player_b.finished.connect(_on_musica_finalizada)
	
	print("[AudioManager] Inicializado com 28 faixas canônicas de Hunter x Hunter.")


func _process(_delta: float) -> void:
	# Monitorar troca de cena e disparar música correspondente automaticamente
	var cur_scene := get_tree().current_scene
	if cur_scene != null:
		var scene_path := cur_scene.scene_file_path
		if not scene_path.is_empty() and scene_path != last_detected_scene_path:
			last_detected_scene_path = scene_path
			_ao_mudar_cena_detectada(scene_path)


func _ao_mudar_cena_detectada(scene_path: String) -> void:
	print("[AudioManager] Nova cena detectada: ", scene_path)
	if scene_path == "res://world/maps/parallel_quest_arena.tscn":
		var pq_id = PlayerData.missao_paralela_ativa_id if PlayerData != null else 1
		tocar_musica_missao_paralela(pq_id)
	elif scene_path == "res://world/lobby.tscn":
		tocar_musica_lobby()
	elif SCENE_TRACKS.has(scene_path):
		tocar_musica(SCENE_TRACKS[scene_path])


# ============================================================
# API PÚBLICA DE REPRODUÇÃO MUSICAL
# ============================================================

func tocar_musica(id_ou_path: String, fade_duration: float = 1.0) -> void:
	var path: String = id_ou_path
	var track_key: String = id_ou_path
	
	if TRACKS.has(id_ou_path):
		path = TRACKS[id_ou_path]["path"]
		track_key = id_ou_path
	else:
		# Procurar por path reverso
		for k in TRACKS.keys():
			if TRACKS[k]["path"] == id_ou_path:
				track_key = k
				break

	# Se a música já está tocando no canal ativo, não reinicia
	var active_player: AudioStreamPlayer = player_a if active_player_is_a else player_b
	if current_track_path == path and active_player.playing:
		return

	var stream: AudioStream = _carregar_stream(path)
	if stream == null:
		push_warning("[AudioManager] Faixa não encontrada ou erro ao carregar: %s" % path)
		return

	current_track_id = track_key
	current_track_path = path
	
	var title = TRACKS.get(track_key, {}).get("title", track_key)
	print("[AudioManager] Tocando: [%s] (%s)" % [title, path])
	musica_alterada.emit(track_key, title)

	_executar_crossfade(stream, fade_duration)


func _carregar_stream(path: String) -> AudioStream:
	# 1. Tentar carregar via ResourceLoader (se o editor já gerou .import)
	if ResourceLoader.exists(path):
		var res = ResourceLoader.load(path)
		if res is AudioStream:
			return res

	# 2. Carregamento direto de arquivo MP3 via FileAccess e AudioStreamMP3 (robusto e universal)
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		if file != null:
			var mp3_stream := AudioStreamMP3.new()
			mp3_stream.data = file.get_buffer(file.get_length())
			mp3_stream.loop = true
			return mp3_stream

	return null


func tocar_musica_lobby() -> void:
	# Seleciona uma faixa nostálgica de início de jornada do anime
	var track_id = LOBBY_TRACKS[lobby_playlist_index % LOBBY_TRACKS.size()]
	lobby_playlist_index += 1
	tocar_musica(track_id, 1.2)


func tocar_musica_arco(arco: int) -> void:
	var track_id: String = ARC_TRACKS.get(arco, "the_world_of_adventurers")
	tocar_musica(track_id, 1.0)


func tocar_musica_missao_paralela(pq_id: int) -> void:
	var track_id: String = PARALLEL_QUEST_TRACKS.get(pq_id, "the_world_of_adventurers")
	tocar_musica(track_id, 0.8)


func tocar_musica_por_cena(scene_path: String) -> void:
	if SCENE_TRACKS.has(scene_path):
		tocar_musica(SCENE_TRACKS[scene_path], 1.0)
	elif scene_path == "res://world/lobby.tscn":
		tocar_musica_lobby()


func parar_musica(fade_duration: float = 1.0) -> void:
	var active_player: AudioStreamPlayer = player_a if active_player_is_a else player_b
	if not active_player.playing:
		return
		
	if fade_tween != null and fade_tween.is_valid():
		fade_tween.kill()
		
	fade_tween = create_tween()
	fade_tween.tween_property(active_player, "volume_db", -80.0, fade_duration)
	fade_tween.tween_callback(func():
		active_player.stop()
		current_track_id = ""
		current_track_path = ""
	)


func pausar_musica() -> void:
	var active_player: AudioStreamPlayer = player_a if active_player_is_a else player_b
	active_player.stream_paused = true


func retomar_musica() -> void:
	var active_player: AudioStreamPlayer = player_a if active_player_is_a else player_b
	active_player.stream_paused = false


func obter_nome_musica_atual() -> String:
	if TRACKS.has(current_track_id):
		return TRACKS[current_track_id]["title"]
	return current_track_id


# ============================================================
# SISTEMA DE CROSSFADE SUAVE
# ============================================================

func _executar_crossfade(novo_stream: AudioStream, fade_duration: float) -> void:
	var outgoing_player: AudioStreamPlayer = player_a if active_player_is_a else player_b
	var incoming_player: AudioStreamPlayer = player_b if active_player_is_a else player_a
	
	active_player_is_a = not active_player_is_a
	
	if fade_tween != null and fade_tween.is_valid():
		fade_tween.kill()

	var target_db: float = linear_to_db(clamp(music_volume_linear * master_volume_linear, 0.0001, 1.0))
	
	incoming_player.stream = novo_stream
	incoming_player.volume_db = -80.0
	incoming_player.play()
	
	fade_tween = create_tween()
	fade_tween.set_parallel(true)
	
	# Fade-in do novo canal
	fade_tween.tween_property(incoming_player, "volume_db", target_db, fade_duration)
	
	# Fade-out do canal anterior
	if outgoing_player.playing:
		fade_tween.tween_property(outgoing_player, "volume_db", -80.0, fade_duration)
		fade_tween.chain().tween_callback(func():
			if not is_instance_valid(outgoing_player):
				return
			outgoing_player.stop()
		)


func _on_musica_finalizada() -> void:
	# Se a música terminar, refaz o loop ou toca a próxima se estiver no lobby
	var active_player: AudioStreamPlayer = player_a if active_player_is_a else player_b
	if not active_player.playing:
		if get_tree().current_scene != null and get_tree().current_scene.scene_file_path == "res://world/lobby.tscn":
			tocar_musica_lobby()
		elif not current_track_path.is_empty():
			active_player.play()


# ============================================================
# CONTROLE DE VOLUME
# ============================================================

func definir_volume_musica(volume: float) -> void:
	music_volume_linear = clamp(volume, 0.0, 1.0)
	var active_player: AudioStreamPlayer = player_a if active_player_is_a else player_b
	if active_player.playing:
		active_player.volume_db = linear_to_db(clamp(music_volume_linear * master_volume_linear, 0.0001, 1.0))


func definir_volume_master(volume: float) -> void:
	master_volume_linear = clamp(volume, 0.0, 1.0)
	definir_volume_musica(music_volume_linear)


# ============================================================
# EFEITOS SONOROS (SFX)
# ============================================================

func tocar_sfx(stream: AudioStream, volume_scale: float = 1.0) -> void:
	if stream == null:
		return
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.volume_db = linear_to_db(clamp(sfx_volume_linear * master_volume_linear * volume_scale, 0.0001, 1.0))
	add_child(p)
	p.play()
	p.finished.connect(func(): p.queue_free())


func tocar_sfx_path(path: String, volume_scale: float = 1.0) -> void:
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is AudioStream:
			tocar_sfx(res, volume_scale)

