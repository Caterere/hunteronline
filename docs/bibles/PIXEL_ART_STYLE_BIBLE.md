# BIBLE 16 — PIXEL ART STYLE LOCK & SPRITE GENERATION BIBLE
## Hunter Online — Single Source of Truth para Arte 2D

---

### 1. PRINCÍPIO SUPREMO: O STYLE ANCHOR DEFINITIVO

O arquivo canônico do projeto é:
```
res://assets/sprites/characters/player.png (também referenciado como player(3).png)
```
Toda e qualquer geração de sprite, seja via **PixelLab MCP**, **Gemini**, ferramentas procedurais ou trabalho manual, **DEVE** replicar rigorosamente a **linguagem de pixels** desta referência.

> [!CRITICAL]
> **SIMPLICIDADE = QUALIDADE.**
> No Hunter Online, "mais detalhado" NÃO significa melhor. "Mais legível", "mais consistente" e "fiel à escala do jogo" é o único critério de qualidade aceito. Se um detalhe não é estritamente necessário para identificar o personagem a 1x de zoom, **ELE NÃO DEVE EXISTIR**.

---

### 2. ANÁLISE NUMÉRICA E VISUAL EXAUSTIVA DA REFERÊNCIA

A análise pixel a pixel extraída diretamente da folha do jogador estabelece os limites matemáticos invioláveis:

| Métrica | Valor Canônico (`player.png`) | Limite Máximo Aceitável | Sprites Reprovados (Ex: Gon / 68px) |
| :--- | :--- | :--- | :--- |
| **Canvas do Frame** | **48×48 pixels** | **48×48 pixels** fixos | 68×68 px / 128×128 px |
| **Altura do Personagem (Idle/Walk)** | **20 a 22 pixels** | **24 pixels** (com chapéu/cabelo) | 45 a 52 pixels (Ocupa frame todo) |
| **Largura do Personagem (Idle/Walk)** | **13 a 15 pixels** | **18 pixels** (com capa/equipamento) | 22 a 32 pixels |
| **Ocupação de Área no Frame** | **~12% a 15%** do canvas | **< 20%** do canvas | > 50% a 70% |
| **Baseline dos Pés (Solo)** | **Y = 42** | **Y = 41 a 43** | Y = 46 a 47 (colado na borda) |
| **Top Padding (Espaço Vazio Acima)** | **20 a 23 pixels livres** | **>= 18 pixels livres** | 0 a 2 pixels livres |
| **Bottom Padding (Espaço Vazio Abaixo)**| **5 pixels livres** (Y=43..47) | **>= 4 pixels livres** | 0 a 1 pixel livre |
| **Padding Lateral (Esquerda/Direita)**| **16 a 18 pixels livres** | **>= 12 pixels livres** | 4 a 8 pixels livres |
| **Cores Únicas por Frame** | **7 a 11 cores** | **14 cores** | 30 a 50 cores |
| **Cores Totais na Spritesheet** | **15 cores únicas** | **22 cores** | 50 a 120 cores |
| **Proporção Corporal** | **Chibi / Estilizado (~2.5 cabeças)** | **2.2 a 2.6 cabeças** | 5 a 6 cabeças (Anatômico realista) |

---

### 3. ANATOMIA PIXEL A PIXEL DO SPRITE CANÔNICO

#### 3.1. Cabeça e Rosto
- **Altura da Cabeça:** 12 a 13 pixels (incluindo cabelo) — representa ~60% da altura total do personagem.
- **Rosto (Pele Visível):** Apenas 5 a 6 pixels de altura por 7 a 8 pixels de largura.
- **Olhos:** Dois pontos verticais de **1 pixel de largura por 2 pixels de altura** (`#21110d` ou preto `#000000`), separados por exatamente **3 pixels de pele**.
- **PROIBIÇÕES ABSOLUTAS NO ROSTO:**
  - ❌ NENHUM branco nos olhos (esclera).
  - ❌ NENHUM brilho/reflexo na pupila.
  - ❌ NENHUM nariz desenhado (sem ponto de nariz, sem sombra de fossa nasal).
  - ❌ NENHUMA boca desenhada em estado de repouso/idle.
  - ❌ NENHUMA sobrancelha detalhada ou blush/bochechas rosadas.

#### 3.2. Cabelo
- Representado por **massas e agrupamentos sólidos de pixels** (grandes blocos).
- Composto por:
  - 1 Tom Base (`#573a23`).
  - 1 Tom de Sombra em bloco (`#402717`).
  - Pouquíssimos pixels de contorno/profundidade (`#21110d`).
- **PROIBIÇÕES NO CABELO:**
  - ❌ NENHUM fio de cabelo individual.
  - ❌ NENHUM gradiente ou iluminação especular linear.
  - ❌ NENHUM contorno interno excessivo entre mechas minúsculas.

#### 3.3. Tronco e Roupas
- **Tronco visível:** Apenas 3 a 4 pixels de altura por 7 a 9 pixels de largura.
- **Pernas e Botas:** Apenas 4 a 5 pixels de altura.
- **Mãos:** Pequenos blocos de 2×2 pixels de pele nas laterais.
- **PROIBIÇÕES NAS ROUPAS:**
  - ❌ NENHUMA dobra ou ruga de tecido.
  - ❌ NENHUMA costura, fivela microscópica ou botões individuais.
  - ❌ NENHUM degradê suave de sombreamento.

#### 3.4. Sombra Projetada no Solo
- Uma elipse plana de sombra de contato sob os pés, em Y=41 e Y=42.
- Cor: `#0c0e19` com 50% de opacidade (`#0c0e1980`).
- Largura da elipse: 11 a 13 pixels; Altura: 2 pixels.

---

### 4. PALETA MESTRA CANÔNICA (15 CORES)

Arquivo de paleta mestre gerado em: `res://assets/sprites/characters/master_palette.png`

| Hex | Nome / Função | Amostra de Uso |
| :--- | :--- | :--- |
| `#573a23` | Cabelo / Madeira Base | Massa principal de cabelo |
| `#402717` | Cabelo Sombra | Sombra inferior e recorte de mechas |
| `#21110d` | Cabelo Profundo / Olhos | Olhos verticais (1×2) e vãos mais escuros |
| `#c1ac8f` | Pele Clara / Base | Testa, bochechas, mãos |
| `#ac7b5d` | Pele Sombra | Queixo, pescoço, contorno lateral do rosto |
| `#9a5c42` | Pele Transição | Sombra profunda de dobra facial/pescoço |
| `#a4a8b5` | Tecido / Metal Claro | Camisa base, reflexos cinza |
| `#787e97` | Tecido / Metal Sombra | Sombra de tecido neutro / armadura |
| `#2c65b5` | Tecido / Acento Azul Base | Calças, túnica azul |
| `#1d438a` | Tecido / Acento Azul Sombra | Sombra da calça, divisão de pernas |
| `#0d205e` | Tecido Azul Profundo | Vinco entre pernas |
| `#ffffff` | Brilho Máximo / Lâmina | Fio de corte da adaga / reflexo de arma |
| `#dbd2c7` | Metal Médio | Corpo de lâminas / fivelas simples |
| `#000000` | Contorno Externo Principal | Silhueta do personagem, cabelo exterior |
| `#0c0e19` | Contorno Secundário / Sombra de Solo | Contorno de tecido e elipse no chão (com alpha 0.5) |

---

### 5. SEPARAÇÃO ENTRE ESTILO E PERSONAGEM

Ao gerar novos personagens (ex: "Hunter Veterano", "Examinador", "Mercador", "Guarda Real"):

- **O que MUDA:**
  - Cor do cabelo, silhueta do chapéu ou capacete.
  - Paleta de cores da roupa (ex: verde, vinho, couro marrom, armadura metálica).
  - Acessório característico (ex: cajado simples, mochila de 3×4 px, espada embainhada).
- **O que NUNCA MUDA:**
  - Canvas 48×48 com personagem de 20-22 px de altura.
  - Baseline com pés em Y=42.
  - Olhos de 1×2 pixels sem esclera branca.
  - 1 a 2 níveis de sombra por material (máximo 11-13 cores por frame).
  - Cabeça ocupando ~55-60% da altura do boneco.
  - Contornos nítidos de 1 pixel sem anti-aliasing no corpo.

---

### 6. GUIA DE INTEGRAÇÃO PIXELLAB MCP

Quando o agente ou desenvolvedor invocar o MCP `pixellab`, as seguintes regras são **mandatórias**:

#### 6.1. Ferramenta Principal: `create_character`

```json
{
  "name": "NomeDoPersonagem",
  "description": "retro 16-bit 48x48 rpg sprite, tiny low detail character, chibi 2.5 heads proportion, 20 pixels tall character centered inside 48x48 transparent frame, simple chunky shapes, dot eyes no sclera, flat shading, basic outline, 2 colors per material, game sprite",
  "mode": "standard",
  "size": 48,
  "detail": "low detail",
  "shading": "flat shading",
  "outline": "single color black outline",
  "view": "low top-down",
  "n_directions": 4,
  "proportions": "{\"type\": \"preset\", \"name\": \"chibi\"}"
}
```

> [!WARNING]
> - **NUNCA** use `size: 68` ou `size: 128` para personagens de gameplay. O padrão é estritamente `size: 48`.
> - **NUNCA** use `detail: "medium detail"` ou `"high detail"`.
> - **NUNCA** use `shading: "detailed shading"`.
> - Se o personagem gerado ocupar mais de 25 pixels verticais no canvas, ele deve ser rejeitado imediatamente.

#### 6.2. Quantização e Limpeza de Paleta: `reduce_colors`

Caso um sprite retorne com variações de cor excessivas:
- Use `reduce_colors` com `palette_image_base64` apontando para `res://assets/sprites/characters/master_palette.png`.
- Defina `dithering: "none"`.
- Nunca use dithering ordenado para personagens do jogo.

---

### 7. CHECKLIST DE ACEITAÇÃO (GATE INTRANSIGENTE)

Antes de aprovar e commitar qualquer sprite novo para `assets/sprites/`:

- [ ] **Frame 48×48:** Dimensão total é múltiplo exato de 48×48.
- [ ] **Escala e Bounding Box:** Altura em repouso entre 19 e 24 px; largura entre 12 e 18 px.
- [ ] **Baseline dos Pés:** Pés descansando entre Y=41 e Y=43.
- [ ] **Headroom Superior:** Pelo menos 18 a 22 pixels transparentes no topo do frame.
- [ ] **Margens Laterais:** Pelo menos 12 a 16 pixels transparentes de cada lado.
- [ ] **Rosto:** Olhos estilizados em ponto (1×2 px); sem boca, sem nariz, sem esclera.
- [ ] **Shading:** Flat ou basic shading em blocos; máximo de 1 tom de luz e 1 tom de sombra por material.
- [ ] **Sem Gradientes / Sem Dithering:** Cores chapadas em agrupamentos legíveis.
- [ ] **Alpha Binário:** Alpha 1.0 em todo o corpo (sem anti-aliasing suave em bordas).
- [ ] **Densidade de Cores:** Máximo de 14 cores por frame e 22 cores na folha completa.
- [ ] **Validação Automatizada:** Executou e foi aprovado por `tools/validate_sprite_style.gd`.

---

### 8. COMANDO DE AUDITORIA AUTOMATIZADA

Para validar qualquer folha de sprites contra o Style Lock:

```powershell
& "C:\Users\Ditec\Downloads\Godot_v4.4-stable_win64.exe\Godot_v4.4-stable_win64_console.exe" --headless -s "tools/validate_sprite_style.gd" -- "caminho/do/sprite.png"
```
