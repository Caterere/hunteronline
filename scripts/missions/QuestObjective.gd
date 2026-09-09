class_name QuestObjective
extends Resource


enum Type {
	KILL,
	COLLECT,
	CRAFT,
	VISIT,
	INVESTIGATE,
	STEALTH_PASS,
	PERSUASION
}


@export var type: Type = Type.VISIT


@export_group("Kill")

@export var enemy_type: StringName = &""


@export_group("Item")

@export var item_id: StringName = &""
@export var required_amount: int = 1


@export_group("NPC")

@export var target_npc_id: StringName = &""
@export var target_npc_name: String = ""


@export_group("Investigation / Stealth")

@export var target_clue_id: StringName = &""
@export var target_zone_id: StringName = &""


@export_group("Condições & Opcionalidade")

@export var is_optional: bool = false
@export var conditions: Array[GameplayCondition] = []


func avaliar_condicoes(contexto: Dictionary) -> bool:
	if conditions.is_empty():
		return true
	for cond in conditions:
		if cond != null and not cond.evaluate(contexto):
			return false
	return true


func describe() -> String:
	var desc_base: String = ""
	match type:

		Type.KILL:
			var nome_inimigo := str(enemy_type)
			if nome_inimigo.is_empty() or nome_inimigo == "any" or nome_inimigo == "inimigo" or nome_inimigo == "monstro":
				desc_base = "⚔️ Derrote Criaturas / Inimigos da Área"
			else:
				desc_base = "⚔️ Derrote %s" % nome_inimigo.replace("_", " ").capitalize()

		Type.COLLECT:
			desc_base = "🎒 Colete %s" % str(item_id).replace("_", " ").capitalize()

		Type.CRAFT:
			desc_base = "🔨 Forje/Crie %s" % str(item_id).replace("_", " ").capitalize()

		Type.VISIT:
			if target_npc_name.is_empty():
				desc_base = "💬 Converse com o NPC"
			else:
				desc_base = "💬 Fale com %s" % target_npc_name

		Type.INVESTIGATE:
			desc_base = "🔍 [GYO] Investigue a pista '%s'" % str(target_clue_id).replace("_", " ").capitalize()

		Type.STEALTH_PASS:
			desc_base = "🥷 [ZETSU] Atravesse a zona '%s' furtivamente" % str(target_zone_id).replace("_", " ").capitalize()

		Type.PERSUASION:
			desc_base = "🤝 Convença / Negocie com %s" % (target_npc_name if not target_npc_name.is_empty() else str(target_npc_id).capitalize())

		_:
			desc_base = "Objetivo da Missão"

	if is_optional:
		return "⭐ [OPCIONAL] " + desc_base
	return desc_base
