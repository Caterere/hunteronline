# HUNTER ONLINE — ARCHITECTURE SPECIFICATION (v1.0 PRODUCTION)

Este documento define a arquitetura oficial do projeto Hunter Online, estabelecendo limites claros de responsabilidade e fluxos de comunicação entre subsistemas.

---

## 1. DOMÍNIOS ARQUITETURAIS & RESPONSABILIDADES

### 🏛️ 1. CORE & INFRAESTRUTURA
- **`EventBus` (`autoload/EventBus.gd`)**: Barramento global de sinais desacoplados (jogador, combate, nen, quests, mundo, economia, rede e interface).
- **`GameManager` (`autoload/GameManager.gd`)**: Coordenador do ciclo de vida global da aplicação (estados BOOT, MAIN_MENU, CHARACTER_CREATION, IN_GAME, PAUSED, CUTSCENE, GAME_OVER) e registro da instância ativa do jogador.
- **`DataManager` (`autoload/DataManager.gd`)**: Repositório estático central de dados com busca O(1) de Itens, Equipamentos e Modelos de Inimigos (`EnemyData`).
- **`TimeManager` (`autoload/TimeManager.gd`)**: Relógio mundial contínuo, ciclo dia/noite e fases solares (DAWN, DAY, DUSK, NIGHT) que regem horários de NPCs e eventos.
- **`AudioManager` (`autoload/AudioManager.gd`)**: Gerenciador de trilhas canônicas com crossfade progressivo e canais de áudio.

---

### 👤 2. PLAYER & ENTITY
- **`Player` (`entities/Player/Player.gd`)**: Controlador físico (`CharacterBody2D`) responsável por input de movimentação, dash, disparo de ataque e atualização da árvore de animação (`AnimationTree`). Integra os componentes especializados sem centralizar regras de cálculo.
- **`PlayerData` (`autoload/PlayerData.gd`)**: Repositório dinâmico de estado do personagem (Nome, Afinidade, Dificuldade, Títulos, Inventário, Arcos de História, Quests Ativas e Bestas de Nen).
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

### 📜 5. HATSU SYSTEM (LEGADO APROVADO)
- **`HatsuManager` (`autoload/HatsuManager.gd`)**: Autoload e Nen Judge Engine. Analisador Semântico Inteligente de Juramentos, fábrica de Hatsu e Grimório de habilidades.
- **`HatsuSystem` (`scripts/systems/HatsuSystem.gd`)**: Execução de habilidades nos 4 slots ativos do jogador, processamento de votos/juramentos (Pain Packer, Godspeed, Guanyin Bodhisattva, Crazy Slots, Chain Prison), escudos elementais e colheita de almas.

---

### 👾 6. PVE & INIMIGOS
- **`EnemySystem` (`scripts/systems/EnemySystem/EnemySystem.gd`)**: Gerenciamento de ciclo de vida de inimigos (HP, Defesa, Força, Postura/Stagger, Vulnerabilidades de Gyo, Drops e XP).
- **`EnemyAI` (`scripts/systems/EnemySystem/EnemyAI.gd`)**: Máquina de estados de IA (Patrulha, Perseguição, Ataque, Stagger e Morte).

---

### 🧭 7. QUEST SYSTEM
- **`QuestManager` (`scripts/QuestManager.gd` / Autoload `QuestSystem`)**: Rastreamento de missões ativas, avaliação de pré-requisitos, despacho de objetivos (Kill, Visit, Collect, Reach, Interact) e concessão de recompensas.
- **`CanonQuestCatalog` (`resource/quest/CanonQuestCatalog.gd`)**: Definições das 6 etapas canônicas por arco da história.

---

### 🗺️ 8. WORLD & CONTENT DIRECTOR
- **`RegionWorldGenerator` (`world/generator/RegionWorldGenerator.gd`)**: Construtor do mundo 512x512 tiles utilizando o `TileDatabase` e `RoomComposer`.
- **`TileDatabase` (`world/catalog/TileDatabase.gd`)**: Catálogo semântico de tiles (Floor, Wall, Door, Furniture, Decoration) desacoplado de coordenadas hardcoded.
- **`ContentDirector` (`world/content/ContentDirector.gd`)**: Gestão de densidade espacial de NPCs, Encontros Ambientais, Eventos Mundiais e POIs baseado em zonas de risco (SAFE, LOW, MEDIUM, HIGH, DANGER).
- **`WorldChunkLoader` (`world/components/WorldChunkLoader.gd`)**: Streaming de chunks e ciclo de vida de entidades distantes.

---

### 💾 9. SAVE & LOAD
- **`SaveManager` (`autoload/SaveManager.gd`)**: Persistência multi-slot unificada em `user://savegame_slot_%d.json`. Salva o estado consolidado: PlayerData, Economy, WorldState, Quests, Nen, Hatsu, Bestas de Nen e Posição.

---

### 🖥️ 10. UI & APRESENTAÇÃO
- **Princípio Fundamental**: A UI apenas observa e envia intenções aos sistemas; a UI não calcula atributos nem gerencia regras de gameplay.
- **Componentes**: `PlayerHUD`, `StatusMenu`, `NenMenu`, `HatsuBookUI`, `InventoryUI`, `ShopUI`, `BlacksmithUI`, `VisualDialogueUI`.

---

### 🌐 11. NETWORK & MMORPG PREPARATION
- **`NetworkProtocol` (`scripts/network/NetworkProtocol.gd`)**: Estrutura de pacotes binários e opcodes (movimento, combate, nen, chat, inventário) preparada para modelo Server-Authoritative.
