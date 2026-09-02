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

## Próxima tarefa

- `[ ]` Fase 2 — condições contextuais e sinergias da Skill Tree.
  - Integrar condições aos nós comportamentais (First Strike, Bloodied, Surrounded, Isolated Target e Hunter's Mark).
  - Reutilizar `GameplayCondition`, `GameplayTags` e `StatModifier`.
  - Não duplicar a sinergia de tags já existente em `HatsuManager`.
  - Critérios: condições verdadeiras/falsas testadas, efeito aplicado pelo sistema dono e save/load preservado.

## Ordem planejada

1. `[x]` Fundação: tags, condições e modificadores.
2. `[ ]` Skill Tree contextual e sinergias entre técnicas.
3. `[ ]` Tags de dano/Hatsu consumidas pelo combate central.
4. `[ ]` Arquétipos, aggro e estados reutilizáveis de inimigos.
5. `[ ]` Weak Points e feedback de combate.
6. `[ ]` Fases e mecânicas configuráveis de bosses.
7. `[ ]` Estados, rotinas e eventos de NPCs.
8. `[ ]` Objetivos condicionais, opcionais e consequências de quests.
9. `[ ]` Eventos dinâmicos, encontros raros e zonas do mundo.
10. `[ ]` HUD de alvo, Hatsu, condições e feedback contextual.
11. `[ ]` Ferramentas de debug para builds, condições e encontros.
12. `[ ]` Suíte de testes, regressão completa e atualização final das Bibles.

## Critério geral de conclusão

Uma tarefa só muda para `[x]` quando o comportamento estiver integrado ao dono correto, não duplicar estado ou fórmula, tiver documentação atualizada e possuir validação registrada. Se o Godot não estiver disponível, registrar a validação estática e a limitação explicitamente.

## Registro de execução

### 2026-09-02

- Roadmap criado.
- Sistemas existentes identificados: `HatsuManager` já possui sinergia de tags; `PlayerData` possui o pipeline de modificadores; `GameplayCondition` é a base declarativa compartilhada.
- Próximo passo: implementar a Fase 2 sem criar uma segunda camada de sinergia de Hatsu.
