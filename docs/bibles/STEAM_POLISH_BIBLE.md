# STEAM POLISH BIBLE — Hunter Online

> **O que é:** contrato de qualidade perceptível para ship / review Steam.  
> **O que não é:** backlog de sistemas MMO novos (ver [`../roadmap/MMO_FEATURES_BACKLOG.md`](../roadmap/MMO_FEATURES_BACKLOG.md)).  
> **Diretriz:** qualidade de gameplay > quantidade de sistemas · foco **COMBATE + NEN + HATSU + PROGRESSÃO**.  
> **SSOT de knobs numéricos de progressão:** [`autoload/ProgressionConfig.gd`](../../autoload/ProgressionConfig.gd) · Hatsu: [`scripts/systems/hatsu/HatsuConfig.gd`](../../scripts/systems/hatsu/HatsuConfig.gd) · Jenny: [`autoload/Economy.gd`](../../autoload/Economy.gd).

---

## 1. Diagnóstico canônico

Os **sistemas** já estão em nível de produção. O gap Steam é **conteúdo denso + feedback legível + pacing deliberado** em cima do que existe.

| Já forte | Gap perceptível |
| :--- | :--- |
| CombatEngine, hitstop, boss phases | Poucos inimigos únicos e silhuetas early |
| Nen + sensores + PerceptionSystem | Instâncias insuficientes por rota (>10s sem Gyo/Ko/Zetsu) |
| Catálogos canônicos grandes | Poucos `.tres`/diálogos reais; etapas template |
| 9 mapas + hub | Dead zones early; living world desigual |
| Save / suites verdes | Playtest humano early = P0 |
| Tier S/A/B MMO no código | Superfície larga, profundidade de uso baixa |

**Escopo de produto:** solo-first · até Arena Celestial compacto · Yorknew+ longo/imersivo · Nen no mundo semiaberto (não forçar no lobby) · arte PixelLab com o diretor · **não** abrir VPS até o solo estar review-proof.

---

## 2. Gates de ship Steam (Fase 0)

Todo mapa / arco só “passa” se cumprir os cinco gates. Suites headless **não** substituem playtest humano.

### G1 — Regra dos 10 segundos
Toda caminhada **>10s em linha reta** deve conter ao menos um de:
- pista `GyoInspectable` / sensor Nen
- baú / recurso / prop interativo
- som ou rastro de criatura / walker / placa “próximo passo”

Preservar **respiro 4–8s sem mob**. Encontros ContentDirector: espaçamento **300–600px**.

### G2 — Nen fora do combate
Cada mapa **early/mid** exige ≥1 uso real de:
- **Gyo** (pista / inspeção)
- **Zetsu** (aproximação / stealth / cofre)
- **Ko** (obstáculo / selo / break)

Tutorial não conta sozinho — o gate exige instâncias no mapa jogável.

### G3 — Legibilidade de inimigo
Inimigo novo = **silhueta distinta** + **telegraph legível** + **1 fraqueza Nen óbvia** (arquétipo fast / ambusher / tank no early).

### G4 — Recompensa em clareira
Clareira sem combate ainda entrega *something*: pista, fala, Jenny, prop, toast de zona, ou discovery SFX.

### G5 — Playtest humano P0
Rota **Exame → Padokia → Floresta → Ruínas** com gravação / notas. Critério: dead time contínuo ≤6s; Nen tools usados de verdade; boss Guardião legível em 3 fases.

---

## 3. Referências de pacing (emprestar o feeling, não o jogo)

Alvo: **demorado porém interativo e recompensador** — não rush Maple, não Souls punitivo.

| Jogo | Emprestar | Aplicar em HO |
| :--- | :--- | :--- |
| Monster Hunter World | Prep → telegraph → janela de punição → loot ritual | Combate / raids / Hatsu CD |
| Sekiro | Postura/stagger como vitória; defesa ativa | Ko + stagger + Ten |
| Hollow Knight | Segredo a cada 8–15s | Sensores Nen + baús + falas |
| BOTW / TotK | Ferramentas abrem o mapa | Gyo/Zetsu/En/Ko como chaves |
| Disco Elysium | Investigação densa | Quests Investigate / Stealth / Ko |
| Sea of Stars / Chained Echoes | Juice curto + build identity | Game feel + Hatsu mastery |
| Persona (leve) | Respiro social entre picos | Lobby + Training + Gourmet |

---

## 4. Tabelas de pacing / TTK / reward (alinhadas ao código)

### 4.1 Faixas de sessão

| Bracket | Sagas | Níveis (`ProgressionConfig`) | Sensação |
| :--- | :--- | :--- | :--- |
| EARLY | 1–3 Exame→Arena | 1–60 | Compacto, mentores diretos, Nen tools |
| MID | 4–5 Yorknew→GI | 61–130 | Longo, imersivo, caminhada recompensada |
| LATE | 6–9 Formigas→Whale | 131–350 | Difícil, denso, Hatsu identity |
| ENDGAME | Paralelas / expansões | 351–1000 | Soft-cap saga + farm residual |

Soft-cap XP: acima do soft-max da saga atual → multiplicador ≤0.30 decaindo até 0.05 (`obter_multiplicador_xp_soft_cap`).

### 4.2 Timing de sessão

| Momento | Early (Exame→Ruínas) | Mid (Kukuroo→Arena) | Late (Yorknew→Whale) |
| :--- | :--- | :--- | :--- |
| 1º NPC | <2s | hub imediato | hub / zona viva |
| 1º combate | 15–25s | após brief prep | após exploração |
| Boss / checkpoint de rota | 60–90s (slice) | missão 8–15 min | arco 40–90+ min |
| Dead time contínuo | ≤6s | ≤8s | ≤10s (sempre com micro-reward a cada 10s de caminhada) |
| Respiro sem mob | 4–8s | 4–10s | 6–12s |

### 4.3 TTK (time-to-kill) alvo

| Conteúdo | TTK alvo | Notas |
| :--- | :--- | :--- |
| Mob early | 4–8s | Espaço para telegraph + 1 Hatsu |
| Mob mid | 12–25s | Leitura MH; CD inimigo alto o bastante |
| Elite / puzzle Nen | 20–40s | Exige Gyo/Zetsu/Ko ou Hatsu |
| Boss phase | 45–90s por fase | Nunca one-shot sem telegraph ≥1.0s |
| Raid wipe legível | enrage warn ≥60s (Zaban polish) | checkpoint claro |

Speeds de referência early (decisão produto): player ~112 · enemies ~58 — manter espaço para Hatsu.

### 4.4 Reward cadence

| Camada | Frequência | Exemplos |
| :--- | :--- | :--- |
| Micro | cada ação | hitstop, SFX, XP/Jenny float, gyo_detect |
| Médio | 3–5 min | item, SP, baú, toast de zona, mastery +10 feedback |
| Macro | por arco / checkpoint | story gate, Hatsu slot, rank Arena, raid loot |

### 4.5 Knobs canônicos (não reinventar)

| Sistema | Valores SSOT |
| :--- | :--- |
| XP | `XP_BASE=400`, `XP_GROWTH=1.65`, soft-cap por saga |
| Jenny kill | `Economy.calcular_drop_jenny_inimigo` — fator 0.45 se lv≤15 |
| Hatsu forge | 5000 Jenny · CD criação 1800s · switch 600s (`HatsuConfig`) |
| SP | +1 por level |
| Milestones | 1, 25, 40, 60, 85, 130, 230, 350, 500, 750, 1000 |
| Encontros | 300–600px · SAFE na vila |

**Consumíveis:** código sem poções HP/Aura clássicas — preferir **Pedras de Aura** / comida **Gourmet** (sink + buff temporário). Alinhar bibles de economia a isso.

---

## 5. Densificação early (Exame → Ruínas) — checklist por mapa

Factory: `world/components/exploration/NenSensorFactory.gd`. Quests modelo: “Trilha de Aura” / “Selos do Guardião” (`PadokiaQuestCatalog`).

### 5.1 `exame_maratona`
- [ ] 1º NPC / toast de zona em <2s
- [ ] 1 combate 15–25s com telegraph legível
- [ ] ≥1 Gyo pista de rota · ≥1 prop/placa “próximo passo”
- [ ] Sem corredor >10s vazio
- [ ] Mentoria direta (não assuntos vagos)

### 5.2 `world/lobby` (hub)
- [ ] Elena mentor direto + marcador `?`/`!`
- [ ] Walkers / props sem overdense na praça
- [ ] Nen **não** forçado (semiaberto)
- [ ] Saídas claras: Padokia / Story Gateway / loja / ferreiro

### 5.3 `estrada_padokia` + `regiao_vale_padokia`
- [ ] Desagregar NPCs da praça (OVERDENSE → espalhar loja/dojo)
- [ ] Vila Exterior: baú ou glifo Gyo (matar UNDERDENSE)
- [ ] Estrada: regra 10s + 1 evento social leve (Associação × Máfia × Guardas)
- [ ] Quest Padokia “um de cada vez” + Investigate/Stealth/Ko
- [ ] Tutorial Nen 3 beats **antes** da dungeon: Gyo → Zetsu → Ko

### 5.4 `floresta_vestigios`
- [ ] 3 arquétipos legíveis (fast / ambusher / tank)
- [ ] ≥8 sensores (Gyo/Ko/Zetsu) na rota principal + clareiras
- [ ] Floresta Profunda: ninho / evento / baú (matar DEAD ZONE)
- [ ] Respiro 4–8s; sem spam de mobs
- [ ] SFX `gyo_detect` em 100% dos inspectables da rota

### 5.5 `dungeon_ruinas_zaban` (+ vertical slice)
- [ ] Entrada: aviso sonoro + runas Gyo
- [ ] Selos Ko / zonas Zetsu em acampamentos internos
- [ ] Boss Guardião 3 fases (template mestre) + juice entrada/saída
- [ ] Loot ritual no chão (MH-style)
- [ ] Raid solo: telegraph AoE ~1.2s · enrage warn 60s · wipe → checkpoint

Checklist operacional espelhado: [`../roadmap/STEAM_EARLY_DENSITY_CHECKLIST.md`](../roadmap/STEAM_EARLY_DENSITY_CHECKLIST.md).

---

## 6. Pass de densificação por pilar (Fase 2)

Sem sistemas novos — alimentar o que já existe.

### 6.1 Combate
| | Ação |
| :--- | :--- |
| Melhorar | ≥4 variantes `EnemyData` por bioma; heavy windows; Hatsu inimigo em elites |
| Densificar | Telegraphs por afinidade; Ko/stagger “vitória Sekiro” mid; 1 elite puzzle Nen/mapa |
| Balance | TTK §4.3; never one-shot sem telegraph |

### 6.2 Nen no mundo (Prioridade S)
| | Ação |
| :--- | :--- |
| Melhorar | SFX/VFX discovery 100% Gyo; falha legível (alarme Zetsu, En assusta NPC) |
| Densificar | 8–15 sensores/mapa mid; cofres Zetsu; portas Ko; En vs fauna |
| Balance | Gyo barato p/ exploração; Zetsu risco alto / reward alto |

### 6.3 Hatsu
| | Ação |
| :--- | :--- |
| Melhorar | Canalização → impacto → residual por afinidade; feedback mastery a cada 10 |
| Densificar | 1 “momento Hatsu” por arco; presets canônicos como trainers |
| Balance | CDs longos MH; vow tradeoff no HUD; anti-farm já em código — expor no UI |

### 6.4 Progressão / Skill Tree
| | Ação |
| :--- | :--- |
| Melhorar | Identidade por cluster (não só +stat); milestones narrativos |
| Densificar | Training Wing/Biscuit como respiro entre ranks Arena |
| Balance | Soft-caps saga; alinhar docs `PowerScale` ao cap 1000 / `TARGET_STATS_LEVEL_1000` |

### 6.5 Quests / Story
| | Ação |
| :--- | :--- |
| Melhorar | Etapas template → beats com fala + escolha + ORDEM; Quest HUD História % vs Atividades |
| Densificar | Cutscenes 15–40s nos checkpoints; CompanionChatter leve nos arcos longos |
| Balance | Yorknew+: caminhada longa **com** micro-rewards; nunca 30s de corredor vazio |

### 6.6 Economia / Loot
| | Ação |
| :--- | :--- |
| Melhorar | Sinks (Hatsu 5k, blacksmith, gourmet, multa); faucets previsíveis por arco |
| Densificar | 30–50 itens com identidade; loot no chão com juice; baús de clareira |
| Balance | Pedras de Aura / Gourmet (não poções clássicas) |

### 6.7 Mundo / Living World
| | Ação |
| :--- | :--- |
| Melhorar | Schedules NPC; placas próximo passo; crowd Yorknew mínimo viável |
| Densificar | Props + ambient SFX por bioma; dia/noite se parcial |
| Balance | ContentDirector SAFE na vila; 1 evento facção na Estrada |

### 6.8 Áudio / UI
| | Ação |
| :--- | :--- |
| Melhorar | Barks curtos em mentores; spatial discovery |
| Densificar | Stingers por reward; crossfade OST nos story gates |
| Não priorizar | Radial menu, themes por saga, housing MMO |

### 6.9 Multiplayer
Só **depois** do early Steam-slice + review vertical: prova LAN 2 clientes em raid Zaban. VPS depois de solo review-proof.

---

## 7. Vertical de review Steam (90–120 min)

Sessão que um reviewer deve sentir “jogo profissional” na primeira hora+ :

| # | Bloco | Gate |
| :--- | :--- | :--- |
| 1 | Character select → Exame | Clareza + juice; 1º combate 15–25s |
| 2 | Lobby Elena | Mentor direto + hub vivo |
| 3 | Padokia investigativa | Gyo → Zetsu → Ko usados |
| 4 | Floresta → Ruínas | Regra 10s + boss 3 fases |
| 5 | Retorno hub → Skill Tree SP → 1 Hatsu moment | Progressão perceptível |
| 6 | (Opcional) Arena rank 1 | Hook mid compacto |

### Critérios de “review-proof” antes de LAN/VPS
- [ ] G1–G5 verdes na rota early
- [ ] Nenhum dead corridor >10s na rota de review
- [ ] TTK e speeds early dentro da tabela §4
- [ ] Boss Guardião: telegraph legível, loot no chão, wipe→checkpoint
- [ ] Save/load sem regressão schema
- [ ] Playtest humano gravado com notas (não só suite)
- [ ] Arte: silhueta/arquétipo ok mesmo com placeholder (sprites finais = diretor)

**Bloqueadores explícitos de VPS:** early não review-proof · LAN raid Zaban não provada · diluição por sistema MMO novo.

---

## 8. Ordem de execução

1. Gates (este doc) + playtest humano early  
2. Densidade sensores + baús + quests investigativas early  
3. Enemy variety + telegraph + Hatsu feel retune  
4. Economia/itens + reward juice  
5. Mid maps audit (mesma regra dos 10s)  
6. LAN raid proof  
7. Diálogos/cutscenes finos nos checkpoints  

### Fora de escopo
Novos sistemas MMO · housing · world PvP · battle pass P2W · segundo combat system · rebuild de catálogos.

---

## 9. Links

| Doc | Papel |
| :--- | :--- |
| [`../roadmap/PRODUCTION_ROADMAP.md`](../roadmap/PRODUCTION_ROADMAP.md) | Agora / next / later + STEAM_POLISH |
| [`../roadmap/STEAM_EARLY_DENSITY_CHECKLIST.md`](../roadmap/STEAM_EARLY_DENSITY_CHECKLIST.md) | Checklist operacional early |
| [`QA_BIBLE.md`](QA_BIBLE.md) | Suites + gates Steam no protocolo QA |
| [`GAME_FEEL_BIBLE.md`](GAME_FEEL_BIBLE.md) | Juice de combate |
| [`PERCEPTION_BIBLE.md`](PERCEPTION_BIBLE.md) | Gyo / Zetsu / En |
| [`../archive/audits/PROFESSIONAL_QUALITY_GAP.md`](../archive/audits/PROFESSIONAL_QUALITY_GAP.md) | Gap histórico (diagnóstico) |
| [`../archive/audits/WORLD_DENSITY_AUDIT.md`](../archive/audits/WORLD_DENSITY_AUDIT.md) | Dead zones Padokia |
