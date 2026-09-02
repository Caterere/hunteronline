# HUNTER X HUNTER — CANON LORE & HATSU ENCYCLOPEDIA (COMPÊNDIO GERAL)

Este compêndio reúne a decomposição de habilidades e mecânicas canônicas de Hunter x Hunter, estruturadas diretamente para o consumo do agente de IA e integração com a arquitetura do jogo (`CombatEngine`, `PlayerData`, `NenSystem`, `GameplayTags`, `GameplayCondition`, `StatModifier` e `SaveManager`). Identificadores marcados como **[PLANEJADA]** são referências de design e ainda não estão implementados em `GameplayCondition`.

---

## 1. REGRAS DE CONVERSÃO CANÔNICA PARA SISTEMA DE JOGO

Ao implementar qualquer habilidade descrita neste documento:
1. **Afinidade & Eficiência**: Respeite o hexágono de afinidade. Componentes fora da afinidade primária sofrem penalidade de eficácia (80%, 60%, 40%) e custo aumentado de aura.
2. **Tags Canônicas (`GameplayTags`)**: Use identificadores normalizados em `snake_case` (ex: `offensive`, `projectile`, `melee`, `control`, `utility`, `buff`, `debuff`, `summon`, `binding`, `tether`, `counter`, `transmutation`, `emission`, `enhancement`, `conjuration`, `manipulation`, `specialization`).
3. **Condições (`GameplayCondition`)**: Habilidades complexas ou com Juramentos/Limitações exigem verificação de contexto. `target_marked` e `player_hp_percent` são suportadas; `target_in_en`, `aura_threshold`, `charge_time`, `target_faction` e `vow_active` são **[PLANEJADAS]**.
4. **Modificadores Passivos/Buffs (`StatModifier`)**: Nenhum buff deve alterar diretamente os atributos base de `PlayerData`. Crie instâncias de `StatModifier` com tipos e valores adequados.
5. **Custo e Limite de Liberação**: Habilidades de grande impacto consomem aura respeitando o AOP (Actual Output Power / teto instantâneo de liberação de aura).

---

## 2. PROTAGONISTAS & PERSONAGENS PRINCIPAIS

### 2.1 Gon Freecss
- **Afinidade Primária**: Reforço (100%)
- **Habilidades / Hatsu**:
  - **Jajanken: Rock (Guu)**
    - *Afinidade*: Reforço (100%)
    - *Tags*: `["offensive", "melee", "charge", "high_risk", "ko", "enhancement"]`
    - *Mecânica*: Concentra uma quantidade extrema de AOP no punho via Ko. Requer tempo de carregamento estático enquanto entoa o lema ("First comes rock...").
    - *GameplayCondition [PLANEJADA]*: `player_charging`, `target_in_melee_range`.
    - *Risco/Compensação*: Durante a canalização, a defesa do corpo cai severamente (vulnerabilidade a contra-ataques). Dano massivo no impacto.
  - **Jajanken: Scissors (Chii)**
    - *Afinidade*: Transmutação (80% de eficiência)
    - *Tags*: `["offensive", "melee", "slashing", "transmutation"]`
    - *Mecânica*: Transmuta a aura estendida pelos dedos indicador e médio em lâminas afiadas.
    - *Efeito*: Dano cortante em cone frontal de curto alcance; menor dano de impacto bruto que o Rock, mas com chance de sangramento/crítico.
  - **Jajanken: Paper (Paa)**
    - *Afinidade*: Emissão (80% de eficiência)
    - *Tags*: `["offensive", "projectile", "ranged", "emission"]`
    - *Mecânica*: Projeta uma esfera esférica de aura concentrada contra o alvo.
    - *Efeito*: Ataque à distância de velocidade média. Causa dano contundente moderado.

### 2.2 Killua Zoldyck
- **Afinidade Primária**: Transmutação (100%)
- **Habilidades / Hatsu**:
  - **Lightning Palm (Izutsushi)**
    - *Afinidade*: Transmutação (100%) + Emissão (60%)
    - *Tags*: `["offensive", "melee", "stun", "electric", "transmutation"]`
    - *Mecânica*: Descarrega alta voltagem pelas palmas das mãos ao tocar o alvo.
    - *Efeito*: Causa dano elétrico moderado e aplica breve atordoamento (`stun`) ou paralisia muscular.
  - **Thunderbolt (Narukami)**
    - *Afinidade*: Transmutação (100%) + Emissão (60%)
    - *Tags*: `["offensive", "ranged", "projectile", "electric", "burst"]`
    - *Mecânica*: Dispara um raio concentrado de eletricidade a partir do ar ou à distância.
    - *Efeito*: Dano perfurante elétrico rápido e atordoamento prolongado.
  - **Godspeed: Speed of Lightning (Kanmuru: Denkou Sekka)**
    - *Afinidade*: Transmutação (100%) + Reforço (80%)
    - *Tags*: `["buff", "transformation", "speed", "mobility"]`
    - *Mecânica*: Transmuta aura em impulsos elétricos que percorrem os nervos, controlando o corpo conscientemente em velocidade sobre-humana.
    - *Efeito*: Adiciona `StatModifier` extremo de velocidade de movimento e esquiva passiva. Drena aura continuamente e requer recarga periódica de eletricidade.
  - **Godspeed: Whirlwind (Kanmuru: Shippu Jinrai)**
    - *Afinidade*: Transmutação (100%) + Manipulação (40%)
    - *Tags*: `["buff", "counter", "reflex", "defensive"]`
    - *Mecânica*: O corpo reage diretamente aos estímulos de aura do inimigo sem passar pelo processamento cerebral.
    - *Efeito*: Esquiva ou contra-ataque automático contra o primeiro golpe que entrar no raio de detecção.

### 2.3 Kurapika
- **Afinidade Primária**: Conjuração (100%) / Especialização (100% sob Scarlet Eyes)
- **Habilidades / Hatsu**:
  - **Emperor Time (Olhos Escarlates)**
    - *Afinidade*: Especialização (100%)
    - *Tags*: `["buff", "specialization", "high_risk", "emperor_time"]`
    - *Mecânica*: Permite usar 100% de eficiência e maestria máxima em todas as categorias de Nen.
    - *Condição & Risco*: Cada segundo ativo drena 1 hora do tempo de vida do usuário. No jogo, gera debuff cumulativo de fadiga e dreno contínuo de HP/Aura.
  - **Holy Chain (Polegar)**
    - *Afinidade*: Conjuração (100%) + Reforço (100% via Emperor Time, senão 60%)
    - *Tags*: `["heal", "support", "recovery", "enhancement"]`
    - *Mecânica*: Corrente com terminação em cruz que acelera drasticamente a regeneração celular natural.
    - *Efeito*: Cura rápida de HP próprio ou de aliados.
  - **Chain Jail (Dedo Médio)**
    - *Afinidade*: Conjuração (100%) + Manipulação (60% / 100% via Emperor Time)
    - *Tags*: `["control", "single_target", "binding", "vow_restricted"]`
    - *Juramento Absoluto*: SÓ PODE SER USADA CONTRA MEMBROS DO PHANTOM TROUPE (Genei Ryodan).
    - *GameplayCondition [PLANEJADA]*: `target_has_tag: phantom_troupe`. Se violada, ativa `kill_player`.
    - *Efeito*: Prende o alvo indefensavelmente e força-o ao estado de Zetsu absoluto (aura cai para 0).
  - **Dowsing Chain (Dedo Anelar)**
    - *Afinidade*: Conjuração (100%)
    - *Tags*: `["utility", "detection", "ranged", "guidance"]`
    - *Mecânica*: Corrente com pêndulo metálico sensível à mentira, presenças ocultas e rastreamento.
    - *Efeito*: Revela inimigos camuflados/em In e aumenta a precisão de projéteis.
  - **Judgement Chain (Dedo Mindinho)**
    - *Afinidade*: Conjuração (100%) + Emissão (100% via Emperor Time) + Manipulação (100% via Emperor Time)
    - *Tags*: `["curse", "execution", "rule_based"]`
    - *Mecânica*: Insere uma lâmina de corrente no coração do alvo e impõe uma ou mais regras/condições.
    - *Efeito*: Se o alvo violar a regra estipulada, a lâmina esmaga seu coração causando morte instantânea.
  - **Steal Chain & Stealth Dolphin (Dedo Indicador)**
    - *Afinidade*: Conjuração (100%) + Especialização
    - *Tags*: `["utility", "ability_theft", "drain", "synergy"]`
    - *Mecânica*: Corrente com seringa que drena a aura do alvo e extrai temporariamente seu Hatsu.
    - *Efeito*: O alvo entra em Zetsu temporário. O Stealth Dolphin materializado analisa a habilidade e permite usá-la uma única vez ou transferi-la para um aliado.

### 2.4 Leorio Paradinight
- **Afinidade Primária**: Emissão (100%)
- **Habilidades / Hatsu**:
  - **Remote Punch (Soco Remoto)**
    - *Afinidade*: Emissão (100%) + Transmutação/Reforço
    - *Tags*: `["offensive", "ranged", "surprise", "portal_strike"]`
    - *Mecânica*: Golpela uma superfície com o punho, transmitindo a aura pelo solo ou parede para que ela emerja através de um portal de aura diretamente sob o queixo ou corpo do inimigo distante.
    - *Efeito*: Dano de concussão à distância que ignora obstáculos físicos diretos entre o atacante e o alvo.
  - **Ultrasound Echo (Varredura Ultrassônica)**
    - *Afinidade*: Emissão (100%)
    - *Tags*: `["utility", "detection", "sonar"]`
    - *Mecânica*: Emite pulsos microscópicos de aura semelhantes a ultrassom através de superfícies para mapear tumores, anomalias ou inimigos ocultos em paredes.
    - *Efeito*: Revela contornos de salas adjacentes e alvos em stealth no mini-mapa.

---

## 3. TRUPE FANTASMA (GENEI RYODAN)

### 3.1 Chrollo Lucilfer
- **Afinidade Primária**: Especialização (100%)
- **Habilidades / Hatsu**:
  - **Skill Hunter: Bandit's Secret**
    - *Afinidade*: Especialização (100%)
    - *Tags*: `["ability_theft", "utility", "specialization", "grimoire"]`
    - *Mecânica*: Rouba habilidades de Nen alheias e as armazena em um grimório conjurado.
    - *Condições Estritas de Roubo*:
      1. Ver a habilidade em ação com os próprios olhos.
      2. Fazer perguntas sobre a habilidade e obter resposta do usuário.
      3. A mão da vítima deve tocar a impressão digital na capa do livro.
      4. As etapas anteriores devem ocorrer dentro do prazo de 1 hora.
    - *Efeito no Jogo*: Permite equipar e invocar Hatsu roubados de chefes/NPCs específicos, consumindo aura mantendo o livro aberto em uma das mãos.
  - **Double Face (Marcador de Página)**
    - *Mecânica*: Um marcador que permite manter ativada uma habilidade mesmo com o livro fechado, ou usar duas habilidades roubadas simultaneamente.
  - **Indoor Fish (Peixes do Quarto)**
    - *Afinidade*: Conjuração (100%) + Manipulação
    - *Tags*: `["offensive", "summon", "drain", "room_bound"]`
    - *Condição*: Só sobrevive em recintos totalmente selados e fechados hermeticamente.
    - *Efeito*: Peixes esqueléticos que devoram a carne do inimigo sem causar dor ou perda de sangue. Quando o quarto é aberto, o dano acumulado manifesta-se instantaneamente, resultando na morte do alvo.
  - **Fun Fun Cloth (Pano de Encolhimento - Roubada de Owl)**
    - *Afinidade*: Conjuração (100%) + Manipulação
    - *Tags*: `["control", "capture", "utility"]`
    - *Efeito*: Tecido conjurado que encolhe tudo o que envolve, permitindo capturar inimigos inteiros ou armazenar itens volumosos.
  - **Sun and Moon (Sol e Lua - Roubada dos Anciãos de Meteor City)**
    - *Tags*: `["offensive", "mark", "explosive", "delayed_burst"]`
    - *Mecânica*: Aplica uma marca solar (mão esquerda) e uma marca lunar (mão direita). Quando as marcas se tocam, detonam uma explosão violenta proporcional ao tempo de contato.

### 3.2 Hisoka Morow
- **Afinidade Primária**: Transmutação (100%)
- **Habilidades / Hatsu**:
  - **Bungee Gum (Goma Elástica)**
    - *Afinidade*: Transmutação (100%)
    - *Tags*: `["utility", "control", "tether", "mobility", "projectile"]`
    - *Mecânica*: Concede à aura propriedades combinadas de chiclete (adesão total) e borracha (elasticidade extrema).
    - *Efeito*: Puxa inimigos, rebate projéteis balísticos, arremessa o próprio usuário em alta velocidade ou prende os membros do adversário ao solo.
  - **Texture Surprise (Textura Surpresa)**
    - *Afinidade*: Conjuração (100%) + Transmutação
    - *Tags*: `["utility", "illusion", "camouflage", "deception"]`
    - *Mecânica*: Aplica uma fina camada de aura sobre qualquer superfície plana reproduzindo fielmente texturas visuais e táteis (pele falsa, ferimentos maquiados, cartas falsas).
    - *Efeito*: Engana a interface de percepção do inimigo até que este utilize Gyo para detectar a aura subjacente.

### 3.3 Uvogin
- **Afinidade Primária**: Reforço (100%)
- **Habilidades / Hatsu**:
  - **Big Bang Impact (Impacto Big Bang)**
    - *Afinidade*: Reforço (100%)
    - *Tags*: `["offensive", "melee", "aoe", "burst", "ko"]`
    - *Mecânica*: Concentra toda a reserva de AOP no punho direito e golpeia com a força equivalente a um míssil antitanque.
    - *Efeito*: Dano físico maciço com onda de choque em área que destrói o terreno e atordoa alvos adjacentes.
  - **Superhuman Roar (Rugido Sônico)**
    - *Afinidade*: Reforço (100%) + Emissão
    - *Tags*: `["offensive", "aoe", "debuff", "disruption"]`
    - *Mecânica*: Amplifica as cordas vocais com aura, gerando uma onda sônica ensurdecedora em cone frontal.
    - *Efeito*: Rompe tímpanos, causa confusão/desorientação e anula canalizações mágicas.

### 3.4 Feitan Portor
- **Afinidade Primária**: Transmutação (100%) + Conjuração
- **Habilidades / Hatsu**:
  - **Pain Packer (Embalador de Dor)**
    - *Afinidade*: Conjuração (100%)
    - *Tags*: `["armor", "counter", "revenge_gauge", "defensive"]`
    - *Mecânica*: Conjura uma armadura protetora pesada em resposta à raiva e aos ferimentos recebidos em batalha.
    - *GameplayCondition [PLANEJADA]*: `damage_received_threshold`.
  - **Rising Sun (Sol Nascente)**
    - *Afinidade*: Transmutação (100%) + Emissão
    - *Tags*: `["offensive", "aoe", "fire", "heat", "burst"]`
    - *Mecânica*: Transmuta toda a dor acumulada em uma esfera de calor extremo e fogo incandescente que incinera uma vasta área circular.
    - *Escalonamento*: O dano é diretamente proporcional à perda de HP sofrida por Feitan na luta.

### 3.5 Machi Komacine
- **Afinidade Primária**: Transmutação (100%)
- **Habilidades / Hatsu**:
  - **Nen Stitches (Pontos de Nen)**
    - *Afinidade*: Transmutação (100%)
    - *Tags*: `["heal", "support", "surgery", "utility"]`
    - *Mecânica*: Fios de aura finos e incrivelmente resistentes usados para reconectar músculos, ossos e membros decepados com precisão cirúrgica quase instantânea.
  - **Nen Threads (Fios Invisíveis de Nen)**
    - *Tags*: `["control", "trap", "tether", "stealth"]`
    - *Mecânica*: Fios de aura estendidos em In para criar armadilhas, estrangular alvos ou manipular corpos humanos como marionetes.

### 3.6 Nobunaga Hazama
- **Afinidade Primária**: Reforço (100%)
- **Habilidades / Hatsu**:
  - **Iai / En Domain Cut**
    - *Afinidade*: Reforço (100%) + Emissão
    - *Tags*: `["counter", "melee", "reaction", "precision", "en"]`
    - *Mecânica*: Mantém uma esfera de En de raio circular estrito de 4 metros (alcance de sua katana).
    - *GameplayCondition [PLANEJADA]*: `target_enters_en_zone`.
    - *Efeito*: Qualquer inimigo ou projétil que atravesse o limite do En recebe um contra-ataque de desembainhar instantâneo com acerto crítico garantido.

### 3.7 Shizuku Murasaki
- **Afinidade Primária**: Conjuração (100%)
- **Habilidades / Hatsu**:
  - **Blinky (Deme-chan - Aspirador Conjurado)**
    - *Afinidade*: Conjuração (100%)
    - *Tags*: `["utility", "drain", "cleanse", "lethal"]`
    - *Regra Canônica*: Não pode aspirar criaturas vivas nem objetos feitos puramente de Nen, mas aspira qualquer objeto inanimado infinito e sem restrição de volume.
    - *Efeito de Combate*: Pode aspirar todo o sangue derramado através de feridas abertas de um inimigo, causando sangramento contínuo letal por anemia súbita.

### 3.8 Franklin Bordeau
- **Afinidade Primária**: Emissão (100%)
- **Habilidades / Hatsu**:
  - **Double Machine Gun (Metralhadora Dupla)**
    - *Afinidade*: Emissão (100%)
    - *Tags*: `["offensive", "ranged", "rapid_fire", "projectile"]`
    - *Limitação Autoimposta*: Cortou as pontas dos próprios dedos para fortalecer a convicção do disparo.
    - *Efeito*: Dispara rajadas ininterruptas e ultra-rápidas de projéteis densos de aura a partir das pontas dos dedos modificadas.

### 3.9 Shalnark
- **Afinidade Primária**: Manipulação (100%)
- **Habilidades / Hatsu**:
  - **Black Voice (Voz Negra)**
    - *Afinidade*: Manipulação (100%)
    - *Tags*: `["control", "puppet", "single_target"]`
    - *Mecânica*: Insere uma antena com terminação de morcego no corpo do alvo e controla seus movimentos remotamente através de um celular customizado.
    - *Efeito*: O alvo perde o controle de suas ações e executa comandos cegamente até que a antena seja fisicamente removida.
  - **Autopilot (Piloto Automático)**
    - *Afinidade*: Manipulação (100%) + Reforço (60%)
    - *Tags*: `["buff", "transformation", "berserk", "high_risk"]`
    - *Mecânica*: Espeta a antena em seu próprio corpo e programa o celular para atingir um objetivo específico.
    - *Efeito*: A aura explode em níveis titânicos e o corpo combate automaticamente com atributos maximizados. Ao encerrar o efeito, o usuário sofre fadiga muscular extrema e amnésia dos eventos.

### 3.10 Phinks Magcub
- **Afinidade Primária**: Reforço (100%)
- **Habilidades / Hatsu**:
  - **Ripper Cyclotron (Ciclótron Despedaçador)**
    - *Afinidade*: Reforço (100%)
    - *Tags*: `["offensive", "melee", "charge", "escalating"]`
    - *Mecânica*: Gira o braço direito em círculos como uma manivela. Cada volta completa acumula aura proporcional no punho.
    - *Efeito*: O poder de dano escala exponencialmente por volta acumulada, descarregando um golpe de impacto devastador ao socar o adversário.

### 3.11 Bonolenov Ndongo
- **Afinidade Primária**: Conjuração (100%) + Emissão
- **Habilidades / Hatsu**:
  - **Battle Cantabile: Prologue & Jupiter**
    - *Tags*: `["offensive", "ranged", "sound", "crush"]`
    - *Mecânica*: O ar passa pelos orifícios esculpidos em seu corpo durante danças tribais, gerando melodias que materializam armas ou uma réplica em miniatura esmagadora do planeta Júpiter arremessada contra o inimigo.

### 3.12 Pakunoda
- **Afinidade Primária**: Especialização (100%)
- **Habilidades / Hatsu**:
  - **Memory Extraction & Memory Bomb**
    - *Tags*: `["utility", "mind_reading", "information", "ranged"]`
    - *Mecânica*: Ao tocar alguém e fazer uma pergunta, lê memórias puras e sem filtros mentais. Converte essas memórias em balas de revólver que, ao atingirem aliados, transmitem as lembranças instantaneamente sem dano.

### 3.13 Kortopi
- **Afinidade Primária**: Conjuração (100%)
- **Habilidades / Hatsu**:
  - **Gallery Fake (Galeria Falsa)**
    - *Tags*: `["utility", "cloning", "tracking", "conjuration"]`
    - *Mecânica*: Toca um objeto com a mão esquerda e materializa uma cópia física exata e idêntica com a mão direita.
    - *Regras*: As cópias duram exatamente 24 horas e funcionam como receptores de En (Kortopi sabe a localização exata de cada cópia).

---

## 4. FAMÍLIA ZOLDYCK

### 4.1 Zeno Zoldyck
- **Afinidade Primária**: Transmutação (100%) + Emissão (80%)
- **Habilidades / Hatsu**:
  - **Dragon Head (Cabeça de Dragão)**
    - *Afinidade*: Transmutação (100%)
    - *Tags*: `["offensive", "utility", "tether", "weapon"]`
    - *Mecânica*: Transmuta a aura em forma de cabeça de dragão chinesa que se estende de suas mãos para agarrar, morder ou transportar combatentes.
  - **Dragon Lance (Lança do Dragão)**
    - *Afinidade*: Transmutação (100%) + Emissão (80%)
    - *Tags*: `["offensive", "ranged", "piercing", "laser"]`
    - *Mecânica*: Dispara a cabeça de dragão como um feixe contínuo e perfurante de longo alcance sob controle manual direto.
  - **Dragon Dive (Chuva de Dragões)**
    - *Afinidade*: Transmutação (100%) + Emissão (80%)
    - *Tags*: `["offensive", "aoe", "bombardment", "ranged"]`
    - *Mecânica*: Desmembra um dragão gigante de aura em milhares de fragmentos perfurantes que despencam do céu como chuva de meteoros sobre uma vasta área.

### 4.2 Silva Zoldyck
- **Afinidade Primária**: Transmutação (100%) + Emissão (80%)
- **Habilidades / Hatsu**:
  - **Explosive Orbs (Orbes Explosivos de Aura)**
    - *Afinidade*: Transmutação (100%) + Emissão (80%)
    - *Tags*: `["offensive", "ranged", "aoe", "explosive"]`
    - *Mecânica*: Concentra duas esferas densas de aura crepitante, uma em cada palma, arremessando-as para criar uma detonação monumental combinada.

### 4.3 Illumi Zoldyck
- **Afinidade Primária**: Manipulação (100%)
- **Habilidades / Hatsu**:
  - **Needle People (Agulhas de Controle Mental)**
    - *Afinidade*: Manipulação (100%)
    - *Tags*: `["control", "puppet", "minion", "debuff"]`
    - *Mecânica*: Cravando agulhas imbuidas de Nen na cabeça de alvos humanos, priva-os de raciocínio transformando-os em zumbis obedientes que lutam até a morte.
  - **Body Alteration (Alteração Facial)**
    - *Tags*: `["utility", "disguise", "stealth"]`
    - *Mecânica*: Reorganiza ossos e cartilagens faciais usando agulhas para se disfarçar com perfeição.

### 4.4 Kalluto Zoldyck
- **Afinidade Primária**: Manipulação (100%)
- **Habilidades / Hatsu**:
  - **Paper Manipulation: Snake Bite & Surveillance**
    - *Tags*: `["offensive", "ranged", "scrying", "slashing"]`
    - *Mecânica*: Controla pequenos recortes de papel confete imbuídos de Shu como projéteis cortantes mortais ou dispositivos de escuta remota.

---

## 5. ASSOCIAÇÃO HUNTER & EXAMINADORES

### 5.1 Isaac Netero
- **Afinidade Primária**: Reforço (100%) + Emissão/Manipulação
- **Habilidades / Hatsu**:
  - **100-Type Guanyin Bodhisattva (Bodhisattva Guanyin de 100 Tipos)**
    - *Afinidade*: Conjuração/Emissão + Manipulação + Reforço
    - *Tags*: `["offensive", "summon", "melee", "divine", "god_speed"]`
    - *Mecânica*: Ora com as mãos juntas antes de cada movimento. A velocidade dessa oração e do subsequente golpe da estátua ultrapassa a barreira do som e a capacidade de reação biológica.
  - **First Hand, Third Hand, Ninety-Ninth Hand**
    - *Variações*: Golpes verticais de palma, palmas cruzadas esmagadoras e tempestades de centenas de golpes contínuos e impiedosos.
  - **Zero Hand (Mão Zero)**
    - *Afinidade*: Emissão (80%) + Reforço (100%)
    - *Tags*: `["offensive", "ultimate", "burnout", "last_resort"]`
    - *Mecânica*: A estátua surge pelas costas do inimigo e o imobiliza; Netero canaliza todo o remanescente absoluto de sua aura (MOP residual) através de sua boca em uma labareda de pura energia destrutiva. O usuário envelhece e esgota completamente suas forças.

### 5.2 Biscuit Krueger
- **Afinidade Primária**: Transmutação (100%)
- **Habilidades / Hatsu**:
  - **Magical Esthetician (Cookie-chan)**
    - *Afinidade*: Conjuração (100%) + Transmutação (100%) + Manipulação
    - *Tags*: `["support", "heal", "stamina_recovery", "utility"]`
    - *Mecânica*: Concura uma massagista de aura que secreta loções transmutadas para curar lesões e restaurar completamente a vitalidade muscular de 8 horas de sono em apenas 30 minutos.
  - **Body Reversion (Forma Muscular Verdadeira)**
    - *Tags*: `["buff", "enhancement", "physical_might"]`
    - *Mecânica*: Rompe a restrição cosmética de garotinha, revelando sua estatura titânica e musculatura hipertrofiada, concedendo aumentos monumentais em Força e Defesa física.

### 5.3 Morel Mackernasey
- **Afinidade Primária**: Manipulação (100%) + Emissão
- **Habilidades / Hatsu**:
  - **Deep Purple (Fumaça de Nen)**
    - *Afinidade*: Manipulação (100%) + Emissão (80%) + Transmutação (40%)
    - *Tags*: `["summon", "utility", "clone", "crowd_control"]`
    - *Mecânica*: Sopra fumaça através de seu cachimbo gigante e molda soldados autônomos, cordas de contenção impenetráveis ou duplicatas idênticas de pessoas.
  - **Smoky Jail (Prisão de Fumaça)**
    - *Tags*: `["binding", "cage", "barrier", "impenetrable"]`
    - *Mecânica*: Cria um domo selado de fumaça sólida indestrutível que isola o usuário e o oponente do restante do mundo.

### 5.4 Knov
- **Afinidade Primária**: Conjuração (100%) + Emissão (40%)
- **Habilidades / Hatsu**:
  - **Hide and Seek (4-Dimensional Mansion)**
    - *Afinidade*: Conjuração (100%) + Emissão
    - *Tags*: `["utility", "teleport", "dimension", "inventory"]`
    - *Mecânica*: Desenha portais no chão que conectam a uma mansão quadridimensional de 21 salas separadas, permitindo evacuação, armazenamento ou transporte furtivo de exércitos.
  - **Scream (Grito Espacial)**
    - *Afinidade*: Conjuração + Emissão
    - *Tags*: `["offensive", "lethal", "spatial_cut", "execution"]`
    - *Mecânica*: Abre um portal espacial entre as duas mãos envolvendo a cabeça/corpo do alvo e fecha o portal subitamente, enviando a parte decepada para outra dimensão e ignorando defesas físicas.

### 5.5 Knuckle Bine
- **Afinidade Primária**: Emissão (100%)
- **Habilidades / Hatsu**:
  - **A.P.R. (Hakoware - Falência de Aura)**
    - *Afinidade*: Emissão (100%) + Manipulação
    - *Tags*: `["debuff", "aura_debt", "invulnerable_pet", "tactical"]`
    - *Mecânica*: Ao desferir um golpe, empresta aura ao oponente sem causar dano físico. Uma criatura indestrutível (Toritaten) passa a acompanhar o alvo cobrando 10% de juros compostos a cada 10 segundos.
    - *Penalidade*: Se a dívida de aura ultrapassar a reserva total de Nen do alvo, A.P.R. transforma-se em I.R.S. e força o adversário ao estado de **Zetsu por 30 dias**.

### 5.6 Shoot McMahon
- **Afinidade Primária**: Manipulação (100%) + Conjuração
- **Habilidades / Hatsu**:
  - **Hotel Rafflesia (Jaula Escura & Mãos Flutuantes)**
    - *Afinidade*: Manipulação (100%) + Conjuração
    - *Tags*: `["control", "seal", "ranged", "disarm"]`
    - *Mecânica*: Controla três mãos levitantes desincorporadas. Cada golpe bem-sucedido arranca uma parte do corpo do oponente e a sela dentro de uma pequena gaiola suspensa.

### 5.7 Palm Siberia
- **Afinidade Primária**: Reforço (100%) / Quimera
- **Habilidades / Hatsu**:
  - **Black Widow (Viúva Negra)**
    - *Afinidade*: Reforço (100%) + Manipulação
    - *Tags*: `["armor", "melee", "enhancement", "spikes"]`
    - *Mecânica*: Envolve seu corpo inteiro em cabelos armados com Ko e Ten, formando uma armadura viva e afiada para combate corpo a corpo brutal.
  - **Merman Clairvoyance (Clarividência da Sereia)**
    - *Tags*: `["utility", "tracking", "vision"]`
    - *Mecânica*: Alimentando uma esfera de cristal com seu sangue, pode observar a localização de qualquer pessoa que já tenha visto com os próprios olhos.

---

## 6. FORMIGAS QUIMERA (CHIMERA ANTS)

### 6.1 Meruem (O Rei)
- **Afinidade Primária**: Especialização (100%)
- **Habilidades / Hatsu**:
  - **Aura Synthesis (Síntese de Aura)**
    - *Afinidade*: Especialização (100%)
    - *Tags*: `["passive", "absorption", "stat_growth", "evolution"]`
    - *Mecânica*: Ao devorar usuários de Nen, assimila completamente sua aura e desenvolve novas capacidades baseadas nas afinidades e habilidades da vítima.
  - **Photon En & Rage Blast (Pós-Rosa)**
    - *Afinidade*: Emissão + Transmutação + Especialização
    - *Tags*: `["offensive", "en", "ranged", "detection", "annihilation"]`
    - *Mecânica*: Transmuta seu En em partículas microscópicas de fótons de luz que mapeiam instantaneamente qualquer presença, emoção ou intenção, além de disparar canhões concentrados de pura aura capazes de pulverizar montanhas.

### 6.2 Neferpitou
- **Afinidade Primária**: Especialização (100%) + Manipulação
- **Habilidades / Hatsu**:
  - **Terpsichora (Dança da Marionete Titânica)**
    - *Afinidade*: Manipulação (100%) + Especialização
    - *Tags*: `["buff", "combat_puppet", "berserk", "post_mortem"]`
    - *Mecânica*: Conjura uma bailarina monstruosa de cordas que manipula o próprio corpo de Pitou além de seus limites biológicos normais, atacando em frações de décimos de segundo. Funciona mesmo após a morte biológica via Nen Pós-Morte.
  - **Doctor Blythe (Doutor Blythe)**
    - *Afinidade*: Especialização (100%) + Conjuração
    - *Tags*: `["heal", "surgery", "anchor", "utility"]`
    - *Mecânica*: Cirurgiã gigante que reconecta tecidos, órgãos e remove toxinas.
    - *Restrição*: Fica fixa no espaço geográfico onde foi conjurada e consome toda a aura defensiva de Pitou, deixando-a vulnerável enquanto opera.
  - **Puppeteering Army (Exército de Marionetes)**
    - *Tags*: `["control", "summon", "mass_manipulation"]`
    - *Mecânica*: Controla soldados e cadáveres em larga escala a quilômetros de distância usando fios invisíveis de aura.

### 6.3 Shaiapouf (Pouf)
- **Afinidade Primária**: Manipulação (100%)
- **Habilidades / Hatsu**:
  - **Beelzebub (Rei das Moscas)**
    - *Afinidade*: Manipulação (100%) + Especialização
    - *Tags*: `["utility", "cloning", "evasion", "invulnerable"]`
    - *Mecânica*: Divide seu corpo em milhões de clones microscópicos do tamanho de células. Imune a dano físico contundente normal enquanto o núcleo principal estiver protegido.
  - **Spiritual Message (Escamas Hipnóticas)**
    - *Tags*: `["debuff", "aoe", "mind_reading", "hypnosis"]`
    - *Mecânica*: Espalha escamas brilhantes através de suas asas de borboleta que induzem hipnose em massas de pessoas e leem com precisão absoluta as emoções psicológicas do alvo.

### 6.4 Menthuthuyoupi (Youpi)
- **Afinidade Primária**: Reforço (100%) + Transmutação
- **Habilidades / Hatsu**:
  - **Metamorfose e Fúria Célular**
    - *Afinidade*: Reforço (100%) + Transmutação (80%)
    - *Tags*: `["transformation", "tentacles", "melee", "adaptation"]`
    - *Mecânica*: Altera sua anatomia instantaneamente criando tentáculos, olhos extras, asas carnosas e lâminas orgânicas densas.
  - **Rage Incarnate & Rage Cannon (Canhão de Fúria)**
    - *Afinidade*: Reforço (100%) + Emissão (80%)
    - *Tags*: `["offensive", "aoe", "explosive", "burst"]`
    - *Mecânica*: Converte sua fúria desmedida em uma explosão cataclísmica de aura vulcânica ao redor de si mesmo ou canalizada em formato de canhão centauro.

### 6.5 Ikalgo
- **Afinidade Primária**: Manipulação (100%)
- **Habilidades / Hatsu**:
  - **Living Dead Dolls (Parasitismo Cadavérico)**
    - *Tags*: `["utility", "puppet", "infiltration"]`
    - *Mecânica*: Entra no cadáver de uma criatura falecida e assume o controle completo de sua voz, memória motora e habilidades corporais.
  - **Flea Bullets (Balas de Pulga)**
    - *Tags*: `["offensive", "ranged", "sniper", "bleed"]`
    - *Mecânica*: Transforma seus tentáculos em um rifle de precisão que dispara pulgas parasitas gigantes que impedem a coagulação sanguínea do alvo.

### 6.6 Meleoron
- **Afinidade Primária**: Especialização (100%)
- **Habilidades / Hatsu**:
  - **Perfect Plan (Plano Perfeito / Furtividade Absoluta)**
    - *Afinidade*: Especialização (100%)
    - *Tags*: `["stealth", "invisibility", "invulnerable_presence"]`
    - *Mecânica*: Enquanto prende a respiração, torna-se totalmente invisível e indetectável por visão, audição, olfato, tato, En ou sexto sentido.
  - **God's Accomplice (Cúmplice de Deus)**
    - *Mecânica*: Estende os efeitos do Perfect Plan a qualquer companheiro que estiver em contato físico direto consigo.

---

## 7. GREED ISLAND & ANTAGONISTAS SECUNDÁRIOS

### 7.1 Genthru (The Bomber)
- **Afinidade Primária**: Conjuração (100%) + Transmutação
- **Habilidades / Hatsu**:
  - **Little Flower (Pequena Flor)**
    - *Afinidade*: Transmutação (80%) + Reforço (60%)
    - *Tags*: `["offensive", "melee", "explosive", "high_risk"]`
    - *Mecânica*: Faz explodir a aura em contato com as mãos. Para não ter as próprias mãos dilaceradas, precisa proteger suas palmas com uma concentração maior de aura via Gyo (ex: 80% defensivo nas mãos, 20% explosivo).
  - **Countdown (Contagem Regressiva)**
    - *Afinidade*: Conjuração (100%) + Emissão + Manipulação
    - *Tags*: `["curse", "timed_bomb", "co-op", "vow_restricted"]`
    - *Condições Estritas*:
      1. Tocar o alvo na área do tórax.
      2. Dizer a palavra secreta "Bomber".
      3. Explicar detalhadamente o funcionamento de sua habilidade ao alvo.
    - *Efeito*: Um contador numérico cardíaco é acoplado ao peito da vítima, detonando com força devastadora ao chegar a zero.

### 7.2 Razor (Mestre de Greed Island)
- **Afinidade Primária**: Emissão (100%)
- **Habilidades / Hatsu**:
  - **14 Devils (14 Demônios de Aura)**
    - *Afinidade*: Emissão (100%) + Manipulação (80%)
    - *Tags*: `["summon", "minion", "sports_rules", "coordinated"]`
    - *Mecânica*: Emite e sustenta 14 feras humanóides autônomas de aura que podem se combinar ou executar ações táticas sincronizadas.
  - **Spike Cannon (Disparo de Aura Esférico)**
    - *Afinidade*: Emissão (100%) + Reforço (80%)
    - *Tags*: `["offensive", "projectile", "heavy_impact"]`
    - *Mecânica*: Corta ou arremessa uma bola com velocidade supersônica carregada de aura pura, destruindo navios e quebrando membros de mestres de Nen.

---

## 8. SUCESSÃO DE KARKINO & DARK CONTINENT

### 8.1 Halkenburg Hui Guo Rou
- **Afinidade Primária**: Reforço / Emissão
- **Habilidades / Hatsu**:
  - **GNB Arrow (Arco e Flecha de Vontade Coletiva)**
    - *Tags*: `["offensive", "armor_piercing", "possession", "resonance"]`
    - *Mecânica*: Une a determinação e lealdade de seus súditos em uma flecha de aura colossal. O disparo perfura qualquer barreira de Nen e substitui a consciência do alvo pela de um de seus seguidores.

### 8.2 Camilla Hui Guo Rou
- **Afinidade Primária**: Especialização (100%)
- **Habilidades / Hatsu**:
  - **Cat's Name (Gato de Um Milhão de Vidas)**
    - *Afinidade*: Especialização (100%) + Nen Pós-Morte
    - *Tags*: `["counter", "revive", "lethal", "post_mortem"]`
    - *Condição*: Camilla deve morrer assassinada por um atacante.
    - *Efeito*: Invoca uma gata gigante de aura pós-morte que esmaga o assassino até extrair toda a sua energia vital, usando essa energia para ressuscitar Camilla imediatamente sem sequelas.

---

## 9. GLOSSÁRIO DE INTEGRAÇÃO COM GODOT

Ao converter qualquer uma dessas entradas para scripts GDScript ou arquivos de recursos `.tres` (`HatsuData`):
- O campo `category` recebe a string canônica em inglês minúsculo: `"enhancement"`, `"transmutation"`, `"emission"`, `"conjuration"`, `"manipulation"`, `"specialization"`.
- As tags no array `tags` devem ser filtradas por `GameplayTags.normalize(tag)`.
- Requisitos situacionais implementados utilizam instâncias de `GameplayCondition` alimentadas pelo dicionário de contexto da cena de combate. Os identificadores acima marcados como **[PLANEJADA]** devem ser adicionados em uma fase futura antes de serem usados em runtime.
