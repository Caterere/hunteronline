# BACKLOG & TASKS: FASE G — MUNDO VIVO, IDENTIDADE & GAME FEEL (HUNTER ONLINE)

> **Diretriz de Design:** Não reconstruir sistemas estruturais base. O foco absoluto é **Profundidade, Apresentação, Feedback (Game Feel) e Identidade Hunter x Hunter**.  
> **Filosofia Central:** De *"O sistema funciona?"* para *"O jogador percebe, sente e é impactado pelo sistema?"*.  
> **Regra de Ouro:** Não adicionar dezenas de sistemas vazios. Aumentar a densidade de detalhes de ponta a ponta:  
> `NPC → Animação → Diálogo → Reação → Combate → Recompensa → Mundo → Consequência`.

---

## 🚫 RESTRIÇÕES & O QUE NÃO FAZER AGORA (OUT OF SCOPE)
- [x] **PROIBIDO:** Refazer sistemas base de XP, Atributos ou Skill Trees.
- [x] **PROIBIDO:** Reconstruir o criador/sistema de Hatsu do zero.
- [x] **PROIBIDO:** Implementar Multiplayer, Co-op ou PvP nesta fase (preparar apenas abstrações/arquitetura escalável).
- [x] **PROIBIDO:** Criar centenas de mobs genéricos sem propósito ou inflar números/estatísticas arbitrariamente.
- [x] **PROIBIDO:** Waypoints automáticos para segredos e conteúdos de exploração orgânica.

---

## 📋 EPICS & TASKS BREAKDOWN

---

### ⚔️ EPIC 1: G1 — GAME FEEL & COMBAT POLISH
**Objetivo:** Transformar o combate em uma experiência visceral, com peso perceptível, feedbacks sonoros/visuais e clareza de impacto entre ataque básico e Hatsu.

- [x] **Task 1.1 — Hit Reaction & Hitstop Framework**
  - Implementar micro-pausa de impacto (*hitstop / hit-freeze*) proporcional à força do golpe (ataque básico = 30-50ms; finalizador/Hatsu = 100-250ms).
  - Configurar *knockback*, *knockdown* e direcionalidade de recuo com base no vetor do golpe.
  - Adicionar *directional screen-shake* ajustado por intensidade (com toggle nas opções).
- [x] **Task 1.2 — Efeitos Visuais de Impacto & Partículas Nen**
  - Desenvolver partículas de impacto (*slashes*, *blunt impact bursts*, *dust kickup* nos pés).
  - Criar shaders/overlays de aura para aplicação de *Ten*, *Ren*, *Ko* e *Ken* durante o combate.
  - Implementar números de dano estilizados com tipografia HxH (diferenciação visual clara entre Dano Físico, Dano de Hatsu e Dano Crítico/Fraqueza).
- [x] **Task 1.3 — Balanceamento Funcional: Básico vs. Hatsu**
  - Garantir viabilidade de matar mobs comuns e farmar utilizando apenas o ataque básico (preservando Aura).
  - Ajustar o Hatsu para ser decisivo: controle de grupo, burst, reposicionamento, contra-ataque ou aplicação de condições severas.
  - Configurar animações de transição fluida entre combos básicos e disparo de técnicas de Hatsu.
- [x] **Task 1.4 — Sequência de Ativação Dramática de Hatsu**
  - Criar pipeline de ativação: Flash de aura do usuário → Callout do nome do Hatsu na tela / balão de fala → Efeito sonoro característico de ativação → Aplicação de pós-efeitos / condições no cenário ou alvo.

---

### 🧠 EPIC 2: G2 — HIERARQUIA & "BATTLE PERSONALITY" DE NPCS
**Objetivo:** Elevar os NPCs de meros sacos de HP a entidades com temperamento, reatividade e inteligência contextual.

- [x] **Task 2.1 — Hierarquia de NPCs**
  - **Tier 1 (NPC Comum / Mob):** Sem Hatsu, IA direta, drops simples, farm e quests menores.
  - **Tier 2 (NPC Especial):** Habilidade única/simples, comportamento tático diferenciado, diálogos de área contextuais.
  - **Tier 3 (Mini Boss):** Hatsu próprio, 2–4 ataques com telegrafia clara, falas em combate e fase de fúria/baixa vida.
  - **Tier 4 (Boss de Quest):** Personalidade completa, leitura de Nen do player, múltiplas fases, reações a Hatsu e diálogos dinâmicos.
- [x] **Task 2.2 — Arquitetura de Battle Personality**
  - Criar script/componente `BattlePersonality`:
    ```
    BattlePersonality
    ├── Intro (entrada e fala inicial)
    ├── Taunts (provocações durante o combate)
    ├── Attack Lines (falas contextuais por habilidade)
    ├── Hatsu Lines (grito/ativação de técnica)
    ├── Damage Reactions (reações a dano pesado ou acertos críticos)
    ├── Low HP Reactions (desespero, foco ou postura defensiva)
    ├── Player Hatsu Reactions (ex.: "Então esse é o seu tipo de Nen...")
    ├── Phase Transitions (mudança de postura, efeito ou animação)
    ├── Victory (fala e animação de vitória)
    └── Defeat (fala, animação de colapso ou fuga narrativa)
    ```
- [x] **Task 2.3 — Hatsus Assinatura de Personagens Icônicos**
  - **Hisoka:** Mecânica de armadilha/elasticidade, imprevisibilidade de alcance, provocações cínicas.
  - **Razor:** Projéteis de Nen pesados, alta velocidade de arremesso, pressão contínua e presença física maciça.
  - **Meruem:** Velocidade de teleporte/avanço instantâneo, previsão de golpes do jogador e ataques devastadores de impacto.

---

### 🗣️ EPIC 3: G3 — MEMÓRIA, RELAÇÕES E CONSEQUÊNCIAS NARRATIVAS
**Objetivo:** Fazer com que o mundo reaja ao histórico de ações do jogador e transforme a derrota em um motor de gameplay.

- [x] **Task 3.1 — Sistema de Reputação & Relacionamento de NPCs (`NPCRelationship`)**
  - Implementar eixos relacionais para NPCs relevantes: `Confiança`, `Respeito`, `Medo`, `Amizade`, `Rivalidade`.
  - Integrar branches de quests secundárias com escolhas que alteram status (Ajudar, Mentir, Intimidar, Trair).
- [x] **Task 3.2 — Sistema de Memória Contextual de NPCs**
  - Criar registro de flags persistentes de histórico do jogador:
    - Mestres lembrando do treinamento (ex.: "Ainda usando aquele Gyo que ensinei?").
    - Menções públicas a caçadas/bosses derrotados pelo jogador.
- [x] **Task 3.3 — Sistema de "Derrota como Conteúdo"**
  - Substituir tela de *Game Over* punitiva por nós de fluxo narrativo:
    - Derrota em duelos/bosses → Cutscene de fuga ou resgate → NPC comenta sobre a derrota → Desbloqueio de sub-quest de treino/recuperação → Revanche contextualizada.

---

### 🌍 EPIC 4: G4 — MUNDO VIVO (WORLD STATE ENGINE)
**Objetivo:** Implementar um ecossistema com ciclos temporais, dinâmicas de clima e rotinas de entidades.

- [x] **Task 4.1 — Componente `WorldStateManager`**
  - Implementar relógio global integrado com os seguintes sub-sistemas:
    ```
    WORLD STATE
    ├── Time (Dia / Entardecer / Noite)
    ├── Weather (Limpo, Chuva, Neblina, Tempestade de Aura)
    ├── Region State (Nível de perigo, ocupação ou controle)
    ├── NPC Schedule (Rotinas de trabalho, descanso, abrigo)
    ├── Events (Eventos temporários ativados por gatilhos)
    └── Story State (Progresso global das sagas)
    ```
- [x] **Task 4.2 — Rotina de NPCs vinculada ao Clima e Horário**
  - Noite: barracas fecham, NPCs voltam para casas, guardas assumem postos.
  - Chuva: NPCs procuram toldos/interiores de construções; visibilidade reduzida.
- [x] **Task 4.3 — Sistema de Eventos Mundiais Orgânicos**
  - Exemplo: "Invasão de Bestas Mágicas na Floresta".
  - O mapa altera spawns, NPCs entram em alerta com diálogos dedicados, mini-boss exclusivo surge, e um encerramento via comunicado da Associação Hunter restaura o status quo.

---

### 🧭 EPIC 5: G5 — EXPLORAÇÃO ORGÂNICA & SEGREDOS (NO WAYPOINTS)
**Objetivo:** Resgatar a sensação clássica de exploração de MMORPGs, premiando a curiosidade e observação.

- [x] **Task 5.1 — Divisão de Missões: Rastreado vs. Oculto**
  - Quest Tracker restrito estritamente a conhecimentos oficiais informados formalmente ao jogador.
  - Criação de entidades ocultas no mapa sem marcação na bússola/mapa:
    - NPCs excêntricos com dicas sutis em falas.
    - Paredes falsas, cavernas escondidas atrás de vegetação ou cachoeiras.
    - Gatilhos de quebra-cabeça ambiental (ex.: usar *Gyo* para ver inscrições de Nen em ruínas).
- [x] **Task 5.2 — Recompensas e Descobertas Secretas**
  - Bosses opcionais fora de rotas comuns com tabelas de loot exclusivas.
  - Fragmentos de lore e colecionáveis raros que desbloqueiam diálogos especiais.

---

### 📈 EPIC 6: G6 — PROGRESSÃO PROFUNDA: MASTERY & EQUIPAMENTOS COM IDENTIDADE
**Objetivo:** Tornar o avanço de Hatsu e equipamentos expressivos e estratégicos, evitando aumentos genéricos de atributos.

- [x] **Task 6.1 — Sistema de Maestria de Hatsu (`HatsuMastery`)**
  - Implementar progressão de Mastery (Níveis 1 a 6+):
    - *Mastery Inicial:* Técnica recém-criada, custo alto de Nen, execução lenta e crua.
    - *Mastery Intermediária:* Redução de tempo de conjuração, menor consumo de aura, ampliação sutil de alcance/área.
    - *Mastery Avançada:* Redução máxima de custo, execução instantânea e fluida (mantendo a função criada pelo jogador, sem gerar novas mecânicas automáticas não autorizadas).
- [x] **Task 6.2 — Equipamentos com Trade-offs (Prós e Contras)**
  - Migrar equipamentos de bônus puro para peças com implicações de gameplay:
    - Exemplo 1: *Lâmina do Caçador* (+8% Velocidade, -5% Defesa).
    - Exemplo 2: *Equipamento de Nen Concentrado* (+12% Dano de Hatsu, +8% Custo de Aura).
    - Exemplo 3: *Arma Envenenada* (+10% Dano, chance de envenenamento ao usuário ou alvo sob condições).
- [x] **Task 6.3 — Lore Tooltips para Itens**
  - Criar componente de UI de tooltip exibindo citações, origem de caçadores lendários ou histórias curtas de expedição para itens raros/históricos (sem obrigatoriedade de quests associadas).

---

### 🎨 EPIC 7: G7 — IDENTIDADE VISUAL & SPRITES MODULARES
**Objetivo:** Garantir a estética Hunter x Hunter com produção otimizada de assets e customização profunda.

- [x] **Task 7.1 — Sprites de Personagens Principais**
  - Produção de sprites e retratos de alta fidelidade para figuras-chave: Gon, Killua, Kurapika, Leorio, Hisoka, Biscuit, Wing, Razor, Chrollo, Meruem.
- [x] **Task 7.2 — Sistema Modular de Sprites para NPCs Genéricos**
  - Implementar gerador de sprites em camadas:
    `Corpo (Base) + Cabelo + Rosto + Roupas + Acessório + Arma + Paleta de Cores`.
- [x] **Task 7.3 — Customização Modular do Player**
  - Suporte ao mesmo pipeline em camadas para o personagem do jogador, permitindo personalização de vestimentas, acessórios e visual de aura ativa.
- [x] **Task 7.4 — UI Temática de Hunter x Hunter**
  - Redesenhar elementos de interface baseados em elementos canônicos: Licença Hunter, contratos de trabalho, tipografia e documentos oficiais da Associação Hunter.

---

### 🏗️ EPIC 8: G8 & G9 — ARQUITETURA DE EXPANSÃO & ROADMAP FUTURO
**Objetivo:** Estruturar o código para permitir adições modulares de sagas e preparar o terreno para a futura camada online.

- [x] **Task 8.1 — Arquitetura de Sagas e Regiões Modulares**
  - Modularizar carregamento de conteúdos por Saga (`Saga 1`, `Saga 2`...) com tabelas de eventos, bosses e reputações desacopladas do core engine.
- [x] **Task 8.2 — Abstração para Multiplayer Futuro (Single-player First)**
  - Isolar a lógica de controle de entidades e processamento de estado para permitir serialização de rede (Co-op, Party, World Bosses e PvP) quando a Fase G for finalizada.

---

## 🎯 DEFINITION OF DONE (DoD) - FASE G
- [x] 1. O combate transmite impacto físico nítido (hitstop, recuo, partículas e sons específicos).
- [x] 2. Mini bosses e Bosses de Quest utilizam ativamente o `BattlePersonality` reagindo às ações e Hatsus do player.
- [x] 3. NPCs reagem a escolhas passadas, exibem horários de rotina e reagem à chuva/dia/noite.
- [x] 4. Exploração contém segredos orgânicos sem waypoints guia.
- [x] 5. Hatsu evolui em maestria (eficiência e execução) sem perder a identidade original configurada.
- [x] 6. A interface e a atmosfera geral evocam instantaneamente a estética de *Hunter x Hunter*.
