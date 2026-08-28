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


func describe() -> String:

	match type:

		Type.KILL:
			var nome_inimigo := str(enemy_type)
			if nome_inimigo.is_empty() or nome_inimigo == "any" or nome_inimigo == "inimigo" or nome_inimigo == "monstro":
				return "⚔️ Derrote Criaturas / Inimigos da Área"
			return "⚔️ Derrote %s" % nome_inimigo.replace("_", " ").capitalize()

		Type.COLLECT:
			return "🎒 Colete %s" % str(item_id).replace("_", " ").capitalize()

		Type.CRAFT:
			return "🔨 Forje/Crie %s" % str(item_id).replace("_", " ").capitalize()

		Type.VISIT:
			if target_npc_name.is_empty():
				return "💬 Converse com o NPC"

			return "💬 Fale com %s" % target_npc_name

		Type.INVESTIGATE:
			return "🔍 [GYO] Investigue a pista '%s'" % str(target_clue_id).replace("_", " ").capitalize()

		Type.STEALTH_PASS:
			return "🥷 [ZETSU] Atravesse a zona '%s' furtivamente" % str(target_zone_id).replace("_", " ").capitalize()

		Type.PERSUASION:
			return "🤝 Convença / Negocie com %s" % (target_npc_name if not target_npc_name.is_empty() else str(target_npc_id).capitalize())

	return "Objetivo da Missão"
