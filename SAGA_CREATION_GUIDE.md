# GUIA DE CRIAÇÃO DE SAGAS — SAGA CREATION GUIDE

> **Manual de Criação e Integração de Novas Sagas e Capítulos no Hunter MMORPG**
> **Versão:** 1.0 (Fase L) | **Engine:** Godot 4.6 Stable

---

## 1. ESTRUTURA DE UMA SAGA

Novas histórias são criadas definindo instâncias do recurso SagaDefinition (es://resource/saga/SagaDefinition.gd) contendo um array de recursos ChapterDefinition (es://resource/saga/ChapterDefinition.gd).

### 1.1 Exemplo de Construção em GDScript:
`gdscript
var saga := SagaDefinition.new(
    & saga_expedicao_selva,  # saga_id
    10,                       # order_index (Ordem narrativa)
    Expedição à Selva,      # display_name
    Uma jornada perigosa..., # synopsis
    Vector2i(25, 60)          # recommended_level (Min, Max)
)
saga.difficulty = 2 # 1: Iniciante, 2: Intermediário, 3: Pro, 4: Calamidade
saga.is_canonical = false
saga.flags = [&story, &coop, &live_content]
saga.regions = [selva_misteriosa]
saga.bosses = [gorila_rei_nen]

# Criação de Capítulo
var cap1 := ChapterDefinition.new(
    1,                        # chapter_index
    Capítulo 1: O Pouso,    # title
    Estabeleça o posto.,    # synopsis
    quest_selva_etapa_1     # main_quest_id
)
cap1.gating_requirements = [
    {type: level, value: 25},
    {type: quest_completed, value: exame_hunter_final}
]
cap1.rewards = {xp: 3000, gold: 5000}
saga.add_chapter(cap1)

# Registro no StoryManager
StoryManager.registrar_saga_definition(saga)
`

---

## 2. REGRAS DE GATING DE CAPÍTULOS

O StoryGatingEvaluator suporta as seguintes condições declarativas no array gating_requirements:
* {type: level, value: 30} — Nível mínimo do jogador.
* {type: quest_completed, value: quest_id} — Conclusão de missão prévia.
* {type: npc_met, value: kane} — NPC encontrado pelo menos 1 vez.
* {type: reputation, faction: associacao, min_value: 100} — Reputação mínima.
* {type: has_item, item_id: licenca_hunter, quantity: 1} — Posse de item no inventário.
* {type: hatsu_unlocked} / {type: nen_awakened} — Status do sistema Nen.
* {type: narrative_choice, choice_id: dilema, expected_value: poupar} — Escolhas morais prévias.
* {type: world_flag, flag: portal_aberto, expected_value: true} — Estado dinâmico do mundo.
* {type: boss_defeated, boss_id: gorila_rei_nen} — Abate de chefe.

---

## 3. O QUE ESTÁ IMPLEMENTADO

* **SagaDefinition & ChapterDefinition:** Modelagem completa de metadados, recompensas, flags e gating.
* **Serialização Completa (	o_dict / rom_dict):** Exportação e restauração limpa em formato JSON e .tres.
* **Registro Dinâmico no StoryManager:** Injeção runtime via egistrar_saga_definition sem reescrever arcos canônicos.
* **Gating Multicritério:** Suporte a 12 tipos diferentes de validação de progresso narrativo.
* **Test Saga Builder (es://data/sagas/saga_expedicao_selva/TestSagaBuilder.gd):** Saga completa funcional servindo como modelo canônico de expansão.

---

## 4. O QUE ESTÁ PLANEJADO

1. **Ramos Narrativos Alternativos (Branching Chapters):** Suporte nativo a múltiplos ramos de capítulos (ex: Capítulo 2A vs Capítulo 2B dependendo da escolha no Capítulo 1).
2. **Sagas Exclusivas Co-op / Raid:** Sagas com travas para grupos mínimos de 2 a 4 jogadores conectados.
3. **Cutscenes Dinâmicas com Atores Locais:** Gatilhos automáticos para cutscenes in-engine usando puppets dos jogadores da party.

---

## 5. O QUE É FUTURO

1. **Geração Procedural de Mini-Sagas (Bounties Narrativos):** Arcos secundários gerados dinamicamente com base no perfil de reputação do jogador.
2. **Cross-Saga World Impact:** Decisões na Saga A alterando a disposição das facções na Saga C meses depois.
