# QA & REGRESSION TESTING BIBLE
## HUNTER ONLINE — QUALITY ASSURANCE, AUTOMATED TEST SUITES & REGRESSION PROTOCOLS

---

## 1. FILOSOFIA DE TESTES DO HUNTER ONLINE

> **"Nenhum sistema novo é aprovado sem testes automatizados que validem sua execução em runtime headless, garantindo 0 quebras no Save Schema e nos subsistemas legados."**

O projeto adota uma pirâmide rigorosa de testes executáveis de forma headless no motor Godot 4.6, garantindo idempotência e diagnósticos instantâneos.

---

## 2. SUÍTES OFICIAIS DE TESTE

### 2.1 Fase H — Mundo, Conteúdo & Quests
- **Cena Executável:** `res://scratch/test_phase_h.tscn`
- **Script:** `scratch/test_phase_h_world_content_suite.gd`
- **Cobertura (76/76 Testes - 100% Pass):**
  - Conexões físicas de regiões e transições de cena (`SceneTransition`).
  - Bestiário canônico e arquitetura de arquétipos (`bruiser`, `tank`, `fast`, `ambusher`).
  - Hierarquia de 6 tiers de NPCs e rotinas vivas contextuais.
  - Catálogo de 7 quests de Padokia com caça, entrega e segredos sem GPS.
  - 3 fases mecânicas orientadas a dados para Chefes mundiais.
  - Resolução de crises dinâmicas e rumores com o `WorldEventManager`.
  - Ciclo solar 24h (`TimeManager`) e weather engine (`WorldStateManager`).
  - Serialização e desserialização Schema 2.3 atômica no `SaveManager`.

### 2.2 Fase I — Balanceamento & Endgame (LV1 a LV1000)
- **Cena Executável:** `res://scratch/test_phase_i_balance_suite.tscn`
- **Script:** `scratch/test_phase_i_balance_suite.gd`
- **Cobertura (85/85 Testes - 100% Pass):**
  - Curvas de XP normal e Nen do Nível 1 ao Nível 1000 (Sem overflow de int64).
  - Teto matemático de atributos e multiplicadores do Nexus Central da Skill Tree.
  - Afinidades hexagonais canônicas (100%, 80%, 60%, 40%).
  - Desbloqueio dos 4 slots de Hatsu nos marcos canônicos.
  - Escalabilidade do bestiário e Chefes Secretos sem waypoints de GPS.
  - Contratos de Bounty Ranks S e A com perseguição dinâmica.
  - Catálogo de 34 conquistas com conquista de platina no nível 1000.
  - Integridade de save/load no nível 1000 sob o Schema 2.3.

### 2.3 Fase J — Polimento Pesado & Game Feel
- **Cena Executável:** `res://scratch/test_phase_j_polish_suite.tscn`
- **Script:** `scratch/test_phase_j_polish_suite.gd`
- **Cobertura (36/36 Testes - 100% Pass):**
  - Visual Swing Arcs e arcos procedurais de ataque básico e pesado.
  - Floating combat cues (`spawn_esquiva` e `spawn_bloqueio`).
  - Content pipeline fix: `EnemySystem.setup_from_data` e mitigação completa de dano.
  - Limites de câmera contextual por mapa e zoom tático.
  - Afterimages de dash, poeira de sprint e cadência de passos por piso.
  - Banner cinemático de introdução de chefe e pulsos de fase.
  - ConditionTrackerUI modular com suporte a requisitos de Hatsu e votos.
  - 13 geradores procedurais de áudio no `AudioSynth.gd`.
  - Prompts dinâmicos flutuantes de interação [E].

---

## 3. PROTOCOLO DE EXECUÇÃO HEADLESS

Para rodar qualquer suíte via terminal:
```powershell
& "Godot_v4.6-stable_win64_console.exe" --headless "res://scratch/test_phase_j_polish_suite.tscn"
& "Godot_v4.6-stable_win64_console.exe" --headless "res://scratch/test_phase_i_balance_suite.tscn"
& "Godot_v4.6-stable_win64_console.exe" --headless "res://scratch/test_phase_h.tscn"
```
**Critério de Aprovação:** Código de saída `0`, zero erros de compilação ou GDScript backtrace, e `FALHAS: 0`.

---

## 4. MATRIZ DE STATUS DE IMPLEMENTAÇÃO (FASE J)

| Subsistema de QA | Status | Detalhes & Componentes |
| :--- | :--- | :--- |
| **Suíte Automatizada Fase H** | `[IMPLEMENTED]` | 76 testes aprovados em `test_phase_h.tscn` |
| **Suíte Automatizada Fase I** | `[IMPLEMENTED]` | 85 testes aprovados em `test_phase_i_balance_suite.tscn` |
| **Suíte Automatizada Fase J** | `[IMPLEMENTED]` | 36 testes aprovados em `test_phase_j_polish_suite.tscn` |
| **Failsafe Telemetria & Debug** | `[IMPLEMENTED]` | `PlaytestTelemetry.gd` com overlays F2 e F3 |
| **Stress Test de Memória / Leaks** | `[IN PROGRESS]` | Análise de ObjectDB e cleanup de nós temporários |
| **Runner Integrado de CI/CD** | `[PLANNED]` | Script GitHub Actions para validação a cada commit |
| **Simulação de Rede com Bots** | `[FUTURE]` | Carga de 100 clientes virtuais conectados ao Lobby |
