# HUNTER MMORPG — MASTER REBUILD BLUEPRINT

## 1. VISÃO

Reconstruir o Hunter MMORPG praticamente do zero.

O projeto atual deve ser tratado como **protótipo de estilo e validação**, não como arquitetura definitiva. Podemos reaproveitar ideias, conhecimento e sistemas que funcionaram, mas a nova versão deve ser planejada para escalar.

Objetivo:

> Criar um MMORPG/RPG 2D top-down em pixel art inspirado em Hunter x Hunter, com mundo conectado, exploração, NPCs, quests, combate em tempo real, Nen, Hatsu customizável e progressão narrativa.

A sensação desejada é:

> "Estou vivendo uma aventura dentro do mundo de Hunter x Hunter."

E não:

> "Estou selecionando fases."

---

# 2. REFERÊNCIAS

## IconicQuest

Usar como referência estrutural e de experiência para:

- mundo conectado;
- cidades;
- estradas;
- regiões;
- NPCs;
- quests;
- combate em tempo real;
- exploração;
- progressão;
- dungeons;
- sensação de mundo.

**Não copiar código, assets ou conteúdo proprietário.**

## Pokémon GBA

Usar como referência para:

- exploração top-down;
- cidades;
- rotas;
- caminhos;
- descoberta;
- regiões conectadas;
- transições.

## Dragon Ball Xenoverse 1 e 2

Usar como referência para:

- sensação de estar dentro de uma franquia;
- personagens importantes;
- eventos;
- narrativa;
- conteúdo paralelo;
- progressão;
- mundo vivo.

## Hunter x Hunter

A identidade própria vem de:

- Nen;
- Hatsu;
- restrições;
- votos;
- estratégia;
- inteligência;
- personagens;
- sagas;
- mundo.

---

# 3. PRINCÍPIO DA RECONSTRUÇÃO

O projeto atual é:

> PROTOTYPE / REFERENCE

Não:

> FINAL ARCHITECTURE

A nova arquitetura deve priorizar:

- modularidade;
- escalabilidade;
- manutenção;
- testabilidade;
- sistemas desacoplados;
- dados separados da lógica;
- conteúdo orientado a dados;
- persistência;
- facilidade para adicionar regiões;
- facilidade para adicionar NPCs;
- facilidade para adicionar quests;
- facilidade para adicionar inimigos;
- facilidade para adicionar Hatsus.

---

# 4. GAME LOOP

CRIAR PERSONAGEM
↓
LOBBY / HUB
↓
EXPLORAR
↓
ENCONTRAR NPCs
↓
RECEBER QUESTS
↓
EXPLORAR REGIÕES
↓
COMBATER
↓
PROGREDIR
↓
DESBLOQUEAR HISTÓRIA
↓
DESENVOLVER NEN
↓
CRIAR HATSU
↓
NOVOS DESAFIOS
↓
NOVAS REGIÕES
↓
PRÓXIMAS SAGAS

---

# 5. MUNDO CONECTADO

Não construir:

LOBBY → MENU → FASE → TELEPORT → FASE

Construir:

LOBBY → CIDADE → ESTRADA → FLORESTA → DUNGEON → CIDADE → OUTRA REGIÃO

O jogador deve caminhar fisicamente pelo mundo.

Pode ser um **semi-open world / connected world**.

Não é necessário criar uma única cena gigantesca.

---

# 6. ESTRUTURA DO WORLD

WORLD
├── HUBS
├── CITIES
├── ROUTES
├── FORESTS
├── DUNGEONS
├── SPECIAL LOCATIONS
├── STORY LOCATIONS
└── PORTALS / TRANSITIONS

Cada região deve possuir identidade própria.

---

# 7. REGIÕES

Criar definições orientadas a dados.

Exemplo:

RegionDefinition

- id
- display_name
- saga_id
- scene_path
- spawn_points
- exits
- NPCs
- enemy_spawns
- quests
- story_requirements
- unlocked

---

# 8. SPAWN E CHECKPOINTS

O jogador deve possuir:

- spawn inicial;
- spawn por região;
- checkpoints;
- respawn;
- último local salvo.

A lógica deve pertencer ao sistema de mundo, não ficar toda dentro do Player.

---

# 9. TRANSIÇÕES

PLAYER
↓
ENTRADA / SAÍDA / PORTAL
↓
TRANSITION
↓
NOVA REGIÃO
↓
DESTINATION SPAWN

Preservar:

- PlayerData;
- XP;
- Level;
- atributos;
- Nen;
- Hatsus;
- inventário;
- quests;
- StoryState.

---

# 10. SAGAS

A história deve ser dividida em grandes sagas.

Exemplo:

- Hunter Exam
- Heavens Arena
- Yorknew
- Greed Island
- Chimera Ant
- Election
- Ship
- Dark Continent

A estrutura deve permitir expansão.

---

# 11. PORTAIS

Portais representam transições importantes entre sagas/regiões.

Exemplo:

HUNTER EXAM COMPLETED
↓
PORTAL
↓
PRÓXIMA REGIÃO

Um portal pode exigir:

- quest;
- boss;
- story flag;
- evento;
- nível;
- condição.

Não permitir progressão antes dos requisitos.

---

# 12. HISTÓRIA

A história deve acontecer dentro do mundo.

Em vez de:

NPC → selecionar arco → teleporte

usar:

EXPLORAÇÃO
↓
NPC
↓
DIÁLOGO
↓
EVENTO
↓
QUEST
↓
COMBATE
↓
CONSEQUÊNCIA
↓
PRÓXIMO EVENTO

O antigo NPC central de história pode ser mantido se tiver conteúdo útil, mas não deve ser responsável por transportar o jogador entre todas as fases.

---

# 13. NPCs

NPCs são parte essencial do mundo.

Cada NPC pode possuir:

- identidade;
- diálogo;
- localização;
- rotina;
- relacionamento;
- quests;
- informações;
- eventos;
- requisitos;
- reação ao StoryState.

Categorias:

- Story NPC
- Quest NPC
- Merchant
- Trainer
- Hunter
- Civilian
- Enemy
- Boss
- Companion
- Important Character
- Hidden NPC
- Event NPC

---

# 14. NPCs VIVOS

Quando fizer sentido, NPCs podem possuir rotinas:

MANHÃ → mercado
TARDE → praça
NOITE → casa

Não é necessário aplicar a todos inicialmente.

---

# 15. QUEST SYSTEM

Quest orientada a dados.

QuestDefinition:

- id
- title
- description
- objectives
- rewards
- requirements
- story_flags
- NPC references
- region
- next_quest

Objectives:

- Kill
- Collect
- Talk
- Escort
- Reach
- Interact
- Protect
- Survive
- Investigate
- Find
- Deliver
- Defeat Boss
- Trigger Event
- Learn Ability
- Complete Condition

---

# 16. QUEST CHAINS

QUEST 001
↓
QUEST 002
↓
QUEST 003
↓
QUEST 004
↓
STORY EVENT

Missões paralelas devem existir separadas da linha principal.

---

# 17. WORLD EVENTS

A arquitetura deve permitir:

- NPC aparecer;
- NPC desaparecer;
- inimigos aparecerem;
- boss aparecer;
- portal desbloquear;
- região mudar;
- diálogo mudar;
- quest iniciar;
- evento iniciar;
- cutscene iniciar.

---

# 18. STORY STATE

Criar ou reutilizar um sistema central de progresso.

Exemplos:

hunter_exam_started
hunter_exam_stage_1
hunter_exam_stage_2
hunter_exam_completed
greed_island_unlocked

Não duplicar sistemas de progresso.

---

# 19. COMBATE

Combate em tempo real.

Base:

- movimento;
- ataque;
- hitbox;
- hurtbox;
- dano;
- defesa;
- knockback;
- esquiva;
- cooldown;
- Aura quando aplicável.

O combate não deve ser simplesmente:

HP + DANO.

---

# 20. INIMIGOS

Inimigos devem possuir diferenças reais.

Exemplos:

- lento/resistente;
- rápido/frágil;
- ranged;
- emboscada;
- fuga;
- usuário de Nen;
- usuário de Hatsu.

Arquitetura:

EnemyDefinition
EnemyAI
EnemyCombat
EnemyHealth
EnemySpawner
EnemyLoot

---

# 21. ENEMY AI

Estados possíveis:

- IDLE
- PATROL
- INVESTIGATE
- CHASE
- ATTACK
- EVADE
- FLEE
- SEARCH
- STUNNED
- DEAD

---

# 22. NEN

Categorias:

- Reforço
- Emissão
- Transformação
- Conjuração
- Manipulação
- Especialização

Técnicas:

- Ten
- Zetsu
- Ren
- Gyo
- Shu
- Ko

Funções planejadas:

Ten → reduzir dano
Zetsu → regenerar vida
Ren → aumentar alcance de ataque
Gyo → aumentar esquiva
Shu → reservado para expansão
Ko → aumentar dano

Valores devem ser configuráveis.

---

# 23. HATSU

Hatsu é o maior diferencial do jogo.

O jogador deve conseguir criar habilidades customizadas.

HatsuDefinition:

- id
- name
- category
- archetype
- effects
- components
- conditions
- restrictions
- vows
- costs
- cooldown
- range
- area
- duration
- power_budget
- deficit
- visual_profile

---

# 24. HATSU ENGINE

Todos os Hatsus devem convergir para:

HatsuDefinition
↓
HatsuEngine

Evitar criar um executor separado para cada habilidade.

---

# 25. HATSU CREATOR

IDEIA
↓
CATEGORIA
↓
ARQUÉTIPO
↓
EFEITOS
↓
CONDIÇÕES
↓
RESTRIÇÕES
↓
VOTOS
↓
CUSTOS
↓
POWER BUDGET
↓
VALIDAÇÃO
↓
VISUAL
↓
HATSU FINAL

---

# 26. HATSU IA

Futuramente permitir que uma IA interprete:

- texto digitado;
- escolhas;
- intenção;
- categoria;
- efeito desejado.

A IA deve ajudar a transformar ideias em Hatsus jogáveis.

Não deve conceder poder ilimitado.

---

# 27. ESPECIALISTA

Especialista não deve ser:

"todas as outras categorias juntas."

Deve ser uma categoria de mecânicas:

- conceituais;
- anômalas;
- excepcionais;
- baseadas em regras próprias.

Possíveis arquétipos:

- Ability Theft
- Storage
- Information
- Future Sight
- Fate
- Probability
- Rule Creation
- Contract
- Memory
- Identity
- Condition Manipulation
- Cooldown Manipulation
- Ability Fusion
- Ability Evolution
- Copy
- Adaptive
- Randomization
- Resource Exchange

---

# 28. RESTRIÇÕES E VOTOS

Quanto mais extraordinário o Hatsu:

maior o preço.

Ferramentas:

- condição;
- restrição;
- voto;
- custo;
- cooldown;
- preparação;
- risco;
- limite de usos;
- limite de alvo;
- limite de alcance.

Se a ideia for poderosa demais:

IDEIA
↓
POWER BUDGET
↓
DÉFICIT
↓
SUGESTÕES DE LIMITAÇÕES
↓
JOGADOR ESCOLHE
↓
RECALCULAR

Não bloquear automaticamente ideias criativas.

---

# 29. HATSU BOOK

O jogador deve possuir:

- Owned
- Learned
- Captured
- Temporary
- Locked

Futuramente permitir:

- armazenar;
- equipar;
- trocar;
- capturar;
- usar múltiplos Hatsus.

---

# 30. ABILITY THEFT

Fluxo:

OBSERVE
↓
IDENTIFY
↓
CONDITION
↓
CAPTURE
↓
STORE
↓
VALIDATE
↓
EXECUTE

Hatsus capturados devem possuir suas próprias condições e restrições.

---

# 31. HATSU HUD

Ao ativar:

GODSPEED ON

ARCHIVE ON

etc.

Também mostrar:

- ACTIVE
- READY
- COOLDOWN
- LOCKED

---

# 32. CONDITION HUD

Para Hatsus condicionais:

CONDITIONS

✓ Observar inimigo 1/1
✓ Identificar habilidade 1/1
○ Tocar alvo 0/1
○ Completar captura 0/1

Quando completo:

HATSU READY

---

# 33. VISUAIS DE HATSU

Priorizar recursos procedurais do Godot:

- partículas;
- shaders;
- trails;
- círculos;
- linhas;
- flashes;
- glow;
- AnimationPlayer;
- Tween;
- GPUParticles;
- CanvasItem shaders.

Não depender obrigatoriamente de sprites.

---

# 34. CORES CUSTOMIZÁVEIS

Hatsus devem possuir VisualProfile.

O jogador pode escolher, quando aplicável:

- cor;
- intensidade;
- tamanho;
- trail;
- brilho.

Visual deve ser separado da lógica.

---

# 35. UI

Menus modulares:

- Status
- Hatsu
- Nen
- Inventory
- Quest
- Map
- Settings

Não colocar lógica de gameplay dentro da UI.

---

# 36. MAPA

Futuramente mostrar:

- região;
- cidade;
- NPC;
- quest;
- objetivo;
- portal;
- dungeon;
- checkpoint.

---

# 37. INVENTÁRIO

Separar:

ItemDefinition
ItemInstance
InventorySystem

Preparar para:

- equipamentos;
- itens de quest;
- recursos;
- objetos Nen;
- itens especiais.

---

# 38. SAVE

Salvar:

- Player;
- Level;
- XP;
- atributos;
- Nen;
- Hatsus;
- Hatsu Book;
- Inventory;
- Quests;
- StoryState;
- regiões desbloqueadas;
- checkpoints.

---

# 39. PLAYER DATA

PlayerData deve ser fonte central dos dados persistentes.

Não colocar toda a lógica no PlayerData.

Separar:

DATA
de
SYSTEMS.

---

# 40. DATA-DRIVEN DESIGN

Sempre que possível:

CONTEÚDO → DATA
LÓGICA → SYSTEM

Exemplo:

QuestDefinition
EnemyDefinition
HatsuDefinition
RegionDefinition

Evitar centenas de scripts específicos com dados hardcoded.

---

# 41. INTEGRAÇÃO ENTRE SISTEMAS

NPC
→ Quest

Quest
→ StoryState

StoryState
→ Região desbloqueada

Região
→ Portal

Portal
→ Próxima saga

NPC
→ Hatsu

Hatsu
→ Combate

Tudo deve utilizar interfaces/estados bem definidos.

---

# 42. MULTIPLAYER FUTURO

Mesmo que a primeira versão seja single-player/local:

Separar:

- Player State;
- World State;
- Entity State;
- Combat State;
- Quest State.

Não construir sistemas que dependam de variáveis globais impossíveis de sincronizar futuramente.

---

# 43. PERFORMANCE

Planejar:

- spawning;
- despawning;
- object pooling quando necessário;
- transições;
- carregamento;
- partículas;
- limites de NPCs;
- inimigos ativos.

Não otimizar prematuramente, mas evitar arquitetura impossível de escalar.

---

# 44. VERTICAL SLICE

Não construir o mundo inteiro imediatamente.

Primeiro criar uma pequena parte totalmente funcional:

LOBBY
↓
CIDADE
↓
ESTRADA
↓
FLORESTA
↓
NPC
↓
QUEST
↓
3 MOBS
↓
COMBATE
↓
RECOMPENSA
↓
PORTAL
↓
PRÓXIMA ÁREA

Tudo deve funcionar antes de expandir.

---

# 45. TESTE DO VERTICAL SLICE

Verificar:

- lobby;
- spawn;
- movimentação;
- NPC;
- diálogo;
- quest;
- objetivos;
- inimigos;
- combate;
- XP;
- Level;
- Nen;
- Hatsu;
- Save;
- Load;
- portal;
- transição;
- persistência.

---

# 46. ESCALA DO MUNDO

Não é necessário ter uma única cena enorme.

Criar sensação de mundo através de:

- estradas;
- cidades;
- florestas;
- dungeons;
- caminhos alternativos;
- áreas secretas;
- landmarks;
- NPCs;
- quests;
- eventos;
- distância entre objetivos.

---

# 47. ESCALA DA HISTÓRIA

Uma saga deve parecer uma jornada.

Não:

Saga
→ missão
→ missão
→ missão
→ boss.

Sim:

Saga
→ cidade
→ NPCs
→ exploração
→ pequenas histórias
→ quests
→ viagem
→ eventos
→ conflito
→ dungeon
→ boss
→ consequências
→ nova região.

---

# 48. FILOSOFIA DE DESIGN

Recompensar:

- exploração;
- estratégia;
- preparação;
- criatividade;
- conhecimento;
- experimentação.

Não usar apenas:

DANO MAIOR = VITÓRIA.

O jogador deve poder vencer através de inteligência.

---

# 49. IDENTIDADE HUNTER X HUNTER

A identidade deve aparecer em:

- Nen;
- Hatsu;
- restrições;
- votos;
- personagens;
- diálogos;
- missões;
- conflitos;
- mundo;
- combate estratégico.

---

# 50. ROADMAP

## Fase 0
Documentação.

Criar/atualizar:

- GDD;
- Architecture Bible;
- World Bible;
- Quest Bible;
- Enemy Bible;
- Nen Bible;
- Hatsu Bible;
- UI Bible.

## Fase 1
Core:

- GameManager;
- SceneManager;
- SaveManager;
- PlayerData;
- WorldManager;
- EventBus.

## Fase 2
Player:

- movimento;
- animação;
- combate;
- hitbox;
- hurtbox;
- atributos.

## Fase 3
World:

- mapa;
- regiões;
- cidades;
- estradas;
- spawn;
- checkpoints;
- transições.

## Fase 4
NPC:

- interação;
- diálogo;
- definitions;
- states.

## Fase 5
Quest:

- QuestDefinition;
- QuestManager;
- objectives;
- QuestTracker;
- Quest HUD.

## Fase 6
Enemies:

- EnemyDefinition;
- EnemyAI;
- EnemyCombat;
- EnemyHealth;
- EnemySpawner;
- loot.

## Fase 7
Nen:

- Ten;
- Zetsu;
- Ren;
- Gyo;
- Shu;
- Ko.

## Fase 8
Hatsu:

- HatsuDefinition;
- HatsuEngine;
- HatsuCreator;
- restrictions;
- conditions;
- Power Budget;
- VisualProfile.

## Fase 9
Especialista:

- arquétipos;
- Hatsu Book;
- Ability Theft;
- Storage;
- Conditions;
- Specialist Creator.

## Fase 10
Story:

- sagas;
- StoryState;
- eventos;
- personagens;
- progressão.

## Fase 11
Polish:

- efeitos;
- UI;
- áudio;
- animações;
- feedback;
- balanceamento.

---

# 51. REGRA PARA O AGENTE

Antes de implementar qualquer coisa:

1. Ler esta documentação.
2. Auditar o projeto.
3. Identificar sistemas reutilizáveis.
4. Identificar sistemas que devem ser descartados.
5. Mapear dependências.
6. Implementar em pequenas etapas.
7. Testar.
8. Documentar.
9. Só então avançar.

Não criar scripts aleatoriamente.

Não duplicar sistemas.

Não carregar arquitetura ruim do protótipo apenas porque já existe.

---

# 52. DEFINIÇÃO DE SUCESSO

Quando o jogador entrar no jogo:

> "Onde eu vou agora?"

e não:

> "Qual fase eu seleciono?"

Quando encontrar um NPC:

> "O que será que ele sabe?"

Quando encontrar um inimigo:

> "Como essa criatura luta?"

Quando encontrar um usuário de Nen:

> "Qual é o Hatsu dele?"

Quando criar um Hatsu:

> "Como posso fazer minha ideia funcionar?"

Quando chegar a uma nova região:

> "O que existe depois daquela estrada?"

---

# 53. FILOSOFIA FINAL

O protótipo antigo serviu para responder:

> "Esse estilo funciona?"

A nova versão precisa responder:

> "Como construir um mundo de Hunter x Hunter no qual o jogador possa realmente viver uma aventura?"

O jogo deve combinar:

ICONICQUEST
→ estrutura de MMORPG e exploração

POKÉMON GBA
→ exploração top-down e mundo conectado

XENOVERSE
→ sensação de estar dentro de uma franquia

HUNTER X HUNTER
→ identidade, Nen, estratégia e narrativa

HATSU CUSTOM
→ liberdade criativa do jogador

O resultado deve possuir identidade própria.

---

# FIM
