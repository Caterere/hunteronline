extends CanvasLayer

# ============================================================
# SHIM LEGADO — PortalHunterUI (REMOVIDO)
# ============================================================
#
# A UI de seleção de saga/dificuldade foi descontinuada.
# Qualquer código antigo que ainda instancia esta cena/script
# é redirecionado imediatamente para o checkpoint da missão atual.
# ============================================================


func _ready() -> void:
	layer = 30
	name = "PortalHunterUI"
	print("[PortalHunterUI] UI legado bloqueada — despachando para missão atual.")
	call_deferred("_redirigir_para_missao_atual")


func _redirigir_para_missao_atual() -> void:
	if EventBus != null and EventBus.has_method("emit_toast"):
		EventBus.emit_toast("🚩 Portal atualizado: indo à sua missão atual (sem escolher dificuldade).", Color(0.3, 0.9, 1.0))

	if StoryManager != null and StoryManager.has_method("continuar_do_checkpoint"):
		StoryManager.continuar_do_checkpoint(get_tree())
	queue_free()
