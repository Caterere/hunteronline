# Roadmap de tarefas futuras — Hunter Online

Este documento acompanha a evolução incremental do projeto. Cada tarefa deve reutilizar os sistemas canônicos, ter critérios verificáveis e ser marcada somente depois de implementada e testada.

## Status

- `[x]` concluída e validada
- `[~]` em andamento
- `[ ]` planejada
- `[!]` bloqueada por decisão ou dependência

## Concluídas

- `[x]` Auditoria das Bibles, arquitetura e referências do projeto.
- `[x]` Fase 1 — fundação de `GameplayTags`, `GameplayCondition` e uso único de `StatModifier`.
  - Tags de Hatsu normalizadas e persistidas.
  - Condições declarativas serializáveis integradas à ativação de Hatsu.
  - Modificador privado removido da `NenSkillTree`.
  - Bibles e documentação consolidada atualizadas.
- `[x]` Fase 2 — condições contextuais e sinergias da Skill Tree.
  - Nós comportamentais declarativos integrados à `NenSkillTree` (`first_strike`, `bloodied`, `surrounded`, `isolated_target`, `hunters_mark`).
  - Sinergias entre técnicas fundamentais de Nen integradas (`ken_mastery`, `in_mastery`, `en_expansion`).
  - Reutilização canônica estrita de `GameplayCondition`, `GameplayTags` e `StatModifier` (sem duplicação de fórmulas ou modificadores privados).
  - Sinergias de tags do `HatsuManager` mantidas isoladas e intactas.
  - Pipeline dinâmico de `StatModifier` aplicado e limpo pelo dono canônico (`PlayerData`).
  - Persistência e restauração de nós da Skill Tree, pontos e caminhos de Ryu integrados ao `SaveManager`.
  - Integração do contexto canônico de combate no `CombatEngine`.
  - Suíte de testes criada em `scratch/test_skill_tree_contextual_suite.gd`.
- `[x]` Fase 3 — tags de dano/Hatsu consumidas pelo combate central.
  - Tags canônicas (`slashing`, `blunt`, `piercing`, `projectile`, `elemental`, `aura`) integradas em `CombatEngine.calcular_dano_jogador` e `calcular_dano_sofrido_jogador`.
  - Mitigações por fraqueza (x1.5), resistência (x0.5) e imunidade (0x) do alvo e do jogador (`PlayerData.resistance_tags`, `weakness_tags`, `immunity_tags`).
- `[x]` Fase 4 — arquétipos, aggro e estados reutilizáveis de inimigos.
  - Tabela de ameaça (`threat_table`), decaimento de aggro, seleção de alvo prioritário e distância máxima de coleira (leash) no `EnemyAI`.
  - Percepção sensorial canônica de Nen com Zetsu reduzindo detecção e limpando 90% da ameaça acumulada.
  - Novos estados `ALERT` e `FLEE` implementados para arquétipos que recuam ou reagem a ruídos.
- `[x]` Fase 5 — HUD da Skill Tree.
  - Interface modular `NenSkillTreeUI.gd` criada com abas (Fundamentos, Modos de Ryu, Comportamentais, Sinergias), pontos disponíveis, custos, pré-requisitos, tooltips de tags/condições e integração direta na aba "Nen Tree" do `HunterMenuUI`.
- `[x]` Fase 6 — fases e mecânicas configuráveis de bosses.
  - Recurso declarativo orientado a dados `BossPhaseData.gd` (`phase_index`, `hp_threshold`, `speed_multiplier`, `windup_multiplier`, `hatsu_cd_multiplier`, `mechanic`, `color_modulate`, `dialogue_quote`).
  - `EnemyData` estendido com `boss_phases` e `EnemyAI` adaptado para consumir fases configuráveis.
- `[x]` Fase 7 — estados, rotinas e eventos de NPCs.
  - Integração de `NPCScheduleData` no `LivingNPCBehavior` sincronizada com `TimeManager` (manhã -> trabalho, dia -> patrulha, noite -> descanso) e reações dinâmicas a eventos mundiais.
- `[x]` Fase 8 — objetivos condicionais, opcionais e consequências de quests.
  - `QuestObjective` estendido com `is_optional`, `conditions` e avaliação de `GameplayCondition`.
  - `Quest` estendido com `optional_rewards`, `consequence_tags` e `optional_consequence_tags`.
  - `QuestManager` ajustado para não bloquear conclusão por opcionais e registrar consequências no `PlayerData.quest_states`.
- `[x]` Fase 9 — eventos dinâmicos, encontros raros e zonas do mundo.
  - `ZoneData` enriquecido com `rare_encounters`, tags de zona e cálculo ponderado por multiplicador de perigo.
  - `WorldEventManager` equipado com sorteio de encontros raros e notificações imersivas.
- `[x]` Fase 10 — HUD de alvo, Hatsu, condições e feedback contextual.
  - `TargetHUD.gd` criado exibindo alvo focado, barra de HP, barra de postura (stagger), afinidade de Nen, fraquezas/resistências e status de combate.
  - Disparo de `target_changed` integrado no `CombatSystem` e `EventBus`.
- `[x]` Fase 11 — ferramentas de debug para builds, condições e encontros.
  - `BuildDebugMenu.gd` implementado (tecla F2) com controle de Nen Skill Points, injeção de condições de combate (HP baixo, cercado, alvo marcado) e disparo de fases de boss.
- `[x]` Fase 12 — suíte de testes, regressão completa e atualização final das Bibles.
  - Suíte de validação abrangente criada em `scratch/test_tasks_futuras_suite.gd` cobrindo todas as 8 novas áreas de funcionalidade.
  - Atualização completa de `TASKS_FUTURAS.md` e referências do projeto.

## Ordem planejada

1. `[x]` Fundação: tags, condições e modificadores.
2. `[x]` Skill Tree contextual e sinergias entre técnicas.
3. `[x]` Tags de dano/Hatsu consumidas pelo combate central.
4. `[x]` Arquétipos, aggro e estados reutilizáveis de inimigos.
5. `[x]` Hud Da Skill Tree.
6. `[x]` Fases e mecânicas configuráveis de bosses.
7. `[x]` Estados, rotinas e eventos de NPCs.
8. `[x]` Objetivos condicionais, opcionais e consequências de quests.
9. `[x]` Eventos dinâmicos, encontros raros e zonas do mundo.
10. `[x]` HUD de alvo, Hatsu, condições e feedback contextual.
11. `[x]` Ferramentas de debug para builds, condições e encontros.
12. `[x]` Suíte de testes, regressão completa e atualização final das Bibles.

## Critério geral de conclusão

Uma tarefa só muda para `[x]` quando o comportamento estiver integrado ao dono correto, não duplicar estado ou fórmula, tiver documentação atualizada e possuir validação registrada. Se o Godot não estiver disponível, registrar a validação estática e a limitação explicitamente.

## Registro de execução

### 2026-09-03

- **Fases 3 a 12 concluídas**:
  - `CombatEngine.gd`: tags de dano integradas em `calcular_dano_jogador` e `calcular_dano_sofrido_jogador`; multiplicadores canônicos de fraqueza (x1.5), resistência (x0.5) e imunidade (0x) conectados ao `PlayerData` e inimigos.
  - `EnemyAI.gd`: implementada tabela de ameaça (`threat_table`), decaimento de aggro, estados `ALERT` e `FLEE`, mitigação de aggro de Zetsu e coleira máxima de perseguição (`aggro_leash_distance`).
  - `ui/SkillTree/NenSkillTreeUI.gd`: criado HUD interativo da árvore de Nen com abas de categorias, alocação de pontos, seletores de modos de Ryu e tooltips de condições; integrado na aba "Nen Tree" do `HunterMenuUI`.
  - `BossPhaseData.gd` & `EnemyData.gd`: criado recurso de fases de chefes e consumo dinâmico no `EnemyAI`.
  - `LivingNPCBehavior.gd`: rotinas vinculadas ao `NPCScheduleData` e sincronizadas com o `TimeManager`, com reações a crises de mundo.
  - `QuestObjective.gd`, `Quest.gd` e `QuestManager.gd`: suporte a objetivos opcionais, avaliação de condições e persistência de consequências de escolhas.
  - `ZoneData.gd` & `WorldEventManager.gd`: encontros raros ponderados por risco regional e geração dinâmica de eventos.
  - `TargetHUD.gd`: HUD de foco de alvo com barras de HP/postura, afinidade de Nen e badges de tags de fraqueza e status.
  - `BuildDebugMenu.gd`: menu de desenvolvedor (F2) para injeção de condições de combate, pontos de Skill Tree e teste de fases de chefes.
  - `scratch/test_tasks_futuras_suite.gd`: suíte com 8 testes abrangentes cobrindo todas as novas mecânicas.

- **Fase 2 concluída**:
  - `NenSkillTree.gd`: adicionadas categorias `COMPORTAMENTAL` e `SINERGIA`; `SkillNodeDef` estendido para aceitar `conditions` e `tags`; registrados 5 nós comportamentais (`first_strike`, `bloodied`, `surrounded`, `isolated_target`, `hunters_mark`) e 3 nós de sinergia entre técnicas (`ken_mastery`, `in_mastery`, `en_expansion`).
  - Métodos `avaliar_condicoes_no`, `obter_modificadores_contextuais_ativos`, `atualizar_modificadores_contextuais`, `limpar_modificadores_contextuais` implementados.
  - `SaveManager.gd`: persistência e restauração de `nen_skill_points`, `nen_skill_tree_progress` e `nen_ryu_caminho` integrados com tolerância a falhas e compatibilidade legada.
  - `CombatEngine.gd`: adicionado `construir_contexto_combate` e sincronização contextual com a Skill Tree.
  - `scratch/test_skill_tree_contextual_suite.gd`: suíte com 8 testes validando integridade, condições, modificadores, Ryu, save/load e não-duplicação.

### 2026-09-02

- Roadmap criado.
- Sistemas existentes identificados: `HatsuManager` já possui sinergia de tags; `PlayerData` possui o pipeline de modificadores; `GameplayCondition` é a base declarativa compartilhada.
- Próximo passo: implementar a Fase 2 sem criar uma segunda camada de sinergia de Hatsu.
