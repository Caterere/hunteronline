# HATSU SYSTEM DESIGN BIBLE — Hunter x Hunter MMORPG
**Document Version:** 1.0.0  
**Target Audience:** AI Game Design Agents, Systems Designers, Combat Engineers  
**Scope:** Nen Architecture, Modular Creator Mechanics, Formal Archetype Breakdown & Canonical Reference Index  

---

## CONVENÇÃO DE TAGS METODOLÓGICAS
Para manter a fidelidade ao cânone de Yoshihiro Togashi e orientar o Game Engine/Agent na tomada de decisões mecânicas, cada elemento deste documento possui uma das três etiquetas:

* `[CANÔNICO]`: Regra, restrição ou habilidade explicitamente demonstrada no mangá/anime canônico de *Hunter x Hunter*.
* `[INTERPRETAÇÃO PARA O JOGO]`: Abstração sistêmica criada para o motor do MMORPG (valores numéricos, loops de gameplay, cooldowns, orçamentos de aura e buffers de estado).
* `[CRIAÇÃO DO JOGADOR]`: Parâmetros abertos no *Hatsu Creator* que o jogador pode customizar livremente ao desenhar sua técnica original.

---

# PARTE 1 — REGRAS DO SISTEMA DE NEN & HATSU

```
               [ REFORÇO (100%) ]
             /                    \
   [ TRANSFORMAÇÃO (80%) ]    [ EMISSÃO (80%) ]
          |                          |
   [ CONJURAÇÃO (60%) ]       [ MANIPULAÇÃO (60%) ]
             \                    /
             [ ESPECIALIZAÇÃO (0%*) ]
      (*Especialização posicionada entre Conjuração e Manipulação; 
        Afinidade de 0% para não-natos com probabilidade de conversão tardia)
```

### 1.1 As 6 Categorias de Nen e a Roda de Afinidade
* `[CANÔNICO]` Todo usuário de Nen possui uma Afinidade Natural (100%) em uma das categorias fundamentais. A eficiência de aprendizado e a potência máxima das categorias vizinhas decresce conforme a distância na roda: Categoria Primária (100%), Adjacentes (80%), Intermediárias (60%), Oposta (40%), Especialização (0% a menos que seja a categoria nativa ou adquirida tardiamente por Conjuração/Manipulação).
* `[INTERPRETAÇÃO PARA O JOGO]` O cálculo do Custo de Aura Final e Eficácia de Dano/Escudo/Utilidade é modulado pelo multiplicador de afinidade:
  $$\text{Eficácia Real} = \text{Potência Base} \times \text{Afinidade}(\%)$$
  $$\text{Custo Real de Aura} = \frac{\text{Custo Base}}{\text{Afinidade}(\%)}$$
  *Penalidade por Quebra de Categoria:* Tentar criar um Hatsu com funções fora da afinidade primária consome exponencialmente mais "Capacidade de Memória" (*Memory Load*) do usuário (conceito de Kastro).

### 1.2 Recursos de Aura: POP, AOP e MOP
* `[CANÔNICO]`
  * **MOP (Maximum Operating Power / Volume Máximo de Aura):** Reserva total de energia de um usuário.
  * **AOP (Actual Operating Power / Potência Real de Saída):** O volume máximo que o usuário pode liberar e concentrar em um único instante (Ken, Ryu, Ko ou disparo de Hatsu).
  * **POP (Potential Operating Power / Capacidade Latente de Recuperação):** A taxa de regeneração e sustentabilidade ao longo de combate prolongado.
* `[INTERPRETAÇÃO PARA O JOGO]`
  * `MOP`: Barra de Mana/Aura total do jogador.
  * `AOP`: Teto máximo de gasto por ação individual (determina o "Dano Máximo de um Ko/Hatsu" ou a "Escala de uma Conjuração").
  * `POP`: Regeneração passiva de aura por segundo em combate ($/s$) e resistência à fadiga muscular/mental de Nen (*Zetsu Forçado por Exaustão*).

### 1.3 A Equação do Hatsu: Condições, Restrições e Juramentos
O poder de um Hatsu não é arbitrário; ele é o resultado estrito da fórmula fundamental de Nen:
$$\text{Potência Final} = (\text{Aura Base} + \text{Aura Injetada}) \times \prod (1 + \text{Multiplicador de Condição}) \times \text{Fator de Juramento}$$

#### 1. Taxonomia de Limitações
1. **Condição (Condition) `[CANÔNICO]`:** Gatilho operacional ou pré-requisito de ativação sem risco existencial.
   * *Exemplos:* "Tocar o alvo com as duas mãos", "O alvo responder a uma pergunta", "Permanecer imóvel por 3 segundos".
   * *Multiplicador Mecânico `[INTERPRETAÇÃO PARA O JOGO]`:* $+15\%$ a $+75\%$ na potência ou redução proporcional de custo de aura.
2. **Restrição (Restriction) `[CANÔNICO]`:** Limitação contínua autoimposta sobre o uso ou escopo da habilidade.
   * *Exemplos:* "Apenas funciona dentro de uma sala fechada", "Apenas utilizável em noites de lua cheia", "Só pode criar 1 cópia por vez".
   * *Multiplicador Mecânico `[INTERPRETAÇÃO PARA O JOGO]`:* $+50\%$ a $+200\%$ de eficácia em troca de estreitamento tático severo.
3. **Juramento e Voto (Vow & Punishment) `[CANÔNICO]`:** Promessa solene com penalidade punitiva absoluta (morte, perda irrevogável de Nen ou coma) em caso de violação deliberada ou falha.
   * *Exemplos:* *Chain Jail* de Kurapika ("Se eu usar contra alguém que não seja da Trupe Fantasma, eu morro imediatamente").
   * *Multiplicador Mecânico `[INTERPRETAÇÃO PARA O JOGO]`:* $\times 5.0$ a $\times 15.0$ (Multiplicador Exponencial / Quebra de Teto de Tier). Se violado no sistema, o personagem sofre morte permanente (*Permadeath*) ou bloqueio definitivo da árvore de Nen (*Zetsu Permanente Irreversível*).

### 1.4 Sistema de "Créditos de Complexidade" (Memory Load Budget)
* `[CANÔNICO]` Como demonstrado na luta entre Hisoka e Kastro, criar um Hatsu que exija conjuração complexa somada a manipulação consome demasiada "memória cerebral" de combate, deixando o usuário cego e vulnerável a táticas básicas.
* `[INTERPRETAÇÃO PARA O JOGO]`
  * Todo personagem possui um teto de **Pontos de Complexidade (CP)** baseado no seu nível de maestria em Nen (Ex: 100 CP).
  * Funções simples (Disparo de Emissão puro) = 15 CP.
  * Funções híbridas (Criar clone conjurado + animá-lo com Manipulação) = 75 CP.
  * O jogador não pode exceder o CP total ao montar seus Hatsu no Creator, forçando a especialização em vez da acumulação desenfreada de utilidades.

### 1.5 Diferença Fundamental: Hatsu Criado vs. Hatsu Adquirido (Roubado/Emprestado/Transferido)
* **Hatsu Criado `[CRIAÇÃO DO JOGADOR]`:**
  * Moldado pela personalidade, afinidade e histórico do personagem.
  * Escala com a maestria pessoal do usuário nas técnicas básicas (*Ten, Zetsu, Ren, Gyo, Ko, Ryu, Shu, En*).
  * Otimizado organicamente para o seu biotipo de combate e afinidade nativa.
* **Hatsu Adquirido (Roubado/Copiado/Emprestado) `[INTERPRETAÇÃO PARA O JOGO]`:**
  * O portador deve satisfazer os requisitos de afinidade do Hatsu original, sofrendo penalidade de custo de aura se sua afinidade for diferente da do dono original (a menos que a habilidade de roubo anule isso explicitamente, como a *Skill Hunter* faz para certas propriedades).
  * A habilidade roubada não evolui de forma autônoma; ela opera estritamente nas variáveis em que foi extraída.
  * Se o dono original morrer, a habilidade desaparece do inventário — salvo se o Nen do falecido se tornar mais forte após a morte (*Nen Póstumo / Post-Mortem Nen*).

---

# PARTE 2 — MATRIZ DE ARQUÉTIPOS DE HATSU NO MMORPG

O *Hatsu Creator* não pergunta "quanto dano você quer dar?". Ele categoriza a habilidade pelo seu **Arquétipo Estrutural**, definindo a interface e as variáveis configuráveis:

| Arquétipo Primário | Exemplos Canônicos | Mecânica Principal no Engine | Variáveis de Customização do Jogador |
| :--- | :--- | :--- | :--- |
| **Transformação / Estado (Combat Stance)** | *Godspeed* (Killua), *Big Bang Impact* (Uvo - foco), *Body Alteration* (Bisky) | Modificador global de atributos, conversão de propriedades e sobrescrita de inputs do jogador. | • Propriedade da Aura<br>• Dreno de MOP/s<br>• Modificadores de Status<br>• Gatilho de Desativação |
| **Ataque Carregado / Multimodo** | *Jajanken* (Gon), *Ripper Cyclotron* (Phinks), *Dragon Head* (Zeno) | Estados de preparação (*Charge*), janelas de vulnerabilidade e canais de liberação seletiva. | • Número de Modos<br>• Tempo de Canalização (*Ko*)<br>• Multiplicador por Segundo<br>• Afinidade por Modo |
| **Propriedade de Aura / Transmutação** | *Bungee Gum* (Hisoka), *Electricity* (Killua), *Nen Threads* (Machi) | Atribuição de vetores de física (elasticidade, viscosidade, condutividade, tensão) à aura. | • Coeficiente de Elasticidade<br>• Adesão ao Cenário/Alvo<br>• Condutividade Elétrica/Térmica<br>• Invisibilidade sob In |
| **Roubo de Hatsu (Theft)** | *Skill Hunter* (Chrollo), *Steal Chain* (Kurapika) | Extração do objeto `HatsuDefinition` do alvo e injeção no container `Player.HatsuInventory`. | • Número de Condições de Roubo<br>• Requisito de Contato/Interrogatório<br>• Capacidade do Livro/Container<br>• Manutenção de Vida do Alvo |
| **Cópia / Replicação (Duplication)** | *Gallery Fake* (Kortopi), *Conversion Hands* (Chrollo/Original) | Instanciação de entidades clonadas no mapa com metadados de rastreamento (*En*) e tempo de vida. | • Duração do Clone (ex: 24h)<br>• Cópia de Objetos Inanimados vs. Seres Vivos<br>• Emissão de En via Objeto Conjurado<br>• Teto de Entidades Simultâneas |
| **Drenagem / Supressão (Drain & Suppress)** | *Hakoware* (Knuckle), *Steal Chain* (Kurapika), *Toritaten* (Smoky Jail/Morel) | Manipulação direta das variáveis `Target.AOP` e `Target.MOP`, forçando estados de *Zetsu*. | • Taxa de Empréstimo/Juros (10%/10s)<br>• Raio de Manutenção do Mascote<br>• Limiar de Falência (*Zetsu Forçado*)<br>• Imunidade a Dano do Alvo |
| **Controle / Manipulação Direta (Puppeteering)** | *Black Voice* (Shalnark), *Order Stamp*, *Needleman* (Illumi) | Sobrescrita da máquina de estados (*FSM/AI*) ou bloqueio completo de inputs de jogadores. | • Vetor de Aplicação (Agulha, Antena, Selo)<br>• Alvo (Cadáver, NPC, Jogador Vivo)<br>• Nível de Controle (Controle Total / Piloto Automático / Sugestão)<br>• Condição de Remoção do Marcador |
| **Selamento / Prisão (Domain / Confinement)** | *Chain Jail* (Kurapika), *Smoky Jail* (Morel), *Hide and Seek* (Knov) | Criação de zonas de contenção física ou dimensional intransponíveis com anulação de teleporte. | • Tipo de Confinamento (Barreira Física vs. Bolha Dimensional)<br>• Alvo Válido (Geral vs. Específico/Juramento)<br>• Força de Ruptura (Baseada em Ko vs. Inquebrável)<br>• Dreno de Manutenção |
| **Previsão / Extração de Informação** | *Lovely Ghostwriter* (Neon), *Memory Bomb* (Pakunoda), *Dowsing Chain* (Kurapika) | Consulta a metadados do servidor: logs de combate, inventário de jogadores, detecção de mentiras ou leitura de inputs futuros. | • Mídia de Comunicação (Poema, Bala, Pêndulo)<br>• Condição de Input (Dados de Nascimento, Toque, Pergunta)<br>• Fidelidade/Ambiguidade da Informação<br>• Cooldown Estratégico |
| **Armazenamento & Espaço Dimensional** | *Hide and Seek* (Knov), *Blinky / Deme-chan* (Shizuku), *Skill Hunter* | Instanciação de inventários dedicados ou mapas instanciados isolados fora da malha do jogo principal. | • Dimensão de Bolsão (`PocketDimensionInstance`)<br>• Capacidade de Volume (Litros / Entidades)<br>• Filtragem de Objetos (Orgânico vs. Não-Orgânico)<br>• Portais de Entrada e Saída |
| **Besta de Nen / Invocação Autônoma** | *Nen Beasts* de Kakin, *Dr. Blythe* (Pitou), *Crazy Slots* (Kite) | Instanciação de agentes independentes (`NenEntityAI`) vinculados ao `MOP` do portador. | • Autonomia (Comando Direto vs. Ação Automática Reativa)<br>• Aleatoriedade (Rolar Roleta de Armas)<br>• Funções Específicas (Cirurgia, Defesa, Sentinela)<br>• Custo de Ancoragem |
| **Contrato Parasítico / Simbiótico** | *Guardian Spirit Beasts* (Kakin), *Hakoware* (Knuckle) | Alimentação contínua da aura do hospedeiro ou alvo para manifestação de efeitos sem gasto do criador. | • Fonte de Aura (Hospedeiro Involuntário / Voluntário)<br>• Gatilho de Despertar<br>• Efeito Reativo a Ameaças<br>• Vulnerabilidade do Usuário Base |
| **Nen Póstumo (Post-Mortem Nen)** | *Terpsichora* (Pitou), *Sun and Moon* (Chrollo), *Hisoka Resurrect* | Gatilho de execução condicional disparado no evento `OnCharacterDeath`. | • Condição de Óbito (Rancor, Desejo Inacabado)<br>• Multiplicador de Potência Pós-Morte ($\\ge \\times 10$)<br>• Persistência Eterna no Mundo/Alvo<br>• Ressuscitação Autônoma (Massagem Cardíaca de Nen) |

---

# PARTE 3 — CATÁLOGO COMPLETO DE HATSU CANÔNICOS DE REFERÊNCIA

---

## 🟢 TIER 1: HATSU BÁSICOS & FUNDAMENTAIS (Operações Diretas de Combate)

---

### 01. Jajanken: Rock (Guu)
* **Personagem:** Gon Freecss `[CANÔNICO]`
* **Tipo de Nen:** Reforço (100%) `[CANÔNICO]`
* **Arquétipo:** Ataque Carregado / Impacto Crítico `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Concentração máxima de aura ofensiva nos punhos para causar dano destrutivo em curto alcance `[CANÔNICO]`.
* **Mecânica Principal:**
  ```
  [Input Carregar: Ko nos Punhos] -> [Canalização do Cântico: "First comes Rock..."]
         | (Gera Zetsu no restante do corpo: Vulnerabilidade 300%)
         V
  [Release: Impacto Físico] -> Dano = Dano Base * (1 + Tempo de Carga * 1.5)
  ```
* **Variáveis Predefinidas (Hardcoded):** Ângulo de impacto (corpo a corpo frontal), perda total de aura defensiva no restante do corpo durante o carregamento `[INTERPRETAÇÃO PARA O JOGO]`.
* **Variáveis Configuráveis pelo Jogador:** Tempo de canalização (1 a 4 segundos), gasto de AOP por soco `[CRIAÇÃO DO JOGADOR]`.
* **Condições & Restrições:** O usuário deve recitar o cântico em voz alta (`AudioBroadcast`), ficar imóvel durante o acúmulo e canalizar 95% da aura em *Ko* `[CANÔNICO]`.
* **Como Aparece no Creator:** Menu de *Ataque Carregado* $\rightarrow$ *Canalização com Vulnerabilidade Exposta* $\rightarrow$ *Bônus Multiplicador por Segundo*.

---

### 02. Jajanken: Scissors (Chii)
* **Personagem:** Gon Freecss `[CANÔNICO]`
* **Tipo de Nen:** Transmutação (80%) `[CANÔNICO]`
* **Arquétipo:** Propriedade de Aura / Lâmina de Corte `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Moldar a aura emitida pelos dedos indicador e médio em uma lâmina afiada capaz de cortar alvos resistentes `[CANÔNICO]`.
* **Mecânica Principal:** Converte aura pura em vetor cortante. Penetração de armadura física de 50%, com alcance médio (1 metro estendido) `[INTERPRETAÇÃO PARA O JOGO]`.
* **Como Aparece no Creator:** Menu *Transmutação* $\rightarrow$ *Propriedade Cortante* $\rightarrow$ *Alcance Curto Estendido*.

---

### 03. Jajanken: Paper (Paa)
* **Personagem:** Gon Freecss `[CANÔNICO]`
* **Tipo de Nen:** Emissão (80%) `[CANÔNICO]`
* **Arquétipo:** Projétil de Aura `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Disparo de uma esfera de aura concentrada a longa distância `[CANÔNICO]`.
* **Mecânica Principal:** Projétil linear desacelerado com alta área de impacto (*AoE*), mas com apenas 60% do dano bruto do Rock (devido à penalidade natural de afinidade) `[INTERPRETAÇÃO PARA O JOGO]`.
* **Como Aparece no Creator:** Menu *Emissão* $\rightarrow$ *Projétil Esférico Direcional*.

---

### 04. Ripper Cyclotron
* **Personagem:** Phinks Magcub `[CANÔNICO]`
* **Tipo de Nen:** Reforço (100%) `[CANÔNICO]`
* **Arquétipo:** Ataque Carregado Cíclico / Acúmulo Infinito Teórico `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Aumentar a potência do soco a cada rotação completa do braço `[CANÔNICO]`.
* **Mecânica Principal:**
  $$\text{Dano Total} = \text{AOP Base} \times (\text{Número de Rotações})^{1.35}$$
  Cada rotação leva 0.4s e drena uma quantidade fixa de MOP `[INTERPRETAÇÃO PARA O JOGO]`.
* **Condições & Restrições:** Requer movimento contínuo do braço em 360 graus. Se a rotação for interrompida por atordoamento, toda a aura acumulada se dissipa e o custo é consumido `[CANÔNICO]`.
* **Como Aparece no Creator:** *Ataque Carregado* $\rightarrow$ *Gatilho de Rotação/Stacks* $\rightarrow$ *Escalonamento Exponencial*.

---

### 05. Big Bang Impact
* **Personagem:** Uvogin `[CANÔNICO]`
* **Tipo de Nen:** Reforço (100%) `[CANÔNICO]`
* **Arquétipo:** Impacto Sísmico de Alta Escala `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Canalizar 100% do AOP em um único golpe direto focado no punho, gerando uma cratera similar a um míssil pequeno `[CANÔNICO]`.
* **Mecânica Principal:** Dano massivo no ponto de impacto primário + onda de choque circular que derruba inimigos em um raio de 15 metros `[INTERPRETAÇÃO PARA O JOGO]`.
* **Como Aparece no Creator:** *Reforço Puro* $\rightarrow$ *AOP Máximo* $\rightarrow$ *AoE de Onda de Choque*.

---

### 06. Aura Cannon / Emitted Blast
* **Personagem:** Franklin Bordeau (Fundamento) `[CANÔNICO]`
* **Tipo de Nen:** Emissão (100%) `[CANÔNICO]`
* **Arquétipo:** Projétil Rápido Contínuo `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Disparar rajadas puras de aura a partir das pontas dos dedos `[CANÔNICO]`.
* **Mecânica Principal:** Taxa de disparo contínua (8 disparos/segundo), com consumo sustentado de MOP/segundo `[INTERPRETAÇÃO PARA O JOGO]`.

---

### 07. Double Machine Gun
* **Personagem:** Franklin Bordeau `[CANÔNICO]`
* **Tipo de Nen:** Emissão (100%) `[CANÔNICO]`
* **Arquétipo:** Projétil Balístico Aprimorado por Autocortilação `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Metralhadora de aura disparada pelas pontas dos dedos modificadas `[CANÔNICO]`.
* **Condição / Restrição (Fator Crítico):** Franklin cortou deliberadamente as pontas de todos os dedos fora para criar uma restrição visual e física `[CANÔNICO]`.
* **Multiplicador de Condição:** $+180\%$ na velocidade do projétil e penetração balística comparado a um disparo de emissão comum `[INTERPRETAÇÃO PARA O JOGO]`.
* **Como Aparece no Creator:** *Emissão* $\rightarrow$ *Modificador de Sacrifício Permanente* $\rightarrow$ *Buff de Taxa e Dano*.

---

### 08. Bungee Gum: Fixar & Puxar
* **Personagem:** Hisoka Morow `[CANÔNICO]`
* **Tipo de Nen:** Transmutação (100%) `[CANÔNICO]`
* **Arquétipo:** Propriedade de Aura (Borracha e Goma) `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Conferir à aura propriedades combinadas de extrema elasticidade e aderência adesiva total `[CANÔNICO]`.
* **Mecânica Principal:** Aplica âncora de tração no alvo (`TargetAnchor`). O usuário pode retrair a aura instantaneamente para puxar o alvo até si ou se arremessar até a superfície ancorada `[INTERPRETAÇÃO PARA O JOGO]`.
* **Como Aparece no Creator:** *Transmutação* $\rightarrow$ *Propriedade Mecânica: Adesão/Elasticidade* $\rightarrow$ *Controle Vetorial de Movimento*.

---

### 09. Texture Surprise (Falsificação Estética)
* **Personagem:** Hisoka Morow `[CANÔNICO]`
* **Tipo de Nen:** Conjuração (60%) / Transmutação `[CANÔNICO]`
* **Arquétipo:** Mimetismo de Textura / Camuflagem `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Aplicar uma camada ultra-fina de aura conjurada sobre tecidos, papel ou pele para reproduzir mais de mil texturas visuais e táteis diferentes `[CANÔNICO]`.
* **Mecânica Principal:** Muda a renderização visual e os metadados de inspeção de um item/personagem. Revelada instantaneamente se o observador utilizar *Gyo* nos olhos `[INTERPRETAÇÃO PARA O JOGO]`.
* **Como Aparece no Creator:** *Conjuração Ilusória* $\rightarrow$ *Disfarce de Objeto/Interface* $\rightarrow$ *Vulnerabilidade a Gyo*.

---

### 10. Nen Threads (Fios de Cura & Sutura)
* **Personagem:** Machi Komacine `[CANÔNICO]`
* **Tipo de Nen:** Transmutação (100%) `[CANÔNICO]`
* **Arquétipo:** Propriedade Filar / Sutura Biológica `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Transformar a aura em fios extremamente resistentes para costurar membros decepados ou controlar alvos como marionetes `[CANÔNICO]`.
* **Regra de Escala Canônica:** A resistência do fio é inversamente proporcional ao seu comprimento (um fio com o diâmetro da Terra quebra fácil; um fio de 1 metro sustenta toneladas) `[CANÔNICO]`.
* **Mecânica no Jogo:**
  $$\text{Resistência Tensil} = \frac{\text{Aura Investida}}{\text{Comprimento (metros)}}$$
* **Como Aparece no Creator:** *Transmutação* $\rightarrow$ *Fio/Cabo* $\rightarrow$ *Relação Inversa de Comprimento/Resistência*.

---

### 11. Nen Threads: Armadilha Invisível
* **Personagem:** Machi Komacine `[CANÔNICO]`
* **Tipo de Nen:** Transmutação (100%) + In `[CANÔNICO]`
* **Arquétipo:** Controle de Área / Armadilha Oculta `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Espalhar teias de fios invisíveis pelo campo de batalha para prender ou cortar adversários desprevenidos `[CANÔNICO]`.
* **Como Aparece no Creator:** *Controle de Zona* $\rightarrow$ *Fios com In* $\rightarrow$ *Detecção de Colisão*.

---

### 12. Vacuum Cleaner: Blinky (Deme-chan)
* **Personagem:** Shizuku Murasaki `[CANÔNICO]`
* **Tipo de Nen:** Conjuração (100%) `[CANÔNICO]`
* **Arquétipo:** Objeto Conjurado Utilitário / Aspiração Dimensional `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Conjurar um aspirador com dentes capaz de sugar uma quantidade infinita de matéria inanimada `[CANÔNICO]`.
* **Condições & Restrições Canônicas:**
  1. Não pode sugar nada que o usuário considere "vivo" ou feito de Nen puro `[CANÔNICO]`.
  2. Pode sugar venenos, sangue ou objetos a partir de ordens específicas ("Deme-chan, sugue o sangue do chão") `[CANÔNICO]`.
  3. O último item sugado pode ser expelido de volta `[CANÔNICO]`.
* **Como Aparece no Creator:** *Conjuração de Objeto* $\rightarrow$ *Filtro Booleano de Alvo (IsAlive == False)* $\rightarrow$ *Absorção de Inventário/Cenário*.

---

### 13. Shadow Beast: Porcupine Needle Armor
* **Personagem:** Porcupine (Shadow Beasts) `[CANÔNICO]`
* **Tipo de Nen:** Transmutação / Reforço `[CANÔNICO]`
* **Arquétipo:** Modificação Corporal Defensiva `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Controlar a maleabilidade e rigidez dos pelos do corpo, tornando-os macios como algodão para absorver golpes ou rígidos como agulhas de aço para empalar `[CANÔNICO]`.
* **Como Aparece no Creator:** *Transmutação/Reforço Corporal* $\rightarrow$ *Alternância de Estado (Absorção de Impacto / Contra-Ataque Perfurante)*.

---

### 14. Shadow Beast: Worm Mole Movement
* **Personagem:** Worm (Shadow Beasts) `[CANÔNICO]`
* **Tipo de Nen:** Transmutação / Reforço `[CANÔNICO]`
* **Arquétipo:** Manipulação de Terreno / Furtividade Subterrânea `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Amolecer a rocha e terra ao redor do corpo para nadar sob o solo com velocidade `[CANÔNICO]`.
* **Como Aparece no Creator:** *Mobilidade de Terreno* $\rightarrow$ *Submersão Subterrânea* $\rightarrow$ *Ataque de Emboscada*.

---

### 15. Shadow Beast: Leech Body Infestation
* **Personagem:** Leech (Shadow Beasts) `[CANÔNICO]`
* **Tipo de Nen:** Manipulação (100%) `[CANÔNICO]`
* **Arquétipo:** Manipulação Biológica / Parasitismo `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Implantar sanguessugas no corpo do inimigo através de mordidas ou feridas para devorar órgãos e injetar toxinas `[CANÔNICO]`.
* **Como Aparece no Creator:** *Manipulação Orgânica* $\rightarrow$ *DoT (Damage over Time) Cumulativo* $\rightarrow$ *Requisito de Contato Físico Prévio*.

---

### 16. Shadow Beast: Rabid Dog Poison Fang
* **Personagem:** Rabid Dog (Shadow Beasts) `[CANÔNICO]`
* **Tipo de Nen:** Reforço / Transmutação `[CANÔNICO]`
* **Arquétipo:** Dente Aprimorado com Neurotoxina `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Dentes com dureza amplificada por Nen que injetam veneno paralisante que age do pescoço para baixo sem afetar a sensibilidade da dor `[CANÔNICO]`.
* **Como Aparece no Creator:** *Ataque Físico com Efeito de Status* $\rightarrow$ *Paralisia Motora Progressiva*.

---

### 17. Body Alteration (Forma Verdadeira de Bisky)
* **Personagem:** Biscuit Krueger `[CANÔNICO]`
* **Tipo de Nen:** Transmutação / Reforço `[CANÔNICO]`
* **Arquétipo:** Transformação Corporal Permanente/Reversível `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Reverter a aparência de menina jovem para a forma gigante e hipermusculosa original, desbloqueando 100% de sua força física bruta `[CANÔNICO]`.
* **Mecânica no Jogo:** Desbloqueia $+250\%$ de Dano Físico e $+100\%$ de Escala de Modelo, mas aumenta a caixa de colisão (*Hitbox*) do jogador `[INTERPRETAÇÃO PARA O JOGO]`.
* **Como Aparece no Creator:** *Transformação Corporal* $\rightarrow$ *Trade-off: Dano Físico vs. Hitbox Aumentada*.

---

### 18. Magical Beautician: Piano Massage
* **Personagem:** Biscuit Krueger `[CANÔNICO]`
* **Tipo de Nen:** Conjuração + Transmutação `[CANÔNICO]`
* **Arquétipo:** Suporte / Recuperação Acelerada de Fadiga `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Conjura a massagista "Cookie-chan", que utiliza loções especiais de aura para restaurar a vitalidade de um dia inteiro em apenas 30 minutos de sono `[CANÔNICO]`.
* **Mecânica no Jogo:** Regenera 100% do MOP, HP e remove todos os debuffs de exaustão e fadiga em zona segura (*Rest Zone*) `[INTERPRETAÇÃO PARA O JOGO]`.
* **Como Aparece no Creator:** *Besta Conjurada de Suporte* $\rightarrow$ *Zona de Descanso Acelerado*.

---

### 19. Nen Exorcism (Devorador de Maldições de Abengane)
* **Personagem:** Abengane `[CANÔNICO]`
* **Tipo de Nen:** Conjuração (100%) `[CANÔNICO]`
* **Arquétipo:** Exorcismo de Nen / Besta Simbiótica Punitiva `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Remover maldições e Hatsus impostos por outros usuários no corpo do alvo, absorvendo a maldição na forma de um monstro conjurado acoplado ao corpo do exorcista `[CANÔNICO]`.
* **Condições Canônicas:** A besta permanece acoplada drenando continuamente o MOP do exorcista até que o usuário original do Nen amaldiçoado morra ou a condição de quebra seja cumprida `[CANÔNICO]`.
* **Como Aparece no Creator:** *Exorcismo de Estado* $\rightarrow$ *Invocação Simbiótica com Dreno Contínuo*.

---

### 20. Nen Bullets (Balas de Aura do Tocino)
* **Personagem:** Tocino `[CANÔNICO]`
* **Tipo de Nen:** Emissão (100%) `[CANÔNICO]`
* **Arquétipo:** Marionetes Conjuradas Simples / Soldados de Aura `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Conjurava até 11 soldados pretos ("Eleven Black Children") emitidos para receber ordens simples e agir como escudo humano `[CANÔNICO]`.
* **Como Aparece no Creator:** *Invocação de Múltiplas Unidades Frágeis* $\rightarrow$ *Comando Básico de Rota*.

---

## 🔵 TIER 2: HATSU INTERMEDIÁRIOS (Sistemas com Condições, Modos e Transformações)

---

### 21. Godspeed: Lightning Palm (Izutsushi)
* **Personagem:** Killua Zoldyck `[CANÔNICO]`
* **Tipo de Nen:** Transmutação (100%) `[CANÔNICO]`
* **Arquétipo:** Propriedade Elétrica / Atordoamento de Contato `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Descarregar eletricidade concentrada através das palmas das mãos para paralisar o sistema neuromuscular do alvo `[CANÔNICO]`.
* **Mecânica Principal:** Dano elétrico moderado + Estado de Atordoamento (*Stun Lock*) por 1.2s por acerto `[INTERPRETAÇÃO PARA O JOGO]`.

---

### 22. Godspeed: Thunderbolt (Narukami)
* **Personagem:** Killua Zoldyck `[CANÔNICO]`
* **Tipo de Nen:** Transmutação (100%) + Emissão (80%) `[CANÔNICO]`
* **Arquétipo:** Disparo Elétrico Vertical / Projétil Perfurante `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Saltar no ar e disparar um raio de eletricidade direto contra o alvo a média distância `[CANÔNICO]`.
* **Como Aparece no Creator:** *Transmutação Elétrica* $\rightarrow$ *Disparo Direcional com Requisito Aéreo*.

---

### 23. Godspeed: Speed of Lightning (Denkosekka)
* **Personagem:** Killua Zoldyck `[CANÔNICO]`
* **Tipo de Nen:** Transmutação (100%) / Reforço `[CANÔNICO]`
* **Arquétipo:** Estado de Movimento / Super Velocidade Consciente `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Passar impulsos elétricos pelo próprio sistema nervoso para amplificar a velocidade de corrida e deslocamento muito além dos limites biológicos `[CANÔNICO]`.
* **Mecânica no Jogo:** $+300\%$ na Velocidade de Movimento e esquiva aprimorada contra projéteis balísticos `[INTERPRETAÇÃO PARA O JOGO]`.

---

### 24. Godspeed: Whirlwind (Shippujinrai)
* **Personagem:** Killua Zoldyck `[CANÔNICO]`
* **Tipo de Nen:** Transmutação (100%) + Manipulação `[CANÔNICO]`
* **Arquétipo:** Automatização Neural de Movimento / Esquiva e Contra-Ataque Automáticos `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Programar a aura para reagir instantaneamente à intenção hostil ou contato do inimigo, contornando o cérebro e enviando sinais elétricos direto aos músculos `[CANÔNICO]`.
* **Mecânica de Engine (NÃO É DANO):**
  ```
  Evento: Enemy.OnAttackInitiation(Target == Player)
  Ação: Player.CancelCurrentFrame() -> Player.TriggerAutomaticCounterHit() -> Player.DodgeHitbox()
  ```
  O jogador não precisa mirar ou pressionar esquiva: o engine executa o desvio perfeito no primeiro frame de colisão `[INTERPRETAÇÃO PARA O JOGO]`.
* **Condição & Limitação Crítica:** Requer que Killua recarregue sua carga elétrica periodicamente em tomadas/geradores elétricos externos (`ElectricalChargeCapacity`); sem carga, o Godspeed é desativado `[CANÔNICO]`.
* **Como Aparece no Creator:** *Estado de Transformação* $\rightarrow$ *Sobrescrita de Input: Automação Reativa de Esquiva* $\rightarrow$ *Bateria de Recarga Externa Obrigatória*.

---

### 25. Black Voice (Controle Absoluto via Antena)
* **Personagem:** Shalnark `[CANÔNICO]`
* **Tipo de Nen:** Manipulação (100%) `[CANÔNICO]`
* **Arquétipo:** Manipulação por Dispositivo / Controle de Marionete `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Inserir uma antena física de morcego em uma criatura ou jogador para controlá-la totalmente através de um telefone celular modificado `[CANÔNICO]`.
* **Condição de Vitória Instantânea Canônica:** Se a antena furar a pele do alvo com sucesso, o alvo perde o controle de seu personagem imediatamente. Não há teste de resistência se o Nen penetrar `[CANÔNICO]`.
* **Mecânica de Engine:**
  ```
  Condição: PhysicalContact(Antenna, Target) == True AND Target.TenDefense < Attacker.KoPiercing
  Efeito: Target.ControllerID = Shalnark.PlayerID
  ```
* **Limitação:** Shalnark só possui 2 antenas físicas. Se as antenas forem destruídas ou removidas por um terceiro, o controle cessa `[CANÔNICO]`.
* **Como Aparece no Creator:** *Manipulação* $\rightarrow$ *Requisito de Projétil Físico Consumível* $\rightarrow$ *Sobrescrita Total do FSM do Alvo*.

---

### 26. Black Voice: Modo Autopilot (Piloto Automático)
* **Personagem:** Shalnark `[CANÔNICO]`
* **Tipo de Nen:** Manipulação (100%) + Reforço `[CANÔNICO]`
* **Arquétipo:** Sobrescrita de Self-AI / Estado de Fúria Automática `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Shalnark espeta a própria antena em si mesmo e define uma ordem prioritária ("Elimine o inimigo à minha frente"). O corpo entra em sobrecarga de aura inacreditável com velocidade e força insanas `[CANÔNICO]`.
* **Penalidade Severa Canônica:** Shalnark perde toda a consciência durante o modo, não se lembra de nada do combate e sofre de fadiga muscular extrema e dores lancinantes por dias após o término `[CANÔNICO]`.
* **Mecânica no Jogo:** O jogador perde o controle do personagem (o bot de IA assume com +500% de DPS e imunidade a CC) por 15 segundos. Ao encerrar: HP reduzido a 5%, MOP zerado e Zetsu forçado por 10 minutos `[INTERPRETAÇÃO PARA O JOGO]`.
* **Como Aparece no Creator:** *Self-Manipulação* $\rightarrow$ *Controle por Bot IA Temporário* $\rightarrow$ *Debuff Pós-Uso Crítico*.

---

### 27. Crazy Slots: #2 Grim Reaper's Scythe (Silent Waltz)
* **Personagem:** Kite `[CANÔNICO]`
* **Tipo de Nen:** Conjuração (100%) + Transmutação `[CANÔNICO]`
* **Arquétipo:** Conjuração Condicional / Roleta Aleatória / Corte em 360° `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Conjura um palhaço mecânico que gira uma roleta de 1 a 9. O número 2 invoca uma foice gigante que só possui um golpe: uma onda de corte devastadora que destrói tudo ao redor em um raio colossal `[CANÔNICO]`.
* **Condição & Restrição Canônica:**
  1. Kite não pode escolher a arma que quer (totalmente aleatório) `[CANÔNICO]`.
  2. A foice NÃO PODE desaparecer até que o ataque "Silent Waltz" seja executado com toda a força `[CANÔNICO]`.
* **Como Aparece no Creator:** *Conjuração Aleatória (Roleta)* $\rightarrow$ *Arma Bloqueada até Execução da Habilidade Obrigatória*.

---

### 28. Crazy Slots: #4 Rifle
* **Personagem:** Kite `[CANÔNICO]`
* **Tipo de Nen:** Conjuração (100%) + Emissão `[CANÔNICO]`
* **Arquétipo:** Arma de Precisão de Longo Alcance `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Invoca um fuzil de longa distância com silenciador de aura para abates de franco-atirador `[CANÔNICO]`.
* **Como Aparece no Creator:** *Conjuração Balística* $\rightarrow$ *Aumento de Alcance e Dano Crítico Furtivo*.

---

### 29. Crazy Slots: #3 Mace / Varinha
* **Personagem:** Kite `[CANÔNICO]`
* **Tipo de Nen:** Conjuração (100%) `[CANÔNICO]`
* **Arquétipo:** Arma Curta de Impacto e Ativação Póstuma `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Clava de combate corpo a corpo vinculada a uma cláusula secreta de reencarnação caso Kite enfrente a morte com determinação absoluta `[CANÔNICO]`.

---

### 30. Deep Purple: Smoke Puppets (Guerreiros de Fumaça)
* **Personagem:** Morel Mackernasey `[CANÔNICO]`
* **Tipo de Nen:** Manipulação (100%) + Emissão `[CANÔNICO]`
* **Arquétipo:** Invocação em Massa de Clones / Ilusão Tática `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Manipular a fumaça expelida de seu cachimbo gigante para criar até 216 clones autônomos de fumaça revestidos com aura para enganar o *Gyo/En* inimigo `[CANÔNICO]`.
* **Mecânica no Jogo:** Cria de 1 a 200 entidades com atributos configuráveis (poucos clones fortes com ordens complexas, ou muitos clones fracos para despistar) `[INTERPRETAÇÃO PARA O JOGO]`.
* **Como Aparece no Creator:** *Manipulação de Matéria Emitida* $\rightarrow$ *Divisão de Estatísticas (Quantidade vs. Complexidade de AI)*.

---

### 31. Deep Purple: Smoky Jail (Cadeia de Fumaça Indestrutível)
* **Personagem:** Morel Mackernasey `[CANÔNICO]`
* **Tipo de Nen:** Manipulação + Transmutação `[CANÔNICO]`
* **Arquétipo:** Confinamento / Gaiola Anti-Fuga Absoluta `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Criar um domo hermético de fumaça sólida e ultra-endurecida que prende o usuário e o oponente (como Shaiapouf), tornando o escape físico impossível `[CANÔNICO]`.
* **Condição / Restrição:** Morel não pode desfazer a cadeia sem dissipar toda a fumaça, e ele próprio fica trancado dentro com a ameaça `[CANÔNICO]`.
* **Como Aparece no Creator:** *Barreira de Confinamento Mútuo* $\rightarrow$ *Indestrutibilidade Física em troca de Auto-Enclausuramento*.

---

### 32. Deep Purple: Smoke Rope & Smoke Boat
* **Personagem:** Morel Mackernasey `[CANÔNICO]`
* **Tipo de Nen:** Transmutação / Manipulação `[CANÔNICO]`
* **Arquétipo:** Utilitário de Fumaça Sólida `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Condensar a fumaça em cordas para amarrar inimigos ou em veículos flutuantes para travessia sobre a água `[CANÔNICO]`.

---

### 33. Rising Sun (Sol Ardente do Feitan)
* **Personagem:** Feitan Portor `[CANÔNICO]`
* **Tipo de Nen:** Transmutação (100%) + Conjuração `[CANÔNICO]`
* **Arquétipo:** Contra-Ataque Retaliatório Escalonado por Dor / Conjurador de Calor `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Converter a dor e as feridas sofridas no combate em uma mini-estrela de calor e radiação que incinera tudo em um raio massivo `[CANÔNICO]`.
* **Mecânica Canônica & Fórmula de Dano:**
  $$\text{Temperatura e Raio do Rising Sun} \propto \text{Dano Recebido por Feitan (HP Perdido)}$$
  Se Feitan não sofrer dano real, a habilidade não pode ser ativada `[CANÔNICO]`.
* **Requisito Defensivo (Pain Packer):** Feitan conjura uma armadura protetora térmica (*Pain Packer*) antes do Sol explodir; sem a armadura, ele morreria com o próprio golpe `[CANÔNICO]`.
* **Como Aparece no Creator:** *Ataque Retaliatório* $\rightarrow$ *Gatilho: % de HP Perdido em Combate* $\rightarrow$ *Obrigatoriedade de Conjuração de Traje de Proteção*.

---

### 34. Dragon Head & Dragon Lance
* **Personagem:** Zeno Zoldyck `[CANÔNICO]`
* **Tipo de Nen:** Transmutação (100%) + Emissão `[CANÔNICO]`
* **Arquétipo:** Modelação de Aura Contínua / Controle de Feixe `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Moldar a aura na forma de um dragão chinês que se projeta a partir das mãos de Zeno para perfurar o oponente e controlar o vetor de empurrão `[CANÔNICO]`.
* **Como Aparece no Creator:** *Transmutação de Forma* $\rightarrow$ *Feixe Contínuo com Empurrão*.

---

### 35. Dragon Dive (Chuva de Dragões de Aura)
* **Personagem:** Zeno Zoldyck `[CANÔNICO]`
* **Tipo de Nen:** Emissão (100%) + Transmutação `[CANÔNICO]`
* **Arquétipo:** Bombardeio de Artilharia de Área Ampla `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Fragmentar o dragão de aura gigante em milhares de lanças afiadas que caem do céu como uma tempestade sobre um palácio inteiro `[CANÔNICO]`.
* **Mecânica no Jogo:** *AoE* de saturação em área de 100x100 metros. Alta penetração de estruturas e quebra de tetos/construções `[INTERPRETAÇÃO PARA O JOGO]`.
* **Como Aparece no Creator:** *Emissão de Artilharia* $\rightarrow$ *Chuva Balística Fragmentada*.

---

### 36. Nen Bullets: Aura Burst
* **Personagem:** Silva Zoldyck `[CANÔNICO]`
* **Tipo de Nen:** Transmutação + Emissão `[CANÔNICO]`
* **Arquétipo:** Orbes Gêmeos de Energia Destrutiva `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Criar duas esferas colossais de aura elétrica/cinética nas duas palmas e arremessá-las simultaneamente, vaporizando tudo no epicentro da colisão `[CANÔNICO]`.
* **Como Aparece no Creator:** *Emissão de Alta Densidade* $\rightarrow$ *Esferas Gêmeas com Dano de Aniquilação Central*.

---

### 37. Dowsing Chain (Corrente de Radiestesia)
* **Personagem:** Kurapika `[CANÔNICO]`
* **Tipo de Nen:** Conjuração (100%) `[CANÔNICO]`
* **Arquétipo:** Rastreador / Detector de Mentiras / Defesa Balística `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Uma corrente com uma esfera na ponta usada para defesa de projéteis, localização de alvos em mapas e verificação de afirmações falsas de suspeitos `[CANÔNICO]`.
* **Como Aparece no Creator:** *Conjuração de Detecção* $\rightarrow$ *Verificação de Verdade em Diálogos/Chat + Auto-Parry de Projéteis*.

---

### 38. Holy Chain (Corrente de Cura)
* **Personagem:** Kurapika `[CANÔNICO]`
* **Tipo de Nen:** Conjuração (100%) + Reforço (Apoiado por Emperor Time) `[CANÔNICO]`
* **Arquétipo:** Cura Crítica de Emergência `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Corrente com uma cruz na ponta aplicada sobre fraturas e ossos quebrados para curar instantaneamente ferimentos mortais `[CANÔNICO]`.
* **Como Aparece no Creator:** *Cura Pessoal/Aliada* $\rightarrow$ *Restauração Instantânea de Fraturas de Membros*.

---

### 39. Judgement Chain (Corrente do Julgamento)
* **Personagem:** Kurapika `[CANÔNICO]`
* **Tipo de Nen:** Conjuração + Emissão + Manipulação `[CANÔNICO]`
* **Arquétipo:** Imposição de Voto Remoto / Execução Condicional `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Envolve uma lâmina de corrente ao redor do coração do alvo e estipula 1 ou 2 regras ("Diga a verdade", "Não use Nen"). Se a regra for quebrada, a lâmina esmaga o coração imediatamente, matando o alvo `[CANÔNICO]`.
* **Condição de Uso:** Só pode ser ativada enquanto os Olhos Escarlates estiverem ativos (*Emperor Time*), pois requer Emissão para manter a corrente distante e Manipulação para verificar a regra `[CANÔNICO]`.
* **Como Aparece no Creator:** *Pacto Condicional de Morte* $\rightarrow$ *Trigger de Verificação de Violação de Regra*.

---

### 40. Goretinu's Black & White Goreinu (Gorilas de Emissão)
* **Personagem:** Goreinu `[CANÔNICO]`
* **Tipo de Nen:** Emissão (100%) + Manipulação `[CANÔNICO]`
* **Arquétipo:** Teletransporte por Troca de Posição (Swap Teleport) `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:**
  1. *White Goreinu:* Troca de posição instantaneamente com o próprio Goreinu `[CANÔNICO]`.
  2. *Black Goreinu:* Troca de posição instantaneamente com um inimigo ou alvo selecionado `[CANÔNICO]`.
* **Mecânica de Engine:**
  ```python
  def trigger_black_gorilla_swap(target_enemy, black_gorilla):
      temp_pos = target_enemy.position
      target_enemy.position = black_gorilla.position
      black_gorilla.position = temp_pos
  ```
* **Como Aparece no Creator:** *Emissão de Marionete* $\rightarrow$ *Troca de Posição Vetorial Instantânea*.

---

## 🟣 TIER 3: HATSU COMPLEXOS & DOMÍNIOS (Selamentos, Empréstimos e Espaços Virtuais)

---

### 41. Chain Jail (Prisão Acorrentada da Trupe)
* **Personagem:** Kurapika `[CANÔNICO]`
* **Tipo de Nen:** Conjuração (100%) + Manipulação `[CANÔNICO]`
* **Arquétipo:** Selamento Absoluto / Indução Forçada de Zetsu `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Prender o alvo em correntes indestrutíveis que forçam o estado de *Zetsu*, impedindo completamente a liberação de aura. O alvo só pode contar com força muscular pura para tentar se soltar `[CANÔNICO]`.
* **O Voto & Juramento de Morte (Canonical Vow):**
  * *Condição Absoluta:* Esta corrente **SÓ PODE** ser usada contra membros oficiais do Genei Ryodan (Trupe Fantasma) `[CANÔNICO]`.
  * *Penalidade:* Há uma *Judgement Chain* apontada para o próprio coração de Kurapika. Se ele usar a *Chain Jail* contra qualquer pessoa que não seja uma aranha, seu coração é perfurado instantaneamente (*Permadeath*) `[CANÔNICO]`.
* **Multiplicador Sistêmico:** Multiplicador de $\times 12.0$ na resistência da corrente, tornando impossível até para o membro mais forte fisicamente (Uvogin) quebrar `[INTERPRETAÇÃO PARA O JOGO]`.
* **Como Aparece no Creator:** *Selamento com Tag de Alvo Restrito (`Faction == PhantomBrigade`)* $\rightarrow$ *Juramento com Cláusula de Auto-Eliminação*.

---

### 42. Emperor Time (Tempo do Imperador)
* **Personagem:** Kurapika `[CANÔNICO]`
* **Tipo de Nen:** Especialização (Nativo apenas sob Olhos Escarlates) `[CANÔNICO]`
* **Arquétipo:** Sobrescrita de Afinidade / Eficiência Total (100% em Todas as Categorias) `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Quando seus olhos ficam escarlates, Kurapika passa de Conjurador para Especialista, permitindo que ele utilize 100% de eficácia e maestria em todas as 5 categorias de Nen na sua escala atual de poder `[CANÔNICO]`.
* **Custo Existencial Canônico (Manga Cap 364):**
  $$\text{Custo de Ativação} = 1 \text{ Segundo de Emperor Time} \rightarrow 1 \text{ Hora de Expectativa de Vida Perdida}$$
* **Mecânica no MMORPG:** O jogador ganha 100% de afinidade em todas as habilidades, mas sofre um dreno permanente da vida máxima da conta ou tempo de bloqueio de personagem por exaustão sistêmica `[INTERPRETAÇÃO PARA O JOGO]`.
* **Como Aparece no Creator:** *Especialização de Estado* $\rightarrow$ *Bypass de Afinidade da Roda (All = 100%)* $\rightarrow$ *Dreno de Vida Existencial*.

---

### 43. Hakoware: Bankruptcy Chapter 7 (A.P.R. e I.R.S.)
* **Personagem:** Knuckle Bine `[CANÔNICO]`
* **Tipo de Nen:** Emissão (100%) + Especialização/Manipulação `[CANÔNICO]`
* **Arquétipo:** Empréstimo de Aura / Juros Compostos / Indução de Falência `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Knuckle empresta uma quantia de sua aura ao oponente através de um golpe sem causar dano. O mascote invulnerável *A.P.R. (Amortizing Power Redirector)* se fixa ao alvo e calcula juros de 10% a cada 10 segundos `[CANÔNICO]`.
* **Loop Mecânico Completo de Engine:**
  1. *Ataque Inicial:* `Target.AuraDebt += Knuckle.PunchAOP`. O alvo não sofre dano de HP enquanto tiver dívida `[CANÔNICO]`.
  2. *Contador de Tempo:* A cada 10.0s, se o alvo estiver a menos de 100m de Knuckle:
     $$\text{Target.AuraDebt} = \text{Target.AuraDebt} \times 1.10$$
  3. *Pagamento da Dívida:* O alvo pode bater em Knuckle para devolver aura e abater o valor da dívida `[CANÔNICO]`.
  4. *Falência (Bankruptcy):* Quando `Target.AuraDebt > Target.MOP_Atual`:
     * O *A.P.R.* se transforma em *I.R.S. (Toritaten)*.
     * O alvo entra em **Zetsu Forçado por 30 Dias no Jogo (ou 72 Horas Reais)**, ficando totalmente indefeso `[CANÔNICO]`.
* **Propriedade Especial:** O mascote A.P.R. é uma massa de aura pura inofensiva e invulnerável; nenhum ataque do mundo pode destruí-lo `[CANÔNICO]`.
* **Como Aparece no Creator:** *Sistema de Empréstimo com Juros* $\rightarrow$ *Gatilho de Zetsu Forçado por Superação de MOP*.

---

### 44. Gallery Fake (Cópia Divina de Kortopi)
* **Personagem:** Kortopi `[CANÔNICO]`
* **Tipo de Nen:** Conjuração (100%) `[CANÔNICO]`
* **Arquétipo:** Replicação em Massa de Objetos / Rastreador `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Tocar um objeto com a mão esquerda e conjurar uma cópia exata com a mão direita. Pode replicar prédios inteiros, carros ou artefatos `[CANÔNICO]`.
* **Condições & Limitações Canônicas:**
  1. As cópias desaparecem irremediavelmente após 24 horas `[CANÔNICO]`.
  2. Não pode copiar seres vivos com consciência (pode copiar cadáveres como objetos inanimados) `[CANÔNICO]`.
  3. Toda cópia criada atua como um radar de *En*: se Kortopi tocar no original, ele sabe a localização exata da cópia `[CANÔNICO]`.
* **Como Aparece no Creator:** *Conjuração de Duplicação* $\rightarrow$ *Duração: 24h* $\rightarrow$ *Função de Rastreamento de En Integrada*.

---

### 45. Hide and Seek (Mansão Quadridimensional de Knov)
* **Personagem:** Knov `[CANÔNICO]`
* **Tipo de Nen:** Conjuração (100%) + Emissão (Portais) `[CANÔNICO]`
* **Arquétipo:** Espaço Dimensional Conjurado / Rede de Teletransporte `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Criar uma mansão de 4 andares e 21 salas isolada em outra dimensão, acessível através de portas de Nen desenhadas no chão ou paredes no mundo real `[CANÔNICO]`.
* **Mecânica de Jogo:**
  * Knov coloca marcadores de entrada (`Portal_Entrance`).
  * Aliados podem entrar na sala dimensional para descansar, estocar suprimentos ou cruzar continentes saindo por outro portal conectado `[INTERPRETAÇÃO PARA O JOGO]`.
* **Como Aparece no Creator:** *Espaço Dimensional Instanciado* $\rightarrow$ *Rede de Portais Entrada/Saída*.

---

### 46. Scream (Vácuo Dimensional de Decapitação)
* **Personagem:** Knov `[CANÔNICO]`
* **Tipo de Nen:** Conjuração + Emissão `[CANÔNICO]`
* **Arquétipo:** Corte Espacial / Instakill por Fechamento de Portal `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Knov abre um portal entre as duas mãos envolvendo a cabeça ou corpo do oponente e fecha o portal, enviando a parte do corpo para a outra dimensão e decapitando o alvo instantaneamente, independente de sua armadura de *Ko/Ken* `[CANÔNICO]`.
* **Como Aparece no Creator:** *Portal Ofensivo* $\rightarrow$ *Dano Puro por Separação Espacial*.

---

### 47. Memory Bomb (Tiro de Memórias)
* **Personagem:** Pakunoda `[CANÔNICO]`
* **Tipo de Nen:** Especialização (100%) + Emissão `[CANÔNICO]`
* **Arquétipo:** Extração e Transmissão de Memória / Leitura de Dados `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:**
  1. *Extração:* Tocar em uma pessoa e fazer uma pergunta para ler as memórias puras do inconsciente imediato `[CANÔNICO]`.
  2. *Transmissão:* Conjurar um revólver e balas de Nen contendo as memórias extraídas. Ao atirar nos aliados, transfere as memórias instantaneamente sem causar dano físico `[CANÔNICO]`.
  3. *Punição:* Se ela atirar em alguém com as próprias memórias daquela pessoa, apaga a memória da vítima `[CANÔNICO]`.
* **Como Aparece no Creator:** *Especialização de Informação* $\rightarrow$ *Projétil de Compartilhamento de Conhecimento/Logs*.

---

### 48. Hotel Rafflesia (Gaiola das 30 Partes)
* **Personagem:** Shoot McMahon `[CANÔNICO]`
* **Tipo de Nen:** Manipulação (100%) + Conjuração `[CANÔNICO]`
* **Arquétipo:** Selamento Gradual por Fragmentação Espacial `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Shoot controla 3 mãos voadoras desencarnadas e uma gaiola flutuante. Ao atingir o oponente com as mãos, ele não causa dano de sangue, mas sela partes do corpo do alvo (um olho, um braço, o torso) dentro da gaiola `[CANÔNICO]`.
* **Como Aparece no Creator:** *Manipulação Espacial Gradual* $\rightarrow$ *Debuff de Desmembramento Provisório*.

---

### 49. Order Stamp (Selo de Controle de Bonecos)
* **Personagem:** Chrollo Lucilfer (Original desconhecido) `[CANÔNICO]`
* **Tipo de Nen:** Manipulação (100%) + Conjuração `[CANÔNICO]`
* **Arquétipo:** Manipulação em Massa por Carimbo `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Carimbar a testa de bonecos, manequins ou cadáveres com um selo mágico para comandá-los através de ordens verbais simples ("Destruam aquele homem", "Segurem o alvo") `[CANÔNICO]`.
* **Condições Canônicas:** Não funciona em corpos humanos vivos; apenas em cópias inanimadas ou cadáveres `[CANÔNICO]`.

---

### 50. Sun and Moon (Marcadores de Bomba de Ryuudou)
* **Personagem:** Chrollo Lucilfer (Ancião de Meteor City) `[CANÔNICO]`
* **Tipo de Nen:** Especialização / Conjuração (Nen Póstumo) `[CANÔNICO]`
* **Arquétipo:** Marcadores de Explosão por Contato `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Tocar com a mão esquerda grava a marca do Sol (+); tocar com a mão direita grava a marca da Lua (-). Quando as duas marcas se tocam, detonam uma explosão catastrófica `[CANÔNICO]`.
* **Propriedade Póstuma Canônica:** Como o criador original morreu, o Nen se tornou eterno dentro da *Skill Hunter*: as marcas nunca desaparecem até explodirem, mesmo que o livro seja fechado `[CANÔNICO]`.
* **Como Aparece no Creator:** *Marcador Polar (+/-)* $\rightarrow$ *Detonação por Proximidade* $\rightarrow$ *Persistência Pós-Morte*.

---

### 51. Convert Hands (Troca de Aparência por Toque)
* **Personagem:** Chrollo Lucilfer (Original desconhecido) `[CANÔNICO]`
* **Tipo de Nen:** Manipulação / Conjuração `[CANÔNICO]`
* **Arquétipo:** Troca de Identidade / Roubo de Skin e Modelo `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Tocar alguém com a mão direita faz a pessoa assumir a aparência de Chrollo; tocar com a mão esquerda faz Chrollo assumir a aparência da pessoa. Tocar com ambas troca a aparência de ambos `[CANÔNICO]`.

---

### 52. Lovely Ghostwriter (Poemas da Morte de Neon)
* **Personagem:** Neon Nostrade `[CANÔNICO]`
* **Tipo de Nen:** Especialização (100%) `[CANÔNICO]`
* **Arquétipo:** Previsão Futura / Consulta a Banco de Eventos `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Um pequeno monstro de aura guia o braço do usuário em escrita automática para criar um poema profético de 4 ou 5 estrofes detalhando eventos terríveis que ocorrerão no mês `[CANÔNICO]`.
* **Condições Críticas Canônicas:**
  1. O usuário não pode ler as próprias profecias nem prever o próprio futuro `[CANÔNICO]`.
  2. Requer nome completo, data de nascimento e tipo sanguíneo do alvo `[CANÔNICO]`.
* **Como Aparece no Creator:** *Especialização Oracular* $\rightarrow$ *Geração de Poema de Alerta de Eventos do Servidor*.

---

### 53. Terpsichora (Marionete de Batalha Monstruosa)
* **Personagem:** Neferpitou `[CANÔNICO]`
* **Tipo de Nen:** Especialização (100%) + Manipulação `[CANÔNICO]`
* **Arquétipo:** Auto-Manipulação de Combate Biomecânico `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Conjura uma bailarina monstruosa de cordas que manipula as articulações e músculos de Pitou para ultrapassar os limites físicos de velocidade e reflexo em saltos de menos de 0.1 segundo `[CANÔNICO]`.
* **Ativação Póstuma Canônica:** Após a cabeça de Pitou ser esmagada por Gon Adulto, o rancor extremo ativou o *Terpsichora* pós-morte, manipulando o cadáver decapitado para decepar o braço de Gon `[CANÔNICO]`.
* **Como Aparece no Creator:** *Auto-Manipulação de Super-Buff* $\rightarrow$ *Gatilho de Continuação Zumbi Pós-Morte*.

---

### 54. Dr. Blythe (Cirurgiã de Reconstrução Biológica)
* **Personagem:** Neferpitou `[CANÔNICO]`
* **Tipo de Nen:** Especialização + Conjuração `[CANÔNICO]`
* **Arquétipo:** Cura Cirúrgica Avançada / Ponto de Ancoragem Fixo `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Conjura uma boneca médica gigante com instrumental cirúrgico para suturar cérebros, reconstruir membros decepados e parar hemorragias mortais `[CANÔNICO]`.
* **Condições Canônicas Severas:**
  1. A boneca fica fixada no espaço físico no ponto onde foi conjurada; não pode se mover nem 1 centímetro `[CANÔNICO]`.
  2. Pitou não pode usar *En* nem outras habilidades de combate enquanto o Dr. Blythe estiver operando, ficando em Zetsu parcial defensivo `[CANÔNICO]`.
* **Como Aparece no Creator:** *Conjuração Cirúrgica* $\rightarrow$ *Ancoragem Espacial Fixa + Desativação de Outras Habilidades*.

---

### 55. Spiritual Message (Escamas de Borboleta e Leitura Mental)
* **Personagem:** Shaiapouf `[CANÔNICO]`
* **Tipo de Nen:** Manipulação (100%) + Especialização `[CANÔNICO]`
* **Arquétipo:** Leitura Emocional por Escamas / Hipnose em Massa `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Espalhar pólen brilhante de suas asas. Ao entrar em contato com a aura dos alvos, Pouf lê as emoções, mentiras e psicologia do adversário, além de colocar multidões inteiras sob transe hipnótico `[CANÔNICO]`.

---

### 56. Beelzebub (Divisão Celular de Minúsculos Clones)
* **Personagem:** Shaiapouf `[CANÔNICO]`
* **Tipo de Nen:** Manipulação (100%) + Especialização `[CANÔNICO]`
* **Arquétipo:** Fragmentação Corporal / Imunidade a Dano Físico `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Dividir o próprio corpo em milhões de clones microscópicos do tamanho de células. Seus clones podem voar, espionar, infiltrar ou se reconstruir em tamanhos humanos `[CANÔNICO]`.
* **Condição:** O núcleo principal com o tamanho de uma abelha precisa permanecer intacto `[CANÔNICO]`.
* **Como Aparece no Creator:** *Manipulação Celular* $\rightarrow$ *Imunidade a Dano Cortante/Perfurante por Divisão*.

---

### 57. Rage Incarnate / Metamorphosis (Transformação de Fúria de Youpi)
* **Personagem:** Menthuthuyoupi `[CANÔNICO]`
* **Tipo de Nen:** Transmutação / Reforço (Apoiado por Biologia de Besta Mágica) `[CANÔNICO]`
* **Arquétipo:** Metamorfose Biológica Dinâmica / Canhão de Fúria `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Moldar livremente a carne e a aura, criando braços extras, asas, tentáculos, dezenas de olhos ou transformando os braços em canhões de pura explosão de raiva comprimida `[CANÔNICO]`.
* **Como Aparece no Creator:** *Transformação Morfológica* $\rightarrow$ *Geração de Membros Extras e Armas Orgânicas*.

---

### 58. 100-Type Guanyin Bodhisattva: Primeira Palma a Nonagésima Nona Palma
* **Personagem:** Isaac Netero `[CANÔNICO]`
* **Tipo de Nen:** Emissão (100%) + Manipulação + Reforço `[CANÔNICO]`
* **Arquétipo:** Invocação Gigante / Ataque por Reconhecimento de Gesto `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Invoca uma estátua colossal de ouro de Guanyin. Cada movimento de ataque é precedido por um gesto de oração com as mãos feito por Netero a uma velocidade que supera a velocidade do som `[CANÔNICO]`.
* **Mecânica de Engine:**
  ```
  [Input: Gesto de Oração (0.01s)] -> [Spawn: Golpe da Palma Selecionada da Estátua]
  Velocidade de Frame: Início no Frame 1 (Prioridade Absoluta sobre Qualquer Ataque)
  ```
* **Como Aparece no Creator:** *Conjuração/Emissão Titânica* $\rightarrow$ *Gatilho de Oração Pré-Ataque com Velocidade Supersônica*.

---

### 59. 100-Type Guanyin Bodhisattva: Zero Hand (Mão Zero)
* **Personagem:** Isaac Netero `[CANÔNICO]`
* **Tipo de Nen:** Emissão (100%) `[CANÔNICO]`
* **Arquétipo:** Disparo Final de Esvaziamento de MOP `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** A estátua surge pelas costas do oponente, prendendo-o em um abraço misericordioso, enquanto Netero vomita todo o restante absoluto de seu MOP através da boca da estátua em um laser de aniquilação contínua `[CANÔNICO]`.
* **Efeito Pós-Uso:** Consome 100% da barra de MOP de Netero e envelhece o corpo drasticamente, deixando-o à beira da morte `[CANÔNICO]`.
* **Como Aparece no Creator:** *Ataque Final Absoluto* $\rightarrow$ *Consumo Total de MOP $\rightarrow$ Zetsu Imediato*.

---

### 60. Photon (Leitura de Matéria por Fótons de Nen)
* **Personagem:** Meruem (Pós-Rosa) `[CANÔNICO]`
* **Tipo de Nen:** Transmutação + Emissão (Especialização) `[CANÔNICO]`
* **Arquétipo:** En Quântico / Leitura Total de Vetores de Informação `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Meruem transforma sua aura em fótons de luz que se espalham por quilômetros instantaneamente na velocidade da luz. Qualquer coisa tocada pelos fótons revela sua forma, peso, estado emocional e localização exata `[CANÔNICO]`.
* **Como Aparece no Creator:** *En Perfeito de Fótons* $\rightarrow$ *Revelação Instantânea de Toda a Malha de Jogadores no Mapa*.

---

## 🔴 TIER 4: HATSU EXTREMAMENTE COMPLEXOS (Roubo, Especialistas e Nen Parasítico)

---

### 61. Skill Hunter (O Segredo do Bandido)
* **Personagem:** Chrollo Lucilfer `[CANÔNICO]`
* **Tipo de Nen:** Especialização (100%) `[CANÔNICO]`
* **Arquétipo:** `Ability Theft` + `Ability Storage` `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Roubar o Hatsu original de outros usuários de Nen e guardá-los em um livro conjurado (*Bandit's Secret*), privando a vítima do uso da habilidade para sempre `[CANÔNICO]`.
* **Não Perguntar no Creator:** "Qual o dano?", "É projétil?". O Hatsu é um sistema operacional de roubo e inventário de habilidades `[INTERPRETAÇÃO PARA O JOGO]`.
* **As 4 Condições Estritas de Roubo Canônicas:**
  1. Chrollo deve testemunhar a habilidade do alvo com os próprios olhos `[CANÔNICO]`.
  2. Chrollo deve fazer perguntas sobre o funcionamento do Hatsu e obter a resposta do alvo `[CANÔNICO]`.
  3. A palma da mão do alvo deve tocar na impressão da capa do livro *Bandit's Secret* `[CANÔNICO]`.
  4. Todas as 3 condições acima devem ser executadas dentro de uma janela de **1 hora** `[CANÔNICO]`.
* **Regra de Execução:** Para usar a habilidade roubada, o livro deve ser conjurado e mantido aberto na página correspondente na mão direita (restringindo o combate com a mão livre) `[CANÔNICO]`.
* **Fluxo no Sistema do MMORPG:**
  ```
  Target.HatsuDefinition
          ↓
  AbilityAcquisitionSystem (Valida 4 Condições)
          ↓
  Target.HatsuAbilities.Remove(HatsuID)  [Vítima perde a skill]
          ↓
  StoredHatsu (Criado com os metadados originais)
          ↓
  Player.HatsuInventory.Add(StoredHatsu)
          ↓
  SkillHunterUI (Livro de Páginas Selecionáveis)
  ```
* **Extensão Canônica: O Marcador de Página (Double Face):** Um marcador de livro que permite usar uma habilidade mantendo o livro fechado (duas mãos livres) ou usar **duas habilidades roubadas simultaneamente** ao abrir em outra página `[CANÔNICO]`.
* **Como Aparece no Creator:** *Especialização: Ability Theft* $\rightarrow$ *Configuração de Matriz de Condições de Aquisição* $\rightarrow$ *Interface de Livro de Inventário*.

---

### 62. Steal Chain & Stealth Dolphin
* **Personagem:** Kurapika `[CANÔNICO]`
* **Tipo de Nen:** Conjuração (100%) + Especialização (via Dolphin) `[CANÔNICO]`
* **Arquétipo:** Drenagem de Aura / Roubo Temporário / Empréstimo de Hatsu `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Uma corrente com uma seringa na ponta que é cravada no inimigo.
  1. *Fase 1 (Dreno):* Suga a aura do alvo continuamente, forçando o estado de *Zetsu* temporário no inimigo enquanto drena `[CANÔNICO]`.
  2. *Fase 2 (Extração):* Extrai uma habilidade de Hatsu da vítima `[CANÔNICO]`.
  3. *Fase 3 (Stealth Dolphin):* Conjura um golfinho mecânico invisível para os outros que analisa o Hatsu roubado, explica como funciona para Kurapika e permite que ele use a técnica 1 vez ou transfira o uso único para um aliado sem Nen `[CANÔNICO]`.
* **Condição de Saída:** O *Stealth Dolphin* só desaparece após o Hatsu roubado ser totalmente disparado e utilizado `[CANÔNICO]`.
* **Como Aparece no Creator:** *Drenagem por Seringa* $\rightarrow$ *Roubo de Uso Único* $\rightarrow$ *Análise por Mascote Guia*.

---

### 63. Parallel World / Cat's Name (Ressurreição da Gata de Camilla)
* **Personagem:** Camilla Hui Guo Rou `[CANÔNICO]`
* **Tipo de Nen:** Especialização (Nen Póstumo) `[CANÔNICO]`
* **Arquétipo:** Contra-Ataque Póstumo / Ressurreição por Sacrifício do Assassino `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Quando Camilla é assassinada e seu coração para, uma gata espectral gigante de Nen surge sobre o cadáver, esmaga o assassino com as patas, drena toda a força vital e aura do agressor e injeta no corpo de Camilla, ressuscitando-a completamente `[CANÔNICO]`.
* **Condição / Restrição Canônica:**
  * Camilla **PRECISA MORRER** pelas mãos de um agressor para a habilidade disparar `[CANÔNICO]`.
  * Ela se coloca deliberadamente em *Zetsu* antes do combate para garantir que levará um golpe fatal `[CANÔNICO]`.
* **Como Aparece no Creator:** *Trigger OnDeath* $\rightarrow$ *Instakill no Atacante + Dreno Vital $\rightarrow$ Revive 100%*.

---

### 64. Predator (Besta Predadora de Nen de Rihan)
* **Personagem:** Rihan `[CANÔNICO]`
* **Tipo de Nen:** Conjuração (100%) + Especialização `[CANÔNICO]`
* **Arquétipo:** Invocação de Predador Adaptativo / Neutralizador de Hatsu Específico `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Conjura um parasita predador dentro do próprio corpo que é cultivado para se alimentar exclusivamente de um Hatsu inimigo específico e devorar o alvo `[CANÔNICO]`.
* **Condições Complexas de Criação Canônicas:**
  1. Rihan deve passar dias observando o alvo em silêncio sem atacar, deduzindo corretamente todas as regras e funções do Hatsu da vítima `[CANÔNICO]`.
  2. Quanto mais precisa e correta for a dedução de Rihan, mais forte e letal nasce a besta predadora `[CANÔNICO]`.
  3. Se ele errar a dedução sobre como o Hatsu funciona, o Predador nasce fraco ou morre, e Rihan fica impedido de usar a técnica por um longo período `[CANÔNICO]`.
* **Como Aparece no Creator:** *Conjuração Adaptativa* $\rightarrow$ *Minigame de Análise de Padrão do Inimigo* $\rightarrow$ *Multiplicador por Precisão de Dedução*.

---

### 65. Aura Synthesis (Canibalismo de Nen do Rei Meruem)
* **Personagem:** Meruem `[CANÔNICO]`
* **Tipo de Nen:** Especialização (100%) `[CANÔNICO]`
* **Arquétipo:** Absorção Permanente de MOP e Hatsu por Consumo Orgânico `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Ao devorar corpos de outros usuários de Nen, Meruem sintetiza a aura da vítima dentro de si, aumentando permanentemente seu próprio MOP e incorporando os Hatsus da vítima de forma aprimorada (como fez com Youpi e Pouf) `[CANÔNICO]`.
* **Como Aparece no Creator:** *Mecânica de Boss / Sistema de Absorção Permanente de Status*.

---

### 66. Wish Granting / Co-dependence (Hatsu de Desejos de Nanika/Alluka)
* **Personagem:** Nanika (Entidade do Continente Negro) `[CANÔNICO]`
* **Tipo de Nen:** Especialização Desconhecida / Poder do Continente Negro `[CANÔNICO]`
* **Arquétipo:** Alteração da Realidade por Ciclo de Pedidos Equivalentes `[INTERPRETAÇÃO PARA O JOGO]`
* **Função Principal:** Concede qualquer desejo no universo, desde curar o incurável até explodir milionários em dinheiro. Em troca, exige 3 pedidos subsequentes de valor e crueldade proporcionais ao próximo humano que falar com ela `[CANÔNICO]`.
* **Mecânica Sistêmica:**
  ```
  [Executa Desejo Tier X] -> [Gera 3 Requisições de Dificuldade Tier X+1 para o Próximo Jogador]
  Se o próximo recusar 4 vezes -> Morte Imediata do Jogador + Morte de Todos os seus Amigos de Faction
  ```
* **Como Aparece no Creator:** *Sistema Global de Evento de Mundo / Risco Cósmico Compartilhado*.

---

# PARTE 4 — GUIA DE IMPLEMENTAÇÃO NO HATSU CREATOR (PIPELINE DO ENGINE)

Ao inicializar uma sessão de design com um jogador, o *Agent* de IA deve guiar a criação através do seguinte fluxo rigoroso de 6 passos:

```
[ PASSO 1: SELEÇÃO DE AFINIDADE NATIVA ]
    └─ Reforço / Transmutação / Emissão / Conjuração / Manipulação / Especialização
          ↓
[ PASSO 2: ESCOLHA DO ARQUÉTIPO ESTRUTURAL (Parte 2) ]
    └─ Stance / Projétil / Transmutação / Roubo / Mascote / Selamento / etc.
          ↓
[ PASSO 3: DEFINIÇÃO DE VARIÁVEIS BASE (Consumo de CP / Memory Load) ]
    └─ Funções Primárias e Secundárias dentro do limite de complexidade do personagem.
          ↓
[ PASSO 4: SISTEMA DE CONDIÇÕES & RESTRIÇÕES (Créditos de Poder) ]
    └─ Inserção de gatilhos operacionais para reduzir custo de MOP ou amplificar AOP.
          ↓
[ PASSO 5: APLICAÇÃO DE JURAMENTOS & PUNIÇÕES (Opcional - High Risk) ]
    └─ Cláusulas de Permadeath, Zetsu Permanente ou Auto-Dano para multiplicadores gigantes.
          ↓
[ PASSO 6: VALIDAÇÃO DE BALANCEAMENTO & GERAÇÃO DE METADADOS ]
    └─ Compilação do objeto 'HatsuDefinition' no formato JSON do servidor.
```

### Exemplo de Objeto Compilado (`HatsuDefinition` JSON)

```json
{
  "hatsu_id": "hatsu_bungee_gum_custom_09",
  "name": "Elastic Bio-Web",
  "creator_id": "player_luiz_01",
  "primary_affinity": "TRANSMUTATION",
  "archetype": "AURA_PROPERTY_MANIPULATION",
  "memory_load_cost_cp": 45,
  "base_stats": {
    "mop_activation_cost": 120,
    "mop_drain_per_second": 8.5,
    "tensile_strength_coefficient": 850.0,
    "max_stretch_distance_meters": 35.0,
    "adhesion_type": "SURFACE_AND_ENTITY"
  },
  "conditions": [
    {
      "trigger_type": "PHYSICAL_TOUCH",
      "description": "Must touch target with palm or weapon imbued with Shu",
      "power_multiplier_bonus": 0.35
    }
  ],
  "restrictions": [
    {
      "restriction_type": "INVISIBILITY_UNDER_IN",
      "description": "Aura properties only hidden if user maintains active 'In'",
      "memory_load_modifier": -10
    }
  ],
  "vow": null,
  "validation_status": "APPROVED"
}
```

---
**Fim da Hatsu System Design Bible.**
