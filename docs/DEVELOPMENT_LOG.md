# DEVELOPMENT LOG
## HUNTER ONLINE — HISTÓRICO DE ENGENHARIA & MARCOS TÉCNICOS

---

### [2026-09-03] — Marco 1: Definitive Gameplay Vision & Nen Rebuild
- **Fase:** Auditoria Mestre & Reestruturação de Nen.
- **Mudanças Realizadas:**
  - Criação de `PassiveNenController.gd` (Ten, Ren, Shu, Ko, Ryu) e `ActiveNenController.gd` (Zetsu, En, Gyo).
  - Implementação de Stealth Real com fórmula de raio efetivo em `EnemyAI.gd`.
  - Implementação de Debuff de Intimidação em Área com En (redução de defesa em monstros na cúpula).
  - Implementação de Percepção Multi-Tier em `GyoInspectable.gd` com `nivel_gyo_minimo`.
  - Mapeamento oficial de `basic_attack`, `nen_zetsu`, `nen_en` e `nen_gyo` no `project.godot`.
  - Matriz Canônica de Conflitos: Zetsu desativa En e Gyo; En e Gyo coexistem; combate interrompe Zetsu.
- **Testes:** 21 / 21 testes aprovados (`test_definitive_gameplay_vision_suite.tscn`, `test_game_vision_suite.tscn`, `test_master_rebuild_suite.tscn`).

---

### [2026-09-03] — Marco 2: Game Master Bible & Perception Layer Decoupling
- **Fase:** Produção e Desacoplamento Arquitetural.
- **Mudanças Realizadas:**
  - Redação da `GAME_MASTER_BIBLE.md` conectando todos os 24 pilares de design.
  - Criação das 8 Bibles especializadas (`PERCEPTION_BIBLE.md`, `ENEMY_AI_BIBLE.md`, `GAME_FEEL_BIBLE.md`, etc.).
  - Criação do `PerceptionSystem.gd` desacoplando a camada sensorial de visão, aura e stealth dos monstros.
  - Implementação de Hit Stop e screenshake dinâmico para impacto tátil de combate.
  - Padronização dos ADRs em `docs/architecture/`.

---

### [2026-09-03] — Marco 3: Vertical Slice & Production Approval
- **Fase:** Validação Ponta a Ponta & Conclusão da Diretriz Mestre de Produção.
- **Mudanças Realizadas:**
  - Construção da suíte contínua do Vertical Slice (`scratch/test_vertical_slice_suite.gd`).
  - Validação de 11 etapas ponta a ponta: Personagem → Lobby → Elena → Missões Paralelas → Percepção Sensorial → Ataque Básico & Hit Stop → Hatsu Ativo → Level Up & Skill Tree → Zetsu Stealth & En Intimidação → Missão de História & Checkpoint → Save/Load Atômico no Hub World.
  - Eliminação de erros residuais em `WorldProgressionManager` e alinhamento do multiplicador de finalizador Ko no `CombatEngine`.
  - Redação da auditoria final em `docs/GAME_MASTER_FINAL_AUDIT.md`.
- **Testes:** 32 / 32 testes aprovados com 100% de sucesso em 4 suítes automatizadas.
