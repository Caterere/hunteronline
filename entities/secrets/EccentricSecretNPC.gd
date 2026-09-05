class_name EccentricSecretNPC
extends CharacterBody2D

# ============================================================
# HUNTER ONLINE - ECCENTRIC SECRET NPC (NÃO RASTREADO POR WAYPOINTS)
# ============================================================
#
# Entidade de exploração orgânica (Fase G — Epic 5):
# - Nunca gera waypoints ou marcadores na bússola do QuestTracker.
# - Oferece pistas enigmáticas sobre cavernas, runas de Gyo e bosses opcionais.
# - Reage a fragmentos de lore ou segredos que o jogador descobriu pelo mapa.
# ============================================================

signal dica_revelada(npc_id: String, texto_pista: String)

@export var eccentric_id: String = "eremita_das_ruinas"
@export var npc_nome: String = "Eremita Cego de Nen"
@export var pista_principal: String = "Aqueles que buscam poder devem olhar onde a água divide a rocha nas ruínas... Mas apenas olhos banhados em Gyo verão o caminho."
@export var recompensa_fragmento_item_id: String = "anel_explorador_ancestral"

var _ja_falou: bool = false
var _area_interacao: Area2D = null

func _ready() -> void:
	add_to_group("npc")
	add_to_group("secret_npc")
	_configurar_interacao()


func _configurar_interacao() -> void:
	_area_interacao = Area2D.new()
	_area_interacao.name = "InteractionArea"
	_area_interacao.collision_layer = 0
	_area_interacao.collision_mask = 2 # Player

	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 32.0
	col.shape = shape
	_area_interacao.add_child(col)
	add_child(_area_interacao)

	_area_interacao.body_entered.connect(_on_player_entered)


func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		falar()


func falar() -> void:
	var texto_fala: String = ""

	# Reação a fragmentos de lore antigos obtidos pelo jogador
	if PlayerData != null and PlayerData.tem_item(StringName("fragmento_lore_tabuleta")):
		texto_fala = "Hoho... Você carrega a Tabuleta Ancestral decifrada! Há decênios nenhum caçador compreendia a escrita dos mestres antigos."
		if not _ja_falou:
			_ja_falou = true
			if WorldState != null:
				WorldState.registrar_marco_historico("conheceu_" + eccentric_id, {
					"timestamp": Time.get_ticks_msec()
				})
			if not recompensa_fragmento_item_id.is_empty():
				PlayerData.adicionar_item(StringName(recompensa_fragmento_item_id), 1)
				if EventBus != null:
					EventBus.emit_toast("🎁 Presente do Eremita: Anel do Explorador Ancestral!", Color(0.3, 0.9, 1.0))
	elif _ja_falou:
		texto_fala = "Lembre-se: os maiores tesouros do mundo nunca estão marcados em mapas oficiais de governos ou sindicatos."
	else:
		_ja_falou = true
		texto_fala = pista_principal

	if ComicBalloon != null:
		ComicBalloon.mostrar(self, "🧙‍♂️ %s: \"%s\"" % [npc_nome, texto_fala], 4.5, -42.0)

	dica_revelada.emit(eccentric_id, texto_fala)
