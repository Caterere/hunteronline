# GAME MASTER BIBLE
## HUNTER ONLINE — DEFINITIVE SINGLE SOURCE OF TRUTH (SSOT)

---

## 1. VISÃO DO JOGO & CORE FANTASY

> **"Hunter Online é um 2D RPG/MMORPG de qualidade de produção, inspirado em Hunter x Hunter, onde o jogador é o autor e protagonista de sua própria jornada como Hunter único."**

### A Promessa ao Jogador:
- **Eu escolhi meu caminho:** O jogador não é um espectador passivo do anime; ele forja sua própria trajetória.
- **Eu construí meu Nen:** Através da Nen Skill Tree, o jogador desenvolve especializações únicas entre as técnicas passivas e ativas.
- **Eu desenvolvi meu Hatsu:** Criação e customização de habilidades ativas dentro das 6 naturezas canônicas com juramentos e votos reais.
- **Eu fiz aliados e inimigos:** As escolhas sociais afetam como NPCs, a Associação Hunter, a Máfia e fugitivos reagem ao jogador.
- **Minha reputação mudou o mundo:** Preços em lojas, acessos a áreas restritas e missões secretas respondem ao histórico moral do jogador.
- **Meu Hunter é diferente de todos os outros:** Não existem classes rígidas pré-definidas; a build de atributos, afinidade e maestria define a identidade em combate.

---

## 2. O CORE GAME LOOP

O jogo opera em um loop contínuo e orgânico de exploração, desafio e recompensa:

```text
       ┌────────────────────────────────────────────────────────┐
       ▼                                                        │
    EXPLORE (Cidades, rotas selvagens, masmorras e segredos)    │
       │                                                        │
       ▼                                                        │
    NPC (Diálogos, relacionamentos e contexto narrativo)        │
       │                                                        │
       ▼                                                        │
    QUEST (Missões principais de Saga, paralelas e de facção)   │
       │                                                        │
       ▼                                                        │
    COMBAT (Ataque básico confiável + 4 slots de Hatsu ativo)   │
       │                                                        │
       ▼                                                        │
    XP & PROGRESSÃO (Pontos de Experiência e Nível)             │
       │                                                        │
       ▼                                                        │
    LEVEL UP (+1 Nen Skill Point por nível alcançado)           │
       │                                                        │
       ▼                                                        │
    NEN SKILL TREE (Passivos Ten/Ren/Shu/Ko/Ryu + Ativos Zetsu/En/Gyo)
       │                                                        │
       ▼                                                        │
    BUILD (Customização de estilo de luta e sinergias)          │
       │                                                        │
       ▼                                                        │
    REPUTATION (Impacto nas 6 Facções do mundo)                 │
       │                                                        │
       ▼                                                        │
    NEW CONTENT (Acesso a novos mestres, lojas e territórios)   │
       │                                                        │
       ▼                                                        │
    STORY CHECKPOINT (Gravação do progresso no Hub World)───────┘
```

---

## 3. OS DOIS PILARES DE COMBATE

O combate de Hunter Online rejeita o modelo de "esmagamento descontrolado de teclas" e apoia-se em dois pilares bem balanceados:

```text
                         SISTEMA DE COMBATE
                                 │
              ┌──────────────────┴──────────────────┐
              │                                     │
         PILAR 1:                              PILAR 2:
      ATAQUE BÁSICO                        SISTEMA DE HATSU
   (Combate Físico Letal)               (Skills Ativas 1 a 4)
```

1. **Ataque Básico (Basic Attack):**
   - **Input:** Mapeado em `basic_attack` (Botão Esquerdo do Mouse / Tecla Espaço).
   - **Zero Custo de Aura:** Permite lutar mesmo em momentos de exaustão de Nen.
   - **Cadência Dinâmica:** Escalonada pelo atributo `Velocidade`.
   - **Combo de 3 Golpes:**
     - Golpe 1: Dano base ágil (1.0x).
     - Golpe 2: Golpe em arco de transição (1.25x).
     - Golpe 3: Finalizador pesado (1.80x), fortalecido pelo passivo de **Ko**.
   - **Game Feel & Feedback:** Hit stop em acertos pesados, screenshake direcional e cancelamento defensivo por Dash.

2. **Sistema de Hatsu (Skills Ativas 1 a 4):**
   - **Inputs:** Teclas `1`, `2`, `3`, `4` (`hatsu_slot_1..4`).
   - **Custo e Recarga:** Consomem quantidade exata de Aura e entram em cooldown tático.
   - **Afinidades:** Intensificação, Transformação, Emissão, Materialização, Manipulação e Especialização.
   - **Juramentos & Votos:** Restrições autoimpostas aumentam drasticamente a potência.
   - **Regra de Ouro:** **Zetsu, En e Gyo NUNCA ocupam slots de Hatsu.**

---

## 4. ESTRUTURA HÍBRIDA DO SISTEMA NEN

O sistema Nen opera em duas camadas rigorosamente definidas:

```text
                                NEN SYSTEM
                                    │
                  ┌─────────────────┴─────────────────┐
                  │                                   │
         5 TÉCNICAS PASSIVAS                 3 TÉCNICAS ATIVAS
        (Modificadores Contínuos)            (Toggles com InputMap)
                  │                                   │
        ┌─────────┼─────────┐               ┌─────────┼─────────┐
        │         │         │               │         │         │
       Ten       Ren       Shu            Zetsu       En       Gyo
        │         │
       Ko        Ryu
```

### Técnicas Passivas (`PassiveNenController`):
- **Ten:** Absorção contínua de dano físico e firmeza postural (mitigação calculada em `CombatEngine`).
- **Ren:** Multiplicador passivo de dano de ataques básicos e capacidade máxima de aura.
- **Shu:** Bônus de perfuração e imbuição em armas empunhadas.
- **Ko:** Bônus de impacto/burst concentrado no golpe finalizador do ataque básico.
- **Ryu:** Distribuição balanceada contínua entre ataque e defesa (Ofensivo, Defensivo ou Equilibrado).

### Técnicas Ativas Especiais (`ActiveNenController`):
- **Zetsu (`nen_zetsu`, Tecla `Z`):** Modo stealth real. Reduz o raio de detecção de inimigos conforme a maestria da Skill Tree (de 20% até 80%). Interrompido ao desferir ou receber dano em combate.
- **En (`nen_en`, Tecla `X`):** Cúpula de percepção espacial (120px a 450px) que aplica o debuff de Intimidação (redução de 5% a 30% na defesa efetiva de monstros dentro da área).
- **Gyo (`nen_gyo`, Tecla `G`):** Percepção multi-tier de segredos (Tiers 1 a 5), pistas e passagens ocultas, evitando a falha de "highlight everything".

### Matriz Canônica de Conflitos:
- **Zetsu vs En:** Mutuamente exclusivos (Zetsu apaga a aura; En a expande). Ativar um desliga o outro.
- **Zetsu vs Gyo:** Mutuamente exclusivos (Zetsu fecha os nós vitais; Gyo exige foco ocular).
- **En + Gyo:** Coexistem (o caçador sustenta sua cúpula sensorial enquanto inspeciona detalhes com a visão focada).

---

## 5. CAMADA CENTRAL DE PERCEPÇÃO (`PerceptionSystem`)

A percepção de monstros e a visibilidade de segredos não são calculadas de forma dispersa em cada entidade. Existe uma camada central autoritativa:
- **Linha de Visão (LOS) & Raio Efetivo:**
  $$\text{Raio Efetivo} = \text{Raio Base} \times (1.0 - \text{Fator Stealth Zetsu})$$
- **Detecção de Emissão de Aura:** Inimigos sensitivos a Nen detectam caçadores com Ren ativo a 130% da distância normal.
- **Estágios de Consciência de Inimigos:**
  $$\text{IDLE} \rightarrow \text{PATROL} \rightarrow \text{SUSPICIOUS} \rightarrow \text{ALERT} \rightarrow \text{CHASE} \rightarrow \text{ATTACK} \rightarrow \text{SEARCH} \rightarrow \text{RETURN}$$

---

## 6. MUNDO, NARRATIVA & CHECKPOINTS

- **Hub World Mandate:** O Lobby persistente (`world/lobby.tscn`) é o centro nevrálgico do jogo. Carregar qualquer save invoca o Hunter na praça do Hub World, onde o `StoryGatewayNPC` coordena a transição para a missão ativa.
- **Checkpoints Autoritativos:** Gerenciados pelo `StoryManager`, preservam a saga, o capítulo, o objetivo e a cena de destino exatos.
- **Missões Data-Driven:** Todas as missões seguem schemas estruturados (`MissionData`) sem lógica espalhada em scripts avulsos.

---

## 7. MAPA DE CONEXÃO ENTRE BIBLES

Para implementar ou auditar qualquer área do jogo, consulte o catálogo de Bibles dedicadas em `docs/bibles/`:

| Bible | Domínio / Responsabilidade |
| :--- | :--- |
| [`COMBAT_BIBLE.md`](file:///c:/Users/Ditec/Documents/hunteronline/docs/bibles/COMBAT_BIBLE.md) | Ataque básico, combos, hitboxes, cancel windows e escalonamento de dano. |
| [`NEN_BIBLE.md`](file:///c:/Users/Ditec/Documents/hunteronline/docs/bibles/NEN_BIBLE.md) | As 5 passivas, as 3 ativas, custos, dreno e matriz de conflitos. |
| [`HATSU_BIBLE.md`](file:///c:/Users/Ditec/Documents/hunteronline/docs/bibles/HATSU_BIBLE.md) | Os 4 slots de Hatsu, arquétipos, juramentos e balanceamento de recarga. |
| [`SKILL_TREE_BIBLE.md`](file:///c:/Users/Ditec/Documents/hunteronline/docs/bibles/SKILL_TREE_BIBLE.md) | Nós de progressão, pré-requisitos, custos e aplicação direta em `PlayerData`. |
| [`PERCEPTION_BIBLE.md`](file:///c:/Users/Ditec/Documents/hunteronline/docs/bibles/PERCEPTION_BIBLE.md) | Camada central `PerceptionSystem`, stealth, consciência e tiers de Gyo. |
| [`ENEMY_AI_BIBLE.md`](file:///c:/Users/Ditec/Documents/hunteronline/docs/bibles/ENEMY_AI_BIBLE.md) | Máquina de estados dos monstros, tabelas de ameaça (Aggro) e chefes. |
| [`GAME_FEEL_BIBLE.md`](file:///c:/Users/Ditec/Documents/hunteronline/docs/bibles/GAME_FEEL_BIBLE.md) | Hit stop, screenshake, números de dano, feedback sonoro e impacto visual. |
| [`NPC_BIBLE.md`](file:///c:/Users/Ditec/Documents/hunteronline/docs/bibles/NPC_BIBLE.md) | Arquitetura de NPCs desacoplados, rotinas, reações sociais e despachantes. |
| [`WORLD_BIBLE.md`](file:///c:/Users/Ditec/Documents/hunteronline/docs/bibles/WORLD_BIBLE.md) | Hub World, áreas selvagens, masmorras, persistência e spawner dinâmico. |
| [`STORY_BIBLE.md`](file:///c:/Users/Ditec/Documents/hunteronline/docs/bibles/STORY_BIBLE.md) | As 9 Sagas, capítulos canônicos, checkpoints e Story Gates. |
| [`MISSION_BIBLE.md`](file:///c:/Users/Ditec/Documents/hunteronline/docs/bibles/MISSION_BIBLE.md) | Missões principais, paralelas (PQ), caçadas e contratos data-driven. |
| [`FACTION_REPUTATION_BIBLE.md`](file:///c:/Users/Ditec/Documents/hunteronline/docs/bibles/FACTION_REPUTATION_BIBLE.md) | As 6 facções, matriz de alinhamento, descontos comerciais e reações. |
| [`ECONOMY_BIBLE.md`](file:///c:/Users/Ditec/Documents/hunteronline/docs/bibles/ECONOMY_BIBLE.md) | Moeda Jenny, fórmulas de precificação, recompensas e controle inflacionário. |
| [`EQUIPMENT_BIBLE.md`](file:///c:/Users/Ditec/Documents/hunteronline/docs/bibles/EQUIPMENT_BIBLE.md) | Armas, vestimentas, anéis e catalisadores que potencializam o Nen/Shu. |
| [`UI_UX_BIBLE.md`](file:///c:/Users/Ditec/Documents/hunteronline/docs/bibles/UI_UX_BIBLE.md) | HUD limpa, GPS contextual, feedback de status e árvore visual de habilidades. |
| [`PROGRESSION_BIBLE.md`](file:///c:/Users/Ditec/Documents/hunteronline/docs/bibles/PROGRESSION_BIBLE.md) | Fórmulas de XP, atributos primários e secundários, licença Hunter e ranks. |
| [`GAMEPLAY_BIBLE.md`](file:///c:/Users/Ditec/Documents/hunteronline/docs/bibles/GAMEPLAY_BIBLE.md) | Visão geral da experiência e ritmo de jogo minuto a minuto. |
| [`TECHNICAL_ARCHITECTURE_BIBLE.md`](file:///c:/Users/Ditec/Documents/hunteronline/docs/bibles/TECHNICAL_ARCHITECTURE_BIBLE.md) | Single Sources of Truth, EventBus, isolamento de camadas e regras de código. |
