# REGISTRO OFICIAL DE ASSETS PERMANENTES (PIXELLAB PIPELINE)
## Hunter Online — Art Pipeline Canon + Production Bible

Este documento registra formalmente todos os assets permanentes gerados via PixelLab MCP e integrados ao projeto.

> **Autoridade:** `docs/bibles/ART_PIPELINE_CANON.md`
> **STYLE ANCHOR DE PERSONAGEM:** `res://assets/sprites/characters/player.png` / `assets/reference/player(3).png`
> Personagens: 48×48, ~20–22 px, pés Y≈42 — `PIXEL_ART_STYLE_BIBLE.md`
> Mundo: densidade controlada — `PIXEL_ART_PRODUCTION_BIBLE.md` + `assets/reference/world_detail_grass_dirt_trees_ref.png`
> Sprites legados 68×68 px: retificação futura.
---

### Registro 01: Est??tua Monumental do 12?? Presidente Netero
- **Asset:** `estatua_netero_monument.png`
- **Tipo:** Map Object (Landmark)
- **PixelLab ID:** `83aab098-805e-4b3f-ab51-a3d380d4135a`
- **Descri????o:** Granite and bronze monumental statue of an elderly zen martial arts master sitting in meditation on an ornate carved stone pedestal with sacred engravings, top-down rpg prop.
- **Tamanho:** 64??96 pixels
- **Dire????es:** 1 (High Top-Down)
- **Anima????es:** N/A (Est??tua s??lida)
- **Mapa:** `world/lobby.tscn` (Pra??a Central em `(0, -280)`)
- **Local no projeto:** `res://assets/sprites/objects/estatua_netero_monument.png`
- **Refer??ncia utilizada:** Isaac Netero em medita????o zen pr??-Kan'non
- **Colis??o:** Base de pedestal `RectangleShape2D(36, 16)` em `(0, -8)`
- **Observa????es:** Y-sort habilitado; passagem limpa pela frente e por tr??s do pedestal; intera????o `[E] Orar na Est??tua de Netero`.

---

### Registro 02: Grande Port??o de Padokia (Port??o do Mundo Exterior)
- **Asset:** `portao_padokia_arch.png`
- **Tipo:** Map Object (Landmark / Portal)
- **PixelLab ID:** `ce62943f-6d77-482a-9861-2499b5f367f9`
- **Descri????o:** Grand stone and wrought iron gate archway of the hunter association city entrance with banners and heraldic crest, top-down rpg prop.
- **Tamanho:** 64??64 pixels
- **Dire????es:** 1 (High Top-Down)
- **Anima????es:** N/A
- **Mapa:** `world/lobby.tscn` (Sa??da Sul em `(0, 480)`)
- **Local no projeto:** `res://assets/sprites/objects/portao_padokia_arch.png`
- **Refer??ncia utilizada:** Port??o de sa??da da Associa????o para a Estrada Real de Padokia
- **Colis??o:** V??o de transi????o central `(32, 16)` e 2 pilares de pedra s??lidos nas laterais `(14, 16)`
- **Observa????es:** O jogador ?? canalizado fisicamente pelo arco sem atravessar as colunas de pedra.

---

### Registro 03: Recepcionista Elena
- **Asset:** `npc_recepcionista_elena_8dir.png`
- **Tipo:** Character / NPC (Style Lock Can??nico)
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Elena Hunter Association receptionist young woman, neat brown hair in low bun, navy blue formal vest over white collared shirt, dark navy skirt, gold button pin, chibi 2.5 heads proportion, 21px height, feet at Y=42.
- **Dire????es:** 8 dire????es (South, South-East, East, North-East, North, North-West, West, South-West)
- **Anima????es:** Idle 8-rotations
- **Mapa:** `world/lobby.tscn` (Pra??a Central em `(110, -20)`)
- **Local no projeto:** `res://assets/sprites/characters/npc_recepcionista_elena_8dir.png` e pasta `npc_recepcionista_elena_rotations/`
- **Refer??ncia utilizada:** Recepcionista da Associa????o Hunter (Elena)
- **Colis??o:** P??s do NPC `CircleShape2D(radius=6.0)` em `(0, -3)`
- **Observa????es:** Respons??vel pelo tutorial guiado de onboarding e introdu????o de Nen.

---

### Registro 04: Instrutor de Combate & Nen (Wing)
- **Asset:** `npc_instrutor_combate_8dir.png`
- **Tipo:** Character / NPC (Style Lock Can??nico)
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Wing Shingen-ryu Nen master instructor, messy unkempt dark hair, thin glasses bridge, loose dark green kimono tunic with sash over white shirt, beige training pants, chibi 2.5 heads proportion, 21px height, feet at Y=42.
- **Dire????es:** 8 dire????es (South, South-East, East, North-East, North, North-West, West, South-West)
- **Anima????es:** Idle 8-rotations
- **Mapa:** `world/lobby.tscn` (Pra??a Central em `(-110, -20)`)
- **Local no projeto:** `res://assets/sprites/characters/npc_instrutor_combate_8dir.png` e pasta `npc_instrutor_combate_rotations/`
- **Refer??ncia utilizada:** Shingen-ryu Dojo Master (Wing)
- **Colis??o:** P??s do NPC `CircleShape2D(radius=6.0)` em `(0, -3)`
- **Observa????es:** Respons??vel pelo tutorial de ataques, combos, esquiva e barra de defesa.

---

### Registro 05: Examinador Oficial da Associa????o Hunter (Satotz)
- **Asset:** `npc_examinador_oficial_8dir.png`
- **Tipo:** Character / NPC (Style Lock Can??nico)
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Satotz 1st Phase Hunter Examiner, dark charcoal bowler hat, tailored purple suit coat, white formal cravat tie, thin wooden walking cane with gold tip, upright gentleman stance, no mouth, dot eyes, chibi 2.5 heads proportion, 22px height, feet at Y=42.
- **Dire????es:** 8 dire????es (South, South-East, East, North-East, North, North-West, West, South-West)
- **Anima????es:** Idle 8-rotations
- **Mapa:** `world/lobby.tscn` (Pra??a Central / Story Gateway em `(0, -90)`)
- **Local no projeto:** `res://assets/sprites/characters/npc_examinador_oficial_8dir.png` e pasta `npc_examinador_oficial_rotations/`
- **Refer??ncia utilizada:** Examinador Satotz (1?? fase do Exame Hunter)
- **Colis??o:** P??s do NPC `CircleShape2D(radius=6.0)` em `(0, -3)`
- **Observa????es:** Gateway oficial para as sagas e exames do Modo Hist??ria.

---

### Registro 06: Tileset Wang da Pra??a (Grama MMORPG & Lajotas de Pedra)
- **Asset:** `pixellab_lobby_sheet.png` / `lobby_tileset.tres` (Source ID 20)
- **Tipo:** Wang Tileset 16??16 px
- **PixelLab ID:** `f62f6ab8-384c-432a-a047-0a01746f3e3f`
- **Descri????o:** Vibrant lush green mmorpg grass with subtle moss and tiny flowers -> ancient polished cobblestone stone pavement for mmorpg city plaza.
- **Tamanho:** 64??64 pixels (16 tiles de 16??16 px)
- **Base Tile Lower ID:** `6ddcea40-d42f-484f-bf65-793fef276ea5` (Grama base para transi????es futuras de floresta)
- **Base Tile Upper ID:** `03738081-b95b-47c1-ac7e-b3514e8a4f10` (Pedra polida para transi????es futuras de avenidas)
- **Local no projeto:** `res://assets/sprites/tilesets/pixellab/pixellab_lobby_sheet.png`
- **Observa????es:** Utilizado para conex??es e transi????es sem costura entre natureza e arquitetura da capital.

---

### Registro 07: Forja do Mestre Ferreiro (Workshop)
- **Asset:** `forja_ferreiro_workshop.png`
- **Tipo:** Map Object (District Workshop)
- **PixelLab ID:** `3ca3053b-11f4-42c6-aff9-d2477574ed65`
- **Descri????o:** Stone and brick blacksmith workshop with an outdoor anvil, glowing hot coal forge, water quenching trough, and weapon racks, top-down rpg prop.
- **Tamanho:** 64??64 pixels
- **Dire????es:** 1 (High Top-Down)
- **Anima????es:** N/A (Estrutura com fornalha est??tica)
- **Mapa:** `world/lobby.tscn` (Distrito Comercial/Artesanal Oeste em `(-420, -180)`)
- **Local no projeto:** `res://assets/sprites/objects/forja_ferreiro_workshop.png`
- **Refer??ncia utilizada:** Oficina Shingen / Ferraria Hunter
- **Colis??o:** Base da oficina `RectangleShape2D(56, 20)` em `(0, 18)`
- **Observa????es:** Y-sort habilitado; passagem livre na frente e atr??s do telhado.

---

### Registro 08: Tenda / Banca do Mercador Hunter
- **Asset:** `tenda_mercador_stall.png`
- **Tipo:** Map Object (Market Stall)
- **PixelLab ID:** `ef3d721d-8a03-4a0c-83e9-d63171703449`
- **Descri????o:** Wooden merchant market stall with striped fabric awning, wooden crates of goods, potion bottles, scrolls, and lanterns, top-down rpg prop.
- **Tamanho:** 64??64 pixels
- **Dire????es:** 1 (High Top-Down)
- **Anima????es:** N/A
- **Mapa:** `world/lobby.tscn` (Distrito Comercial Oeste em `(-220, -180)`)
- **Local no projeto:** `res://assets/sprites/objects/tenda_mercador_stall.png`
- **Refer??ncia utilizada:** Bazar de mercadores de Padokia
- **Colis??o:** Base dos caixotes e balc??o `RectangleShape2D(52, 16)` em `(0, 16)`
- **Observa????es:** Y-sort habilitado; o balc??o separa o comerciante dos clientes.

---

### Registro 09: Fachada da Casa do Ca??ador (Resid??ncia)
- **Asset:** `casa_cacador_facade.png`
- **Tipo:** Map Object (Residential House Facade)
- **PixelLab ID:** `c09c7c6c-5096-4f03-b7e8-25b1a36533db`
- **Descri????o:** Cozy residential hunter cottage entrance facade with timber-frame stone walls, rustic wooden door, glowing shuttered window, and hanging lantern, top-down rpg prop.
- **Tamanho:** 64??64 pixels
- **Dire????es:** 1 (High Top-Down)
- **Anima????es:** N/A
- **Mapa:** `world/lobby.tscn` (Distrito Residencial Leste em `(380, -180)`)
- **Local no projeto:** `res://assets/sprites/objects/casa_cacador_facade.png`
- **Refer??ncia utilizada:** Alojamentos de Hunters licenciados
- **Colis??o:** Base frontal `RectangleShape2D(56, 18)` em `(0, 18)`
- **Observa????es:** Y-sort habilitado; ponto de transi????o com porta interativa `[E] Entrar na Casa do Ca??ador`.

---

### Registro 10: Boneco de Treino Shingen-ryu
- **Asset:** `boneco_treino_dummy.png`
- **Tipo:** Map Object (Combat & Nen Training Prop)
- **PixelLab ID:** `bcff5897-9ee7-42b2-808a-469ffcd8eff2`
- **Descri????o:** Traditional wooden martial arts training dummy with outstretched wooden arms and rope padding on a solid wooden post base, top-down rpg prop.
- **Tamanho:** 32??48 pixels
- **Dire????es:** 1 (High Top-Down)
- **Anima????es:** N/A
- **Mapa:** `world/lobby.tscn` (Distrito de Treinamento Sudoeste em `(-400, 120)`)
- **Local no projeto:** `res://assets/sprites/objects/boneco_treino_dummy.png`
- **Refer??ncia utilizada:** Postes de treino de artes marciais Shingen
- **Colis??o:** Base cil??ndrica do poste `CircleShape2D(radius=6.0)` em `(0, 16)`
- **Observa????es:** Y-sort habilitado; permite ao jogador praticar posicionamento e golpes corpo a corpo.

---

### Registro 11: Mestre Ferreiro
- **Asset:** `npc_ferreiro_mestre_8dir.png`
- **Tipo:** Character / NPC (Style Lock Can??nico)
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Veteran blacksmith craftsman, brown hair with beard stubble, heavy leather brown apron over steel-gray tunic, small iron forge hammer at side, chibi 2.5 heads proportion, 21px height, feet at Y=42.
- **Dire????es:** 8 dire????es (South, South-East, East, North-East, North, North-West, West, South-West)
- **Anima????es:** Idle 8-rotations
- **Mapa:** `world/lobby.tscn` (Distrito Comercial / Ferraria em `(-360, -160)`)
- **Local no projeto:** `res://assets/sprites/characters/npc_ferreiro_mestre_8dir.png` e pasta `npc_ferreiro_mestre_rotations/`
- **Refer??ncia utilizada:** Ferreiro mestre de armas e equipamentos para hunters
- **Colis??o:** P??s do NPC `CircleShape2D(radius=5.0)` em `(0, -2)`
- **Observa????es:** NPC interativo com cena dedicada `res://entities/npc/ferreiro/Ferreiro.tscn`.

---

### Registro 12: Mercador Hunter
- **Asset:** `npc_vendedor_mercador_8dir.png`
- **Tipo:** Character / NPC (Style Lock Can??nico)
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Traveling merchant hunter, forest green traveler's cap with red feather accent, green traveling tunic, diagonal leather shoulder satchel strap, brown breeches, chibi 2.5 heads proportion, 22px height, feet at Y=42.
- **Dire????es:** 8 dire????es (South, South-East, East, North-East, North, North-West, West, South-West)
- **Anima????es:** Idle 8-rotations
- **Mapa:** `world/lobby.tscn` (Distrito Comercial / Tenda em `(-180, -160)`)
- **Local no projeto:** `res://assets/sprites/characters/npc_vendedor_mercador_8dir.png` e pasta `npc_vendedor_mercador_rotations/`
- **Refer??ncia utilizada:** Mercador itinerante de suprimentos Hunter
- **Colis??o:** P??s do NPC `CircleShape2D(radius=5.0)` em `(0, -2)`
- **Observa????es:** NPC interativo com cena dedicada `res://entities/npc/vendedor/Vendedor.tscn`.

---

### Registro 13: Disc??pulo Zushi
- **Asset:** `npc_discipulo_zushi_8dir.png`
- **Tipo:** Character / NPC (Style Lock Can??nico)
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Zushi Shingen-ryu young martial arts disciple, short spiky black hair, crisp white karate dogi with black belt knot, chibi 2.5 heads proportion, 21px height, feet at Y=42.
- **Dire????es:** 8 dire????es (South, South-East, East, North-East, North, North-West, West, South-West)
- **Anima????es:** Idle 8-rotations
- **Mapa:** `world/lobby.tscn` (Distrito de Treinamento / Dojo em `(-360, 100)`)
- **Local no projeto:** `res://assets/sprites/characters/npc_discipulo_zushi_8dir.png` e pasta `npc_discipulo_zushi_rotations/`
- **Refer??ncia utilizada:** Zushi (disc??pulo de Wing no Shingen-ryu)
- **Colis??o:** P??s do NPC `CircleShape2D(radius=5.0)` em `(0, -2)`
- **Observa????es:** Sparring partner e instrutor pr??tico de fundamentos b??sicos de Nen ("Osu!").

---

### Registro 14: Posto de Guarda da Fronteira
- **Asset:** `posto_guarda_watchpost.png`
- **Tipo:** Map Object (Watchpost / Checkpoint)
- **PixelLab ID:** `b0e77861-f974-4a12-a230-78df46e0ce6a`
- **Descri????o:** Stone and timber frontier guard outpost watchpost with weathered wooden shingle roof, royal banner crest, iron lantern, weapon rack, and a checkpoint barrier, top-down rpg prop.
- **Tamanho:** 64??64 pixels
- **Dire????es:** 1 (High Top-Down)
- **Anima????es:** N/A
- **Mapa:** `world/maps/estrada_padokia.tscn` (Estrada Real em `(480, 80)`)
- **Local no projeto:** `res://assets/sprites/objects/posto_guarda_watchpost.png`
- **Refer??ncia utilizada:** Posto de sentinela da fronteira de Padokia
- **Colis??o:** Base de funda????o `RectangleShape2D(52, 20)` em `(0, 6)`
- **Observa????es:** Y-sort habilitado; intera????o `[E] Inspecionar Posto de Guarda`.

---

### Registro 15: Fogueira de Acampamento de Ca??ador
- **Asset:** `fogueira_acampamento_prop.png`
- **Tipo:** Map Object (Campfire & Rest Site)
- **PixelLab ID:** `677136d6-7771-4d1b-b2d0-8f56b8528c4a`
- **Descri????o:** Hunter wilderness campfire with glowing orange embers, crackling logs enclosed by small stone circle, iron cooking spit with hanging kettle, top-down rpg prop.
- **Tamanho:** 32??32 pixels
- **Dire????es:** 1 (High Top-Down)
- **Anima????es:** N/A
- **Mapa:** `world/maps/estrada_padokia.tscn` (Estrada Real em `(280, 240)`)
- **Local no projeto:** `res://assets/sprites/objects/fogueira_acampamento_prop.png`
- **Refer??ncia utilizada:** Acampamento de descanso para Hunters
- **Colis??o:** C??rculo de pedras `RectangleShape2D(18, 10)` em `(0, 2)`
- **Observa????es:** Y-sort habilitado; ponto de descanso interativo `[E] Descansar na Fogueira` restaurando 100% de HP e Aura.

---

### Registro 16: Marco de Pedra das Milhas (Waymarker)
- **Asset:** `marco_pedra_milestone.png`
- **Tipo:** Map Object (Milestone / Waystone)
- **PixelLab ID:** `91217f02-76bb-4803-b42a-ad08e35ca179`
- **Descri????o:** Ancient carved stone milestone obelisk waymarker with carved directional arrows and hunter association runes, mossy stone base, top-down rpg prop.
- **Tamanho:** 32??48 pixels
- **Dire????es:** 1 (High Top-Down)
- **Anima????es:** N/A
- **Mapa:** `world/maps/estrada_padokia.tscn` (Estrada Real em `(460, 140)`)
- **Local no projeto:** `res://assets/sprites/objects/marco_pedra_milestone.png`
- **Refer??ncia utilizada:** Marco mili??rio da Associa????o Hunter
- **Colis??o:** Base de pedra esculpida `RectangleShape2D(16, 10)` em `(0, 0)`
- **Observa????es:** Y-sort habilitado; sinaliza????o e leitura `[E] Ler Marco de Pedra`.

---

### Registro 17: Carro??a de Suprimentos do Mercador
- **Asset:** `carroca_mercador_wagon.png`
- **Tipo:** Map Object (Merchant Wagon / Transport)
- **PixelLab ID:** `a1d9e8ed-3550-40ec-b824-1df2ad8bb59f`
- **Descri????o:** Vintage wooden traveling merchant cargo wagon with cloth canvas tarp cover, wooden spoked wheels, barrels, crates, and ropes, top-down rpg prop.
- **Tamanho:** 64??64 pixels
- **Dire????es:** 1 (High Top-Down)
- **Anima????es:** N/A
- **Mapa:** `world/maps/estrada_padokia.tscn` (Estrada Real em `(240, 360)`)
- **Local no projeto:** `res://assets/sprites/objects/carroca_mercador_wagon.png`
- **Refer??ncia utilizada:** Caravana de mercadores de Padokia
- **Colis??o:** Base das rodas e chassi `RectangleShape2D(46, 18)` em `(0, 4)`
- **Observa????es:** Y-sort habilitado; intera????o `[E] Inspecionar Carro??a`.

---

### Registro 18: Guarda de Fronteira Hunter
- **Asset:** `npc_guarda_fronteira_8dir.png`
- **Tipo:** Character / NPC (Style Lock Can??nico)
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Vigilant royal border guard, steel helmet crest, royal blue tabard over chainmail, upright guard spear/halberd, chibi 2.5 heads proportion, 22px height, feet at Y=42.
- **Dire????es:** 8 dire????es (South, South-East, East, North-East, North, North-West, West, South-West)
- **Anima????es:** Idle 8-rotations
- **Mapa:** `world/maps/estrada_padokia.tscn` (Estrada Real em `(340, 100)`)
- **Local no projeto:** `res://assets/sprites/characters/npc_guarda_fronteira_8dir.png` e pasta `npc_guarda_fronteira_rotations/`
- **Refer??ncia utilizada:** Guarda imperial de fronteira da Associa????o Hunter
- **Colis??o:** P??s do NPC `CircleShape2D(radius=5.0)` em `(0, -2)`
- **Observa????es:** Y-sort habilitado; di??logo com orienta????es sobre armadura de Nen e quebra de postura/defesa.

---

### Registro 19: Batedor Viajante da Estrada
- **Asset:** `npc_viajante_scout_8dir.png`
- **Tipo:** Character / NPC (Style Lock Can??nico)
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Weathered traveling wilderness scout, forest green bandana headwear, tan traveler's duster coat, brown explorer boots, chibi 2.5 heads proportion, 21px height, feet at Y=42.
- **Dire????es:** 8 dire????es (South, South-East, East, North-East, North, North-West, West, South-West)
- **Anima????es:** Idle 8-rotations
- **Mapa:** `world/maps/estrada_padokia.tscn` (Estrada Real em `(320, 240)`)
- **Local no projeto:** `res://assets/sprites/characters/npc_viajante_scout_8dir.png` e pasta `npc_viajante_scout_rotations/`
- **Refer??ncia utilizada:** Ca??ador veterano de explora????o de zonas selvagens
- **Colis??o:** P??s do NPC `CircleShape2D(radius=5.0)` em `(0, -2)`
- **Observa????es:** Y-sort habilitado; orienta????es sobre a Floresta dos Vest??gios e a ??rvore Milenar Sagrada com Gyo.

---

### Registro 20: Gon Freecss (Refinado MMORPG)
- **Asset:** `npc_gon_8dir.png`
- **Tipo:** Character / NPC Can??nico
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Gon Freecss com jaqueta verde e debrum alaranjado, shorts curto verde, botas marrons com cadar??o e solado escuro, cabelo espetado vertical preto com reflexos verdes de topo, olhos expressivos ??mbar.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`npc_gon_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/npc_gon_8dir.png`
- **Cena Associada:** `entities/npc/gon/Gon.tscn`
- **Style Lock:** Bounding Box 11??23 px, 10 cores ??nicas na folha, p??s em Y=42.

---

### Registro 21: Killua Zoldyck (Refinado MMORPG)
- **Asset:** `npc_killua_8dir.png`
- **Tipo:** Character / NPC Can??nico
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Killua Zoldyck com camisa branca de gola V sobre manga longa azul escura/preta, bermuda folgada cinza/azulada, meias/t??nis roxos e cabelo volumoso despenteado prateado/branco com reflexos celestes, olhos azuis felinos.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`npc_killua_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/npc_killua_8dir.png`
- **Cena Associada:** `entities/npc/killua/Killua.tscn`
- **Style Lock:** Bounding Box 11??22 px, 10 cores ??nicas na folha, p??s em Y=42.

---

### Registro 22: Kurapika Kurta (Refinado MMORPG)
- **Asset:** `npc_kurapika_8dir.png`
- **Tipo:** Character / NPC Can??nico
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Kurapika no traje tradicional do Cl?? Kurta com tabardo azul royal, debrum carmesim detalhado em todas as bordas, t??nica interna e cal??as brancas com sapatilhas escuras, cabelo loiro liso em camadas e pontas ca??das sobre o peito.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`npc_kurapika_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/npc_kurapika_8dir.png`
- **Cena Associada:** `entities/npc/kurapika/Kurapika.tscn`
- **Style Lock:** Bounding Box 11??22 px, 10 cores ??nicas na folha, p??s em Y=42.

---

### Registro 23: Leorio Paladiknight (Refinado MMORPG)
- **Asset:** `npc_leorio_8dir.png`
- **Tipo:** Character / NPC Can??nico
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Leorio em terno formal azul-marinho com riscas e costuras de sombra, gravata vermelha estreita, camisa branca de colarinho, sapatos sociais com solado duplo, ??culos escuros redondos e maleta de couro marrom na m??o esquerda.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`npc_leorio_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/npc_leorio_8dir.png`
- **Cena Associada:** `entities/npc/leorio/Leorio.tscn`
- **Style Lock:** Bounding Box 13??23 px, 11 cores ??nicas na folha, p??s em Y=42.

---

### Registro 24: Hisoka Morow (Refinado MMORPG)
- **Asset:** `npc_hisoka_8dir.png`
- **Tipo:** Character / NPC Can??nico
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Hisoka em colete e traje de arlequim vinho escuro com naipes e la??os esmeralda/turquesa, cal??as bufantes brancas, sapatos pontiagudos com curvas de palha??o, cabelo f??csia/magenta erguido em topete espetado, maquiagem de l??grima e estrela nas bochechas.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`npc_hisoka_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/npc_hisoka_8dir.png`
- **Cena Associada:** `entities/npc/hisoka/Hisoka.tscn`
- **Style Lock:** Bounding Box 11??23 px, 11 cores ??nicas na folha, p??s em Y=42.

---

### Registro 25: Chrollo Lucilfer (Refinado MMORPG)
- **Asset:** `npc_chrollo_8dir.png`
- **Tipo:** Character / NPC Can??nico
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Chrollo Lucilfer com sobretudo longo de couro preto e gola espessa de pele branca acinzentada, estampa da Cruz de S??o Pedro invertida bordada a ouro nas costas, cabelos negros penteados para tr??s e tatuagem da cruz na testa com brincos de esmeralda.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`npc_chrollo_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/npc_chrollo_8dir.png`
- **Cena Associada:** `entities/npc/chrollo/Chrollo.tscn`
- **Style Lock:** Bounding Box 11??22 px, 10 cores ??nicas na folha, p??s em Y=42.

---

### Registro 26: Isaac Netero (Refinado MMORPG)
- **Asset:** `npc_netero_8dir.png`
- **Tipo:** Character / NPC Can??nico
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Presidente Netero em dogi tradicional branco de artes marciais com bordas e faixa azuis, sand??lias geta japonesas de madeira, barba e bigode brancos proeminentes com topete/coque superior e sobrancelhas expressivas.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`npc_netero_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/npc_netero_8dir.png`
- **Cena Associada:** `entities/npc/netero/Netero.tscn`
- **Style Lock:** Bounding Box 11??22 px, 11 cores ??nicas na folha, p??s em Y=42.

---

### Registro 27: Biscuit Krueger (Refinado MMORPG)
- **Asset:** `npc_biscuit_8dir.png`
- **Tipo:** Character / NPC Can??nico
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Bisky em vestido vitoriano rodado magenta com babados rendados brancos na barra e peito, cabelos loiros em maria-chiquinha dupla volumosa presa com fitas cor-de-rosa, sapatos boneca e postura refinada de mestre Nen.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`npc_biscuit_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/npc_biscuit_8dir.png`
- **Cena Associada:** `entities/npc/biscuit/Biscuit.tscn`
- **Style Lock:** Bounding Box 13??22 px, 11 cores ??nicas na folha, p??s em Y=42.

---

### Registro 28: Tonpa (Refinado MMORPG)
- **Asset:** `npc_tonpa_8dir.png`
- **Tipo:** Character / NPC Can??nico
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Tonpa o "Esmaga-Novatos", com su??ter azul encorpado e barrigudo, shorts bege c??qui, sapato marrom pesado, distintivo Hunter n?? 16 no peito, cabelo castanho com entradas e express??o desconfiada carregando suco laxante.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`npc_tonpa_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/npc_tonpa_8dir.png`
- **Cena Associada:** `entities/npc/tonpa/Tonpa.tscn`
- **Style Lock:** Bounding Box 13??22 px, 10 cores ??nicas na folha, p??s em Y=42.

---

### Registro 29: Ging Freecss (Refinado MMORPG)
- **Asset:** `npc_ging_8dir.png`
- **Tipo:** Character / NPC Can??nico
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Ging Freecss com turbante/faixa bege acinzentada enrolada na cabe??a com mechas espetadas saindo, t??nica marrom-terra com cinto de fivela de couro, cal??a folgada e botas de desbravador arqueol??gico.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`npc_ging_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/npc_ging_8dir.png`
- **Cena Associada:** `entities/npc/ging/Ging.tscn`
- **Style Lock:** Bounding Box 11??22 px, 10 cores ??nicas na folha, p??s em Y=42.

---

### Registro 30: Hanzo (Refinado MMORPG)
- **Asset:** `npc_hanzo_8dir.png`
- **Tipo:** Character / NPC Can??nico
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Ninja Hanzo de Cloud Village com cabe??a raspada reluzente, dogi roxo/lil??s de shinobi sem mangas, bra??adeiras protetoras e faixa preta com bainha/l??mina curta nas costas.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`npc_hanzo_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/npc_hanzo_8dir.png`
- **Cena Associada:** `entities/npc/hanzo/Hanzo.tscn`
- **Style Lock:** Bounding Box 11??22 px, 9 cores ??nicas na folha, p??s em Y=42.

---

### Registro 31: Pokkle (Refinado MMORPG)
- **Asset:** `npc_pokkle_8dir.png`
- **Tipo:** Character / NPC Can??nico
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Arqueiro Pokkle com t??nica amarela de ca??a, cal??a de viagem, turbante vermelho com pena/faixa decorativa e aljava de flechas nas costas com arco estilizado.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`npc_pokkle_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/npc_pokkle_8dir.png`
- **Cena Associada:** `entities/npc/pokkle/Pokkle.tscn`
- **Style Lock:** Bounding Box 11??22 px, 10 cores ??nicas na folha, p??s em Y=42.

---

### Registro 32: Ponzu (Refinado MMORPG)
- **Asset:** `npc_ponzu_8dir.png`
- **Tipo:** Character / NPC Can??nico
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Ponzu com grande boina amarela abobadada (onde guarda suas abelhas qu??micas), cabelos turquesa caindo pelos lados, vestido curto magenta com cinto e meias brancas.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`npc_ponzu_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/npc_ponzu_8dir.png`
- **Cena Associada:** `entities/npc/ponzu/Ponzu.tscn`
- **Style Lock:** Bounding Box 13??22 px, 10 cores ??nicas na folha, p??s em Y=42.

---

### Registro 33: Buhara (Refinado MMORPG)
- **Asset:** `npc_buhara_8dir.png`
- **Tipo:** Character / NPC Can??nico
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Examinador Gourmet Buhara com constitui????o corporal massiva e imponente, colete aberto amarelo revelando barriga roli??a, cal??a preta e express??o bochechuda jovial.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`npc_buhara_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/npc_buhara_8dir.png`
- **Cena Associada:** `entities/npc/gourmet/Buhara.tscn`
- **Style Lock:** Bounding Box 15??22 px, 9 cores ??nicas na folha, p??s em Y=42.

---

### Registro 34: Menchi (Refinado MMORPG)
- **Asset:** `npc_menchi_8dir.png`
- **Tipo:** Character / NPC Can??nico
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Examinadora Gourmet Menchi de 1 Estrela com top halter cropped preto, shorts jeans curto, cabelos cor de menta/ciano presos em cinco pequenos coques/chifres pontiagudos com faixas.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`npc_menchi_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/npc_menchi_8dir.png`
- **Cena Associada:** `entities/npc/gourmet/Menchi.tscn`
- **Style Lock:** Bounding Box 11??22 px, 9 cores ??nicas na folha, p??s em Y=42.

---

### Registro 35: Gittarackur / Illumi Zoldyck (Refinado MMORPG)
- **Asset:** `npc_gittarackur_8dir.png`
- **Tipo:** Character / NPC Can??nico
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Illumi disfar??ado de Gittarackur com dezenas de agulhas de Nen douradas espetadas no rosto e cabe??a, t??nica verde-oliva com tachas met??licas e olhar arregalado inexpressivo.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`npc_gittarackur_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/npc_gittarackur_8dir.png`
- **Cena Associada:** `entities/npc/illumi/Gittarackur.tscn`
- **Style Lock:** Bounding Box 11??22 px, 9 cores ??nicas na folha, p??s em Y=42.

---

### Registro 36: Bodoro (Refinado MMORPG)
- **Asset:** `npc_bodoro_8dir.png`
- **Tipo:** Character / NPC Can??nico
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Guerreiro veterano Bodoro com armadura samuraica marrom-ferro sobre keikogi, cabelos grisalhos penteados para tr??s e express??o severa de veterano de guerra com lan??a/katana embainhada.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`npc_bodoro_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/npc_bodoro_8dir.png`
- **Cena Associada:** `entities/npc/bodoro/Bodoro.tscn`
- **Style Lock:** Bounding Box 11??22 px, 9 cores ??nicas na folha, p??s em Y=42.

---

### Registro 37: Nicol (Refinado MMORPG)
- **Asset:** `npc_nicol_8dir.png`
- **Tipo:** Character / NPC Can??nico
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Nicol o g??nio do laptop port??til com camisa social azul claro, gravata fina, cal??a social marrom escura e laptop tecnol??gico aberto em m??os digitando dados do exame.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`npc_nicol_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/npc_nicol_8dir.png`
- **Cena Associada:** `entities/npc/nicol/Nicol.tscn`
- **Style Lock:** Bounding Box 11??22 px, 10 cores ??nicas na folha, p??s em Y=42.

---

### Registro 38: Inimigo Candidato ao Exame Hunter (Refinado MMORPG)
- **Asset:** `enemy_candidato_exame_8dir.png`
- **Tipo:** Enemy / Mob (Fase Exame)
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Candidato hostil e rival do exame de ca??adores com bandana vermelha na testa, adaga curva e distintivo com numera????o de exame na jaqueta cinza de couro.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`enemy_candidato_exame_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/enemy_candidato_exame_8dir.png`
- **Style Lock:** Bounding Box 11??22 px, 10 cores ??nicas na folha, p??s em Y=42.

---

### Registro 39: Criatura do Pantanal Numere (Refinado MMORPG)
- **Asset:** `enemy_criatura_pantanal_8dir.png`
- **Tipo:** Enemy / Monstro Silvestre
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Fera enganadora do pantanal com carapa??a r??ptil verde musgo, ventre p??lido, olhos carmesim predadores e garras afiadas para emboscadas na n??voa.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`enemy_criatura_pantanal_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/enemy_criatura_pantanal_8dir.png`
- **Style Lock:** Bounding Box 13??22 px, 9 cores ??nicas na folha, p??s em Y=42.

---

### Registro 40: Mordomo Zoldyck (Refinado MMORPG)
- **Asset:** `enemy_mordomo_zoldyck_8dir.png`
- **Tipo:** Enemy / Elite Humanoide (Montanha Kukuroo)
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Servo mordomo treinado da fam??lia Zoldyck em smoking preto engomado com luvas brancas e postura impec??vel de combate e proje????o de moedas assassinas.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`enemy_mordomo_zoldyck_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/enemy_mordomo_zoldyck_8dir.png`
- **Style Lock:** Bounding Box 11??22 px, 10 cores ??nicas na folha, p??s em Y=42.

---

### Registro 41: Lutador da Arena Celestial (Refinado MMORPG)
- **Asset:** `enemy_lutador_arena_8dir.png`
- **Tipo:** Enemy / Competidor de Artes Marciais (Andar 200)
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Lutador brutal de arena com cal??a de muay thai preta e vermelha, ataduras nas m??os e p??s e complei????o atl??tica musculosa com postura de guarda marcial.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`enemy_lutador_arena_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/enemy_lutador_arena_8dir.png`
- **Style Lock:** Bounding Box 11??22 px, 8 cores ??nicas na folha, p??s em Y=42.

---

### Registro 42: Mafioso de Yorknew (Refinado MMORPG)
- **Asset:** `enemy_mafioso_yorknew_8dir.png`
- **Tipo:** Enemy / Bandido Armado (Saga Yorknew)
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Capanga da m??fia com terno risca de giz escuro, ??culos escuros, chap??u fedora e metralhadora Thompson ou pistola de calibre pesado em punho.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`enemy_mafioso_yorknew_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/enemy_mafioso_yorknew_8dir.png`
- **Style Lock:** Bounding Box 11??22 px, 9 cores ??nicas na folha, p??s em Y=42.

---

### Registro 43: Bomber de Greed Island (Refinado MMORPG)
- **Asset:** `enemy_bomber_greed_8dir.png`
- **Tipo:** Enemy / Usu??rio Hostil de Nen (Greed Island)
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Terrorista especialista em explos??es com regata escura, luvas isolantes de Nen com auras incandescentes nas pontas dos dedos e bandanas de mercen??rio.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`enemy_bomber_greed_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/enemy_bomber_greed_8dir.png`
- **Style Lock:** Bounding Box 11??22 px, 10 cores ??nicas na folha, p??s em Y=42.

---

### Registro 44: Formiga Quimera Soldado (Refinado MMORPG)
- **Asset:** `enemy_formiga_soldado_8dir.png`
- **Tipo:** Enemy / Monstro Quimera (Fase NGL)
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Formiga Quimera com exoesqueleto quitinoso inset??ide verde-escuro, mand??bulas afiadas e ferr??o/carapa??a com espinhos biol??gicos.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`enemy_formiga_soldado_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/enemy_formiga_soldado_8dir.png`
- **Style Lock:** Bounding Box 11??22 px, 5 cores ??nicas na folha, p??s em Y=42.

---

### Registro 45: Formiga Quimera L??der de Esquadr??o (Refinado MMORPG)
- **Asset:** `enemy_formiga_lider_8dir.png`
- **Tipo:** Enemy / Elite Quimera com Nen
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** L??der de esquadr??o h??brido com coura??a biol??gica rubra e chifres frontais proeminentes, capa membranosa nas costas e asas recolhidas.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`enemy_formiga_lider_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/enemy_formiga_lider_8dir.png`
- **Style Lock:** Bounding Box 13??23 px, 8 cores ??nicas na folha, p??s em Y=42.

---

### Registro 46: Guarda Real das Formigas Quimera (Refinado MMORPG)
- **Asset:** `enemy_guarda_real_8dir.png`
- **Tipo:** Enemy / Sub-Boss de Elite (Guarda Real)
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Humanoide quim??rico supremo com tra??os de felino/inseto, casaco abotoado formal, orelhas sensoriais de ca??ador e aura imponente com cauda blindada.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`enemy_guarda_real_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/enemy_guarda_real_8dir.png`
- **Style Lock:** Bounding Box 12??23 px, 13 cores ??nicas na folha, p??s em Y=42.

---

### Registro 47: Chefe Razor (Refinado MMORPG)
- **Asset:** `enemy_boss_razor_8dir.png`
- **Tipo:** Boss / Emissor de Greed Island
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Razor o Game Master de Greed Island, com f??sico monumental imponente, regata atl??tica branca, bermuda e bola de queimada carregada com Nen de Emiss??o na m??o.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`enemy_boss_razor_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/enemy_boss_razor_8dir.png`
- **Style Lock:** Bounding Box 15??23 px, 11 cores ??nicas na folha, p??s em Y=42.

---

### Registro 48: Chefe Meruem ??? O Rei das Formigas Quimera (Refinado MMORPG)
- **Asset:** `enemy_boss_meruem_8dir.png`
- **Tipo:** World Boss / Soberano das Formigas
- **Tamanho:** Frame 48??48 pixels (Folha 384??48 px) ??? 100% Aprovado no Style Lock
- **Descri????o:** Meruem o Rei das Formigas Quimera, com carapa??a verde-jade escura, capacete/coroa biol??gico escuro com protetores auriculares, olhos lilases penetrantes e cauda longa com ferr??o articulado.
- **Dire????es:** 8 dire????es can??nicas (S, SE, E, NE, N, NW, W, SW)
- **Anima????es:** Idle 8-rotations (`enemy_boss_meruem_rotations/*.png`)
- **Local no projeto:** `res://assets/sprites/characters/enemy_boss_meruem_8dir.png`
- **Style Lock:** Bounding Box 14??23 px, 12 cores ??nicas na folha, p??s em Y=42.




---

### Registro 49: Lobo das Sombras (Floresta ? EM PROCESSAMENTO)
- **Tipo:** Enemy / Quadruped (dog template)
- **PixelLab ID:** `4c51b634-5219-46bd-9b25-e249b8a7b38b`
- **Modo:** standard ? 48?48 ? 8 dire??es ? walk-8-frames enfileirado
- **Uso previsto:** `FlorestaVestigiosMap` role `fast` (FeraSombra3)
- **Status:** generating ? integrar em `assets/sprites/characters/` ao concluir

### Registro 50: Fera Alada Emboscadora (Floresta ? EM PROCESSAMENTO)
- **Tipo:** Enemy / Humanoid chibi
- **PixelLab ID:** `02ce2c44-54b1-42df-a7d3-f8843206b3b2`
- **Modo:** v3 ? 48?48 ? 8 dire??es
- **Uso previsto:** `FlorestaVestigiosMap` role `ambusher` (FeraSombra4)
- **Status:** generating ? integrar ao concluir


### Registro 51: Mon?lito de Nen Ancestral (Map Prop)
- **Asset:** `nen_stone_monolith.png`
- **PixelLab ID:** `92520cfe-89f9-48f9-9002-843c9c0e26fc`
- **Local:** `res://assets/sprites/objects/nen_stone_monolith.png`
- **Uso:** landmarks Floresta / Estrada / Dungeon / Vale via `MapAtmosphereDecorator`

### Registro 52: Lanterna da Estrada Hunter
- **Asset:** `hunter_road_lantern.png`
- **PixelLab ID:** `ee80288b-4f32-4b25-8db5-4fe552e4574b`
- **Local:** `res://assets/sprites/objects/hunter_road_lantern.png`

### Registro 53: Tocha de Nen das Ru?nas
- **Asset:** `ruin_nen_torch.png`
- **PixelLab ID:** `ea0af334-3697-4d56-a3da-4dfb47c3d3f9`
- **Local:** `res://assets/sprites/objects/ruin_nen_torch.png`

### Registro 49 (atualizado): Lobo das Sombras
- **Asset:** `enemy_lobo_sombras_8dir.png` + `enemy_lobo_sombras_walk_8x8.png`
- **PixelLab ID:** `4c51b634-5219-46bd-9b25-e249b8a7b38b`
- **Walk group:** `9aaf8257-147f-469d-8c62-79b87e7741a8` (8 dirs ? 8 frames, cells 48?48)
- **Status:** integrado (idle + walk)

### Registro 50 (atualizado): Fera Alada Emboscadora
- **Asset:** `enemy_fera_alada_8dir.png` + `enemy_fera_alada_walk_8x8.png`
- **PixelLab ID:** `02ce2c44-54b1-42df-a7d3-f8843206b3b2`
- **Walk:** folha `384?384` (8?8), cells 48?48
- **Status:** integrado (idle + walk)

### Registro 55: Sentinela de Pedra Ancestral (Tank Floresta)
- **Asset:** `enemy_sentinela_pedra_8dir.png`
- **PixelLab ID:** `9f024283-f8da-4717-89c0-aeff7ac77b7c`
- **Local:** `res://assets/sprites/characters/enemy_sentinela_pedra_8dir.png`
- **Uso:** `FlorestaVestigiosMap` role `tank` / `enemy_id=sentinela_pedra`
- **Nota:** canvas gerado 68px, reamostrado para cells 48�48 (Style Lock)

### Registro 56: Melody (Yorknew)
- **Asset:** `npc_melody_8dir.png`
- **PixelLab ID:** `463b74e6-082b-413f-af14-9425f04333d6`
- **Local:** `res://assets/sprites/characters/npc_melody_8dir.png`

### Registro 57: Battera (Yorknew)
- **Asset:** `npc_battera_8dir.png`
- **PixelLab ID:** `7269c311-12d6-4a00-a7a4-ba68753fdada`
- **Local:** `res://assets/sprites/characters/npc_battera_8dir.png`

### Registro 58: Tsezguerra (Yorknew)
- **Asset:** `npc_tsezguerra_8dir.png`
- **PixelLab ID:** `749a8764-0389-44ef-b121-e98322929410`
- **Local:** `res://assets/sprites/characters/npc_tsezguerra_8dir.png`
- **Style Lock:** restyle 48px + quantize (aprovado)

### Registro 59: Mordoma Canary (Kukuroo)
- **Asset:** `npc_mordoma_canary_8dir.png`
- **PixelLab ID:** `9072cfed-b1a3-4114-9554-c2306dbccb93`
- **Local:** `res://assets/sprites/characters/npc_mordoma_canary_8dir.png`
- **Nota:** gerado 68px ? Style Lock 48 via `scratch/restyle_lock_pixellab_sheets.gd`

### Registro 60: Mordomo Gotoh (Kukuroo)
- **Asset:** `npc_mordomo_gotoh_8dir.png`
- **PixelLab ID:** `8a87c942-f543-4572-9b01-e13c3511ceeb`
- **Local:** `res://assets/sprites/characters/npc_mordomo_gotoh_8dir.png`

### Registro 61: Silva Zoldyck (Kukuroo)
- **Asset:** `npc_silva_zoldyck_8dir.png`
- **PixelLab ID:** `39f1f90c-a977-41bd-88df-9de7c41b64fe`
- **Local:** `res://assets/sprites/characters/npc_silva_zoldyck_8dir.png`

### Registro 62�65: Lobby densifica��o (decora��o)
- `lobby_tent_decor.png` � ID `c2d20f31-0cd6-4f12-aa76-97d3a37c8366`
- `lobby_cottage_decor.png` � ID `64617698-197e-4d84-9c05-ec714103e88b`
- `lobby_stall_decor.png` � ID `a2d23ea7-1295-49c6-a22f-f97be163799a`
- `lobby_bush_flowers_decor.png` � ID `7bccf1f9-2096-42ed-bb00-c0052d352d28`
- **Uso:** `Lobby._densificar_lobby_pixel_art()` (s� decora��o, sem entrada)

### Registro 66: Portal Hunter (landmark)
- Asset: portal_hunter_arch.png � PixelLab 874a56f2-ded1-4c3d-b295-bb9c20b55024
- Uso: PortalHunter.gd + GPS passo 3 (leste)

### Registro 67-70: HUD + Constelacao Nen
- hud_wood_panel_kit.png � bdbd6cac-bb8d-4084-a077-64dce3ca1ab5
- hud_resource_bars.png � 8d9c679b-14ed-4031-906b-44d75a4d12f0
- nen_skill_tree_bg.png � 3561919c-f9dd-4685-8fa2-1d4bc286a52f
- nen_category_icons.png � bfb9da33-cc6d-4caa-a8ca-1aebf8f5abe7
- nen_skill_node_rings.png � 0eec61fe-795e-48cc-95e2-039d7bd709fe

### Registro 71-73: HUD ornamentado + skill small + estradas lobby
- `nen_small_node_icons.png` � e3cc9dbf-b684-4ef2-a118-394515c80bf7 (sheet 192�32, 12 �cones)
- `hud_ornate_bar_frame.png` / `hud_ornate_bars_kit.png` � 8ab02532 + ui 652e1a36 (frame ouro pixel com slot interno)
- `assets/tiles/lobby_paths/*` � path tiles 05f1bf05-c23c-4342-bb10-668da7f1daf6 (18 configs 32px)
- Uso: NenSkillTreeUI n�s SMALL; PlayerHUD barras; Lobby._melhorar_estradas_lobby()

---

### Registro 74: Calibration Batch §94 — Grass/Dirt Wang
- **Asset:** `calibration_grass_dirt_wang.png`
- **Tipo:** Wang Tileset 16×16 (sheet 64×64)
- **PixelLab ID:** `2f8e3bd5-175d-4797-9104-c417157e62e4`
- **Descrição:** Compact warm brown dirt path ↔ soft temperate green grassland with tufts/flowers
- **Local:** `res://assets/sprites/tilesets/pixellab/calibration_grass_dirt_wang.png`
- **Integração:** `CalibrationArtKit` → `EstradaPadokiaMap` (faixa central)
- **Status:** approved / integrated

### Registro 75-80: Calibration Batch §94 — Vegetation / Rocks / Ground
- `calibration_tree_a.png` — ID `b3267310-98cc-46ed-94e3-3ffa06f9f34c` (48×64 deciduous)
- `calibration_tree_b.png` — ID `60c67181-7303-45a0-9998-85f7e117176f` (40×64 pine)
- `calibration_bush_a.png` — ID `b55b47c5-dfc6-4b1c-80a8-8a6f0130f6a6` (32×32)
- `calibration_rock_a.png` — ID `dd973f6c-5fa7-4bc5-b0d9-dca95764a545` (32×32)
- `calibration_rock_b.png` — ID `936fee89-af85-44eb-88c4-3dd362eb1ff9` (40×32)
- `calibration_ground_details.png` — ID `6dc079f6-76a1-4aa9-a5c4-ec9939004455` (48×32 tufts/flowers/pebbles)
- **Local:** `res://assets/sprites/objects/calibration_*.png`
- **Status:** approved / integrated

### Registro 81: Calibration Batch §94 — Viajante Padokia (Style Lock)
- **Asset:** `npc_calibration_viajante_padokia_8dir.png`
- **Tipo:** Character / NPC (Style Lock Canônico 48×48 × 8 dir)
- **PixelLab ID:** `8937fc48-91f8-44aa-a968-d9c096f5966a` (v3 + player reference; rejected first standard/68px attempt)
- **Descrição:** Traveling hunter apprentice, brown cloak, backpack — 8 directions
- **Métricas:** frame 48×48, height ~19px, width ~13px, ~10 cores, feet Y≈40
- **Local:** `res://assets/sprites/characters/npc_calibration_viajante_padokia_8dir.png` + `npc_calibration_viajante_padokia_rotations/`
- **Mapa:** `world/maps/EstradaPadokiaMap.gd` via `CalibrationArtKit` (`ViajanteCalibracao` @ `(400, 260)`)
- **Status:** approved / integrated

---

### Registro 82: World Detail Reference (Grass/Dirt/Trees)
- **Asset:** `world_detail_grass_dirt_trees_ref.png`
- **Tipo:** Style / World Detail Reference (não-asset de gameplay)
- **Local:** `res://assets/reference/world_detail_grass_dirt_trees_ref.png`
- **Uso:** Nível de riqueza ambiental alvo (grama olive + terra jagged + canopies bubbly)
- **Status:** reference

### Registro 83: Phase 2 — Grass/Dirt Wang (refinado)
- **Asset:** `phase2_grass_dirt_wang.png`
- **PixelLab ID:** `599b9329-fb77-44cb-be15-9d15cb2333e4`
- **Local:** `res://assets/sprites/tilesets/pixellab/phase2_grass_dirt_wang.png`
- **Integração:** `WorldDensityKit` (Estrada + Floresta)
- **Status:** approved / integrated

### Registro 84-92: Phase 2 — Vegetation / Rocks / Details
- `phase2_tree_green_a.png` — `32bbad27-1a74-4db4-9c4f-08fbda14ac0f`
- `phase2_tree_green_b.png` — `1b5dd42c-4a7e-4bbd-82c7-6c224f96fb48` (regen: single tree variant)
- `phase2_tree_autumn_a.png` — `e8420273-0455-4c15-aa2c-3183b1280f2d`
- `phase2_bush_berry.png` — `c2ad7609-f263-418f-81fe-19760a60f289`
- `phase2_bush_round.png` — `59d5c200-abf5-43ab-8405-570f75fc6fa1`
- `phase2_rock_boulder.png` — `877d3738-f2bf-4dc4-930c-d79aba8988b1`
- `phase2_rock_cluster.png` — `f428641e-f724-4b27-a7dc-6e8a0107b8e7`
- `phase2_flowers_white.png` — `0086387d-1259-43f9-b092-2073d488fd5f`
- `phase2_stump.png` — `50eae721-5f03-4d16-91e3-5724d4112340`
- **Local:** `res://assets/sprites/objects/phase2_*.png`
- **Status:** approved / integrated


### Registro 93-100: Phase 3 — Props (fences/signs/crates)
- `phase3_fence_wood.png` — `711d79f0-8365-4e62-a384-e0381ab16361`
- `phase3_fence_wood_post.png` — `12046c58-fbe9-4bb7-9b7f-18c4bf28878c`
- `phase3_signpost.png` — `22398083-0d8c-4042-b546-8360c8e174c4`
- `phase3_barrel.png` — `f5e3966e-0020-45cb-9c97-16e9238f0374`
- `phase3_crate.png` — `957ab0f5-155f-43b0-ab1b-02b0601bbf03`
- `phase3_crate_large.png` — `f63db17e-f0ad-4c87-a829-f9abbbd23228`
- `phase3_well.png` — `c6333b26-8600-459b-9ab8-1f0e339d2fa4`
- `phase3_lantern_post.png` — `2b70fa50-946c-48ee-ad53-d71efba29953`
- **Integração:** `WorldPropsKit` (Estrada + Floresta)
- **Status:** approved / integrated


### Registro 101-103: Phase 4 — Landmarks
- `phase4_landmark_hunter_arch.png` — `311c32d4-0417-4ec7-8f7d-217d2c5b5b51` (64×64)
- `phase4_landmark_nen_shrine.png` — `fe8a0429-6445-4946-8f2b-ebbf7ba8919c` (48×64)
- `phase4_landmark_ruin_pillar.png` — `b7ee8a88-f35b-4227-8bd4-9c4535a01d91` (40×64)
- **Local:** `res://assets/sprites/objects/phase4_landmark_*.png`
- **Integração:** `WorldLandmarkKit` (Estrada + Floresta)
- **Status:** approved / integrated

### Registro 104: Phase 4 — NPC Guarda Estrada
- **Asset:** `npc_phase4_guarda_estrada_8dir.png`
- **PixelLab ID:** `8270df66-a380-4754-b8d2-36a0ac6e71a6`
- **Mode:** v3 + player reference (Style Lock 48×48, 8 dirs)
- **Local:** `res://assets/sprites/characters/npc_phase4_guarda_estrada_8dir.png` + `npc_phase4_guarda_estrada_rotations/`
- **Integração:** `WorldLandmarkKit` ambient Guarda (Estrada)
- **Status:** approved / integrated

### Registro 105: Phase 4 — Enemy Fera Padokia
- **Asset:** `enemy_phase4_fera_padokia_8dir.png`
- **PixelLab ID:** `7f86cbaa-5aa3-4ec5-82c6-ed7d24d3bbe2` (regen v2: quadruped `dog` template — humanoid+ref clone rejected)
- **Mode:** standard quadruped 8-dir (resized 68→48 sheet)
- **Local:** `res://assets/sprites/characters/enemy_phase4_fera_padokia_8dir.png` + `enemy_phase4_fera_padokia_rotations/`
- **Integração:** `WorldLandmarkKit` ambient Fera (Floresta)
- **Status:** approved / integrated


### Registro 106-110: Phase 5 — Combat FX (pixen, effect-only regen)
- `phase5_fx_hit.png` — `c4709111-e03a-47d2-9c24-e47c5c04dfdb` (32×32)
- `phase5_fx_slash.png` — `d36ae61a-2865-4c00-8d4c-046e513a993a` (48×32)
- `phase5_fx_nen_aura.png` — `6e16ecbf-9697-42bd-89ca-5a69c90241ee` (48×48)
- `phase5_fx_heal.png` — `963fd22b-56c9-4628-903e-91b2b0c2c3c1` (32×32)
- `phase5_fx_dash_dust.png` — `8303909a-1d1d-4469-84c2-902dce7f266b` (32×32)
- **Local:** `res://assets/sprites/effects/phase5_fx_*.png`
- **Integração:** `WorldFxKit` showcase + `CombatImpactEffect` sprite flash hooks
- **Note:** First pixen pass returned character+FX scenes; regen forced effect-only prompts.
- **Status:** approved / integrated

### Registro 111-113: Phase 5 — Weather / Night
- `phase5_weather_puddle.png` — `ad2e7ddd-207a-428f-9194-6f1812e31fe7`
- `phase5_weather_leaf.png` — `bc4a9a79-7177-4731-a7f0-0f03a0618b4a`
- `phase5_night_lantern_glow.png` — `07fe6176-6858-45f0-84c1-b9805900d8f9`
- **Local:** `res://assets/sprites/objects/phase5_*.png`
- **Integração:** `WorldFxKit` (Estrada + Floresta)
- **Status:** approved / integrated

### Registro 114-125: Main NPC Style Lock hybrid regen (pre–Phase 6)
- Pipeline: `pixen` unique south → fit ~20px/Y42 → `v3` rotate 8dir
- Script: `scripts/tools/pixellab_regen_main_npcs_hybrid_stylelock.py`
- Jobs: `assets/sprites/tilesets/pixellab/main_npc_hybrid_stylelock.json`
- Regenerated (unique vs Viajante, h≈18–20):
  - `npc_recepcionista_elena`, `npc_instrutor_combate`, `npc_examinador_oficial`
  - `npc_ferreiro_mestre`, `npc_vendedor_mercador`, `npc_discipulo_zushi`
  - `npc_guarda_fronteira`, `npc_viajante_scout`
  - `npc_gon`, `npc_killua`, `npc_kurapika`, `npc_leorio`
- **Status:** approved / integrated (paths unchanged — Lobby/maps pick up automatically)

### Registro 126-145: Secondary Cast Style Lock hybrid regen (pre–Phase 6)
- **Batch:** `secondary_cast_hybrid_stylelock`
- **Pipeline:** create_image_pixen → fit (~20px / feet Y≈42) → create_character v3 + fitted south ref
- **NPCs (20):** Hisoka, Netero, Biscuit, Chrollo, Tonpa, Ging, Hanzo, Menchi, Pokkle, Ponzu, Battera, Melody, Canary, Gotoh, Silva, Tsezguerra, Buhara, Gittarackur, Bodoro, Nicol
- **Smoke:** `scratch/test_secondary_cast_stylelock_suite.tscn` → 102/102
- **Meta:** `assets/sprites/tilesets/pixellab/secondary_cast_hybrid_stylelock.json`

### Registro 146-157: Phase 6 WorldPolishKit (polish + storytelling + secrets)
- **Batch:** `phase6_polish_story_secrets`
- **Assets (12):** abandoned camp, broken cart, scuffle mark, torn banner, broken weapon, hollow stump, false rock, glint, trail marker, path crack, moss patch, fence ruin
- **Integração:** `WorldPolishKit` em Estrada Padokia + Floresta Vestígios
- **Smoke:** `scratch/test_phase6_polish_suite.tscn` → 29/29
- **Meta:** `assets/sprites/tilesets/pixellab/phase6_polish_jobs.json`

- `nen_small_node_icons.png` � e3cc9dbf-b684-4ef2-a118-394515c80bf7 (sheet 192�32, 12 �cones)
- `hud_ornate_bar_frame.png` / `hud_ornate_bars_kit.png` � 8ab02532 + ui 652e1a36 (frame ouro pixel com slot interno)
- `assets/tiles/lobby_paths/*` � path tiles 05f1bf05-c23c-4342-bb10-668da7f1daf6 (18 configs 32px)
- Uso: NenSkillTreeUI n�s SMALL; PlayerHUD barras; Lobby._melhorar_estradas_lobby()

### Registro 74: Recepcionista da Arena Celestial (NPC 8dir)
- **Asset:** `npc_recepcionista_arena_8dir.png` (folha 384×48, 8 frames de 48×48)
- **Tipo:** Character / NPC (Style Lock 48px — APROVADO no validador)
- **PixelLab ID:** `e8a33d99-da2e-4ee4-96ee-413143037b3a`
- **Modo:** create_character standard, 8 direções, view low top-down, chibi
- **Descrição:** female arena receptionist, navy blue vest over white shirt with tie.
- **Mapa:** `world/maps/arena_celestial.tscn` (NPC "Recepcionista" — antes usava placeholder `player.png`).
- **Bind:** `NpcSpriteBinder.aplicar(node, ["npc_recepcionista_arena"])` em `ArenaCelestialMap._popular_npcs_arco3()`.
- **Pipeline:** montado por `scripts/tools/pixellab_assemble_8dir.py` (autocrop + reescala + pés Y=42 + quantização ≤13 cores).

### Registro 75: Tileset do Piso da Arena Celestial (Wang top-down)
- **Asset:** `assets/sprites/tilesets/pixellab/arena_celestial/arena_floor_tileset.png` (64×64, 16 tiles de 16px) + `_metadata.json`
- **Tipo:** Top-down Wang tileset (2 terrenos: mármore/ouro → tapete carmesim)
- **PixelLab ID:** `56596d8b-a7ac-45ec-8ecd-4f9376665938`
- **TileSet Godot:** `world/tilesets/arena_celestial_tileset.tres` (terrain set corner-match, 2 terrenos) — gerado por `scratch/build_arena_tileset.gd`.
- **Uso:** pintar o piso da arena (TileMapLayer + aba Terrains → Rect Tool). Demo de autotiling validado.

### Registro 76-78: Tilesets de Cenário Detalhados (PixelLab Wang 32px)
Gerados com `detail: highly detailed`, `shading: detailed`, view high top-down, tiles 32px.
Convertidos para TileSet Godot (corner-match, 2 terrenos) por `scratch/build_topdown_tileset.gd`.
- **Estrada Real de Padokia** — `56...`→ id `1016224d-b2ac-48a0-a8f9-0793895c5e12` — grama ↔ estrada de pedra.
  - PNG: `assets/sprites/tilesets/pixellab/estrada/estrada_tileset.png` (128×128) · TileSet: `world/tilesets/estrada_padokia_tileset.tres`
- **Floresta dos Vestígios** — id `be2236a2-c15e-41b1-a424-e9dacb0d6aec` — grama ↔ solo de floresta (raízes/musgo).
  - PNG: `assets/sprites/tilesets/pixellab/floresta/floresta_tileset.png` · TileSet: `world/tilesets/floresta_vestigios_tileset.tres`
- **Ruínas de Zaban** — id `76e7b45f-3a38-4832-9095-9e5c89bfcb81` — grama ↔ pedra ancestral com runas.
  - PNG: `assets/sprites/tilesets/pixellab/zaban_ruinas/zaban_ruinas_tileset.png` · TileSet: `world/tilesets/zaban_ruinas_tileset.tres`
- Piso da Arena Celestial (Registro 75) agora é PINTADO em jogo por `ArenaCelestialMap._pintar_piso_arena()` (TileMapLayer z=-50).
