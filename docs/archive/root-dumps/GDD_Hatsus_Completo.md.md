# 📖 MASTER GDD: Habilidades e VFX (Hunter x Hunter)

## 1. Regra de Ouro da Geração (Cast vs. VFX)
Para manter a engine do jogo leve e a grade de pixels alinhada, o agente deve SEMPRE dividir a geração de uma habilidade em duas etapas distintas:
*   **Asset 1 (Cast - O Personagem):** O sprite do personagem fazendo a pose de ativação do poder (ex: soco recuado, mãos unidas, apontando a arma). Fundo transparente ou chroma key.
*   **Asset 2 (VFX - O Efeito VisuaL):** Exclusivamente o efeito mágico/físico do poder (ex: eletricidade, fogo, aura). Deve ser gerado separadamente, em fundo preto ou transparente, para ser sobreposto via código na engine.

## 2. Protagonistas e Aliados

| Personagem | Categoria | Hatsu / Poder | Visual Original (Anime) | Prompt para VFX (Asset 2) |
| :--- | :--- | :--- | :--- | :--- |
| **Gon** | Reforço | *Jajanken (Pedra)* | Esfera de aura laranja vibrante concentrada no punho. | "Pixel art VFX de uma esfera de energia laranja e dourada faiscante, sem personagem." |
| **Killua** | Transformação | *Godspeed / Relâmpago* | Eletricidade azul e branca intensa percorrendo o corpo e o chão. | "Pixel art VFX de raios e faíscas azuis elétricas irregulares, loop de animação." |
| **Kurapika** | Materialização | *Correntes (Chain Jail)* | Correntes de metal realistas, brilhando em vermelho com Emperor Time. | "Pixel art de uma corrente de metal cinza com a ponta em formato de âncora/gancho esticada em linha reta." |
| **Leorio** | Emissão | *Warping Punch* | Um portal negro de aura de onde sai um punho gigante. | "Pixel art VFX de um portal escuro/distorcido emitindo ondas de choque vermelhas." |
| **Kite** | Materialização | *Crazy Slots* | Um palhaço flutuante e armas brancas gigantes (ex: Foice prateada). | "Pixel art de uma foice gigante de lâmina prateada brilhante, estilo RPG top-down." |

## 3. Genei Ryodan (Trupe Fantasma)

| Personagem | Categoria | Hatsu / Poder | Visual Original (Anime) | Prompt para VFX (Asset 2) |
| :--- | :--- | :--- | :--- | :--- |
| **Chrollo** | Especialização | *Skill Hunter* | Um livro de capa bordô flutuando ou segurado na mão direita. | "Pixel art de um livro antigo vermelho escuro flutuando com uma aura roxa sutil." |
| **Feitan** | Transformação | *Pain Packer (Rising Sun)* | Uma miniatura de sol incandescente que emite calor extremo. | "Pixel art VFX de uma mini estrela/sol explodindo em chamas laranjas e vermelhas." |
| **Machi** | Transformação | *Nen Stitches* | Fios finíssimos e brilhantes em tom de rosa claro ou azul bebê. | "Pixel art VFX de agulhas e fios de seda finos e brilhantes cruzando o espaço." |

## 4. Chimera Ants e Associação Hunter

| Personagem | Categoria | Hatsu / Poder | Visual Original (Anime) | Prompt para VFX (Asset 2) |
| :--- | :--- | :--- | :--- | :--- |
| **Netero** | Emissão | *100-Type Guanyin* | Uma estátua dourada gigante de Buda de múltiplos braços. | "Pixel art VFX de braços dourados gigantes atacando a partir do fundo, estilo estátua budista." |
| **Hisoka** | Transformação | *Bungee Gum* | Aura com textura de chiclete elástico e translúcido, cor de rosa. | "Pixel art VFX de uma substância elástica e grudenta rosa chiclete esticada." |
| **Meruem** | Emissão | *Aura Blast (Rage)* | Explosão de aura massiva, densa e roxa/magenta. | "Pixel art VFX de uma rajada de energia magenta densa com partículas de destruição." |
## 5. Família Zoldyck

| Personagem | Categoria | Hatsu / Poder | Visual Original (Mangá/Anime) | Prompt para VFX (Asset 2) |
| :--- | :--- | :--- | :--- | :--- |
| **Zeno** | Emissão/Trans. | *Dragon Dive* | Dragões orientais de pura aura dourada/azul caindo do céu ou saindo das mãos. | "Pixel art VFX de um dragão oriental feito de energia brilhante, estilo projétil mágico." |
| **Silva** | Emissão/Trans. | *Esferas Explosivas* | Duas esferas massivas de energia roxa e elétrica em ambas as mãos. | "Pixel art VFX de duas esferas de energia roxa densa pulsando com eletricidade." |
| **Illumi** | Manipulação | *Needle People* | Agulhas com cabeças redondas e amarelas que distorcem o rosto dos alvos. | "Pixel art VFX de agulhas prateadas com cabeças amarelas voando em linha reta." |

## 6. Time de Extermínio e Hunters Oficiais

| Personagem | Categoria | Hatsu / Poder | Visual Original (Mangá/Anime) | Prompt para VFX (Asset 2) |
| :--- | :--- | :--- | :--- | :--- |
| **Biscuit** | Transformação | *Magical Spa Services* | Invoca a Cookie-chan (uma massagista de aura). Forma alternativa: corpo hiper-musculoso. | "Pixel art de uma massagista mágica flutuante (NPC pet) emitindo partículas de cura." |
| **Morel** | Manipulação | *Deep Purple* | Fumaça roxa espessa controlada através de um cachimbo gigante, formando soldados de fumaça. | "Pixel art VFX de nuvens de fumaça roxa densa formando silhuetas de guerreiros." |
| **Knov** | Conjuração | *Hide and Seek* | Portais circulares negros no chão ou no ar que levam a uma dimensão de bolso. | "Pixel art VFX de um portal negro circular abrindo no chão com bordas interdimensionais." |
| **Knuckle** | Emissão | *Hakoware (A.P.R.)* | Um mascote indestrutível flutuante com um contador numérico na testa. | "Pixel art de um mascote chibi flutuante com um placar digital na cabeça." |

## 7. Formigas Quimera (Guardas Reais)

| Personagem | Categoria | Hatsu / Poder | Visual Original (Mangá/Anime) | Prompt para VFX (Asset 2) |
| :--- | :--- | :--- | :--- | :--- |
| **Neferpitou** | Especialização | *Terpsichora / Dr. Blythe* | Uma bailarina/marionetista macabra flutuando presa por fios de aura aos dedos de Pitou. | "Pixel art VFX de fios de marionete roxos e brilhantes pendendo do topo da tela." |
| **Shaiapouf** | Manipulação | *Spiritual Message* | Escamas microscópicas brilhantes caindo das asas de borboleta. | "Pixel art VFX de partículas hipnóticas de pólen brilhante caindo em cascata." |
| **Youpi** | Reforço/Trans. | *Metamorphosis* | Explosões de pura raiva (aura vermelha) e braços extras se formando com lâminas/tentáculos. | "Pixel art VFX de explosões vermelhas viscerais e tentáculos farpados crescendo." |

## 8. Guerra de Sucessão / Continente Negro (Exclusivos do Mangá)

| Personagem | Categoria | Hatsu / Poder | Visual Original (Mangá) | Prompt para VFX (Asset 2) |
| :--- | :--- | :--- | :--- | :--- |
| **Tserriednich** | Especialização | *Parallel Future* | Uma Besta Nen grotesca (forma de cavalo com rosto de mulher) espreitando atrás dele. | "Pixel art de um monstro bizarro e sombrio com múltiplas pernas rastejando no chão." |
| **Hinrigh** | Conjuração | *Biohazard* | Transforma armas modernas (armas de fogo, facas) em animais (cobras, pombos). | "Pixel art de uma cobra metálica rastejando, atirando pequenos projéteis." |
| **Halkenburg** | Emissão | *Flecha da Vontade* | Uma flecha e arco gigantescos de aura, disparados com poder incalculável em linha reta. | "Pixel art VFX de um arco e flecha gigante de energia dourada disparando." |