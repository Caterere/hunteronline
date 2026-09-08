# REGISTRO OFICIAL DE ASSETS PERMANENTES (PIXELLAB PIPELINE)
## Hunter Online — World Production Bible (Seção 37)

Este documento registra formalmente todos os assets permanentes gerados via PixelLab MCP e integrados ao projeto, garantindo reprodutibilidade, continuidade de estilo e rastreabilidade conforme a **World Production Bible**.

> [!CRITICAL]
> **STYLE ANCHOR OFICIAL DO PROJETO:** `res://assets/sprites/characters/player.png` (ou `player(3).png`).
> Todos os personagens do jogo seguem o padrão **48×48 pixels**, com bonecos de **20 a 22 px de altura**, pés em **Y = 42**, proporção chibi 2.5 cabeças, olhos estilizados em ponto (1×2 px sem esclera), sombreamento plano e paleta reduzida (máx. 11-14 cores/frame).
> Aprovados estritamente pela `16_PIXEL_ART_STYLE_BIBLE.md`. Sprites legados gerados em 68×68 px estão marcados para retificação futura para conformidade absoluta com o Style Lock.

---

### Registro 01: Estátua Monumental do 12º Presidente Netero
- **Asset:** `estatua_netero_monument.png`
- **Tipo:** Map Object (Landmark)
- **PixelLab ID:** `83aab098-805e-4b3f-ab51-a3d380d4135a`
- **Descrição:** Granite and bronze monumental statue of an elderly zen martial arts master sitting in meditation on an ornate carved stone pedestal with sacred engravings, top-down rpg prop.
- **Tamanho:** 64×96 pixels
- **Direções:** 1 (High Top-Down)
- **Animações:** N/A (Estátua sólida)
- **Mapa:** `world/lobby.tscn` (Praça Central em `(0, -280)`)
- **Local no projeto:** `res://assets/sprites/objects/estatua_netero_monument.png`
- **Referência utilizada:** Isaac Netero em meditação zen pré-Kan'non
- **Colisão:** Base de pedestal `RectangleShape2D(36, 16)` em `(0, -8)`
- **Observações:** Y-sort habilitado; passagem limpa pela frente e por trás do pedestal; interação `[E] Orar na Estátua de Netero`.

---

### Registro 02: Grande Portão de Padokia (Portão do Mundo Exterior)
- **Asset:** `portao_padokia_arch.png`
- **Tipo:** Map Object (Landmark / Portal)
- **PixelLab ID:** `ce62943f-6d77-482a-9861-2499b5f367f9`
- **Descrição:** Grand stone and wrought iron gate archway of the hunter association city entrance with banners and heraldic crest, top-down rpg prop.
- **Tamanho:** 64×64 pixels
- **Direções:** 1 (High Top-Down)
- **Animações:** N/A
- **Mapa:** `world/lobby.tscn` (Saída Sul em `(0, 480)`)
- **Local no projeto:** `res://assets/sprites/objects/portao_padokia_arch.png`
- **Referência utilizada:** Portão de saída da Associação para a Estrada Real de Padokia
- **Colisão:** Vão de transição central `(32, 16)` e 2 pilares de pedra sólidos nas laterais `(14, 16)`
- **Observações:** O jogador é canalizado fisicamente pelo arco sem atravessar as colunas de pedra.

---

### Registro 03: Recepcionista Elena
- **Asset:** `npc_recepcionista_elena_8dir.png`
- **Tipo:** Character / NPC (Style Lock Canônico)
- **Tamanho:** Frame 48×48 pixels (Folha 384×48 px) — 100% Aprovado no Style Lock
- **Descrição:** Elena Hunter Association receptionist young woman, neat brown hair in low bun, navy blue formal vest over white collared shirt, dark navy skirt, gold button pin, chibi 2.5 heads proportion, 21px height, feet at Y=42.
- **Direções:** 8 direções (South, South-East, East, North-East, North, North-West, West, South-West)
- **Animações:** Idle 8-rotations
- **Mapa:** `world/lobby.tscn` (Praça Central em `(110, -20)`)
- **Local no projeto:** `res://assets/sprites/characters/npc_recepcionista_elena_8dir.png` e pasta `npc_recepcionista_elena_rotations/`
- **Referência utilizada:** Recepcionista da Associação Hunter (Elena)
- **Colisão:** Pés do NPC `CircleShape2D(radius=6.0)` em `(0, -3)`
- **Observações:** Responsável pelo tutorial guiado de onboarding e introdução de Nen.

---

### Registro 04: Instrutor de Combate & Nen (Wing)
- **Asset:** `npc_instrutor_combate_8dir.png`
- **Tipo:** Character / NPC (Style Lock Canônico)
- **Tamanho:** Frame 48×48 pixels (Folha 384×48 px) — 100% Aprovado no Style Lock
- **Descrição:** Wing Shingen-ryu Nen master instructor, messy unkempt dark hair, thin glasses bridge, loose dark green kimono tunic with sash over white shirt, beige training pants, chibi 2.5 heads proportion, 21px height, feet at Y=42.
- **Direções:** 8 direções (South, South-East, East, North-East, North, North-West, West, South-West)
- **Animações:** Idle 8-rotations
- **Mapa:** `world/lobby.tscn` (Praça Central em `(-110, -20)`)
- **Local no projeto:** `res://assets/sprites/characters/npc_instrutor_combate_8dir.png` e pasta `npc_instrutor_combate_rotations/`
- **Referência utilizada:** Shingen-ryu Dojo Master (Wing)
- **Colisão:** Pés do NPC `CircleShape2D(radius=6.0)` em `(0, -3)`
- **Observações:** Responsável pelo tutorial de ataques, combos, esquiva e barra de defesa.

---

### Registro 05: Examinador Oficial da Associação Hunter (Satotz)
- **Asset:** `npc_examinador_oficial_8dir.png`
- **Tipo:** Character / NPC (Style Lock Canônico)
- **Tamanho:** Frame 48×48 pixels (Folha 384×48 px) — 100% Aprovado no Style Lock
- **Descrição:** Satotz 1st Phase Hunter Examiner, dark charcoal bowler hat, tailored purple suit coat, white formal cravat tie, thin wooden walking cane with gold tip, upright gentleman stance, no mouth, dot eyes, chibi 2.5 heads proportion, 22px height, feet at Y=42.
- **Direções:** 8 direções (South, South-East, East, North-East, North, North-West, West, South-West)
- **Animações:** Idle 8-rotations
- **Mapa:** `world/lobby.tscn` (Praça Central / Story Gateway em `(0, -90)`)
- **Local no projeto:** `res://assets/sprites/characters/npc_examinador_oficial_8dir.png` e pasta `npc_examinador_oficial_rotations/`
- **Referência utilizada:** Examinador Satotz (1ª fase do Exame Hunter)
- **Colisão:** Pés do NPC `CircleShape2D(radius=6.0)` em `(0, -3)`
- **Observações:** Gateway oficial para as sagas e exames do Modo História.

---

### Registro 06: Tileset Wang da Praça (Grama MMORPG & Lajotas de Pedra)
- **Asset:** `pixellab_lobby_sheet.png` / `lobby_tileset.tres` (Source ID 20)
- **Tipo:** Wang Tileset 16×16 px
- **PixelLab ID:** `f62f6ab8-384c-432a-a047-0a01746f3e3f`
- **Descrição:** Vibrant lush green mmorpg grass with subtle moss and tiny flowers -> ancient polished cobblestone stone pavement for mmorpg city plaza.
- **Tamanho:** 64×64 pixels (16 tiles de 16×16 px)
- **Base Tile Lower ID:** `6ddcea40-d42f-484f-bf65-793fef276ea5` (Grama base para transições futuras de floresta)
- **Base Tile Upper ID:** `03738081-b95b-47c1-ac7e-b3514e8a4f10` (Pedra polida para transições futuras de avenidas)
- **Local no projeto:** `res://assets/sprites/tilesets/pixellab/pixellab_lobby_sheet.png`
- **Observações:** Utilizado para conexões e transições sem costura entre natureza e arquitetura da capital.

---

### Registro 07: Forja do Mestre Ferreiro (Workshop)
- **Asset:** `forja_ferreiro_workshop.png`
- **Tipo:** Map Object (District Workshop)
- **PixelLab ID:** `3ca3053b-11f4-42c6-aff9-d2477574ed65`
- **Descrição:** Stone and brick blacksmith workshop with an outdoor anvil, glowing hot coal forge, water quenching trough, and weapon racks, top-down rpg prop.
- **Tamanho:** 64×64 pixels
- **Direções:** 1 (High Top-Down)
- **Animações:** N/A (Estrutura com fornalha estática)
- **Mapa:** `world/lobby.tscn` (Distrito Comercial/Artesanal Oeste em `(-420, -180)`)
- **Local no projeto:** `res://assets/sprites/objects/forja_ferreiro_workshop.png`
- **Referência utilizada:** Oficina Shingen / Ferraria Hunter
- **Colisão:** Base da oficina `RectangleShape2D(56, 20)` em `(0, 18)`
- **Observações:** Y-sort habilitado; passagem livre na frente e atrás do telhado.

---

### Registro 08: Tenda / Banca do Mercador Hunter
- **Asset:** `tenda_mercador_stall.png`
- **Tipo:** Map Object (Market Stall)
- **PixelLab ID:** `ef3d721d-8a03-4a0c-83e9-d63171703449`
- **Descrição:** Wooden merchant market stall with striped fabric awning, wooden crates of goods, potion bottles, scrolls, and lanterns, top-down rpg prop.
- **Tamanho:** 64×64 pixels
- **Direções:** 1 (High Top-Down)
- **Animações:** N/A
- **Mapa:** `world/lobby.tscn` (Distrito Comercial Oeste em `(-220, -180)`)
- **Local no projeto:** `res://assets/sprites/objects/tenda_mercador_stall.png`
- **Referência utilizada:** Bazar de mercadores de Padokia
- **Colisão:** Base dos caixotes e balcão `RectangleShape2D(52, 16)` em `(0, 16)`
- **Observações:** Y-sort habilitado; o balcão separa o comerciante dos clientes.

---

### Registro 09: Fachada da Casa do Caçador (Residência)
- **Asset:** `casa_cacador_facade.png`
- **Tipo:** Map Object (Residential House Facade)
- **PixelLab ID:** `c09c7c6c-5096-4f03-b7e8-25b1a36533db`
- **Descrição:** Cozy residential hunter cottage entrance facade with timber-frame stone walls, rustic wooden door, glowing shuttered window, and hanging lantern, top-down rpg prop.
- **Tamanho:** 64×64 pixels
- **Direções:** 1 (High Top-Down)
- **Animações:** N/A
- **Mapa:** `world/lobby.tscn` (Distrito Residencial Leste em `(380, -180)`)
- **Local no projeto:** `res://assets/sprites/objects/casa_cacador_facade.png`
- **Referência utilizada:** Alojamentos de Hunters licenciados
- **Colisão:** Base frontal `RectangleShape2D(56, 18)` em `(0, 18)`
- **Observações:** Y-sort habilitado; ponto de transição com porta interativa `[E] Entrar na Casa do Caçador`.

---

### Registro 10: Boneco de Treino Shingen-ryu
- **Asset:** `boneco_treino_dummy.png`
- **Tipo:** Map Object (Combat & Nen Training Prop)
- **PixelLab ID:** `bcff5897-9ee7-42b2-808a-469ffcd8eff2`
- **Descrição:** Traditional wooden martial arts training dummy with outstretched wooden arms and rope padding on a solid wooden post base, top-down rpg prop.
- **Tamanho:** 32×48 pixels
- **Direções:** 1 (High Top-Down)
- **Animações:** N/A
- **Mapa:** `world/lobby.tscn` (Distrito de Treinamento Sudoeste em `(-400, 120)`)
- **Local no projeto:** `res://assets/sprites/objects/boneco_treino_dummy.png`
- **Referência utilizada:** Postes de treino de artes marciais Shingen
- **Colisão:** Base cilíndrica do poste `CircleShape2D(radius=6.0)` em `(0, 16)`
- **Observações:** Y-sort habilitado; permite ao jogador praticar posicionamento e golpes corpo a corpo.

---

### Registro 11: Mestre Ferreiro
- **Asset:** `npc_ferreiro_mestre_8dir.png`
- **Tipo:** Character / NPC (Style Lock Canônico)
- **Tamanho:** Frame 48×48 pixels (Folha 384×48 px) — 100% Aprovado no Style Lock
- **Descrição:** Veteran blacksmith craftsman, brown hair with beard stubble, heavy leather brown apron over steel-gray tunic, small iron forge hammer at side, chibi 2.5 heads proportion, 21px height, feet at Y=42.
- **Direções:** 8 direções (South, South-East, East, North-East, North, North-West, West, South-West)
- **Animações:** Idle 8-rotations
- **Mapa:** `world/lobby.tscn` (Distrito Comercial / Ferraria em `(-360, -160)`)
- **Local no projeto:** `res://assets/sprites/characters/npc_ferreiro_mestre_8dir.png` e pasta `npc_ferreiro_mestre_rotations/`
- **Referência utilizada:** Ferreiro mestre de armas e equipamentos para hunters
- **Colisão:** Pés do NPC `CircleShape2D(radius=5.0)` em `(0, -2)`
- **Observações:** NPC interativo com cena dedicada `res://entities/npc/ferreiro/Ferreiro.tscn`.

---

### Registro 12: Mercador Hunter
- **Asset:** `npc_vendedor_mercador_8dir.png`
- **Tipo:** Character / NPC (Style Lock Canônico)
- **Tamanho:** Frame 48×48 pixels (Folha 384×48 px) — 100% Aprovado no Style Lock
- **Descrição:** Traveling merchant hunter, forest green traveler's cap with red feather accent, green traveling tunic, diagonal leather shoulder satchel strap, brown breeches, chibi 2.5 heads proportion, 22px height, feet at Y=42.
- **Direções:** 8 direções (South, South-East, East, North-East, North, North-West, West, South-West)
- **Animações:** Idle 8-rotations
- **Mapa:** `world/lobby.tscn` (Distrito Comercial / Tenda em `(-180, -160)`)
- **Local no projeto:** `res://assets/sprites/characters/npc_vendedor_mercador_8dir.png` e pasta `npc_vendedor_mercador_rotations/`
- **Referência utilizada:** Mercador itinerante de suprimentos Hunter
- **Colisão:** Pés do NPC `CircleShape2D(radius=5.0)` em `(0, -2)`
- **Observações:** NPC interativo com cena dedicada `res://entities/npc/vendedor/Vendedor.tscn`.

---

### Registro 13: Discípulo Zushi
- **Asset:** `npc_discipulo_zushi_8dir.png`
- **Tipo:** Character / NPC (Style Lock Canônico)
- **Tamanho:** Frame 48×48 pixels (Folha 384×48 px) — 100% Aprovado no Style Lock
- **Descrição:** Zushi Shingen-ryu young martial arts disciple, short spiky black hair, crisp white karate dogi with black belt knot, chibi 2.5 heads proportion, 21px height, feet at Y=42.
- **Direções:** 8 direções (South, South-East, East, North-East, North, North-West, West, South-West)
- **Animações:** Idle 8-rotations
- **Mapa:** `world/lobby.tscn` (Distrito de Treinamento / Dojo em `(-360, 100)`)
- **Local no projeto:** `res://assets/sprites/characters/npc_discipulo_zushi_8dir.png` e pasta `npc_discipulo_zushi_rotations/`
- **Referência utilizada:** Zushi (discípulo de Wing no Shingen-ryu)
- **Colisão:** Pés do NPC `CircleShape2D(radius=5.0)` em `(0, -2)`
- **Observações:** Sparring partner e instrutor prático de fundamentos básicos de Nen ("Osu!").

---

### Registro 14: Posto de Guarda da Fronteira
- **Asset:** `posto_guarda_watchpost.png`
- **Tipo:** Map Object (Watchpost / Checkpoint)
- **PixelLab ID:** `b0e77861-f974-4a12-a230-78df46e0ce6a`
- **Descrição:** Stone and timber frontier guard outpost watchpost with weathered wooden shingle roof, royal banner crest, iron lantern, weapon rack, and a checkpoint barrier, top-down rpg prop.
- **Tamanho:** 64×64 pixels
- **Direções:** 1 (High Top-Down)
- **Animações:** N/A
- **Mapa:** `world/maps/estrada_padokia.tscn` (Estrada Real em `(480, 80)`)
- **Local no projeto:** `res://assets/sprites/objects/posto_guarda_watchpost.png`
- **Referência utilizada:** Posto de sentinela da fronteira de Padokia
- **Colisão:** Base de fundação `RectangleShape2D(52, 20)` em `(0, 6)`
- **Observações:** Y-sort habilitado; interação `[E] Inspecionar Posto de Guarda`.

---

### Registro 15: Fogueira de Acampamento de Caçador
- **Asset:** `fogueira_acampamento_prop.png`
- **Tipo:** Map Object (Campfire & Rest Site)
- **PixelLab ID:** `677136d6-7771-4d1b-b2d0-8f56b8528c4a`
- **Descrição:** Hunter wilderness campfire with glowing orange embers, crackling logs enclosed by small stone circle, iron cooking spit with hanging kettle, top-down rpg prop.
- **Tamanho:** 32×32 pixels
- **Direções:** 1 (High Top-Down)
- **Animações:** N/A
- **Mapa:** `world/maps/estrada_padokia.tscn` (Estrada Real em `(280, 240)`)
- **Local no projeto:** `res://assets/sprites/objects/fogueira_acampamento_prop.png`
- **Referência utilizada:** Acampamento de descanso para Hunters
- **Colisão:** Círculo de pedras `RectangleShape2D(18, 10)` em `(0, 2)`
- **Observações:** Y-sort habilitado; ponto de descanso interativo `[E] Descansar na Fogueira` restaurando 100% de HP e Aura.

---

### Registro 16: Marco de Pedra das Milhas (Waymarker)
- **Asset:** `marco_pedra_milestone.png`
- **Tipo:** Map Object (Milestone / Waystone)
- **PixelLab ID:** `91217f02-76bb-4803-b42a-ad08e35ca179`
- **Descrição:** Ancient carved stone milestone obelisk waymarker with carved directional arrows and hunter association runes, mossy stone base, top-down rpg prop.
- **Tamanho:** 32×48 pixels
- **Direções:** 1 (High Top-Down)
- **Animações:** N/A
- **Mapa:** `world/maps/estrada_padokia.tscn` (Estrada Real em `(460, 140)`)
- **Local no projeto:** `res://assets/sprites/objects/marco_pedra_milestone.png`
- **Referência utilizada:** Marco miliário da Associação Hunter
- **Colisão:** Base de pedra esculpida `RectangleShape2D(16, 10)` em `(0, 0)`
- **Observações:** Y-sort habilitado; sinalização e leitura `[E] Ler Marco de Pedra`.

---

### Registro 17: Carroça de Suprimentos do Mercador
- **Asset:** `carroca_mercador_wagon.png`
- **Tipo:** Map Object (Merchant Wagon / Transport)
- **PixelLab ID:** `a1d9e8ed-3550-40ec-b824-1df2ad8bb59f`
- **Descrição:** Vintage wooden traveling merchant cargo wagon with cloth canvas tarp cover, wooden spoked wheels, barrels, crates, and ropes, top-down rpg prop.
- **Tamanho:** 64×64 pixels
- **Direções:** 1 (High Top-Down)
- **Animações:** N/A
- **Mapa:** `world/maps/estrada_padokia.tscn` (Estrada Real em `(240, 360)`)
- **Local no projeto:** `res://assets/sprites/objects/carroca_mercador_wagon.png`
- **Referência utilizada:** Caravana de mercadores de Padokia
- **Colisão:** Base das rodas e chassi `RectangleShape2D(46, 18)` em `(0, 4)`
- **Observações:** Y-sort habilitado; interação `[E] Inspecionar Carroça`.

---

### Registro 18: Guarda de Fronteira Hunter
- **Asset:** `npc_guarda_fronteira_8dir.png`
- **Tipo:** Character / NPC (Style Lock Canônico)
- **Tamanho:** Frame 48×48 pixels (Folha 384×48 px) — 100% Aprovado no Style Lock
- **Descrição:** Vigilant royal border guard, steel helmet crest, royal blue tabard over chainmail, upright guard spear/halberd, chibi 2.5 heads proportion, 22px height, feet at Y=42.
- **Direções:** 8 direções (South, South-East, East, North-East, North, North-West, West, South-West)
- **Animações:** Idle 8-rotations
- **Mapa:** `world/maps/estrada_padokia.tscn` (Estrada Real em `(340, 100)`)
- **Local no projeto:** `res://assets/sprites/characters/npc_guarda_fronteira_8dir.png` e pasta `npc_guarda_fronteira_rotations/`
- **Referência utilizada:** Guarda imperial de fronteira da Associação Hunter
- **Colisão:** Pés do NPC `CircleShape2D(radius=5.0)` em `(0, -2)`
- **Observações:** Y-sort habilitado; diálogo com orientações sobre armadura de Nen e quebra de postura/defesa.

---

### Registro 19: Batedor Viajante da Estrada
- **Asset:** `npc_viajante_scout_8dir.png`
- **Tipo:** Character / NPC (Style Lock Canônico)
- **Tamanho:** Frame 48×48 pixels (Folha 384×48 px) — 100% Aprovado no Style Lock
- **Descrição:** Weathered traveling wilderness scout, forest green bandana headwear, tan traveler's duster coat, brown explorer boots, chibi 2.5 heads proportion, 21px height, feet at Y=42.
- **Direções:** 8 direções (South, South-East, East, North-East, North, North-West, West, South-West)
- **Animações:** Idle 8-rotations
- **Mapa:** `world/maps/estrada_padokia.tscn` (Estrada Real em `(320, 240)`)
- **Local no projeto:** `res://assets/sprites/characters/npc_viajante_scout_8dir.png` e pasta `npc_viajante_scout_rotations/`
- **Referência utilizada:** Caçador veterano de exploração de zonas selvagens
- **Colisão:** Pés do NPC `CircleShape2D(radius=5.0)` em `(0, -2)`
- **Observações:** Y-sort habilitado; orientações sobre a Floresta dos Vestígios e a Árvore Milenar Sagrada com Gyo.


