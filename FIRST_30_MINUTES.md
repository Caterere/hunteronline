# HUNTER ONLINE — ANÁLISE DETALHADA DOS PRIMEIROS 30 MINUTOS (FIRST 30 MINUTES)

**Perfil do Jogador Simulado:** Jogador fã de Hunter x Hunter / Action RPG 2D, iniciando um personagem do zero sem conhecimento prévio do código-fonte.

---

## ⏱️ MINUTO 0–5: CRIAÇÃO DE PERSONAGEM & ENTRADA NO MUNDO

### O que acontece:
1. O jogador abre o jogo na tela de Criação / Seleção de Personagem (`CharacterCreationUI`).
2. Escolhe Nome, Afinidade de Nen inicial (Intensificação, Transformação, Emissão, Conjuração, Manipulação ou Especialização), Dificuldade e paleta de cores (Cabelo e Roupa).
3. Entra no mundo e spawna na **Vila de Padokia** (`regiao_vale_padokia.tscn` / `lobby.tscn`).

### Diagnóstico de Experiência:
- **Onboarding:** ⚠️ **REGULAR / AUSENTE.** O jogador não recebe uma introdução contextual ou tutorial dinâmico de movimentação (`WASD` / Setas), ataque básico (`J` / Espaço), dash/esquiva (`K` / Shift) ou abertura de menus (`Tab`, `I`, `N`, `H`).
- **Compreensão de Objetivo:** ⚠️ **CONFUSO.** O jogador spawna no meio da vila. A quest principal *"O Despertar da Aura & O Guardião de Zaban"* inicia automaticamente no log, mas não há um indicador visual no mundo (como uma seta suave, ponto de exclamação animado ou mini-bússola) apontando diretamente onde está o Mestre Wing.
- **Game Feel Inicial:** 🟡 **ACEITÁVEL.** A movimentação física funciona, mas a velocidade base de 64 px/s no mapa de 512x512 tiles parece um pouco lenta até o jogador descobrir o dash. A câmera segue suavemente, mas sem zoom dinâmico ou rotação.

---

## ⏱️ MINUTO 5–10: PRIMEIRO CONTATO COM NPCS & DIÁLOGO

### O que acontece:
1. O jogador anda pela vila, encontra NPCs como **Mestre Wing**, **Ferreiro**, **Vendedora** e **Cidadãos**.
2. Interage (`E` / `Enter`) abrindo balões de fala em quadrinhos (`VisualDialogueUI` / `ComicBalloon`).
3. Mestre Wing instrui o jogador sobre a importância da determinação e fala sobre as Ruínas e o fluxo de Nen.

### Diagnóstico de Experiência:
- **Identidade e Atmosfera:** 🟢 **BOA.** A estética em pixel art e as falas dos NPCs passam o tom do universo de Hunter x Hunter. A música clássica de aventura toca suavemente com transição de dia/noite.
- **Motivação:** 🟡 **REGULAR.** A conversa com Wing conclui o primeiro objetivo de visita da quest (`💬 Fale com Mestre Wing 1/1`), mas o jogador ainda não tem Nen desperto (`Aura: 0/0`).
- **Primeira Recompensa:** 🔴 **AUSENTE.** O jogador ainda não ganhou nenhum item prático, moeda ou senso imediato de empoderamento nos primeiros 10 minutos.

---

## ⏱️ MINUTO 10–15: SAÍDA DA VILA & PRIMEIRO COMBATE PVE

### O que acontece:
1. O jogador caminha para o norte da vila em direção à **Floresta dos Vestígios**.
2. Encontra os primeiros inimigos: **Slimes da Floresta** e **Macacos do Pantanal**.
3. Pressiona ataque básico (`J` / `Espaço`) e executa golpes corpo a corpo com a hitbox.

### Diagnóstico de Experiência:
- **Combate Físico:** 🟡 **ACEITÁVEL.** O golpe conecta, o número de dano flutua (`DamageNumber`) e o inimigo sofre knockback.
- **Falta de Feedback (Juice):** 🔴 **CRÍTICO.** Não há micro-congelamento (hitstop de 0.03s), nem screen shake no golpe, nem efeito sonoro contundente de impacto (apenas animação de sprite).
- **IA do Inimigo:** ⚠️ **PREVISÍVEL.** O monstro persegue em linha reta e ataca instantaneamente ao alcançar distância de golpe. Falta um indicador de antecipação (windup / telégrafo de 0.3s) que permita ao jogador realizar um *Perfect Dodge* consciente em vez de esquivar por pura sorte.
- **Progressão da Quest:** 🟢 **EXCELENTE.** Cada slime derrotado incrementa `1/3, 2/3, 3/3` com notificação limpa na tela.

---

## ⏱️ MINUTO 15–20: O DESPERTAR DO NEN & PRIMEIRO HATSU

### O que acontece:
1. Ao completar o objetivo de caça dos 3 slimes, o jogador sobe de nível (Level Up para Nível 2) e ganha XP de Nen.
2. O jogador abre o menu de Nen (`N`) e descobre as técnicas básicas: **Ten** (redução de dano) e **Ren** (aumento de alcance).
3. Ativa o Ten (`1`) e vê a aura azul brilhando ao redor do personagem.

### Diagnóstico de Experiência:
- **Momento Memorável (O "Aha!" Moment):** 🟢 **MUITO BOM.** Ver a aura de Nen ativando e o consumo/regeneração da barra de Aura no HUD dá a sensação autêntica de Hunter x Hunter.
- **Compreensão Tática:** 🟡 **REGULAR.** O jogador entende que Ten protege e Ren expande o alcance, mas ainda não é desafiado por um inimigo que *exija* Gyo (revelar armadilhas/aura oculta) ou Zetsu (passar despercebido por patrulha de alto risco).

---

## ⏱️ MINUTO 20–30: A DUNGEON DAS RUÍNAS DE ZABAN & PRIMEIRO CHEFE

### O que acontece:
1. O jogador segue a estrada de pedra até a entrada da **Dungeon das Ruínas de Zaban** (`dungeon_ruinas_zaban.tscn`).
2. Entra no mapa interno, a música muda para um tema tenso de masmorra (`dungeon_ruins`) e a barra de chefe surge no topo da tela.
3. Enfrenta Sentinelas de Pedra e luta contra o **Guardião Ancestral de Zaban** (Boss com 600 HP).
4. Derrota o Boss, o Baú Dourado surge no centro da sala, e ao abrir recebe:
   - Licença Hunter
   - Amuleto de Força (+5 Força)
   - 5.000 Jenny
   - Level Up de Nen para Nível 2 (200 Aura Máxima)

### Diagnóstico de Experiência:
- **Clímax do Primeiro Ciclo:** 🟢 **EXCELENTE.** A transição para a dungeon, o surgimento da Boss Bar e o baú de recompensas encerram os primeiros 30 minutos com uma forte sensação de conquista.
- **Dificuldade do Chefe:** 🟡 **ACEITÁVEL.** O Guardião tem HP alto e bate forte, mas suas ações ainda são repetições do comportamento padrão de perseguição de IA. Faltam fases (ex: Enraivecer aos 50% de HP, invocar sentinelas de apoio ou usar ataque em área com aviso no chão).
- **Vontade de Continuar:** 🟢 **ALTA.** Ao sair da dungeon com a Licença Hunter, dinheiro no bolso e Nen nível 2, o jogador desbloqueia o segundo arco de história e quer testar seus novos poderes na Torre Celestial.

---

## 📊 RESUMO EXECUTIVO DOS PRIMEIROS 30 MINUTOS

| Critério | Nota (1-10) | Diagnóstico |
|---|:---:|---|
| **Onboarding & Tutorial** | 4.5 | Falta indicação visual dos controles e guia de teclas para iniciantes. |
| **Pacing (Ritmo de Jogo)** | 7.5 | Bom fluxo: Vila -> Floresta -> Monstros -> Nen -> Dungeon -> Boss. |
| **Combate & Feedback** | 6.5 | Mecânica sólida, mas falta "juice" (hitstop, screen shake, SFX de impacto). |
| **Identidade Hunter x Hunter** | 8.5 | Aura de Nen, Mestre Wing, Zaban e trilha sonora muito fiéis. |
| **Recompensa & Descoberta** | 8.0 | Excelente final de ciclo com Baú Dourado e progressão de Nen. |
| **Engajamento para Hora 2** | 8.0 | O jogador que termina os 30 min quer entrar na Torre Celestial. |