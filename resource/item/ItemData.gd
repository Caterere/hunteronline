class_name ItemData
extends Resource

# ============================================================
# HUNTER ONLINE - ITEM DATA RESOURCE
# ============================================================
#
# Define itens do inventário (Licença Hunter, Plaquetas, Cartas GI, Poções).
#
# ============================================================

enum TipoItem {
	CHAVE,        # Licença Hunter, Chaves de Portais
	QUEST,        # Plaquetas de Número, Ingredientes
	CARTA_GI,     # Cartas de Greed Island (Nº 0 a 99)
	CONSUMAVEL,   # Poções, Elixires
	EQUIPAMENTO   # Amuletos, Armas
}

@export var item_id: StringName = &""
@export var nome_item: String = "Item"
@export var tipo: TipoItem = TipoItem.CONSUMAVEL
@export_multiline var descricao: String = ""
@export var icone_texture: Texture2D = null
@export var raridade: String = "Comum"
@export var preco_compra: int = 100
@export var preco_venda: int = 50
@export var acumulavel: bool = true
