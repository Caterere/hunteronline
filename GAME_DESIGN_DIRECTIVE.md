# GAME DESIGN DIRECTIVE
# PROFUNDIDADE, IMERSÃO, COMBATE E MUNDO VIVO

Diretriz permanente para o desenvolvimento do jogo.

O principal objetivo NÃO é simplesmente implementar funcionalidades rapidamente.
O objetivo é transformar o jogo em uma experiência de RPG de ação encorpada, imersiva e sistêmica.

---

## 1. REFERÊNCIAS DE DESIGN (PRINCÍPIOS, NÃO CÓPIAS)

| Referência | Princípios Fundamentais a Extrair | Aplicação em Hunter Online |
| :--- | :--- | :--- |
| **Hunter x Hunter** | • Estratégia analítica > Números brutos<br>• Condições, restrições, riscos e sinergias<br>• Fraquezas lógicas e dedução | Nen e Hatsu como sistemas de regras e ferramentas táticas, não apenas barras de dano. |
| **CrossCode** | • Integração exploração + combate<br>• Ferramentas com utilidade dupla (in/out combat)<br>• Puzzles ambientais e leitura de fraquezas | Técnicas de Nen (Gyo, Zetsu, Shu) usadas para desvendar cenários, abrir caminhos e interagir com armadilhas/inimigos. |
| **Hyper Light Drifter** | • Combate rápido, cirúrgico e responsivo<br>• Posicionamento, esquiva e janelas de abertura<br>• Derrota por erro de decisão, não por falta de stats<br>• Atmosfera e narrativa ambiental | Fluidez e impacto no combate top-down; punição justa por decisões ruins; leitura de hurtbox/hitbox. |
| **Zelda 2D & Pokémon GBA** | • Exploração instigante do mapa contínuo ("Como chego lá?")<br>• Transição fluida entre cidades, rotas e dungeons com checkpoints<br>• Dungeons, atalhos, segredos, puzzles e portões temáticos | Exploração de mundo conectado e sem menus de teletransporte cego; progressão contínua através de capacidades de Nen e rotas físicas. |
| **Dragon Ball Xenoverse 1 & 2** | • Trajetória própria dentro de um universo vivo<br>• Hub, mentores/treinadores e facções<br>• Sensação de escala, eventos e reputação | O jogador não é um clone da história canônica; constrói seu nome, interage com lendas, escolhe mentores e alianças. |

---

## 2. O PRINCÍPIO DA COMBINAÇÃO

As referências nunca operam isoladas. Elas se somam no loop de gameplay:

$$\text{Fraqueza/Condição (HxH + CrossCode)} + \text{Combate Preciso (HLD)} + \text{Mundo Contínuo (Zelda + Pokémon)} + \text{Progressão (Xenoverse)} = \text{Nosso Sistema}$$

### Exemplo Prático Integrado:
1. **Investigação (Gyo / NPCs)**: O jogador descobre um usuário de Nen com Hatsu desconhecido. Gyo revela alta concentração de aura em um ponto específico e restrição espacial.
2. **Ambiente / Exploração (Zelda / CrossCode / Pokémon)**: O jogador percorre rotas conectadas, descobre atalhos e atrai o inimigo para fora de sua zona favorável.
3. **Execução (Hyper Light Drifter)**: Combate de precisão, esquiva precisa e punição da abertura.
4. **Consequência / Mundo (Xenoverse)**: Vitória altera a percepção dos NPCs, abre novos diálogos de mestres e desbloqueia ramificações de missões.

---

## 3. CHECKLIST PARA NOVAS IMPLEMENTAÇÕES (10 PERGUNTAS DE OURO)

Antes de codificar qualquer sistema ou mecânica nova, responder:
1. *Qual problema este sistema resolve?*
2. *Qual princípio de design ele aproveita?*
3. *Com quais sistemas existentes ele interage?*
4. *Ele cria decisões significativas para o jogador?*
5. *Ele enriquece a exploração?*
6. *Ele aprofunda o combate?*
7. *Ele agrega à narrativa ou imersão?*
8. *Ele pode ser reutilizado em contextos e missões diferentes?*
9. *Ele interage dinamicamente com Nen ou Hatsu?*
10. *Ele evita complexidade artificial (menus inúteis, moedas redundantes)?*

Se a resposta for "não" para a maioria, a mecânica **não deve ser implementada**.

---

## 4. MATRIZ DE PRIORIDADE DE DESENVOLVIMENTO

1. **GAMEPLAY** (Controles, resposta, sensação de jogo)
2. **COMBATE** (Hitboxes, esquiva, impacto, postura, stagger)
3. **NEN** (Ten, Zetsu, Ren, Gyo, Shu, Ko, En, Ken, Ryu)
4. **HATSU** (Sistemas modulares, juramentos proporcionais, categorias)
5. **EXPLORAÇÃO DO MUNDO** (Rotas contínuas, puzzles, segredos, utilidade de Nen no mapa)
6. **NPCS** (Memória, rotinas, diálogos contextuais)
7. **MISSÕES** (Regra das 3 Soluções, consequências)
8. **HISTÓRIA** (Eventos dinâmicos, organizações, reputação)
9. **MUNDO** (Escala, viagens contínuas, rumores)
10. **POLIMENTO** (Efeitos visuais, sonoros, refinamentos)

---

## 5. BALANCEAMENTO, TIERS DE PODER & TIME-TO-KILL (TTK)

A progressão do jogo escala de **100 (Início)** até **50.000.000+ (Endgame)** através de uma escala multiplicativa por Tiers (`PowerScale.gd`), mantendo a física e o Time-To-Kill sempre consistentes.

### 5.1 Tabela de Tiers de Poder

| Tier | Categoria | Multiplicador | HP de Referência | Força | Defesa | Aura Máxima |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: |
| **0** | **Humano / Início** | $\mathbf{1.0}$ | $100$ | $10$ | $5$ | $100$ |
| **1** | **Hunter Iniciante** | $\mathbf{5.0}$ | $500$ | $40$ | $25$ | $500$ |
| **2** | **Hunter Experiente** | $\mathbf{50.0}$ | $5.000$ | $250$ | $150$ | $5.000$ |
| **3** | **Usuário de Nen** | $\mathbf{500.0}$ | $50.000$ | $2.500$ | $1.500$ | $100.000$ |
| **4** | **Hunter de Elite** | $\mathbf{5.000.0}$ | $500.000$ | $25.000$ | $15.000$ | $2.000.000$ |
| **5** | **Monstro / Mestre** | $\mathbf{50.000.0}$ | $5.000.000$ | $250.000$ | $150.000$ | $30.000.000$ |
| **6** | **Endgame Supremo** | $\mathbf{500.000.0}$ | $50.000.000$ | $2.500.000$ | $1.500.000$ | $500.000.000$ |

### 5.2 Curva de Defesa Adaptativa ($K_{\text{tier}}$)
$$\text{FatorDefensivo} = \frac{K_{\text{tier}}}{K_{\text{tier}} + \text{Defesa}}$$
- $K_{\text{tier}}$ é a Defesa de referência do Tier atual.
- Garante mitigação consistente de 50% para defesa padrão do tier em qualquer escala de números.

### 5.3 Escalonamento Dinâmico de Hatsu
$$\text{DanoHatsu} = \text{PoderBase} \times \left( \text{Força} \times w_{\text{forca}} + \text{Aura} \times w_{\text{aura}} \right) \times \text{ModificadorAfinidade}$$
- Hatsu não possui dano plano estático; escala proporcionalmente aos atributos do usuário e multiplicador final de juramentos.

### 5.4 Economia Canônica de Juramentos e Votos de Nen (Hatsu v2.0)
- **Capacidade Inata**: $15\text{ créditos}$ (técnicas básicas de 15 a 20 de dano).
- **Curva Não-Linear de Demanda Funcional**:
  $$\text{Demanda}(P) = \begin{cases} P \times 1.0 & P \le 30 \\ 30 + (P - 30) \times 1.5 & 31 \le P \le 60 \\ 75 + (P - 60) \times 2.5 & 61 \le P \le 100 \\ 175 + (P - 100) \times 4.0 & P > 100 \end{cases}$$
- **Votos e Restrições Severas**: Habilidades devastadoras ($>70\text{ dano}$) exigem juramentos reais e arriscados (auto-dano vital, zetsu forçado, 1 uso por combate ou restrição exclusiva de chefes).
- **Proteção Anti-OneShot (Diminishing Returns)**: Acúmulo de multiplicadores leves acima de $+100\%$ sofre rendimento decrescente de $50\%$.

### 5.5 Balanceamento Baseado em TTK (Time-To-Kill)
$$\text{HP Inimigo} = \text{DPS Médio do Tier} \times \text{TTK Desejado}$$
- **Inimigo Normal**: $5 \sim 10\text{ segundos}$
- **Inimigo Elite**: $15 \sim 30\text{ segundos}$
- **Mini-Boss**: $45 \sim 75\text{ segundos}$
- **Boss de Arco**: $120 \sim 240\text{ segundos}$ (focado em fases e mecânicas, não em parede pura de HP).

---

## 6. FILOSOFIA DE PAPEL

Toda proposta e código devem ser pensados como:
$$\textbf{Programador} + \textbf{Game Designer} + \textbf{System Designer} + \textbf{Narrative Designer}$$

- Não entregar apenas código que executa sem erros; entregar sistemas interconectados que gerem jogabilidade rica e duradoura.
