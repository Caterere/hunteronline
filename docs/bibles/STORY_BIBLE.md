# STORY SYSTEM BIBLE
## HUNTER ONLINE — DEFINITIVE GAMEPLAY DIRECTION

---

## 1. ESTRUTURA NARRATIVA

A narrativa do Hunter Online é dividida em **9 Sagas Canônicas**, cada uma composta por múltiplos capítulos lineares que formam a espinha dorsal da aventura do Hunter.

**SSOT de contagens:** `CanonQuestCatalog.obter_total_quests_do_arco` (total **254** etapas).

1. **Saga 1: 287º Exame Hunter** (24 Etapas)
2. **Saga 2: Montanha Kukuroo** (18 Etapas)
3. **Saga 3: Arena Celestial** (26 Etapas)
4. **Saga 4: Yorknew City & Trupe Fantasma** (34 Etapas)
5. **Saga 5: Greed Island** (36 Etapas)
6. **Saga 6: Formigas Chimera (NGL & Palácio)** (48 Etapas)
7. **Saga 7: Eleição Hunter & Alluka** (20 Etapas)
8. **Saga 8: Expedição ao Continente Negro** (22 Etapas)
9. **Saga 9: Guerra de Sucessão Kakin (Black Whale 1)** (26 Etapas)

### Contrato de capítulo (Fase 0)

Cada etapa carrega metadado em `Quest.custom_data` via `StoryChapterContract`:

- `act_id` / `act_name` — agrupador narrativo (ato)
- `narrative_role` — `setup` | `bond` | `prep` | `prova` | `revelacao` | `climax` | `aftermath`
- `playable_verb` — verbo jogável predominante
- `contract_version` — `phase0`

O Exame (Saga 1) é o piloto: atos Maratona → Numere → Gourmet → Dirigível → Trick Tower → Zevil → Clímax.

---

## 2. O STORY CHECKPOINT SYSTEM

### Regra de Ouro do Save & Load:
> **O jogo NUNCA carrega o jogador diretamente dentro de uma missão de combate ao iniciar.**
> Todo carregamento de jogo transporta o jogador para o **Hub World (Lobby)**.
> Para continuar a campanha, o jogador se dirige ao **Story Gateway NPC**.

### Diferenciação de Estados:
- **`current_saga`:** A saga ativa (1 a 9).
- **`current_chapter`:** A etapa específica dentro da saga.
- **`current_mission`:** O recurso da missão em andamento.
- **`current_objective`:** A tarefa imediata da missão (ex: derrotar 3 criaturas, falar com NPC).
- **`current_story_checkpoint`:** O marco narrativo seguro associado ao capítulo atual.
- **`last_safe_checkpoint`:** A última área/cidade segura onde o jogador esteve antes de entrar em perigo.

---

## 3. O PROTOCOLO DO STORY GATEWAY NPC

O **Story Gateway NPC** está localizado na praça principal do Hub World.
Ao interagir com o jogador:
1. O NPC consulta o `StoryManager`.
2. Apresenta o status da jornada:
   - *"Você está no Arco 3: Arena Celestial, Capítulo 10: O Teste da Água."*
   - *"Checkpoint Seguro: Dojo do 200º Andar de Mestre Wing."*
3. Oferece opções claras:
   - **[Continuar História]:** Transiciona diretamente para o mapa e coordenadas do Checkpoint.
   - **[Explorar o Hub World]:** Permite ao jogador permanecer na cidade para treinar, fazer compras ou side quests.
   - **[Rever Objetivos]:** Exibe o resumo do diário de missões.
