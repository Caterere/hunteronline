class_name ContentDebugOverlay
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - CONTENT DEBUG OVERLAY
# ============================================================
#
# Painel de métricas em tempo real e visualizador de entidades:
# - Exibe Zona de Risco atual, contagens ativas e distâncias
# - Suporta marcadores visuais no mapa com código de cores
#   (🔵 NPC, 🔴 PvE, 🟡 Evento, 🟢 POI)
#
# ============================================================

@onready var lbl_zone: Label = get_node_or_null("%LblZone")
@onready var lbl_counts: Label = get_node_or_null("%LblCounts")
@onready var lbl_distances: Label = get_node_or_null("%LblDistances")
@onready var lbl_next_event: Label = get_node_or_null("%LblNextEvent")
@onready var chk_markers: CheckBox = get_node_or_null("%ChkMarkers")

@export var director_node: Node2D = null

var show_markers: bool = true


func _ready() -> void:
	if director_node == null:
		director_node = get_tree().get_first_node_in_group("content_director") as Node2D
		
	if chk_markers != null:
		chk_markers.button_pressed = show_markers
		chk_markers.toggled.connect(func(val): show_markers = val)


func _process(_delta: float) -> void:
	if director_node == null:
		director_node = get_tree().get_first_node_in_group("content_director") as Node2D
		return
		
	if not director_node.has_method("get_debug_metrics"):
		return
		
	var m = director_node.get_debug_metrics()
	
	if lbl_zone:
		lbl_zone.text = "📍 Zona: " + str(m.get("zone_name", "Desconhecida"))
		
	if lbl_counts:
		lbl_counts.text = "🔵 NPCs: %d  |  🔴 PvE: %d  |  🟡 Eventos: %d  |  ✨ Encontros: %d  |  🟢 POIs: %d" % [
			m.get("active_npcs", 0),
			m.get("active_enemies", 0),
			m.get("active_events", 0),
			m.get("active_encounters", 0),
			m.get("registered_pois", 0)
		]
		
	if lbl_distances:
		lbl_distances.text = "📏 Distância Total: %.0f px (~%d tiles)\n⏱️ Dist. Último Evento: %.0f px  |  Média Encontros: %.0f px" % [
			m.get("distance_travelled", 0.0),
			int(m.get("distance_travelled", 0.0) / 16.0),
			m.get("distance_since_last_event", 0.0),
			m.get("average_encounter_distance", 0.0)
		]
		
	if lbl_next_event:
		lbl_next_event.text = "🎯 Próximo Evento Estimado em: ~%.0f px (~%d tiles)" % [
			m.get("next_event_distance_estimate", 0.0),
			int(m.get("next_event_distance_estimate", 0.0) / 16.0)
		]
