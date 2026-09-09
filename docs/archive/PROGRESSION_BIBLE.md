# ============================================================
# HUNTER ONLINE — PROGRESSION BIBLE (FASE F)
# ============================================================
# Progressão Multidimensional, Treinamento com Mestres, Skill Tree e Slots de Hatsu
# Godot 4.4 / GDScript Estritamente Tipado
# ============================================================

## 1. Visão Geral e Filosofia de Progressão
Em *Hunter x Hunter*, tornar-se mais forte exige perseverança, disciplina física, orientação de mestres experientes e o domínio gradual dos fluxos vitais de Nen.

A progressão do Caçador opera em quatro dimensões estritamente desacopladas e integradas à autoridade única de dados do `PlayerData`:
1. **Nível do Personagem (1 a 1000)**: Atributos base (HP, Força, Defesa, Velocidade, Aura Base) que crescem naturalmente com XP sem depender de alocação de pontos.
2. **Nen Skill Tree (437 Nós, 8 Caminhos)**: 100% passiva, especializada e desbloqueada via Skill Points (SP) concedidos a cada level up.
3. **Treinamento de Mestres & Refinamento de Nen**: Sessões imersivas com Wing, Biscuit Krueger e Mestres de Dojo concedendo expansões permanentes de Aura Máxima e Skill Points adicionais.
4. **Hatsu Slots & Criação de Técnicas**: Desbloqueio canônico de 4 slots de Hatsu (Greed Island concluído + Níveis 600, 800, 1000).

---

## 2. Taxonomia de Status de Implementação
- **IMPLEMENTED**: Código testado, ativo em produção e integrado ao `PlayerData` e `SaveManager`.
- **PARTIAL**: Arquitetura em funcionamento com catálogo de mestres secundários em produção.
- **PLANNED**: Treinamentos em gravidade aumentada ou ambientes extremos (Continente Negro).
- **DEFERRED**: Mecânicas de "Pague para subir de nível" (rejeitado integralmente por ferir o design canônico).
- **LEGACY**: Sistemas de treino antigos desconectados da Skill Tree ou de modificadores centrais.

---

## 3. Matriz de Componentes de Progressão

| Componente | Status | Arquivo / Classe | Descrição |
|---|---|---|---|
| **Level Cap 1000 & Base Stats** | `IMPLEMENTED` | `autoload/ProgressionConfig.gd` | Curvas de crescimento exponencial suave de nível 1 a 1000. |
| **Nen Skill Tree (437 Nós)** | `IMPLEMENTED` | `scripts/systems/NenSkillTree.gd` | Constelação passiva completa com 8 caminhos e 0 botões manuais de toggle. |
| **Hatsu Slots Progression** | `IMPLEMENTED` | `autoload/HatsuProgressionManager.gd` | 4 slots vinculados à conclusão de Greed Island e marcos de nível. |
| **TrainingSystem (Mestres)** | `IMPLEMENTED` | `scripts/systems/TrainingSystem.gd` | Sessões narrativas com Wing, Biscuit e Dojos que expandem Aura e concedem SPs. |
| **Persistência Atômica de Progressão**| `IMPLEMENTED` | `autoload/SaveManager.gd` | Salvamento e restauração íntegros de SPs, atributos, nós e slots. |
| **Mestres Adicionais (NGL / Dojos)** | `PARTIAL` | `scripts/systems/TrainingSystem.gd` | Mestres Wing e Biscuit ativos; Dojos regionais de Yorknew e Meteor City em expansão. |
| **Treinamento em Ambientes Extremos** | `PLANNED` | `ExtremeEnvironmentTraining.gd` | Sobrevivência sob intempéries para desbloqueio de juramentos especiais. |
| **Microtransações de Nível (Pay-to-Win)**| `DEFERRED` | N/A | Totalmente descartado; o poder do Caçador reflete estritamente sua jornada no jogo. |
| **Treino Dummy Isolado sem Recompensa**| `LEGACY` | Antigos scripts de treino | Descontinuado em favor do `TrainingSystem` centralizado. |

---

## 4. O Sistema de Treinamento (`TrainingSystem`)
O `TrainingSystem` implementa o rigor e a filosofia de treinamento do mangá:

### 4.1 Sessões Canônicas Disponíveis
1. **Meditação e Sustentação de Ten (Mestre Wing)**:
   - *Requisito*: Level 5+, Saga 1 (Exame Hunter)
   - *Recompensa*: +25 Aura Máxima permanente, +1 Nen Skill Point.
2. **Fluxo Intenso de Ren (Mestre Wing)**:
   - *Requisito*: Level 15+, Ten concluído
   - *Recompensa*: +40 Aura Máxima permanente, +1 Nen Skill Point.
3. **Escavação de Pedras com Ko (Biscuit Krueger)**:
   - *Requisito*: Level 45+, Saga 5 (Greed Island)
   - *Recompensa*: +80 Aura Máxima permanente, +2 Nen Skill Points.
4. **Disciplina Física do Dojo de Zaban (Instrutor Local)**:
   - *Requisito*: Level 10+
   - *Recompensa*: +15 Defesa base permanente.

---

## 5. Slots de Hatsu e Regras Anti-Bypass
O desenvolvimento de Hatsu é a expressão máxima da alma do Caçador:
- **Slot 1**: Exige conclusão do Arco 5 (Greed Island) com Biscuit.
- **Slot 2**: Exige Slot 1 desbloqueado + Nível 600.
- **Slot 3**: Exige Slot 2 desbloqueado + Nível 800.
- **Slot 4**: Exige Slot 3 desbloqueado + Nível 1000.
Tentativas de equipar habilidades em slots bloqueados ou forçar desbloqueios sem atender requisitos são estritamente interceptadas e expurgadas pelo `HatsuProgressionManager`.
