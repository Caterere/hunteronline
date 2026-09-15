class_name ItemExplainKit
extends RefCounted

# ============================================================
# HUNTER ONLINE — FORMATAÇÃO DE ITENS PARA O JOGADOR
# ============================================================
# Resolve ItemData via DataManager e monta texto legível
# (nome, tipo, stats, trade-off, lore) para inventário / tooltips.
# ============================================================

static func resolver_item(item_id: Variant) -> ItemData:
	if item_id == null:
		return null
	if DataManager == null:
		return null
	var res: Resource = DataManager.get_item(StringName(str(item_id)))
	if res is ItemData:
		return res as ItemData
	# Fallback: equipamento só no equipment_registry
	res = DataManager.get_equipment(StringName(str(item_id)))
	if res is ItemData:
		return res as ItemData
	return null


static func nome_exibicao(item_id: Variant, item: ItemData = null) -> String:
	if item != null and not item.nome_item.strip_edges().is_empty():
		return item.nome_item
	var raw := str(item_id)
	if raw.is_empty():
		return "Item Desconhecido"
	return raw.replace("_", " ").capitalize()


static func rotulo_tipo(item: ItemData) -> String:
	if item == null:
		return "Item"
	if item is EquipmentData:
		return "Equipamento"
	match int(item.tipo):
		ItemData.TipoItem.CHAVE:
			return "Chave / Licença"
		ItemData.TipoItem.QUEST:
			return "Missão / Relíquia"
		ItemData.TipoItem.CARTA_GI:
			return "Carta Greed Island"
		ItemData.TipoItem.CONSUMAVEL:
			return "Consumível"
		ItemData.TipoItem.EQUIPAMENTO:
			return "Equipamento"
		_:
			return "Item Especial"


static func formatar_stats_equipamento(item: ItemData) -> String:
	if item == null or not (item is EquipmentData):
		return ""
	var eq: EquipmentData = item as EquipmentData
	var linhas: PackedStringArray = []
	if eq.bonus_vida != 0:
		linhas.append("%s%d Vida" % ["+" if eq.bonus_vida > 0 else "", eq.bonus_vida])
	if eq.bonus_forca != 0:
		linhas.append("%s%d Força" % ["+" if eq.bonus_forca > 0 else "", eq.bonus_forca])
	if eq.bonus_defesa != 0:
		linhas.append("%s%d Defesa" % ["+" if eq.bonus_defesa > 0 else "", eq.bonus_defesa])
	if eq.bonus_velocidade != 0:
		linhas.append("%s%d Velocidade" % ["+" if eq.bonus_velocidade > 0 else "", eq.bonus_velocidade])
	if not is_zero_approx(eq.bonus_velocidade_pct):
		linhas.append("%+.0f%% Velocidade" % (eq.bonus_velocidade_pct * 100.0))
	if not is_zero_approx(eq.bonus_defesa_pct):
		linhas.append("%+.0f%% Defesa" % (eq.bonus_defesa_pct * 100.0))
	if not is_zero_approx(eq.bonus_dano_hatsu_pct):
		linhas.append("%+.0f%% Dano Hatsu" % (eq.bonus_dano_hatsu_pct * 100.0))
	if not is_zero_approx(eq.bonus_custo_aura_pct):
		linhas.append("%+.0f%% Custo de Aura" % (eq.bonus_custo_aura_pct * 100.0))
	if eq.nivel_upgrade > 0:
		linhas.append("Upgrade Nv.%d" % eq.nivel_upgrade)
	return " · ".join(linhas)


static func formatar_detalhes(item_id: Variant, quantidade: int = 1, item: ItemData = null) -> String:
	if item == null:
		item = resolver_item(item_id)
	var nome := nome_exibicao(item_id, item)
	var partes: PackedStringArray = []
	partes.append("📦 %s" % nome)
	partes.append("📊 Quantidade: %d" % max(0, quantidade))

	if item == null:
		partes.append("⚠️ Sem ficha registrada — item genérico do inventário.")
		partes.append("ID: %s" % str(item_id))
		return "\n".join(partes)

	partes.append("🏷️ %s · %s" % [rotulo_tipo(item), item.raridade if not item.raridade.is_empty() else "Comum"])
	if not item.descricao.strip_edges().is_empty():
		partes.append("—")
		partes.append(item.descricao.strip_edges())

	var stats := formatar_stats_equipamento(item)
	if not stats.is_empty():
		partes.append("—")
		partes.append("⚔️ STATS: %s" % stats)

	if item is EquipmentData:
		var eq: EquipmentData = item as EquipmentData
		if not eq.trade_off_descricao.strip_edges().is_empty():
			partes.append("⚖️ TRADE-OFF: %s" % eq.trade_off_descricao.strip_edges())

	if not item.lore_quote.strip_edges().is_empty():
		partes.append("—")
		partes.append("💬 %s" % item.lore_quote.strip_edges())
	if not item.lore_origin.strip_edges().is_empty():
		partes.append("📜 Origem: %s" % item.lore_origin.strip_edges())

	if item.preco_venda > 0 or item.preco_compra > 0:
		partes.append("💰 Compra %d · Venda %d Jenny" % [item.preco_compra, item.preco_venda])

	return "\n".join(partes)


static func rotulo_botao(item_id: Variant, quantidade: int, item: ItemData = null) -> String:
	if item == null:
		item = resolver_item(item_id)
	var nome := nome_exibicao(item_id, item)
	var curto := nome
	if curto.length() > 10:
		curto = curto.substr(0, 9) + "…"
	return "%s x%d" % [curto, quantidade]
