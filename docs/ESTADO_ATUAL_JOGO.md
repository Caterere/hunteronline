# Hunter Online — Estado Atual do Jogo (Handoff para Agente)

> **Data do snapshot:** 2026-09-18 (atualizado na sessão A–D)  
> **Branch de trabalho:** `cursor/session-abcd-merge48-dab2` (PR #51)  
> **Branch base histórico:** `main` @ handoff + merge PR #48  
> **Objetivo deste doc:** handoff completo para outro agent continuar o trabalho sem redescobrir o projeto.  
> **Regra de ouro:** código e cenas vencem docs desatualizados. Em conflito design vs código → preferir código e reportar.

---

## 0. Decisões de produto (Luiz — 2026-09-18)

| Tema | Decisão |
| :--- | :--- |
| Escopo sessão | **A B C D** (early clarity, Nen no mundo, sagas densas, co-op polish leve). Arte (**E**) fica com o Luiz. |
| PR #48 Tier B | **Mergiar** (feito neste branch). |
| Dor early | Assuntos **vagos** + mapa vazio + tutorial Nen fraco → **também**: move speed alto demais (rush, sem espaço pra Hatsu, objetivos misturados). |
| Ritmo sagas | Até **Arena Celestial**: mais rápido/compacto. **Yorknew / Greed Island+**: mais longos, imersivos, difíceis, muita caminhada. |
| Nen no mundo | Semiaberto/missões; **não** forçar no lobby. |
| Hatsu | Feel com **espaço de combate** (speeds ↓) + polish afinidades na ordem Intensificação→Emissão→Transformação→Conjuração→Manipulação→Especialização. Unlock **Biscuit**. |
| Mapa vivo | NPCs andando + estruturas + marcador **?** / **!** pequeno stylized em NPCs de quest. |
| Tom NPC | **Mentor direto** (diz o que fazer). |
| Raid Ruínas | **Polish solo feito** (telegraph legível, wipe, pacing). |
| Multiplayer | **Solo-first**; LAN depois. |
| Tom | Sandbox MMO com HxH adaptado. |

### Backlog explícito (não esquecer)
- [x] **Raid Ruínas de Zaban — polish solo** (telegraph, wipe legível, pacing)
- [x] Densidade Kukuroo / Arena (NPCs andando + falas diretas + props)
- [x] **Trilha B — Nen no mundo** (sensores Floresta/Ruínas + 2 quests investigativas)
- [x] **Yorknew imersão** (walkers, falas diretas, clues canônicos plantados, etapas 1–8/13/21 claras)
- [x] **Greed Island imersão** (densidade Antokiba→Castelo, clues canônicos, ORDEM early + Bomber/Cova)
- [x] **Greed Island mid/late polish** (Hisoka/Killua no mapa, ORDEM 9–36, demônios missão, toasts Aliança/Ginásio/Bomber)
- [x] **NGL imersão early** (Fronteira→Peijin densificado, clues canônicos 4/16/18/22/26, ORDEM 1–26)
- [x] **NGL mid/late polish** (Escadaria/Tumba, Guanyin/Rosa Pobre, Youpi/Pouf garantidos, ORDEM 27–48)
- [x] **Associação / Alluka imersão** (Auditório→Tribuna, cela_alluka, Alluka NPC, ORDEM 1–20)
- [x] **Continente Negro imersão** (Acampamento→Topo, clues Mobius/Brion/Hellbell/Horizonte, ORDEM 1–22)
- [x] **Black Whale / Sucessão imersão** (Convés1→Profundos, clues assassinato/Heil-Ly/Besta, ORDEM 1–26)
- [x] **Yorknew ORDEM mid/late** (etapas 9–34 + clues `copia_kortopi` / `memoria_pakunoda` / `fita_ging` / `galpao_machinobunaga`)
- [x] **Validação ritmo Yorknew→Whale** (battery suites + `test_session_abcd_final_smoke_suite` 31/31)
- [x] **Co-op polish leve** (raid solo polish já shipado; suite assertions verdes — exit 134 = leak conhecido)

### Progresso desta sessão
- [x] Merge PR #48
- [x] Tutorial Nen + Wing + quest Padokia clara + vila viva
- [x] ContentDirector spawns reais + toasts Exame
- [x] Feel Hatsu (canalização + impacto) + gate Biscuit
- [x] **Move speed ↓** player (~112) + enemies (~58) + dodge; CD inimigo ↑ — espaço pra Hatsu / menos rush
- [x] **QuestMarkerBillboard** (? / !) em NPCs com objetivo/oferta/entrega
- [x] Mentores mais diretos (Elena/Wing) + quest Padokia “um de cada vez”
- [x] Telegraph Hatsu diferenciado por afinidade (ordem pedida)
- [x] **Densidade Kukuroo** — walkers + props + falas diretas + toasts de zona com próximo passo
- [x] **Densidade Arena** — espectadores/staff + props + placas com próximo passo
- [x] **Raid solo polish** — telegraph AoE ~1.2s, enrage warning 60s, wipe solo → checkpoint, adds reduzidos
- [x] **Nen no mundo (Trilha B)** — Floresta/Ruínas densificados; quests “Trilha de Aura” + “Selos do Guardião”; Ko registra INVESTIGATE; factory com props reais
- [x] **Yorknew imersão** — walkers/props/placas intermediárias; Gyo/Zetsu canônicos (`antiguidade_mercado`, `cofre_vazio_leilao`, `requiem_chrollo`, `apagao_yorknew`); falas diretas; canon etapas early com ORDEM
- [x] **Greed Island imersão** — densificação completa + clues (`livro_greed`, `desfiladeiro_biscuit`, `explosao_bomber`, `armadilha_cova_gon`, `quiz_100_cartas`); mentores ORDEM; suite `test_greed_island_immersion_suite`
- [x] **Greed Island mid/late** — Hisoka/Killua spawn; ORDEM etapas 9–36; toasts Aliança/Ginásio/Bomber; Gyo porto/ginásio/carta002/sopro; demônios/golems missão; walkers mid/late
- [x] **NGL imersão early** — densificação Fronteira→Tumba; clues (`fabrica_d2_gyro`, `nascimento_rei_meruem`, `fronteira_goruto`, `portas_knov`, `chuva_dragoes_zeno`); ORDEM 1–26; suite `test_ngl_formigas_immersion_suite`
- [x] **NGL mid/late** — toast Escadaria; Gyo Guanyin/Rosa/Youpi; Youpi/Pouf garantidos; ORDEM 27–48; walkers escadaria/tumba
- [x] **Associação / Alluka** — densificação Auditório→Tribuna; `cela_alluka`; Alluka NPC; mission mordomos/agulhas; ORDEM 1–20; suite `test_associacao_alluka_immersion_suite`
- [x] **Continente Negro** — densificação Acampamento→Topo; clues canon; Cheadle/GingTopo; ORDEM 1–22; suite `test_continente_negro_immersion_suite`
- [x] **Black Whale / Sucessão** — densificação Convés1→Máfia→Aposentos→Profundos; clues (`primeiro_assassinato_kakin`, `seita_heilly`, `besta_tserriednich`, `aposentos_tserriednich`); Hisoka/Cheadle; Chrollo persuasion; ORDEM 1–26; suite `test_black_whale_immersion_suite`
- [x] **Fechamento A–D** — Yorknew ORDEM 34/34 + clues mid/late; smoke `test_session_abcd_final_smoke_suite` (arcos 4–9); battery imersão 0 fails; merge PR #51
- [x] **Bugfix pós-merge** — Yorknew: Killua/Silva faltavam (etapas 16–17); fillers mafioso/clone; `chrollo_boss` id; suite progression match

---

## 0b. Como usar este handoff (leia primeiro)

1. Ler `Hunter Online — AGENTS.md` na raiz (regras de escopo, MODIFY DON'T REBUILD, save compatibility).
2. Design canônico SSOT: `docs/bibles/` (não `.agent/docs/bibles/` — essas são só pontes).
3. Índice mestre: `docs/README.md`.
4. Roadmap ativo: `docs/roadmap/PRODUCTION_ROADMAP.md`.
5. Backlog MMO: `docs/roadmap/MMO_FEATURES_BACKLOG.md`.
6. **Não criar sistemas novos** se já existir autoload/UI/script equivalente — estender.

---

## 1. Identidade do projeto

| Campo | Valor |
| :--- | :--- |
| Nome | **Hunter Online** |
| Engine | Godot **4.6** Forward Plus |
| Linguagem | GDScript 2.0 |
| Gênero | 2D top-down RPG / MMORPG |
| Universo | Inspirado em Hunter × Hunter |
| Cena inicial | `ui/CharacterSelection/CharacterSelectionUI.tscn` |
| Viewport | **960×540** (interno; stretch `canvas_items` / `expand`) — README ainda cita 640×360 (desatualizado) |
| Persistência | `SaveManager` direto (wrapper `GameState` removido) |
| Save schema | **v2.4** (`ContentVersionConfig`) |
| Diretriz de produção | Qualidade de gameplay > quantidade de sistemas · foco **COMBATE + NEN + HATSU + PROGRESSÃO** |

### Fantasia central
O jogador é autor da própria jornada como Hunter: build de atributos, árvore de Nen, Hatsu criado com votos/juramentos, reputação com facções, 9 sagas data-driven.

### Core loop
```
Explore → NPC → Quest → Combat → XP/Level → Nen Skill Tree → Build → Reputation → New Content → Story Checkpoint → …
```

---

## 2. Estrutura do repositório

| Pasta | Papel |
| :--- | :--- |
| `autoload/` | Singletons (PlayerData, CombatEngine, NetworkManager, …) |
| `entities/` | Player, NPCs, inimigos, efeitos |
| `world/` | Mapas, componentes, geradores, sagas |
| `ui/` | HUD, menus, criadores (Hatsu, personagem), Arena, Auction, … |
| `scripts/` | Gameplay (missions, combat, nen, network, systems) |
| `resource/` | Resources `.gd` / `.tres` (quests, hatsu, bosses, …) |
| `data/` | Dados estáticos / catálogos JSON |
| `assets/` | Sprites, tilesets PixelLab, fontes; `assets/reference/` = âncoras de estilo |
| `server/` | Entrada do servidor dedicado |
| `scratch/` | Suites headless / runners (não ship) |
| `docs/` | Documentação (bibles, systems, multiplayer, roadmap) |
| `.agent/` | Skills/bibles pontes para o agente Cursor |

---

## 3. Pilares de gameplay (o que o jogo É)

### 3.1 Combate
- **Ataque básico** (mouse / espaço): combo 3 hits (1.0× → 1.25× → 1.80×), zero custo de aura, finalizador reforçado por **Ko**.
- **Hatsu** slots 1–4 (teclas `1–4`): skills ativas criadas pelo jogador; desbloqueio em cadeia (GI + Biscuit → níveis 600/800/1000).
- Feel: hit-stop, screenshake, dash/dodge, afterimages, texto `IMUNE`, death juice, loot pickup.

### 3.2 Nen (híbrido)
| Camada | Técnicas | Input |
| :--- | :--- | :--- |
| Passivas | Ten, Ren, Shu, Ko, Ryu | Contínuas via skill tree |
| Ativas | **Zetsu** (stealth), **En** (cúpula + intimidação), **Gyo** (percepção multi-tier) | `Z` / `X` / `G` |

**Matriz de conflitos:** Zetsu ↔ En e Zetsu ↔ Gyo (mutuamente exclusivos); En + Gyo coexistem.  
**Regra de ouro:** Zetsu/En/Gyo **nunca** ocupam slots de Hatsu.

Arquivos-chave: `PassiveNenController`, `ActiveNenController`, `PerceptionSystem`, `CombatEngine`, skill tree UI.

### 3.3 Hatsu
- Criação com 6 afinidades, votos/juramentos, custo Jenny + cooldown de forja.
- Mastery 0–100 (anti-farm em inimigos 30+ níveis abaixo).
- Archive de 12 slots separado dos 4 de combate.
- Autoloads: `HatsuManager`, `HatsuProgressionManager`.

### 3.4 Progressão
- Level cap **1000**, soft-caps XP/Jenny implementados.
- +1 SP por level → Nen Skill Tree (visual MMO “constelação” polido no PR #42).
- Economia Jenny + loot (PR #46: grant direto ao inventário, sem orbs no chão não coletáveis).

### 3.5 Missões / história
- 9 sagas modulares (`world/sagas/SagaModuleCatalog.gd` + `SagaDefinition` / `ChapterDefinition`).
- Story gating via `StoryManager` + `StoryGatingEvaluator`.
- GPS/objetivos: `MissionObjectiveResolver` unificado (PRs #45/#43).
- Quests: canônicas, paralelas, secretas, radiant/rotativas (Associação).

### 3.6 Mundo
Mapas shipados (amostra):
- Early: `exame_maratona`, `estrada_padokia`, `regiao_vale_padokia`, `floresta_vestigios`, `dungeon_ruinas_zaban`, `vertical_slice_zaban`
- Mid/late: `montanha_kukuroo`, `arena_celestial`, `yorknew_city`, `greed_island`, `ngl_formigas`, `continente_negro`, `black_whale_1`, `associacao_hunter`, `PlayerHouse`
- Sensores de Nen no mundo: `GyoInspectable`, `KoObstacle`, `ZetsuSensorZone`, factory `NenSensorFactory`
- Territórios das 9 sagas com packs de tiles (PR #36)

---

## 4. Sistemas implementados (estado em `main`)

### 4.1 Autoloads principais (ver `project.godot`)
EventBus, GameManager, TimeManager, DataManager, CombatEngine, PowerScale, ProgressionConfig, PlayerData, SaveManager, StoryManager, QuestSystem, HatsuManager, HatsuProgressionManager, NenBeastManager, Economy, AuctionHouse, ReputationSystem, FactionManager, HunterGuildSystem, NenContractManager, SurpriseQuestSystem, PersonalitySystem, WorldEventManager, WorldState, WorldStateManager, WorldProgressionManager, RelationshipSystem, RumorSystem, BountySystem, AchievementSystem, SecretBossManager, AudioManager, SceneTransition, CinematicManager, PlaytestTelemetry, InputContextManager, UIManager, TutorialManager, DamageNumberSystem, PerceptionSystem, NetworkManager, PartyManager, NPCMemorySystem, LiveEventManager, CollectionManager, TravelSystem, GourmetCooking.

### 4.2 Backlog MMO — Tier S / A (em `main`, marcados IMPLEMENTED)

| ID | Sistema | Status |
| :--- | :--- | :--- |
| PREREQ-1 | Sync binário `NetworkProtocol` (HOS1) + auction/guild bank packets | ✅ |
| PREREQ-2 | Revive aliado (canal 3s, interrupt on hit, tecla E) | ✅ |
| S1 | Leilão Yorknew (escrow local + UI) | ✅ |
| S2 | Heaven’s Arena ranqueada (MMR/season/queue) | ✅ |
| S3 | Raid 8 hunters (Ruínas de Zaban vertical) | ✅ |
| S4 | Greed Island card duel (subset jogável) | ✅ |
| A5 | Contratos Associação rotativos + Star Hunter | ✅ |
| A6 | Guildas + Nen Contracts | ✅ |
| A7 | Blacklist open hunt (world boss co-op) | ✅ |
| A8 | Gourmet life skills (buffs temporários) | ✅ |

### 4.3 Multiplayer LAN (fundação pronta)
- Dedicated ENet, puppets, **20 TPS**, combate RPC, proxies de inimigos, morte/respawn, server list, AoI/delta.
- Launchers: `iniciar_servidor_lan.bat` / `.sh`.
- Docs: `docs/multiplayer/` (architecture, gameplay, protocol, LAN guide, server setup, security, test plan).
- **Ainda aberto em produção pública:** Master server / matchmaking de frota VPS; auth de contas; stress de persistência sob N peers (parcialmente endereçado no PR #48 aberto).

### 4.4 Feel / UX recente (merged)
| PR | O quê |
| :--- | :--- |
| #49 | HUD glass MMO, combat log chat, nameplates, viewport 960×540 |
| #47 | Exame alcançável, combate early, dicas Nen |
| #46 | Jenny/itens direto ao inventário |
| #45 | GPS de missão + bússola sincronizada |
| #43 | Balance early, toast queue, HUD −25% |
| #42 | Polish visual Constelação de Nen |
| #41 | Progressão + imersão (Pilares 1–3); Nen ativo só Gyo/Zetsu/En |
| #36 | Territórios saga com tiles |
| #33 | Feel Gap Close (Maple/RO/Tibia) + vertical MMO |

### 4.5 Qualidade / testes
- Suítes em `scratch/test_*_suite.gd` (+ `.tscn`).
- Telemetria: F3/F4/F5/F6 overlays; `PlaytestTelemetry`.
- Vertical slice histórico: personagem → lobby → Elena → missões → Nen → Hatsu → save/load (auditorias em `docs/archive/audits/`).
- Save/Load: auditoria histórica 10/10 (compatibilidade é sagrada).

---

## 5. O que NÃO está em `main` (atenção)

### PR aberto #48 — `cursor/close-pending-roadmap-e72c`
Fecha residual do roadmap: Tier B + live-ops + sensores early + smoke Exame.

Conteúdo típico desse branch (ainda **não merged**):
- **B9** Mail + Friends (stubs/UI parcial; accept/decline incompleto)
- **B10** Duty Finder (matchmaking stub)
- **B11** Territory wars
- **B12** Travel skins
- **B13** Season Pass cosmético
- **B14** Nen stones (+10 socket Blacksmith)
- Banner de versão / backups rotativos / F9 ContentHotReload stub
- Mais sensores Gyo/Zetsu/Ko no early game
- Fixes de compile (`NetworkManager` timer) e teardown de suites MMO

**Limitações conscientes (do próprio PR):** matchmaking cross-server stub; Friends sem UI completa; F9 não recarrega `.tres` reais; auth VPS = ops manual.

### Outro PR aberto
- #24 PixelLab prompt template (style lock) — arte/pipeline, não gameplay core.

### Explicitamente fora de escopo (agora)
- Housing MMO completo (já existe `PlayerHouse` pessoal)
- World PvP aberto / battlegrounds (PvP só consensual)
- Battle pass pay-to-win / cash shop
- Novos sistemas de combate paralelos a Nen/Hatsu
- Corpse run / gear loss (evitar)

---

## 6. Pendências reais (próximos passos ideais)

Priorize nesta ordem. A diretriz do projeto é **não diluir COMBATE+NEN+HATSU** com mais sistemas MMO genéricos.

### P0 — Continuidade / merge / estabilidade
1. **Decidir destino do PR #48** — review/merge ou cherry-pick seletivo do que importa (Duty Finder stub vs polish real).
2. **Smoke play do early game ponta a ponta** (Exame → Padokia → Floresta → Ruínas): spawn walkable, GPS, combate, Nen tips, loot Jenny, cutscenes maratona.
3. **Corrigir docs desatualizados pontuais** (ex.: README viewport 640×360 vs 960×540; checkboxes do PRODUCTION_ROADMAP vs código).

### P1 — Qualidade de gameplay (maior ROI)
1. ~~**Densidade de sensores Nen no mundo**~~ — feito (Floresta/Ruínas + factory props + Ko clue).
2. ~~**Quests investigativas**~~ — “Trilha de Aura na Floresta” + “Selos do Guardião Ancestral” no `PadokiaQuestCatalog`.
3. **Retune fino early-game** — balance de stats/Jenny se economia ainda inflar; legibilidade do Exame.
4. **Combat feel / silhuetas** — garantir arquétipos fast/ambusher/tank legíveis no early.
5. **HUD/combat log** — validar FOV 960×540; ajustar opacidade/legibilidade se necessário.

### P2 — Conteúdo de sagas (profundidade, não sistemas novos)
1. Validar play humano Kukuroo/Arena/Floresta/Ruínas densificados.
2. Raid vertical Continente Negro (depois de Ruínas Zaban solo polish — feito).
3. ~~Yorknew~~ / ~~GI~~ / ~~NGL~~ / ~~Associação/Alluka~~ / ~~Continente Negro~~ / ~~Black Whale~~ — densificados + clues + ORDEM **100%** arcos 4–9. Sessão A–D fechada (merge PR #51).
4. Suites: `test_kukuroo_density_suite`, `test_zetsu_arena_density_suite`, `test_raid_solo_polish_suite`, `test_nen_mundo_floresta_ruinas_suite`, `test_yorknew_density_xp_suite`, `test_greed_island_immersion_suite`, `test_ngl_formigas_immersion_suite`, `test_associacao_alluka_immersion_suite`, `test_continente_negro_immersion_suite`, `test_black_whale_immersion_suite`, `test_session_abcd_final_smoke_suite`.

### P3 — Multiplayer produção (só se o foco for host público)
1. Contratar/configurar VPS: `public_host`, `--no-lan-discovery`, `config/server_list.json`.
2. Matchmaking real além do registry local UDP 7780.
3. Auth de contas (se necessário).
4. Stress persistência periódica sob N peers.
5. Cap/compressão de taxa já parcialmente feito — medir bandwidth no overlay F4.

### P4 — Live ops / polish (baixa prioridade vs pilares)
1. Hot-reload real de `.tres` (F9 hoje é stub no #48).
2. Aviso de versão no menu + rejeição suave de pacotes.
3. PixelLab style-lock / calibração de sprites (PRs/arte abertos).
4. Mail/Friends UI completa (só se social for prioridade).

---

## 7. Ideias boas para o próximo agent (escolhas concretas)

Escolha **uma** trilha por sessão (escopo pequeno — AGENTS.md):

### Trilha A — “Early game delicioso” (recomendado)
- Playtest manual Exame + Padokia.
- Bugs de pathing/spawn/GPS/missão.
- Feedback de Nen no primeiro combate.
- Suites: `scratch/test_exam_early_game_suite`, `test_exame_spawn_walkable_suite`, `test_mission_objective_gps_suite`, `test_p0_play_smoke_suite`.

### Trilha B — “Nen no mundo” ✅ (sessão atual)
- Sensores Gyo/Ko/Zetsu densos em Floresta + Ruínas.
- Quests: `obter_quest_investigacao_floresta` + `obter_quest_investigacao_ruinas`.
- Suite: `scratch/test_nen_mundo_floresta_ruinas_suite`.
- Próximo refinamento: play humano + mais clareiras na Estrada/Vale se necessário.

### Trilha C — “Fechar #48 com critério”
- Mergiar só o que passa suites e não polui pilares.
- Documentar limitações (stubs vs features reais).
- Atualizar `MMO_FEATURES_BACKLOG.md` status após merge.

### Trilha D — “Raid / co-op polish”
- Validar revive + raid 8 Ruínas em LAN 2 clientes.
- Telegraph AoE, wipe/revive legível, loot por contribuição.
- Suites: `test_s3_raid_8_hunters_suite`, network smokes.

### Trilha E — “Arte / identidade visual”
- Style lock PixelLab + NPCs principais.
- Ver `HUNTER_ONLINE_PIXELLAB_PROMPT_LIBRARY.md`, `docs/guides/PIXELLAB_PROMPT_LIBRARY.md`, jobs em `assets/sprites/tilesets/pixellab/`.

---

## 8. Como trabalhar neste repo (checklist do agent)

```
1. LOCATE  — buscar sistema existente antes de criar
2. UNDERSTAND — ler só o necessário
3. PLAN — mudança mínima
4. IMPLEMENT — preservar APIs, saves, sinais, cenas
5. VALIDATE — suites scratch + sem SCRIPT ERROR
6. REPORT — causa, arquivos, o que mudou, limitações
```

### Não fazer
- Refatorar projeto inteiro por bug pontual.
- Duplicar Mission/Nen/Hatsu/Save managers.
- Quebrar schema de save (v2.4) sem migração.
- Assumir que “stage” == “objective” em missões.
- Inventar segundo EventBus / GameState.

### Testes úteis
```bash
# Godot headless — exemplo de padrão do repo:
godot --headless --path . res://scratch/test_<nome>_suite.tscn
```
(Confirmar path do binário Godot 4.6 no ambiente; suites em `scratch/`.)

### Multiplayer local
```bash
./iniciar_servidor_lan.sh
# Cliente: abrir jogo → menu multiplayer → LAN discovery / server list
```

---

## 9. Mapa rápido de docs por dúvida

| Se o agent precisa de… | Abrir |
| :--- | :--- |
| Regras de contribuição / escopo | `Hunter Online — AGENTS.md` |
| O que o jogo deve ser | `docs/bibles/GAME_MASTER_BIBLE.md` (+ NEN/HATSU/COMBAT/…) |
| O que fazer agora | `docs/roadmap/PRODUCTION_ROADMAP.md` |
| Sistemas MMO futuros | `docs/roadmap/MMO_FEATURES_BACKLOG.md` |
| Rede / LAN / protocolo | `docs/multiplayer/*` |
| Como criar NPC/quest/região/boss | `docs/guides/*` |
| Runtime Nen/Hatsu/Save/Mission | `docs/systems/*` |
| ADRs | `docs/architecture/` |
| Auditorias / playtests antigos | `docs/archive/audits/` |
| Tasks diárias históricas | `docs/roadmap/_history/` |

---

## 10. Resumo executivo (1 parágrafo)

Hunter Online em `main` (set/2026) é um **2D HxH RPG/MMO em Godot 4.6** com pilares sólidos de combate, Nen (passivo+ativo), Hatsu criável, progressão até 1000, 9 sagas data-driven, early world Padokia→Zaban, e **quase todo o backlog MMO Tier S/A já shipado** (auction, arena ranked, raid 8, GI cards, guilds, blacklist, gourmet) + fundação LAN autoritativa. O trabalho de maior valor agora **não é inventar sistemas novos**, e sim: **(1)** playtest/polimento do early game e sensores Nen no mundo, **(2)** decidir/mergear o PR #48 de Tier B/live-ops com critério, **(3)** aprofundar conteúdo das sagas 1–3 e raid co-op, **(4)** só então VPS/matchmaking público.

---

## 11. Prompt sugerido para colar no outro agent

```text
Você vai trabalhar no Hunter Online (Godot 4.6, GDScript).
Leia primeiro:
1) docs/ESTADO_ATUAL_JOGO.md (este handoff)
2) Hunter Online — AGENTS.md
3) docs/roadmap/PRODUCTION_ROADMAP.md
4) docs/roadmap/MMO_FEATURES_BACKLOG.md

Regras: MODIFY DON'T REBUILD; escopo mínimo; preservar saves v2.4;
foco COMBATE+NEN+HATSU+PROGRESSÃO; não criar sistemas MMO novos
se já existem stubs/implementações.

Estado: main está em d399349 (PR #49 HUD). PR #48 (Tier B) ainda aberto.
Tarefa sugerida: [PREENCHER — ex. Trilha A early game / Trilha B sensores Nen].
```

---

*Gerado para handoff entre agents. Atualize a data e o SHA de `main` quando o estado mudar de forma material.*
