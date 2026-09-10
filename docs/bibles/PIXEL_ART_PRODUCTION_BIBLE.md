# HUNTER ONLINE --- PIXEL ART PRODUCTION BIBLE

**Status:** Living production document\
**Project:** Hunter Online\
**Engine:** Godot 4.6\
**Primary visual target:** 2D top-down anime RPG/MMORPG\
**Primary generation pipeline:** PixelLab + existing project assets +
AI-assisted production\
**Character frame standard:** 48×48 px\
**World target:** Rich environmental pixel art with readable, relatively
small characters

> **Escopo SSOT:** hierarquia visual, pipeline de produção de **mundo**, phases,
> quality gates de mapa/tile/prop.
> **Personagens:** números e gates em
> [`PIXEL_ART_STYLE_BIBLE.md`](PIXEL_ART_STYLE_BIBLE.md) — este doc não os
> substitui.
> **Índice de união / anti-conflito:**
> [`ART_PIPELINE_CANON.md`](ART_PIPELINE_CANON.md).
> **Prompts operacionais:**
> [`../guides/PIXELLAB_PROMPT_LIBRARY.md`](../guides/PIXELLAB_PROMPT_LIBRARY.md).
> **Âncora de densidade mundial:**
> `assets/reference/world_detail_grass_dirt_trees_ref.png`.

------------------------------------------------------------------------

# 1. PROPÓSITO

Este documento define o padrão visual e o processo de produção de pixel
art do Hunter Online.

Ele existe para impedir **style drift** durante o desenvolvimento.

O jogo deve evoluir visualmente sem perder coerência.

A regra central é:

> **Personagens pequenos e legíveis + mundo ambientalmente rico,
> detalhado e cheio de variações.**

O objetivo NÃO é fazer todos os elementos igualmente detalhados.

O objetivo é criar uma hierarquia visual:

-   personagens = baixa/média densidade de detalhes;
-   objetos = média densidade;
-   terreno = média densidade;
-   vegetação = média/alta densidade;
-   landmarks = alta riqueza visual;
-   efeitos = detalhe suficiente para comunicar ação, sem virar ruído.

O resultado deve parecer um jogo completo e produzido intencionalmente,
e não uma coleção de assets gerados por IA.

------------------------------------------------------------------------

# 2. REFERÊNCIAS OFICIAIS

## 2.1 STYLE ANCHOR DE PERSONAGEM

Arquivo:

`player(3).png`

Esta referência representa principalmente:

-   escala dos personagens;
-   densidade de pixels;
-   simplicidade;
-   proporções;
-   silhueta;
-   tratamento do cabelo;
-   tratamento do rosto;
-   tratamento da roupa;
-   shading;
-   quantidade de cores;
-   espaço transparente do frame;
-   leitura em baixa resolução.

A referência NÃO deve ser interpretada como um personagem a ser copiado.

Ela é o padrão de linguagem visual dos personagens.

------------------------------------------------------------------------

## 2.2 WORLD DETAIL REFERENCE

O screenshot fornecido pelo usuário em setembro de 2026 representa o
nível de riqueza ambiental desejado.

Ele serve para estabelecer:

-   densidade de detalhes do mapa;
-   quantidade de variações;
-   riqueza de terreno;
-   vegetação;
-   pedras;
-   objetos;
-   caminhos;
-   transições;
-   landmarks;
-   composição;
-   profundidade visual.

Não copiar personagens, mapas, logos ou assets da referência.

Usar somente como referência de **nível de detalhe e acabamento
ambiental**.

------------------------------------------------------------------------

# 3. REGRA VISUAL MAIS IMPORTANTE

Hunter Online NÃO deve ser:

-   pixel art extremamente simples;
-   pixel art HD extremamente detalhada;
-   anime renderizado em pixels;
-   concept art reduzida;
-   ilustração digital reduzida;
-   cenário procedural genérico;
-   mapa com um único tile repetido.

O alvo é:

> **pixel art de jogo, com pixels claros, personagens pequenos e um
> mundo rico em detalhes.**

------------------------------------------------------------------------

# 4. HIERARQUIA DE DETALHE

## 4.1 Personagem

Prioridade:

1.  silhueta;
2.  pose;
3.  cabelo;
4.  roupa;
5.  cores;
6.  pequenos detalhes.

Evitar microdetalhes.

------------------------------------------------------------------------

## 4.2 NPC importante

Pode possuir mais identidade visual que o player.

A diferença deve vir principalmente de:

-   cabelo;
-   roupa;
-   acessórios;
-   silhueta;
-   postura;
-   arma;
-   paleta;
-   animação.

Não aumentar artificialmente a resolução.

------------------------------------------------------------------------

## 4.3 Objeto

Objetos podem possuir mais detalhes que personagens.

Exemplos:

-   baús;
-   barris;
-   placas;
-   bancos;
-   postes;
-   carrinhos;
-   poços;
-   mesas;
-   árvores;
-   pedras.

------------------------------------------------------------------------

## 4.4 Ambiente

O ambiente deve ser a principal fonte de riqueza visual.

Adicionar:

-   pequenas plantas;
-   flores;
-   folhas;
-   pedras;
-   raízes;
-   rachaduras;
-   manchas;
-   variações de terra;
-   caminhos;
-   sombras;
-   transições;
-   pequenos objetos;
-   variações de vegetação.

------------------------------------------------------------------------

# 5. PADRÃO DE PERSONAGEM

## 5.1 Frame

Padrão definitivo:

`48×48 px`

Não alterar sem autorização explícita.

------------------------------------------------------------------------

## 5.2 Área ocupada

O personagem NÃO precisa preencher 48×48.

O espaço transparente faz parte da composição.

Preservar aproximadamente a mesma proporção visual do `player(3).png`.

Não aumentar o personagem apenas para "aproveitar" o canvas.

------------------------------------------------------------------------

## 5.3 Pivot e baseline

Todos os personagens devem possuir:

-   baseline consistente;
-   pés alinhados;
-   pivot consistente;
-   origem consistente;
-   escala consistente;
-   direção de leitura consistente.

A posição dos pés é mais importante que centralizar matematicamente o
sprite.

------------------------------------------------------------------------

# 6. DENSIDADE DE PIXELS DOS PERSONAGENS

O personagem deve parecer desenhado diretamente como sprite pequeno.

Não deve parecer:

> uma ilustração de alta resolução reduzida para 48×48.

Características desejadas:

-   agrupamentos de pixels;
-   formas simples;
-   contornos legíveis;
-   poucas cores;
-   sombras em blocos;
-   cabelo simplificado;
-   rosto simplificado;
-   roupas em massas de cor.

------------------------------------------------------------------------

# 7. PALETA DE PERSONAGENS

Preferir:

-   cor base;
-   sombra;
-   highlight opcional;
-   cores de identidade.

Evitar dezenas de tons semelhantes.

Evitar:

-   gradientes;
-   blur;
-   anti-aliasing;
-   soft shading;
-   brilho fotográfico.

------------------------------------------------------------------------

# 8. CABELO

Cabelo deve ser uma massa visual.

Usar:

-   silhueta;
-   pequenos agrupamentos;
-   1--3 níveis principais de cor.

Não desenhar fios individuais.

A silhueta do cabelo deve ajudar a identificar o personagem.

------------------------------------------------------------------------

# 9. ROSTO

Rosto extremamente simples.

Evitar:

-   olhos detalhados;
-   nariz detalhado;
-   boca detalhada;
-   pele renderizada;
-   iluminação facial complexa.

A leitura deve funcionar em tamanho pequeno.

------------------------------------------------------------------------

# 10. ROUPAS

Roupa deve ser representada por:

-   silhueta;
-   blocos de cor;
-   sombras simples;
-   detalhes distintivos.

Não transformar roupa em concept art miniaturizada.

------------------------------------------------------------------------

# 11. ANIMAÇÕES

Todas as animações devem preservar a mesma densidade visual.

Prioridade:

### IDLE

Pequeno movimento corporal.

### WALK

Movimento claro de pernas e braços.

### ATTACK

Pose forte e legível.

### DASH

Silhueta inclinada e sensação de velocidade.

### HIT

Pose simples e imediata.

### DEATH

Movimento compreensível sem excesso de frames.

------------------------------------------------------------------------

# 12. DIREÇÕES

Preferência:

-   8 direções.

Direções:

-   norte;
-   sul;
-   leste;
-   oeste;
-   nordeste;
-   noroeste;
-   sudeste;
-   sudoeste.

Quando 8 direções não forem necessárias para determinado asset, não
criar conteúdo artificial apenas para cumprir a regra.

------------------------------------------------------------------------

# 13. WORLD ART TARGET

O mundo deve possuir uma densidade de detalhes significativamente maior
que os personagens.

A sensação desejada é:

> **um mapa pequeno que parece vivo porque cada área possui várias
> camadas de informação.**

Não basta colocar árvores.

É necessário combinar:

`terrain + transition + vegetation + rocks + props + landmarks + small details`

------------------------------------------------------------------------

# 14. TERRAIN TILESET 2.0

Cada terreno deve possuir uma família de variações.

## Grass

Exemplos:

-   grass_clean;
-   grass_light;
-   grass_dark;
-   grass_worn;
-   grass_patch;
-   grass_flowers;
-   grass_tall;
-   grass_shadow;
-   grass_detail.

## Dirt

-   dirt_clean;
-   dirt_worn;
-   dirt_dark;
-   dirt_patch;
-   dirt_mud;
-   dirt_cracked;
-   dirt_footpath.

## Stone

-   stone_clean;
-   stone_dark;
-   stone_cracked;
-   stone_moss;
-   stone_small;
-   stone_large.

## Water

-   water_clean;
-   water_edge;
-   water_shallow;
-   water_deep;
-   water_ripple;
-   water_foam;
-   water_vegetation_edge.

------------------------------------------------------------------------

# 15. TRANSITIONS

Transições são prioridade alta.

Criar famílias para:

-   grass → dirt;
-   grass → stone;
-   grass → sand;
-   dirt → stone;
-   dirt → road;
-   water → grass;
-   water → sand;
-   water → stone;
-   road → grass;
-   road → dirt.

As bordas não devem parecer uma linha perfeitamente artificial.

Usar:

-   bordas irregulares;
-   pequenas intrusões;
-   patches;
-   vegetação;
-   pedras;
-   variações de cor.

------------------------------------------------------------------------

# 16. VARIAÇÃO DE TILES

Nunca depender de um único tile repetido dezenas de vezes.

Exemplo:

``` text
Grass
├── grass_a
├── grass_b
├── grass_c
├── grass_d
└── grass_e
```

O mesmo conceito deve existir para:

-   pedras;
-   arbustos;
-   flores;
-   árvores;
-   terra;
-   caminhos;
-   água;
-   cercas;
-   objetos.

As variantes não precisam ser completamente diferentes.

Pequenas diferenças são suficientes.

------------------------------------------------------------------------

# 17. DECORATION TILESET

Criar biblioteca reutilizável.

## Vegetação

-   grass tuft;
-   tall grass;
-   flower;
-   flower cluster;
-   bush;
-   large bush;
-   fern;
-   mushroom;
-   fallen leaf;
-   leaf pile;
-   branch;
-   root;
-   vine.

## Pedras

-   pebble;
-   small rock;
-   medium rock;
-   large rock;
-   rock cluster;
-   moss rock;
-   cracked rock.

## Chão

-   dirt patch;
-   mud;
-   dry grass;
-   footprints;
-   cracks;
-   leaf patch;
-   small hole;
-   small debris.

------------------------------------------------------------------------

# 18. OBJECT / PROP LIBRARY

Criar assets independentes.

Exemplos:

-   bench;
-   barrel;
-   crate;
-   wood stack;
-   sign;
-   lamp;
-   torch;
-   table;
-   chair;
-   bucket;
-   well;
-   fence;
-   stone fence;
-   cart;
-   chest;
-   training dummy;
-   campfire;
-   bridge;
-   stairs;
-   market stall.

Quando fizer sentido, criar variantes:

-   normal;
-   velho;
-   danificado;
-   abandonado;
-   destruído.

------------------------------------------------------------------------

# 19. LANDMARKS

Cada região deve possuir elementos visualmente memoráveis.

Exemplos:

## Hunter Association

-   entrada monumental;
-   bandeiras;
-   placas;
-   estátuas;
-   treinamento;
-   guardas;
-   recepção;
-   documentos;
-   bancos;
-   arquitetura própria.

## Cidade

-   praça;
-   fonte;
-   lojas;
-   placas;
-   becos;
-   casas;
-   postes;
-   bancas;
-   pequenas áreas sociais.

## Floresta

-   clareiras;
-   árvores especiais;
-   riachos;
-   raízes;
-   pedras;
-   troncos;
-   caminhos;
-   árvores antigas.

## Área de treinamento

-   bonecos;
-   marcas no chão;
-   pedras quebradas;
-   árvores danificadas;
-   alvos;
-   obstáculos.

------------------------------------------------------------------------

# 20. COMPOSIÇÃO DOS MAPAS

Todo mapa definitivo deve ser construído em camadas.

``` text
1. Macro terrain
2. Main paths
3. Terrain transitions
4. Large landmarks
5. Medium objects
6. Vegetation
7. Small ground details
8. NPCs
9. Interactive objects
10. Secrets
11. Lighting/weather polish
```

------------------------------------------------------------------------

# 21. REGRA DE 3 ESCALAS

Todo ambiente importante deve possuir detalhes em três escalas.

## Macro

-   montanhas;
-   rios;
-   cidades;
-   estradas;
-   grandes construções;
-   grandes florestas.

## Médio

-   árvores;
-   pedras;
-   casas;
-   cercas;
-   pontes;
-   arbustos;
-   postes.

## Pequeno

-   flores;
-   folhas;
-   pedrinhas;
-   rachaduras;
-   grama;
-   pegadas;
-   pequenos resíduos.

Isso cria profundidade visual.

------------------------------------------------------------------------

# 22. EVITAR ÁREAS VAZIAS

Área aberta não significa área sem conteúdo.

Uma área aparentemente vazia deve possuir pelo menos alguns elementos:

-   variação de terreno;
-   vegetação;
-   pequenas pedras;
-   detalhes de chão;
-   caminho;
-   sombra;
-   landmark distante;
-   NPC;
-   objeto;
-   segredo.

Não preencher tudo indiscriminadamente.

O vazio também pode existir para criar contraste.

------------------------------------------------------------------------

# 23. REPETIÇÃO CONTROLADA

Evitar padrões visíveis como:

``` text
TREE TREE TREE TREE TREE
```

Preferir:

``` text
TREE_A
      TREE_C

  TREE_B

          TREE_A

TREE_D
```

Variar:

-   rotação quando visualmente válido;
-   espaçamento;
-   escala somente se o asset permitir;
-   variante;
-   agrupamento;
-   direção;
-   posição.

------------------------------------------------------------------------

# 24. PIXELLAB COMO ASSET FACTORY

PixelLab deve ser usado principalmente para gerar **bibliotecas de
assets**, não mapas gigantes completos.

Pipeline:

``` text
Style Reference
        ↓
Tileset
        ↓
Terrain Variants
        ↓
Transitions
        ↓
Vegetation
        ↓
Rocks
        ↓
Props
        ↓
Structures
        ↓
Landmarks
        ↓
Map Composition
```

O Godot é responsável pela composição final.

------------------------------------------------------------------------

# 25. PIXELLAB --- PRINCÍPIOS

Quando houver MCP PixelLab disponível:

1.  usar referências existentes;
2.  preservar identidade visual;
3.  reutilizar assets quando possível;
4.  criar variantes coerentes;
5.  não gerar assets isolados sem considerar o tileset;
6.  validar escala;
7.  validar transparência;
8.  validar integração com Godot.

Consultar a documentação oficial do PixelLab antes de depender de uma
ferramenta ou parâmetro específico.

Não assumir endpoints REST quando o fluxo disponível for MCP.

------------------------------------------------------------------------

# 26. REFERÊNCIA DE ESTILO VS REFERÊNCIA DE IDENTIDADE

São conceitos diferentes.

## Style Reference

Ensina:

-   densidade;
-   pixel scale;
-   shading;
-   paleta;
-   proporções;
-   acabamento.

## Character Reference

Ensina:

-   identidade;
-   roupa;
-   cabelo;
-   rosto;
-   silhueta;
-   personagem específico.

Nunca confundir os dois.

------------------------------------------------------------------------

# 27. NOVOS PERSONAGENS

Ao pedir:

> "crie um Hunter veterano"

não copiar o player.

Criar:

-   cabelo diferente;
-   roupa diferente;
-   silhueta diferente;
-   acessórios diferentes.

Mas preservar:

-   48×48;
-   baseline;
-   densidade;
-   simplicidade;
-   shading;
-   linguagem de pixels.

Resultado:

> novo personagem + mesmo universo visual.

------------------------------------------------------------------------

# 28. NPC HIERARCHY VISUAL

## NPC comum

Poucos detalhes.

## NPC especial

Mais identidade.

## NPC importante

Silhueta memorável + roupa específica + acessórios.

## Mini-boss

Silhueta forte + presença visual.

## Boss

Maior complexidade permitida pelo estilo, mas sem sair da linguagem do
jogo.

A diferença visual deve vir principalmente da identidade, não de
simplesmente adicionar pixels.

------------------------------------------------------------------------

# 29. ENEMIES

Inimigos devem possuir leitura imediata.

Cada família de inimigos deve ter:

-   silhueta própria;
-   paleta própria;
-   comportamento visual coerente;
-   variações.

Evitar dezenas de inimigos que parecem o mesmo sprite recolorido.

------------------------------------------------------------------------

# 30. EFEITOS DE COMBATE

Efeitos devem ser produzidos na mesma linguagem visual.

Exemplos:

-   punch impact;
-   kick impact;
-   slash;
-   dash;
-   dust;
-   aura;
-   Nen aura;
-   Hatsu projectile;
-   explosion;
-   shield;
-   heal;
-   stun;
-   hit;
-   death.

------------------------------------------------------------------------

# 31. EFEITOS NÃO DEVEM VIRAR RUÍDO

Evitar:

-   partículas demais;
-   blur;
-   glow excessivo;
-   explosões fotográficas;
-   gradientes;
-   efeitos com resolução muito superior aos personagens.

Preferir:

-   blocos de pixels;
-   arcos;
-   linhas;
-   pequenos agrupamentos;
-   silhuetas;
-   poucos frames;
-   leitura instantânea.

------------------------------------------------------------------------

# 32. WEATHER

O mundo deve suportar variações visuais.

## Normal

Estado base.

## Chuva

-   poças;
-   terreno úmido;
-   gotas;
-   pequenas alterações de iluminação.

## Tempestade

-   iluminação mais escura;
-   chuva forte;
-   vento;
-   efeitos ambientais.

## Noite

-   iluminação;
-   sombras;
-   janelas;
-   postes;
-   fogueiras;
-   NPC schedules.

## Outras variações

Quando fizer sentido:

-   folhas caídas;
-   vegetação diferente;
-   lama;
-   neve;
-   eventos temporários.

Não duplicar mapas desnecessariamente.

------------------------------------------------------------------------

# 33. WORLD EVENTS

Eventos devem poder alterar visualmente áreas.

Exemplos:

-   acampamento temporário;
-   construção;
-   destruição;
-   invasão;
-   festival;
-   treinamento;
-   batalha recente;
-   NPCs reunidos;
-   objetos temporários.

O mundo deve parecer capaz de mudar.

------------------------------------------------------------------------

# 34. ENVIRONMENTAL STORYTELLING

O cenário pode contar histórias sem Quest Tracker.

Exemplo:

``` text
árvore quebrada
↓
pedras destruídas
↓
marcas no chão
↓
acampamento abandonado
↓
NPC que conhece o ocorrido
```

Não explicar tudo automaticamente.

Exploração deve recompensar observação.

------------------------------------------------------------------------

# 35. SEGREDOS

Segredos NÃO devem ser obrigatoriamente apontados pelo Quest Tracker.

Podem usar:

-   detalhe estranho no chão;
-   caminho escondido;
-   árvore diferente;
-   parede quebrada;
-   NPC suspeito;
-   objeto interativo;
-   pequena passagem;
-   evento temporal.

O jogador deve poder descobrir coisas por conta própria.

------------------------------------------------------------------------

# 36. MAPAS DEFINITIVOS

Nenhum asset ou mapa criado sob este pipeline deve ser tratado
automaticamente como descartável.

Quando uma região for criada:

-   identidade;
-   navegação;
-   colisão;
-   assets;
-   landmarks;
-   NPCs;
-   objetos;
-   segredos;
-   iluminação;
-   clima;
-   eventos

devem ser pensados para permanecer no projeto final.

------------------------------------------------------------------------

# 37. ESCALA E COLISÃO

Arte e colisão precisam concordar.

Para personagens:

-   colisão concentrada principalmente na região dos pés/base;
-   não usar o corpo inteiro como hitbox de navegação;
-   não criar corredores invisíveis;
-   não permitir que detalhes visuais impeçam passagem quando não
    deveriam;
-   não permitir que o player atravesse elementos sólidos.

Qualquer diferença visual entre sprite e colisão deve ser auditada.

Não corrigir hitbox com um multiplicador cego.

Investigar:

-   escala;
-   Transform2D;
-   Node2D;
-   Sprite2D;
-   CollisionShape2D;
-   TileMap;
-   TileSet;
-   pivot;
-   offsets;
-   parent scale;
-   câmera.

------------------------------------------------------------------------

# 38. TILESET ENGINEERING

Cada tileset deve possuir documentação ou metadados quando necessário.

Registrar:

-   nome;
-   categoria;
-   tamanho;
-   variantes;
-   colisão;
-   autotile/terrain;
-   transições;
-   origem;
-   referência;
-   asset ID;
-   versão.

Não gerar dezenas de assets sem catálogo.

------------------------------------------------------------------------

# 39. ASSET NAMING

Preferir nomes consistentes.

Exemplo:

``` text
forest_grass_a
forest_grass_b
forest_dirt_a
forest_dirt_transition_grass
forest_rock_small_a
forest_rock_large_a
forest_tree_medium_a
forest_bush_a
forest_flower_red_a
```

Para personagens:

``` text
npc_hunter_guard
npc_hunter_merchant
npc_hunter_trainer
player_main
```

Para efeitos:

``` text
fx_punch_impact
fx_dash_trail
fx_hatsu_projectile
fx_hatsu_explosion
```

------------------------------------------------------------------------

# 40. ASSET CATALOG

Manter um catálogo central.

Exemplo:

``` text
res://data/world/tile_catalog_data.json
```

O catálogo deve evoluir junto com os assets.

Não criar sistemas paralelos de catálogo sem necessidade.

------------------------------------------------------------------------

# 41. STYLE ANCHORS

Manter referências oficiais para:

### Characters

`player(3).png`

### World Detail

screenshot de referência ambiental fornecido pelo usuário.

### UI

referência visual atual consolidada do Hunter Online.

### Effects

um conjunto pequeno de efeitos aprovados.

### Architecture

não misturar referências externas sem decidir oficialmente se entram na
Art Bible.

------------------------------------------------------------------------

# 42. PROMPT BASE --- PERSONAGEM

Usar como base para PixelLab/AI:

``` text
Create a small 2D top-down game character for Hunter Online.

Use the provided Hunter Online player sprite as the PRIMARY STYLE REFERENCE.

Preserve:
- 48x48 pixel frame;
- small character scale;
- low-density pixel art;
- clear silhouette;
- simple face;
- simplified hair;
- block-based shading;
- limited palette;
- hard pixel edges;
- no anti-aliasing;
- no gradients;
- no soft rendering;
- no realistic anatomy;
- no excessive micro-details.

Create a NEW character identity.

Do not copy the reference character's identity.

The target is:
small readable RPG sprite,
not high-resolution pixel illustration.
```

------------------------------------------------------------------------

# 43. PROMPT BASE --- WORLD TILE

Usar como base:

``` text
Create a production-ready 2D top-down pixel art environment asset for Hunter Online.

Use the project's existing world art references as STYLE AND DETAIL DENSITY REFERENCES.

Target:
rich game environment pixel art,
clear pixel clusters,
strong readable shapes,
many controlled environmental details,
natural variation,
layered terrain,
small decorative details,
coherent shadows,
limited but rich palette.

The environment should feel substantially more detailed than the small character sprites.

Do not create a high-resolution digital painting.
Do not use gradients.
Do not use anti-aliasing.
Do not use smooth vector-like edges.
Do not create photographic textures.

The result must look like a real game tileset asset.
```

------------------------------------------------------------------------

# 44. PROMPT BASE --- VARIANTS

``` text
Create multiple visually coherent variants of the same Hunter Online environment asset.

Keep:
- same scale;
- same pixel density;
- same palette family;
- same lighting direction;
- same material;
- same artistic language.

Change only enough details to prevent visible repetition.

Do not make the variants look like different games.
```

------------------------------------------------------------------------

# 45. PROMPT BASE --- LANDMARK

``` text
Create a memorable environmental landmark for Hunter Online.

The landmark must be visually recognizable from gameplay distance.

Use:
- strong silhouette;
- layered construction;
- richer pixel detail than ordinary terrain;
- controlled decorative elements;
- coherent shadows;
- small environmental details.

It must feel like a permanent part of the world, not a generated prop floating on a map.
```

------------------------------------------------------------------------

# 46. PROMPT BASE --- PROP

``` text
Create a production-ready top-down pixel art prop for Hunter Online.

Match the existing world style.

Use:
- clear silhouette;
- readable material;
- limited palette;
- block-based shading;
- moderate environmental detail;
- hard pixel edges.

The prop must integrate naturally with the game's terrain and scale.

Do not over-render it.
```

------------------------------------------------------------------------

# 47. PIXELLAB PRODUCTION ORDER

Para uma região nova:

``` text
1. Style reference
2. Base terrain
3. Terrain variants
4. Terrain transitions
5. Water/road systems
6. Trees
7. Bushes
8. Rocks
9. Ground details
10. Props
11. Structures
12. Landmarks
13. NPCs
14. Enemies
15. Effects
16. Weather variants
17. Final polish
```

------------------------------------------------------------------------

# 48. NÃO GERAR MAPA GIGANTE PRIMEIRO

Não usar IA para produzir uma única imagem gigante e tentar transformar
isso diretamente no mapa.

Preferir:

``` text
asset library
↓
tileset
↓
Godot composition
↓
navigation
↓
collision
↓
interactive world
```

Isso garante reutilização.

------------------------------------------------------------------------

# 49. QUALITY GATE --- PERSONAGEM

Antes de aprovar:

``` text
[ ] 48×48
[ ] escala compatível
[ ] baseline correto
[ ] pivot correto
[ ] transparência correta
[ ] silhueta legível
[ ] baixa densidade
[ ] poucos detalhes
[ ] paleta controlada
[ ] sem gradiente
[ ] sem anti-aliasing
[ ] sem aparência de ilustração reduzida
[ ] cabelo simples
[ ] rosto simples
[ ] roupa legível
[ ] compatível com player(3).png
```

------------------------------------------------------------------------

# 50. QUALITY GATE --- TILE

``` text
[ ] escala correta
[ ] pixel density correta
[ ] material reconhecível
[ ] shading consistente
[ ] sem gradientes
[ ] sem anti-aliasing
[ ] não apresenta textura fotográfica
[ ] integra com tiles existentes
[ ] possui variantes quando necessário
[ ] possui transições quando necessário
[ ] não cria repetição óbvia
[ ] colisão planejada
```

------------------------------------------------------------------------

# 51. QUALITY GATE --- MAPA

``` text
[ ] identidade regional
[ ] macro composição
[ ] caminhos
[ ] transitions
[ ] landmarks
[ ] vegetação
[ ] pedras
[ ] ground details
[ ] props
[ ] NPCs
[ ] objetos interativos
[ ] segredos
[ ] áreas de interesse
[ ] variedade
[ ] ausência de repetição excessiva
[ ] colisões corretas
[ ] navegação correta
[ ] iluminação
[ ] clima
[ ] eventos
```

------------------------------------------------------------------------

# 52. QUALITY GATE --- WORLD DETAIL

Perguntar:

1.  O mapa parece vazio?
2.  Há repetição evidente?
3.  Existem variações de terreno?
4.  Há detalhes pequenos suficientes?
5.  Existem landmarks?
6.  As transições parecem naturais?
7.  Há elementos de escala macro, média e pequena?
8.  O cenário parece pertencer ao mesmo jogo?
9.  O mundo possui identidade?
10. O mapa parece produzido manualmente mesmo usando geração assistida?

Se várias respostas forem "não", o mapa não está pronto.

------------------------------------------------------------------------

# 53. TESTE DE DISTÂNCIA

Todo asset deve ser observado em pelo menos:

-   tamanho de trabalho;
-   tamanho aproximado de gameplay;
-   zoom reduzido.

Se os detalhes desaparecem mas a forma continua legível:

bom.

Se o asset só parece bom com zoom extremo:

revisar.

------------------------------------------------------------------------

# 54. TESTE DE COERÊNCIA

Colocar o asset novo ao lado de assets antigos.

Perguntar:

> Parece que foi criado para o mesmo jogo?

Se não:

-   corrigir escala;
-   corrigir densidade;
-   corrigir paleta;
-   corrigir shading;
-   corrigir outline;
-   corrigir proporção.

Não aprovar apenas porque o asset é bonito isoladamente.

------------------------------------------------------------------------

# 55. PRINCÍPIO "COERÊNCIA \> BELEZA ISOLADA"

Um asset individualmente bonito pode ser errado para o jogo.

Prioridade:

``` text
coerência
>
legibilidade
>
integração
>
identidade
>
detalhe
>
beleza isolada
```

------------------------------------------------------------------------

# 56. PRINCÍPIO "MAIS PIXELS NÃO É AUTOMATICAMENTE MELHOR"

Para personagens:

menos detalhes.

Para mundo:

mais riqueza ambiental.

Isso não é contradição.

É hierarquia visual.

------------------------------------------------------------------------

# 57. PRINCÍPIO "DETALHE CONTROLADO"

Detalhe deve possuir função.

Um detalhe pode:

-   indicar material;
-   indicar direção;
-   indicar uso;
-   indicar dano;
-   criar identidade;
-   quebrar repetição;
-   orientar o jogador;
-   contar história.

Detalhe puramente decorativo pode existir, mas não deve dominar a
composição.

------------------------------------------------------------------------

# 58. PRINCÍPIO "NÃO PREENCHER POR PREENCHER"

Um mapa rico não é um mapa coberto de objetos.

Deixar áreas de respiro.

Usar densidade variável:

``` text
alta densidade → landmark
média densidade → caminho/atividade
baixa densidade → transição/respiro
```

------------------------------------------------------------------------

# 59. IDENTIDADE REGIONAL

Cada região deve possuir:

-   paleta própria;
-   vegetação própria;
-   pedras próprias;
-   terreno próprio;
-   arquitetura própria;
-   landmarks próprios;
-   props próprios;
-   clima possível;
-   eventos próprios.

Mesmo usando o mesmo pipeline, regiões não devem parecer cópias.

------------------------------------------------------------------------

# 60. REUTILIZAÇÃO INTELIGENTE

Reutilizar:

-   sistemas;
-   famílias de tiles;
-   bases;
-   variantes;
-   props genéricos.

Não reutilizar excessivamente:

-   landmarks;
-   elementos narrativos;
-   objetos que deveriam identificar uma região.

------------------------------------------------------------------------

# 61. ART DIRECTION POR SAGA

Quando novas sagas forem adicionadas:

não criar um novo estilo de pixel art.

Manter:

-   mesma linguagem de pixels;
-   mesma escala;
-   mesma filosofia de personagem;
-   mesmo padrão de UI.

Alterar apenas:

-   ambiente;
-   paleta regional;
-   arquitetura;
-   vegetação;
-   props;
-   efeitos específicos;
-   elementos narrativos.

------------------------------------------------------------------------

# 62. FUTURO DARK CONTINENT / ÁREAS ESPECIAIS

Áreas futuras podem ter:

-   flora diferente;
-   fauna estranha;
-   estruturas incomuns;
-   maior contraste;
-   efeitos especiais;
-   assets raros.

Mas ainda devem parecer Hunter Online.

"Especial" não significa "outro jogo".

------------------------------------------------------------------------

# 63. PIPELINE DE APROVAÇÃO

Nenhum asset gerado por IA deve entrar diretamente no jogo sem passar
por:

``` text
Generate
↓
Compare with references
↓
Reject obvious mismatch
↓
Refine
↓
Integrate into tileset/library
↓
Test in Godot
↓
Compare at gameplay scale
↓
Approve
```

------------------------------------------------------------------------

# 64. QUANDO REJEITAR UM ASSET

Rejeitar imediatamente se:

-   parece outro jogo;
-   possui resolução visual diferente;
-   possui anti-aliasing;
-   possui gradientes;
-   possui excesso de detalhes;
-   parece concept art;
-   parece 3D;
-   parece vetor;
-   possui escala errada;
-   não integra com os assets existentes;
-   quebra a leitura do mapa;
-   exige zoom para ser compreendido.

------------------------------------------------------------------------

# 65. QUANDO NÃO GERAR UM NOVO ASSET

Antes de chamar o PixelLab, verificar:

> Já existe algo reutilizável?

Se sim:

1.  reutilizar;
2.  criar variante;
3.  modificar composição;
4.  só então gerar novo asset.

Isso evita inflação desnecessária da biblioteca.

------------------------------------------------------------------------

# 66. PRODUÇÃO INCREMENTAL

Não tentar criar o jogo visual inteiro de uma vez.

A estratégia é:

``` text
Região
↓
assets
↓
composição
↓
polish
↓
aprovação
↓
próxima região
```

Cada região aprovada aumenta a biblioteca global.

------------------------------------------------------------------------

# 67. PRIMEIRA META VISUAL

A primeira grande meta não é:

> "ter 30 mapas".

É:

> **ter uma região definitiva que pareça um jogo completo.**

Essa região deve provar que o pipeline funciona.

Depois:

``` text
região 1
→ região 2
→ estrada
→ floresta
→ cidade
→ dungeon
→ novas sagas
```

------------------------------------------------------------------------

# 68. MAPA FINAL --- CHECKLIST DE PRODUÇÃO

Antes de marcar uma região como definitiva:

``` text
ART
[ ] terrain
[ ] transitions
[ ] variants
[ ] vegetation
[ ] rocks
[ ] props
[ ] structures
[ ] landmarks
[ ] NPCs
[ ] enemies
[ ] effects

GAMEPLAY
[ ] navigation
[ ] collision
[ ] interaction
[ ] combat
[ ] quests
[ ] secrets
[ ] events

WORLD
[ ] identity
[ ] time
[ ] weather
[ ] NPC schedules
[ ] environmental storytelling

TECHNICAL
[ ] asset catalog
[ ] naming
[ ] scene integration
[ ] performance
[ ] save/load compatibility
[ ] regression tests
```

------------------------------------------------------------------------

# 69. REGRA PARA O ANTIGRAVITY

Ao trabalhar com arte:

**não assumir que o pedido "faça mais bonito" significa "adicione
detalhes".**

Primeiro diagnosticar:

-   falta de variação?
-   falta de transição?
-   falta de composição?
-   falta de landmarks?
-   falta de objetos?
-   falta de contraste?
-   falta de vegetação?
-   falta de shading?
-   falta de identidade?

Só depois alterar assets.

------------------------------------------------------------------------

# 70. REGRA PARA O PIXELLAB

Ao gerar:

> **não maximizar detalhe. Maximizar coerência, leitura e riqueza
> ambiental controlada.**

Personagens:

> pequenos, simples e reconhecíveis.

Mundo:

> detalhado, variado e vivo.

Landmarks:

> memoráveis.

Efeitos:

> claros e rápidos.

------------------------------------------------------------------------

# 71. ANTI-STYLE-DRIFT

A cada nova geração comparar com:

-   `player(3).png`;
-   world detail reference;
-   assets aprovados mais recentes.

Se a geração começar a ficar progressivamente:

-   mais HD;
-   mais suave;
-   mais detalhada;
-   mais realista;
-   mais brilhante;
-   mais complexa;

reduzir e recalibrar.

------------------------------------------------------------------------

# 72. DEFINIÇÃO DE "PIXEL ART APROVADA"

Uma arte está aprovada quando:

> **parece ter sido criada diretamente para Hunter Online.**

Não quando:

> "parece uma ótima imagem de pixel art".

Essa diferença é fundamental.

------------------------------------------------------------------------

# 73. DOCUMENTAÇÃO OBRIGATÓRIA

Mudanças relevantes na pipeline visual devem atualizar:

-   este documento;
-   Art Bible existente;
-   catálogo de assets;
-   documentação técnica relevante.

Não criar documentos duplicados para a mesma regra.

Se outro documento já for a fonte oficial de determinada regra,
atualizar a fonte existente.

------------------------------------------------------------------------

# 74. REGISTRO DE ASSETS

Para assets importantes registrar:

``` text
Asset:
Category:
Region:
Source:
PixelLab generation/reference:
Style anchor:
Dimensions:
Animation:
Collision:
Godot integration:
Status:
```

Status possíveis:

-   planned;
-   generating;
-   review;
-   approved;
-   integrated;
-   deprecated.

------------------------------------------------------------------------

# 75. CONTROLE DE VERSÃO VISUAL

Quando um asset for substituído:

não apagar imediatamente a referência anterior se ela for necessária
para regressão.

Registrar:

``` text
old asset
→ reason for replacement
→ new asset
→ approved date/version
```

------------------------------------------------------------------------

# 76. PERFORMANCE

Riqueza visual não pode significar desperdício técnico.

Preferir:

-   atlas/tileset;
-   reutilização;
-   variantes;
-   assets pequenos;
-   composição no Godot;
-   evitar texturas gigantes sem necessidade.

Não duplicar dezenas de texturas idênticas.

------------------------------------------------------------------------

# 77. PIXEL-PERFECT

Preservar a filosofia pixel-perfect do projeto.

Evitar:

-   escalas fracionárias;
-   subpixel movement visual quando não desejado;
-   filtering suave;
-   transformação que borra pixels.

Manter a apresentação consistente com o render base do jogo.

------------------------------------------------------------------------

# 78. CÂMERA E ESCALA

Toda avaliação visual deve considerar a escala real de gameplay.

Um asset que parece perfeito no editor pode parecer:

-   pequeno demais;
-   grande demais;
-   detalhado demais;
-   simples demais

quando colocado na câmera real.

Sempre validar dentro do jogo.

------------------------------------------------------------------------

# 79. GUIA DE DECISÃO RÁPIDA

Quando houver dúvida:

### Personagem ficou detalhado demais?

Reduzir detalhes.

### Tile ficou simples demais?

Adicionar variações e detalhes ambientais.

### Mapa ficou vazio?

Adicionar composição, não apenas mais tiles.

### Mapa ficou poluído?

Reduzir objetos e preservar áreas de respiro.

### Asset não combina?

Priorizar coerência sobre beleza isolada.

### Região parece igual à anterior?

Adicionar identidade regional.

### PixelLab gerou algo bonito mas incompatível?

Rejeitar.

------------------------------------------------------------------------

# 80. TARGET FINAL

O Hunter Online deve chegar visualmente a:

``` text
PERSONAGEM
↓
pequeno
legível
simples
48×48
identidade forte

AMBIENTE
↓
rico
variado
detalhado
pixelado
camadas de profundidade

MAPA
↓
bem composto
com landmarks
com vida
com segredos
com identidade

EFEITOS
↓
claros
rápidos
pixelados
sem excesso

MUNDO
↓
coeso
memorável
vivo
expansível
```

------------------------------------------------------------------------

# 81. FRASE-MESTRA DA ART DIRECTION

> **Hunter Online não busca a maior quantidade possível de pixels. Busca
> a maior quantidade possível de identidade e riqueza visual dentro de
> uma linguagem de pixel art coerente.**

E:

> **Personagens simples não significam mundo simples.**

E:

> **Mais detalhe no cenário, mais identidade nos personagens e mais
> variação no mundo --- sem perder a escala e a linguagem visual do
> jogo.**

------------------------------------------------------------------------

# 82. INSTRUÇÃO FINAL PARA AGENTES DE IA

Antes de qualquer tarefa de arte:

1.  ler este documento;
2.  verificar os style anchors;
3.  procurar assets existentes;
4.  reutilizar antes de gerar;
5.  gerar somente o necessário;
6.  comparar com assets aprovados;
7.  integrar no Godot;
8.  validar na escala real;
9.  documentar mudanças;
10. não criar um novo estilo sem autorização explícita.

**Nunca sacrificar a identidade visual do Hunter Online por uma geração
individualmente mais impressionante.**

------------------------------------------------------------------------

# 83. REFERÊNCIA OFICIAL DO PIPELINE PIXELLAB

Documentação oficial:

`https://api.pixellab.ai/mcp/docs`

Ao utilizar PixelLab MCP, consultar a documentação atual para confirmar:

-   ferramentas disponíveis;
-   parâmetros;
-   referências;
-   geração de personagens;
-   animações;
-   tilesets;
-   assets;
-   operações assíncronas.

Não inventar parâmetros ou APIs.

------------------------------------------------------------------------

# 84. DEFINIÇÃO DE PRONTO

A pipeline visual está funcionando quando:

-   novos personagens parecem pertencer ao mesmo jogo;
-   novos tiles integram naturalmente;
-   regiões possuem identidade;
-   mapas não parecem vazios;
-   mapas não parecem excessivamente poluídos;
-   assets possuem variantes;
-   transições parecem naturais;
-   landmarks são memoráveis;
-   PixelLab acelera produção em vez de introduzir inconsistência;
-   o Godot recebe assets organizados e reutilizáveis;
-   o mundo fica progressivamente mais rico sem virar visualmente
    incoerente.

**Este documento é uma regra de produção, não apenas uma referência
estética.**
