class_name CompanionChatter
extends Node

# ============================================================
# HUNTER ONLINE — Companion chatter (arcos longos / mid-late)
# ============================================================
# Comentários leves de Gon / Killua / Kurapika / Leorio ao
# cruzar marcos X no mapa. Sem UI nova — toast + opcional HUD.
# ============================================================

@export var saga_id: int = 4
## Anti toast-spam: intervalo maior nos arcos mid (intensidade > ruído)
@export var intervalo_minimo_s: float = 22.0

var _ultimo_toast_s: float = -999.0
var _falas_ja: Dictionary = {}
var _marcos: Array[Dictionary] = []


func _ready() -> void:
	add_to_group("companion_chatter")
	_marcos = _catalogo_para_saga(saga_id)
	set_process(true)


func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var agora: float = Time.get_ticks_msec() / 1000.0
	if agora - _ultimo_toast_s < intervalo_minimo_s:
		return
	var px: float = player.global_position.x
	for m in _marcos:
		var mid: String = str(m.get("id", ""))
		if mid.is_empty() or bool(_falas_ja.get(mid, false)):
			continue
		var x_min: float = float(m.get("x_min", -99999.0))
		var x_max: float = float(m.get("x_max", 99999.0))
		if px < x_min or px > x_max:
			continue
		_falas_ja[mid] = true
		_ultimo_toast_s = agora
		_emitir(str(m.get("speaker", "Companheiro")), str(m.get("texto", "")))
		break


func _emitir(speaker: String, texto: String) -> void:
	if texto.is_empty():
		return
	var msg := "%s: %s" % [speaker, texto]
	if EventBus != null:
		EventBus.emit_toast(msg, Color(0.85, 0.95, 0.7))
	var hud = get_tree().get_first_node_in_group("player_hud")
	if hud != null and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao(msg)


static func _catalogo_para_saga(saga: int) -> Array[Dictionary]:
	# Banter canônico — teclas/ORDEM ficam no GPS/HUD, não na boca do cast.
	match saga:
		2:
			return [
				{"id": "kuku_portao", "x_min": 0.0, "x_max": 500.0, "speaker": "Gon", "texto": "Esse portão… parece que respira. A gente sobe sem pressa."},
				{"id": "kuku_alameda", "x_min": 900.0, "x_max": 1600.0, "speaker": "Killua", "texto": "Mike escuta presença. Se for esconder, esconde de verdade."},
				{"id": "kuku_mansao", "x_min": 2200.0, "x_max": 2800.0, "speaker": "Gon", "texto": "Gotoh e as moedas. Eu confio no Killua — e nele em mim."},
			]
		3:
			return [
				{"id": "arena_recep", "x_min": 0.0, "x_max": 400.0, "speaker": "Killua", "texto": "Torre longa. Respira entre andares — bravata morre no 50º."},
				{"id": "arena_wing", "x_min": 900.0, "x_max": 1300.0, "speaker": "Gon", "texto": "Wing e a água… eu quero ver o que a minha aura faz."},
				{"id": "arena_200", "x_min": 3200.0, "x_max": 3800.0, "speaker": "Killua", "texto": "200º. Hisoka. Se o ar pesar, sai do golpe — eu cubro."},
			]
		4:
			return [
				{"id": "york_leilao", "x_min": 0.0, "x_max": 600.0, "speaker": "Leorio", "texto": "Leilão fedido a dinheiro. Olha com calma — pechincha cega sangra."},
				{"id": "york_ruas", "x_min": 1400.0, "x_max": 2000.0, "speaker": "Kurapika", "texto": "Avenida longa. A Aranha caça no silêncio entre as luzes."},
				{"id": "york_cem", "x_min": 2500.0, "x_max": 3100.0, "speaker": "Killua", "texto": "Cemitério. Battera depois. Sem rush — a Trupe odeia pressa alheia."},
				{"id": "york_trupe", "x_min": 3600.0, "x_max": 4300.0, "speaker": "Gon", "texto": "Aranhas. Eu fico com o Kurapika. Vocês ficam comigo."},
			]
		5:
			return [
				{"id": "gi_book", "x_min": 0.0, "x_max": 500.0, "speaker": "Gon", "texto": "Book na mão. Parece brincadeira… mas eu sinto peso de verdade."},
				{"id": "gi_biscuit", "x_min": 1300.0, "x_max": 1800.0, "speaker": "Killua", "texto": "Biscuit no desfiladeiro. Ko dói — e ela quer que doa."},
				{"id": "gi_soufrabi", "x_min": 2400.0, "x_max": 2900.0, "speaker": "Gon", "texto": "Porto Soufrabi. Razor… eu quero jogar limpo. E ganhar."},
			]
		6:
			return [
				{"id": "ngl_fronteira", "x_min": 0.0, "x_max": 800.0, "speaker": "Killua", "texto": "NGL. Formigas ouvem Ren. Quando eu sumir, some comigo."},
				{"id": "ngl_palacio", "x_min": 2800.0, "x_max": 3400.0, "speaker": "Gon", "texto": "Palácio. Um guarda de cada vez. Kite… espera."},
			]
		7:
			return [
				{"id": "assoc_sede", "x_min": 0.0, "x_max": 600.0, "speaker": "Leorio", "texto": "Sede. Voto e Alluka — sem misturar coração com política. Quase."},
			]
		8:
			return [
				{"id": "cn_entrada", "x_min": 0.0, "x_max": 700.0, "speaker": "Kurapika", "texto": "Continente Negro. Cada passo é contrato. Não corra do que assinou."},
			]
		9:
			return [
				{"id": "bw_convés", "x_min": 0.0, "x_max": 800.0, "speaker": "Kurapika", "texto": "Black Whale. Corredores longos — o que brilha demais mente."},
				{"id": "bw_pricipes", "x_min": 2400.0, "x_max": 3000.0, "speaker": "Killua", "texto": "Príncipes à frente. Se precisar sumir, some. Eu te acho."},
			]
		_:
			return []
