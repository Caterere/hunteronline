extends Node

# ============================================================
# HUNTER ONLINE - GAME STATE COMPATIBILITY WRAPPER
# ============================================================
#
# Encaminha chamadas transparentemente para SaveManager unificado,
# garantindo compatibilidade total sem duplicação de dados.
#
# ============================================================

signal jogo_salvo(slot: int)
signal jogo_carregado(slot: int)

func _ready() -> void:
	if SaveManager != null:
		if not SaveManager.jogo_salvo.is_connected(_on_save_manager_jogo_salvo):
			SaveManager.jogo_salvo.connect(_on_save_manager_jogo_salvo)
		if not SaveManager.jogo_carregado.is_connected(_on_save_manager_jogo_carregado):
			SaveManager.jogo_carregado.connect(_on_save_manager_jogo_carregado)

func _on_save_manager_jogo_salvo(slot: int) -> void:
	jogo_salvo.emit(slot)

func _on_save_manager_jogo_carregado(slot: int) -> void:
	jogo_carregado.emit(slot)

func obter_caminho_slot(slot: int) -> String:
	return SaveManager.obter_caminho_slot(slot)

func existe_save_no_slot(slot: int) -> bool:
	return SaveManager.existe_save_no_slot(slot)

func obter_resumo_slot(slot: int) -> Dictionary:
	return SaveManager.obter_resumo_slot(slot)

func salvar_jogo(slot: int = -1) -> bool:
	return SaveManager.salvar_jogo(slot)

func carregar_jogo(slot: int) -> bool:
	return SaveManager.carregar_jogo(slot)

func deletar_save(slot: int) -> void:
	SaveManager.deletar_save(slot)

func novo_jogo(slot: int = 1) -> void:
	SaveManager.novo_jogo(slot)
