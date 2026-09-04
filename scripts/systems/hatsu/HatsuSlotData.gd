class_name HatsuSlotData
extends RefCounted

# ============================================================
# HUNTER ONLINE — HATSU SLOT DATA (DATA-DRIVEN PROGRESSION)
# ============================================================
#
# Define as regras de um slot de Hatsu no sistema de progressão.
# Os slots representam a evolução narrativa e o domínio espiritual
# do personagem, com dependência obrigatória em cadeia (Anti-Bypass).
#
# ============================================================

enum SlotState {
	LOCKED = 0,     # Requisitos não atendidos
	AVAILABLE = 1,  # Requisitos atendidos, pronto para desbloqueio
	UNLOCKED = 2,   # Desbloqueado e disponível (vazio)
	EQUIPPED = 3    # Desbloqueado e com Hatsu alocado
}

var slot_id: int = 1
var display_name: String = "Hatsu Slot 1"
var description: String = ""
var required_level: int = 0
var required_slot_id: int = 0
var required_saga_id: int = 0
var required_story_flag: String = ""

func _init(
	p_slot_id: int = 1,
	p_display_name: String = "",
	p_description: String = "",
	p_req_level: int = 0,
	p_req_slot: int = 0,
	p_req_saga: int = 0,
	p_req_flag: String = ""
) -> void:
	slot_id = p_slot_id
	display_name = p_display_name if not p_display_name.is_empty() else ("Hatsu Slot %d" % p_slot_id)
	description = p_description
	required_level = p_req_level
	required_slot_id = p_req_slot
	required_saga_id = p_req_saga
	required_story_flag = p_req_flag
