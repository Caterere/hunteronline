# MISSION SYSTEM & MISSION INSTANCE
## HUNTER ONLINE — DATA-DRIVEN QUESTS & INSTANCED LIFECYCLE

### 1. Data-Driven Mission Architecture
As missões não são codificadas com `if mission_id == "hunter_exam_03"` espalhados em scripts de mapas. Toda missão é representada por recursos `MissionData` / `Quest` e `QuestObjective`:

```text
Quest / MissionData
 ├── id: StringName
 ├── quest_name: String
 ├── description: String
 ├── objectives: Array[QuestObjective]
 ├── rewards: Array[QuestReward]
 └── completion: Enum (ALL, ANY, SEQUENCE)
```

### 2. Tipos de Objetivos Genéricos (ObjetiveType)
* `KILL`: Derrotar quantidade N de inimigos com `enemy_id`.
* `TALK_NPC`: Falar com NPC identificado por `target_npc_id`.
* `INVESTIGATE`: Interagir com pista, objeto ou teste (ex: `teste_agua_wing`).
* `REACH_AREA`: Chegar a uma área ou marco específico.
* `COLLECT`: Coletar itens ou cards.
* `STEALTH_PASS`: Atravessar uma zona em Zetsu sem ser detectado.
* `SURVIVE`: Sobreviver a um timer ou onda de inimigos.
* `DEFEAT_BOSS`: Derrotar chefe com fases de combate.

### 3. Estados de Objetivo
* `LOCKED`: Ainda indisponível para progressão.
* `ACTIVE`: Monitorando eventos de gameplay (abates, visitas).
* `COMPLETED`: Meta satisfeita com sucesso (ícone `✓`).
* `FAILED`: Condição quebrada (ex: falha de stealth em área restrita).

### 4. MissionInstance (Ciclo de Vida Isolado)
```text
Início da Missão
       │
       ▼
[ Criação de MissionInstance ]
       │ - Spawna inimigos exclusivos da missão
       │ - Registra listeners para eventos
       │ - Inicializa contadores em 0
       ▼
[ Execução / Combate ]
       │
       ├── Se Jogador Morre ou Cancela:
       │     └─► [ Cleanup Completo ] -> Deleta monstros órfãos -> Reset limpo
       │
       └── Se Todos os Objetivos São Cumpridos:
             └─► [ Entrega de Rewards ] -> [ Notificação StoryManager ] -> [ Cleanup ]
```
