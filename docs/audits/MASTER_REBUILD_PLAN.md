# MASTER REBUILD PLAN — HUNTER MMORPG
## CONCRETE & VERIFIABLE ARCHITECTURAL REBUILD ROADMAP

**Lead Game Architect & Technical Director**  
**Priority Legend:**  
* **P0 (Critical):** Impede o avanço do jogo, bloqueia história, quebra saves ou trava cenas.
* **P1 (High):** Sistemas fundamentais com arquitetura incorreta, duplicação ou falta de ciclo de vida.
* **P2 (Medium):** Inconsistências de feedback, GPS, validação de dados ou diálogos.
* **P3 (Low):** Polimento, limpeza de pastas, código morto e documentação.

---

## 1. BACKLOG DE TAREFAS POR PRIORIDADE

### PRIORIDADE P0 — CRÍTICO (BLOCKERS DE GAMEPLAY & HISTÓRIA)

* [ ] **[P0-01] Corrigir Arena Celestial (Inimigos Faltantes & Teste da Água)**:
  - Adicionar instâncias de `LutadorArena1`, `LutadorArena2`, `LutadorArena3`, `LutadorArena4` em `arena_celestial.tscn` (ou instanciar no `ArenaCelestialMap.gd` caso ausentes).
  - Criar o gatilho interativo `teste_agua_wing` no dojo de Wing em `ArenaCelestialMap.gd` para permitir a conclusão da Etapa 10 do Arco 3.
  - Sincronizar o diálogo de Wing com `CanonQuestCatalog.gd`.

* [ ] **[P0-02] Corrigir Máquina de Estados de Elena no Tutorial**:
  - Em `RecepcionistaHunter.gd`, adicionar tratadores no `match etapa:` para todas as etapas do enum (`MOVIMENTACAO`, `MENU_ABRIR`, `INVENTARIO_VER`, `COMBATE_GOLPES`, `STATUS_VER`).
  - Garantir que `_interacao_em_processamento` sempre seja resetado via callback ou timeout de segurança para evitar travamento da interação [E].
  - Em `Lobby.gd`, impedir que o trigger automático do tutorial cause race conditions ao reentrar na cena.

* [ ] **[P0-03] Implementar Ciclo de Vida de Spawn e Respawn de Inimigos**:
  - Criar `world/components/WorldSpawner.gd`: gerencia spawn e respawn com timer para monstros de mundo livre.
  - Quando um monstro comum morre, o `WorldSpawner` aguarda o tempo de renascimento (ex: 15s a 30s) e recria a criatura sem exigir reload de cena.
  - Inimigos de missão são associados a uma `MissionInstance` e resetados sob demanda.

* [ ] **[P0-04] Corrigir Trava de Treinamento de Biscuit em Greed Island**:
  - Em `entities/npc/biscuit/Biscuit.gd`, permitir que o diálogo de treino e a forja de Hatsu sejam acessíveis quando o jogador estiver no Arco 5 (Greed Island) nas etapas canônicas de treino com a Mestra, sem exigir prematuramente a conclusão prévia do próprio arco.

---

### PRIORIDADE P1 — ALTA (RECONSTRUÇÃO ARQUITETURAL & SINGLE SOURCE OF TRUTH)

* [ ] **[P1-05] Implementar `StoryManager` Canônico**:
  - Criar `autoload/StoryManager.gd` como a **Fonte Única da Verdade** para o Story Mode:
    ```text
    Story
     └── Saga (Arco)
          └── Chapter (Capítulo)
               └── Mission (Missão)
                    └── Objectives (Objetivos)
    ```
  - Migrar `PlayerData.arco_atual` e `PlayerData.etapa_quest_arco` para `StoryManager`. `PlayerData` apenas armazena os dados brutos serializados.
  - Sinais claros: `saga_iniciada(id)`, `missao_iniciada(id)`, `objetivo_atualizado(id, progresso, total)`, `missao_concluida(id)`, `saga_concluida(id)`.

* [ ] **[P1-06] Implementar `MissionInstance` Isolada**:
  - Criar `scripts/missions/MissionInstance.gd`:
    - Armazena referências aos monstros gerados para a missão.
    - Contém timer, checkpoints e estado dos objetivos (`LOCKED`, `ACTIVE`, `COMPLETED`, `FAILED`).
    - Ao reiniciar a missão: executa cleanup completo de entidades órfãs e recria o spawn inicial.

* [ ] **[P1-07] Unificar Persistência e Versionamento de Save**:
  - Em `autoload/SaveManager.gd`, introduzir `save_version: int = 1` com suporte formal a migrações futuras.
  - Eliminar o script proxy inútil `autoload/GameState.gd` e direcionar chamadas diretamente a `SaveManager`.
  - Proteger `obter_resumo_slot` contra dicionários parciais garantindo valores padrão para todas as chaves.

* [ ] **[P1-08] Remover Criador de Personagem Legado Conflitante**:
  - Deletar `ui/CharacterCreation/CharacterCreationUI.gd` e `.tscn` (que forçava overwrite no slot 1).
  - Centralizar 100% da criação e seleção no `ui/CharacterSelection/CharacterSelectionUI.gd` (3 slots oficiais).

---

### PRIORIDADE P2 — MÉDIA (FEEDBACK, REGRAS DE GAMEPLAY & PORTAIS)

* [ ] **[P2-09] Blindagem Anti-Bypass dos Portais (`StoryGate`)**:
  - Garantir que todos os portais de mapas mundiais consultem `StoryGate` antes de permitir a travessia física ou via tecla [E].
  - Emitir diálogos explicativos e toast na tela informando exatamente quais objetivos ou abates estão pendentes.

* [ ] **[P2-10] Estabilidade do GPS de Missão (`MissionGPSIndicator`)**:
  - Atualizar o cálculo de coordenadas para priorizar o spawner da missão ou instância ativa quando um inimigo morre, evitando coordenadas `Vector2.ZERO`.

* [ ] **[P2-11] Consolidar Sistema de Diálogos**:
  - Remover `scripts/systems/dialogue/` (pasta vazia).
  - Desacoplar `DialogueSystem.gd` do nó físico do Player, unificando as chamadas em `VisualDialogueUI`.

---

### PRIORIDADE P3 — BAIXA (LIMPEZA, POLIMENTO & DOCUMENTAÇÃO)

* [ ] **[P3-12] Gerar Todos os Guias Técnicos de Arquitetura (`docs/`)**:
  - `docs/STORY_SYSTEM.md`
  - `docs/MISSION_SYSTEM.md`
  - `docs/SAVE_SYSTEM.md`
  - `docs/SPAWN_SYSTEM.md`
  - `docs/DIALOGUE_SYSTEM.md`
  - `docs/NEN_SYSTEM.md`
  - `docs/HATSU_SYSTEM.md`
  - `docs/PLAYER_DATA.md`
  - `docs/WORLD_STATE.md`
  - `docs/TESTING_STRATEGY.md`

* [ ] **[P3-13] Criar Ferramenta de Debug & Teste de Regressão**:
  - Implementar suíte automatizada `scratch/test_master_rebuild_suite.gd` e `.tscn` para rodar headless via console do Godot 4.4 validando o ciclo completo:
    `Criação -> Save -> Carregamento -> Missão -> Objetivos -> Spawn -> Morte -> Respawn -> Conclusão -> Portal`.
