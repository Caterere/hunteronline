# VISUAL & ART DIRECTION BIBLE
## HUNTER ONLINE — 2D MMORPG VISUAL IDENTITY & GAME FEEL

---

## 1. RESOLUÇÃO E FIDELIDADE PIXEL ART

O Hunter Online é renderizado a uma resolução base nativa de **640x360 pixels**, com escala inteira proporcional para 1080p (3x) e 4K (6x):
- **Pixel-Snap:** Todas as entidades, arcos de corte e projéteis respeitam a grade de pixels sem distorção bilinear.
- **Hierarquia Visual:** O jogador e inimigos principais possuem maior densidade visual e contraste de aura do que o plano de fundo.
- **Paleta de Iluminação:** Inspirada na estética clássica do anime de Hunter x Hunter (1999 e 2011), utilizando cores saturadas em áreas verdes e tons dessaturados com aberração sutil em áreas hostis (Ruínas e Continente Negro).

---

## 2. CAMADAS DE RENDERIZAÇÃO & PROFUNDIDADE (Y-SORT)

- **Camada 0 (Chão/Terreno):** Tilemap de piso e sombras estáticas.
- **Camada 1 (Y-Sort Entities):** Jogador, NPCs, Inimigos e Objetos Interativos ordenados dinamicamente no eixo Y pelo pé da entidade.
- **Camada 2 (Efeitos Cinéticos):** Arcos de espada, poeira de arrancada, faíscas de bloqueio.
- **Camada 3 (Aura & Iluminação):** Brilho de Nen (Ten, Ren, En), telegrafias circulares e halos mágicos.
- **Camada 4 (Telhados e Copa de Árvores):** Elementos aéreos com fade de transparência quando o jogador passa por baixo.
- **Camada 5 (CanvasLayer HUD):** Elementos de interface, minimapa, diálogos e banners de chefe.

---

## 3. FEEDBACK VISUAL DE COMBATE (GAME FEEL)

### 3.1 Arcos de Golpe Dinâmicos (Swing Arcs)
- Implementados proceduralmente via `CombatImpactEffect.spawn_swing_arc()`.
- Curva parabólica suave com espessura variável e ponta afiada que acompanha a direção do mouse/ataque.
- Cor personalizável: Branca para corte padrão, Dourada para combos finalizadores, Azul Ciano para golpes energizados com Shu.

### 3.2 Hit Flash & Feedback de Dano
- O atacado pisca com multiplicador HDR `Color(2.5, 2.5, 2.5, 1.0)` durante **0.08 segundos**, retornando à modulação natural sem interromper o loop de animação.
- Quando o golpe é evadido ou aparado, balões contextuais `DamageNumberSystem.spawn_esquiva()` e `spawn_bloqueio()` sobem em arco suave.

### 3.3 Afterimages & Poeira de Movimento
- **Dash do Jogador:** Duas silhuetas translúcidas (`_spawn_afterimage`) surgem na posição anterior, dissolvendo suavemente em 0.18 segundos.
- **Sprint Sustentado:** Poeira fina de terra (`spawn_dust_kickup`) emerge dos pés do Hunter em cadência ritmada.

---

## 4. MATRIZ DE STATUS DE IMPLEMENTAÇÃO (FASE J)

| Subsistema Visual | Status | Detalhes & Componentes |
| :--- | :--- | :--- |
| **Resolução Nativa 640x360** | `[IMPLEMENTED]` | `project.godot` e layouts de viewport configurados |
| **Arcos Visuais de Ataque** | `[IMPLEMENTED]` | `CombatImpactEffect.spawn_swing_arc()` |
| **Afterimages de Dash** | `[IMPLEMENTED]` | `Player._spawn_afterimage()` com tween de alfa |
| **Hit Flash (0.08s Snappy)** | `[IMPLEMENTED]` | `CombatSystem._executar_hit_flash()` e `EnemySystem._hit_flash()` |
| **Poeira de Arrancada/Sprint** | `[IMPLEMENTED]` | `CombatImpactEffect.spawn_dust_kickup()` |
| **Banner Cinemático de Chefe** | `[IMPLEMENTED]` | `BossIntroBanner.gd` com tipografia dourada |
| **Partículas de Folhas no Lobby**| `[IMPLEMENTED]` | `Lobby._adicionar_detalhes_ambiente_lobby()` |
| **Ghost Bar no Target HUD** | `[IMPLEMENTED]` | `TargetHUD.hp_ghost_bar` com tween atrasado |
| **Câmera Dinâmica & Limites** | `[IMPLEMENTED]` | `Player.configurar_limites_camera()` e `definir_zoom_camera()` |
| **Shaders de Água & Reflexo** | `[IN PROGRESS]` | Shaders de distorção para rios e lagos |
| **Desmembramento de Quimeras** | `[PLANNED]` | Efeitos gore moderados para insetos do Continente Negro |
| **Ciclo Meteorológico Completo**| `[FUTURE]` | Tempestades elétricas de aura com iluminação global 2D |
