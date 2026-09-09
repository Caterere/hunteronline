# ============================================================
# HUNTER ONLINE — STORY EXPERIENCE BIBLE (FASE F)
# ============================================================
# Autoridade Narrativa, Ritmo, Escolhas e Sagas Canônicas
# Godot 4.4 / GDScript Estritamente Tipado
# ============================================================

## 1. Visão Geral e Filosofia Narrativa
Em *Hunter x Hunter*, a narrativa não é um mero corredor de diálogos que conduz a lutas automáticas. A experiência de história deve transmitir a imprevisibilidade, o perigo tático, as nuances morais e os momentos cotidianos de camaradagem e treinamento dos personagens.

O objetivo desta Bible é estabelecer a arquitetura do **Story Experience**, garantindo que o jogador se sinta dentro de uma aventura viva onde decisões têm consequências e o ritmo respeita os clássicos respiros e escaladas de Togashi.

---

## 2. Taxonomia de Status de Implementação
- **IMPLEMENTED**: Totalmente implementado no código-fonte e validado com testes automatizados.
- **PARTIAL**: Arquitetura base implementada, com ramificações avançadas em expansão.
- **PLANNED**: Especificado e modelado arquiteturalmente para sagas futuras.
- **DEFERRED**: Postergado formalmente para evitar diluição do foco narrativo autoral.
- **LEGACY**: Mantido estritamente para compatibilidade com saves antigos ou cenas legadas.

---

## 3. Matriz de Componentes Narrativos

| Componente | Status | Arquivo / Classe | Descrição |
|---|---|---|---|
| **StoryManager (Single Source of Truth)** | `IMPLEMENTED` | `autoload/StoryManager.gd` | Autoridade central de sagas, capítulos, flags e escolhas. |
| **StoryPacingState Enum** | `IMPLEMENTED` | `autoload/StoryManager.gd` | 6 estados de ritmo (`EXPLORATION`, `DIALOGUE`, `CUTSCENE`, `COMBAT_EVENT`, `TRAINING_SESSION`, `REST_PACE`). |
| **Character Choices System** | `IMPLEMENTED` | `autoload/StoryManager.gd` | Registro atômico de decisões narrativas (`register_choice`, `has_choice`, `get_choice`). |
| **Saga Progress Calculator** | `IMPLEMENTED` | `autoload/StoryManager.gd` | `obter_progresso_saga_atual()` com retorno percentual (0.0% a 100.0%). |
| **Story Pacing Manager** | `IMPLEMENTED` | `scripts/systems/StoryPacingManager.gd` | Cadência entre combate e exploração, detecção de fadiga de combate e sugestão de respiros. |
| **Story Pacing Save/Load** | `IMPLEMENTED` | `autoload/StoryManager.gd` | Serialização e restauração integral de estados de ritmo e dicionário de escolhas. |
| **Living Story Gates** | `IMPLEMENTED` | `scripts/world/StoryGate.gd` | Portões e barreiras validadas contra StoryManager prevenindo desvios prematuros. |
| **Ramificações Avançadas (Arcos 2-7)** | `PARTIAL` | `world/maps/` | Escolhas canônicas completas no Arco 1 (Zaban/Exame); Arcos 2 a 7 com estrutura de flags pronta. |
| **Interjeições de Companheiros em Viagem** | `PLANNED` | `scripts/story/CompanionChatter.gd` | Comentários contextuais de Gon, Killua, Kurapika e Leorio durante travessias a pé. |
| **Geração Procedural de Histórias** | `DEFERRED` | N/A | Postergado; fidelidade ao universo de Hunter x Hunter exige curadoria canônica artesanal. |
| **Flags Locais Isoladas em Scripts de Cenas** | `LEGACY` | Vários scripts legados | Flags gravadas fora do StoryManager foram substituídas pelo registro centralizado. |

---

## 4. Arquitetura dos Estados de Ritmo (`StoryPacingState`)
O ritmo é controlado pelo `StoryManager` e respeitado globalmente por subsistemas de áudio, HUD e input:

1. **`EXPLORATION`**: Ritmo padrão de mundo aberto. Câmera livre, movimentação liberada, HUD visível.
2. **`DIALOGUE`**: Conversação ativa com NPC. Movimento do jogador travado, câmera aproxima com foco no interlocutor.
3. **`CUTSCENE`**: Momento cinematográfico data-driven com atores autônomos, ângulos de câmera dramáticos e letterbox.
4. **`COMBAT_EVENT`**: Encontros climáticos ou emboscadas com BGM de batalha e foco tático sem interrupções triviais.
5. **`TRAINING_SESSION`**: Sessões dedicadas de aprimoramento de Nen com Mestres (Wing, Biscuit, Dojos).
6. **`REST_PACE`**: Momentos de calmaria (beira de fogueira, lanchonetes de Zaban, vista da montanha) recuperando HP/Aura e abrindo diálogos reflexivos.

---

## 5. Escolhas do Jogador e Causalidade
Toda decisão registrada via `StoryManager.register_choice(id, valor)`:
1. Emite o sinal `character_choice_registered(choice_id, choice_value)`.
2. Cria automaticamente a story flag `escolha_<id>_<valor> = true`.
3. Informa imediatamente NPCs vivos com `LivingNPCBehavior`, alterando opções de diálogo e reações.
4. É gravada no JSON de savegame do jogador, garantindo consistência permanente da biografia do Caçador.
