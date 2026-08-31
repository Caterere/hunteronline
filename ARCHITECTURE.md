# HUNTER ONLINE — ARCHITECTURE SPECIFICATION (v2.0 PRODUCTION)

Este documento define a arquitetura oficial do projeto Hunter Online, estabelecendo limites claros de responsabilidade e fluxos de comunicação entre subsistemas.

---

## 1. DOMÍNIOS ARQUITETURAIS & RESPONSABILIDADES

### 🏛️ 1. CORE & INFRAESTRUTURA
- **`EventBus` (`autoload/EventBus.gd`)**: Barramento global de sinais desacoplados (jogador, combate, nen, quests, mundo, economia, rede e interface).
- **`GameManager` (`autoload/GameManager.gd`)**: Coordenador do ciclo de vida global da aplicação (estados BOOT, MAIN_MENU, CHARACTER_CREATION, IN_GAME, PAUSED, CUTSCENE, GAME_OVER) e registro da instância ativa do jogador.
- **`WorldProgressionManager` (`autoload/WorldProgressionManager.gd`)**: Gerenciador de mundo contínuo e progressão de mapas (estilo Pokémon/Xenoverse). Mantém o catálogo de regiões, registro dinâmico de instâncias de `SpawnPoint`, checkpoints e posicionamento preciso do Player em transições de cena.
- **`SceneTransition` (`autoload/SceneTransition.gd`)**: Orquestrador de transição de telas com fade suave, carregamento assíncrono e posicionamento automático no `target_spawn_id`.
- **`DataManager` (`autoload/DataManager.gd`)**: Repositório estático central de dados com busca O(1) de Itens, Equipamentos e Modelos de Inimigos (`EnemyData`).
- **`TimeManager` (`autoload/TimeManager.gd`)**: Relógio mundial contínuo, ciclo dia/noite e fases solares (DAWN, DAY, DUSK, NIGHT) que regem iluminação, horários de NPCs e eventos dinâmicos.
- **`AudioManager` (`autoload/AudioManager.gd`)**: Gerenciador de trilhas canônicas com crossfade progressivo, canais de áudio dedicados e SFX de combate.

---

### 👤 2. PLAYER & ENTITY
- **`Player` (`entities/Player/Player.gd`)**: Controlador físico (`CharacterBody2D`) responsável por input de movimentação, dash, disparo de ataque e atualização da árvore de animação (`AnimationTree`). Integra os componentes especializados sem centralizar regras de cálculo. Auto-posiciona-se no spawn registrado via `WorldProgressionManager` ao inicializar a cena.
- **`PlayerData` (`autoload/PlayerData.gd`)**: Repositório dinâmico de estado do personagem (Nome, Afinidade, Dificuldade, Títulos, Inventário, Arcos de História, Quests Ativas, Catálogo de Hatsu criado com `hatsu_id` único, 4 Slots de Hatsu Ativos e Bestas de Nen).
- **`XPSystem` (`scripts/systems/XPSystem.gd`)**: Gerencia o ganho de experiência, cálculo de curva de nível normal e disparo de eventos de Level Up.

---

### ⚔️ 3. COMBAT & FEEDBACK
- **`CombatEngine` (`autoload/CombatEngine.gd`)**: Motor central matemático de combate. Realiza o cálculo autoritativo de dano considerando:
  $$\text{Dano Final} = \max(1, (\text{Dano Base} + \text{Força}) \times \text{Nen Mult} \times \text{Hatsu Mult} - \text{Defesa} - \text{Ten/Ken/Ryu Mitigações})$$
- **`HunterCombatSystem` (`scripts/combat/CombatSystem.gd`)**: Componente acoplado ao Player que processa ações táticas de combate: hitbox de ataque, timing de esquiva com invulnerabilidade (i-frames), perfect dodge (bullet time), knockback e gatilho de morte.
- **`DamageNumber` (`scripts/ui/Damage/DamageNumber.gd`)**: Feedback visual de dano flutuante na tela (dano físico, crítico de Ko, acertos furtivos e mitigação de Ten).

---

### 🌀 4. NEN SYSTEM
- **`NenSystem` (`scripts/systems/NenSystem.gd`)**: Controlador em tempo real das 10 técnicas canônicas:
  - **Básicas**: Ten (mitigação), Zetsu (cura/ocultação), Ren (alcance/pressão), Hatsu (habilidades).
  - **Avançadas**: Gyo (visão/crítico), Ko (dano concentrado), En (radar espacial), Shu (reforço de objetos), Ken (defesa total), Ryu (distribuição percentual de aura).
- **Regeneração de Aura**: Controlada pelo `NenSystem` de acordo com a taxa por segundo e estado de combate.

---

### 📜 5. HATSU SYSTEM (v2.0 REBALANCEADO)
- **`HatsuData` (`resource/hatsu/HatsuData.gd`)**: Recurso de definição de Hatsu contendo identificador único (`hatsu_id`), categoria, parâmetros base, metadados de juramento e cálculos:
  - **Demanda Não-Linear de Poder**: $\le 30$ ($1.0\times$), $31-60$ ($1.5\times$), $61-100$ ($2.5\times$), $>100$ ($4.0\times$).
  - **Limitation Credits Budget**: Base inata de 15 créditos + créditos justos por custos pesados, cooldowns longos e juramentos.
  - **Diminishing Returns de Combate**: Proteção suave contra empilhamento de multiplicadores leves acima de $+100\%$.
- **`HatsuComponentLibrary` (`resource/hatsu/HatsuComponentLibrary.gd`)**: Catálogo modular de Cores, Efeitos, Condições, Restrições e Drawbacks com metadados de custo e risco.
- **`HatsuManager` (`autoload/HatsuManager.gd`)**: Autoload do motor de Hatsu. Analisador Semântico Inteligente de Juramentos (`analisar_juramento_inteligente`), validação de equilíbrio e templates canônicos data-driven.
- **`HatsuSystem` (`scripts/systems/HatsuSystem.gd`)**: Execução das técnicas nos 4 slots ativos de combate com verificação de canais, consumo de aura e penalidades de juramento.

---

### 👾 6. PVE & INIMIGOS
- **`EnemySystem` (`scripts/systems/EnemySystem/EnemySystem.gd`)**: Gerenciamento de ciclo de vida de inimigos (HP, Defesa, Força, Postura/Stagger, Vulnerabilidades de Gyo, Drops e XP).
- **`EnemyAI` (`scripts/systems/EnemySystem/EnemyAI.gd`)**: Máquina de estados de IA com suporte a 4 papéis táticos (Bruiser, Fast, Tank, Ambusher) e telegrafia de ataque (`PREPARE_ATTACK`).

---

### 🧭 7. QUEST SYSTEM
- **`QuestManager` (`scripts/QuestManager.gd` / Autoload `QuestSystem`)**: Rastreamento de missões ativas, avaliação de pré-requisitos, despacho de objetivos (Kill, Visit, Collect, Reach, Interact) e concessão de recompensas.
- **`CanonQuestCatalog` (`resource/quest/CanonQuestCatalog.gd`)**: Definições das etapas canônicas por arco da história.
- **`SurpriseQuestSystem` (`autoload/SurpriseQuestSystem.gd`)**: Missões dinâmicas de oportunidade desencadeadas por exploração e eventos mundiais.

---

### 🗺️ 8. WORLD & EXPLORAÇÃO CONTÍNUA
- **`SpawnPoint` (`entities/world/SpawnPoint.gd`)**: Componente posicional instalado em entradas, saídas, portões e retornos de mapa com registro automático no `WorldProgressionManager`.
- **`MapTransitionArea` (`world/components/MapTransitionArea.gd`)**: Gatilho físico `Area2D` para viagem entre mapas que dispara `SceneTransition` informando o `target_spawn_id`.
- **`StoryGate`**: Portões com verificação de requisitos (Nível e Quests Canônicas) para liberar o avanço do jogador.
- **`RegionWorldGenerator` (`world/generator/RegionWorldGenerator.gd`) & `TileDatabase`**: Construtor semântico de biomas e streaming de chunks via `WorldChunkLoader`.

---

### 💾 9. SAVE & LOAD
- **`SaveManager` (`autoload/SaveManager.gd`)**: Persistência multi-slot unificada em `user://savegame_slot_%d.json`. Salva o estado consolidado: PlayerData, Economy, WorldState, Quests, Nen, Hatsu (com IDs e slots equipados), Bestas de Nen e Posição/Mapa atual.

---

### 🖥️ 10. UI & APRESENTAÇÃO
- **Princípio Fundamental**: A UI apenas observa e envia intenções aos sistemas; a UI não calcula atributos nem gerencia regras de gameplay.
- **Componentes**: `PlayerHUD`, `StatusMenu`, `HunterMenuUI` (Menu integrado com Abas de Status, Nen, Hatsu com gestão de 4 slots ativos, Besta de Nen e Missões), `HatsuCreationUI` (Criador com auditoria de créditos dinâmica), `InventoryUI`, `ShopUI`, `BlacksmithUI`, `VisualDialogueUI`.

---

### 🌐 11. NETWORK & MMORPG PREPARATION
- **`NetworkProtocol` (`scripts/network/NetworkProtocol.gd`)**: Estrutura de pacotes binários e opcodes (movimento, combate, nen, chat, inventário) preparada para modelo Server-Authoritative.
