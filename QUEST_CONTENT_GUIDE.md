# GUIA DE CONTEÚDO DE QUESTS — QUEST CONTENT GUIDE

> **Manual de Criação de Missões Principais, Secundárias, Surpresas e Gating Narrativo**
> **Versão:** 1.0 (Fase L) | **Engine:** Godot 4.6 Stable

---

## 1. TIPOS DE QUESTS NO HUNTER MMORPG

O jogo divide missões em quatro grandes verticais:
1. **Missões Principais de Saga (main_quest_id):** Amarradas a um ChapterDefinition. Conduzem a espinha dorsal narrativa de cada saga.
2. **Missões Secundárias (side_quest_ids):** Opcionais, enriquecem o folclore da região e desbloqueiam itens e reputação com guildas locais.
3. **Quests Surpresas & Rumores (SurpriseQuestSystem):** Acionadas sem aviso prévio por exploração de pistas, tempo ou clima.
4. **Bounties & Caçadas de Procurados (BountySystem):** Contratos de eliminação com rankings (E até S).

---

## 2. CONFIGURANDO MISSÕES EM CAPÍTULOS DE SAGA

Dentro de um ChapterDefinition:
`gdscript
var cap := ChapterDefinition.new(
    1,
     Capítulo 1: O Resgate do Expedicionário,
    Localize os batedores desaparecidos na floresta profunda.,
    quest_selva_principal_1
)

# Missões secundárias ligadas ao capítulo
cap.side_quest_ids = [
    quest_selva_recolher_ervas,
    quest_selva_eliminar_lobos
]

# Gating para liberar a quest
cap.gating_requirements = [
    {type: level, value: 25},
    {type: npc_met, value: guia_moro}
]

# Recompensas
cap.rewards = {
    xp: 3500,
    gold: 6000,
    items: [bussola_antiga]
}
`

---

## 3. O QUE ESTÁ IMPLEMENTADO

* **ChapterDefinition Gating Integrado:** StoryGatingEvaluator impede início de missões sem os pré-requisitos morais, temporais ou de nível.
* **Persistência de Estados em PlayerData.quest_states:** Rastreamento universal dos estados (0: Inativa, 1: Ativa, 2: Requisitos prontos, 3: Concluída).
* **Quests Cooperativas:** Membros da mesma party sincronizam o progresso de abates e coleta de itens no mesmo mapa.
* **Consequências Mundiais:** Conclusão de capítulos pode alternar world flags que modificam spawns de monstros e presença de NPCs.

---

## 4. O QUE ESTÁ PLANEJADO

1. **Missões com Tempo Limite Real:** Caçadas que falham caso o jogador não conclua dentro de um número fixo de horas do jogo.
2. **Quests com Consequências Morais Excludentes:** Ajudar a guilda de contrabandistas bloqueando definitivamente a cadeia de missões da polícia local.
3. **Marcadores de Bússola Imersivos:** Indicadores visuais na borda da tela substituindo minimapas intrusivos para reforçar a imersão de caçada.

---

## 5. O QUE É FUTURO

1. **Quests Geradas Dinamicamente por Facções em Guerra:** Guerras territoriais no endgame gerando missões de ataque e defesa baseadas nas ações da comunidade.
2. **Santuários de Caçador com Provas Rituais:** Missões secretas encontradas em ruínas isoladas exigindo uso coordenado de técnicas de Nen (Gyo, In, Ryu).
