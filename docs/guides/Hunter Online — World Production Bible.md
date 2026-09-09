# HUNTER ONLINE
## WORLD PRODUCTION & PIXEL ART PIPELINE BIBLE

**Projeto:** Hunter Online  
**Engine:** Godot 4.6  
**Gênero:** MMORPG 2D Top-Down  
**Direção:** Hunter x Hunter-inspired original MMORPG  
**Pixel Art:** PixelLab + MCP + Godot  
**Status:** Documento de produção permanente

---

# 1. OBJETIVO DESTE DOCUMENTO

Este documento define como o mundo definitivo de Hunter Online deve ser produzido daqui em diante.

A regra mais importante é:

> **NÃO produzir protótipos descartáveis quando for possível produzir conteúdo definitivo.**

O projeto será construído gradualmente.

Cada mapa, personagem, NPC, inimigo, animação, tileset, efeito e sistema produzido deve ser pensado para permanecer no jogo final.

Não existe a mentalidade:

```text
"vamos fazer um teste e depois refazer."
```

A mentalidade correta é:

```text
"vamos fazer uma parte pequena, mas definitiva."
```

É permitido avançar lentamente.

É preferível ter:

- 1 cidade excelente;
- 3 mapas conectados;
- 5 NPCs bons;
- 1 player excelente;

do que:

- 20 mapas genéricos;
- 100 NPCs provisórios;
- centenas de sprites inconsistentes.

---

# 2. PAPEL DO ANTIGRAVITY

O Antigravity deve atuar como:

- Lead Game Developer;
- World Designer;
- Gameplay Engineer;
- Technical Artist;
- Pixel Art Pipeline Manager;
- QA Engineer;
- Documentador.

Ele não deve apenas escrever código.

Ele deve:

1. auditar;
2. planejar;
3. criar;
4. integrar;
5. testar;
6. corrigir;
7. documentar.

Sempre que uma ferramenta MCP estiver disponível, ela deve ser considerada antes de inventar uma solução manual.

---

# 3. PIXELLAB MCP

Use como referência oficial:

[PixelLab MCP Documentation](https://api.pixellab.ai/mcp/docs?utm_source=chatgpt.com)

A documentação oficial deve ser consultada sempre que houver dúvida sobre:

- criação de personagens;
- animações;
- direções;
- tilesets;
- geração de assets;
- referências;
- jobs assíncronos;
- custo de geração;
- ferramentas disponíveis.

O PixelLab MCP trabalha com operações assíncronas e fornece IDs de jobs/recursos que devem ser consultados posteriormente.

NÃO assumir que uma geração terminou imediatamente.

Fluxo:

```text
CRIAR
 ↓
OBTER ID
 ↓
CONSULTAR STATUS
 ↓
VALIDAR RESULTADO
 ↓
BAIXAR/INTEGRAR
 ↓
TESTAR NO GODOT
```

---

# 4. REGRA DE CRIATIVIDADE

O agente deve usar criatividade.

Porém:

> **criatividade não significa aleatoriedade.**

A criatividade deve existir dentro da linguagem de Hunter Online.

Usar como referência conceitual:

- Hunter x Hunter;
- cidades de aventura;
- Hunter Association;
- viagens;
- treinamento;
- Nen;
- Hunters;
- torneios;
- mercados;
- guildas;
- regiões perigosas;
- cidades com personalidade;
- ambientes naturais;
- organizações;
- rivalidades;
- exploração;
- mistério;
- preparação para missões.

NÃO copiar diretamente:

- cidades;
- personagens;
- roupas;
- mapas;
- arquitetura específica;
- sprites;
- logos;
- layouts exatos.

O resultado deve parecer:

> **"um mundo que poderia existir ao lado do universo de Hunter x Hunter"**

e não:

> "uma cópia do anime."

---

# 5. PRINCÍPIO DE DESIGN DO MUNDO

Cada região deve responder:

### Onde estou?

O jogador precisa reconhecer visualmente o lugar.

### Por que estou aqui?

A região precisa ter uma função.

### O que existe aqui?

NPCs, atividades, caminhos, landmarks e segredos.

### Para onde posso ir?

A navegação precisa ser natural.

### O que existe além?

O mapa deve sugerir expansão do mundo.

---

# 6. ESCALA DO MUNDO

Não criar mapas gigantes apenas para parecer que o jogo é grande.

Preferir:

```text
MAPA PEQUENO + DENSO
```

a:

```text
MAPA GIGANTE + VAZIO
```

Um mapa deve possuir:

- caminhos;
- landmarks;
- áreas abertas;
- áreas fechadas;
- pontos de interesse;
- pequenas histórias visuais;
- obstáculos;
- atalhos;
- locais secundários;
- espaço para NPCs;
- áreas de exploração.

---

# 7. ESTRUTURA DE FASES

O mundo será construído em fases permanentes.

Exemplo:

```text
FASE 01
Cidade Inicial

FASE 02
Estrada da Cidade

FASE 03
Floresta

FASE 04
Área de Treinamento

FASE 05
Primeira Região de Caça

FASE 06
Dungeon

FASE 07
Nova Cidade

FASE 08
Região Perigosa
```

Essas fases NÃO são testes.

Cada uma passa a fazer parte do mundo definitivo.

---

# 8. CONECTIVIDADE

O mundo deve evoluir para uma estrutura semelhante a:

```text
                 CIDADE
                   |
                ESTRADA
                   |
                FLORESTA
                /      \
        ÁREA DE CAÇA   RUÍNAS
                          |
                       DUNGEON
```

O jogador deve sentir que está viajando.

Evitar a estrutura:

```text
Lobby
 ↓
Tela de seleção
 ↓
Mapa isolado
 ↓
Voltar ao lobby
```

sempre que uma conexão física fizer sentido.

---

# 9. CIDADES

Cada cidade precisa possuir identidade.

Uma cidade pode ter:

- praça;
- comércio;
- associação;
- área residencial;
- treinamento;
- hospedagem;
- becos;
- locais secretos;
- NPCs;
- serviços;
- saídas.

Não é obrigatório que todas tenham exatamente os mesmos elementos.

A repetição deve ser evitada.

---

# 10. LANDMARKS

Cada região precisa ter elementos que permitam ao jogador dizer:

> "eu sei onde estou."

Exemplos:

- torre;
- grande árvore;
- prédio da associação;
- ponte;
- estátua;
- arena;
- lago;
- mercado;
- portão;
- montanha;
- ruína;
- templo;
- navio;
- estação.

Landmarks devem funcionar também como pontos de orientação.

---

# 11. CAMINHOS

Os caminhos devem parecer construídos para pessoas.

Evitar:

- corredores perfeitamente retos em excesso;
- mapas quadrados;
- caminhos sem destino;
- paredes aleatórias;
- áreas impossíveis de atravessar.

Criar:

- curvas;
- bifurcações;
- pequenas áreas abertas;
- atalhos;
- caminhos secundários;
- pontos de encontro.

---

# 12. HITBOXES — REGRA PERMANENTE

Hitboxes devem representar o espaço físico real.

O problema atual do projeto apresentou colisões aproximadamente 25% maiores que o esperado.

Isso deve ser tratado como um problema de pipeline, não como um simples ajuste visual.

Antes de alterar colisões, auditar:

- escala do sprite;
- escala do Node;
- escala herdada;
- TileMap;
- TileSet;
- CollisionShape2D;
- origem;
- pivot;
- offset;
- tamanho do tile;
- pixels por unidade;
- câmera;
- zoom;
- transformação dos pais.

Nunca aplicar:

```text
scale *= 0.75
```

sem entender a causa.

---

# 13. PLAYER HITBOX

A colisão do player deve representar principalmente sua base física/pés.

Em RPG top-down:

```text
      CABEÇA
       ███
      █████
      █████
       ███
      ████
     ██████  ← área física principal
```

A região dos pés/base deve determinar principalmente a colisão.

Isso permite:

- passar atrás de objetos;
- passar na frente;
- posicionamento natural;
- Y-sort/depth sorting.

---

# 14. OBJETOS

Objetos sólidos devem ter colisões coerentes.

Exemplos:

- paredes;
- prédios;
- árvores;
- pedras;
- caixas;
- móveis;
- cercas;
- postes;
- obstáculos.

Elementos puramente decorativos não precisam necessariamente possuir colisão.

Não transformar cada pixel visual em colisão.

---

# 15. CORREDORES E PASSAGENS

Se visualmente existe espaço para passar:

o jogador deve conseguir passar.

Nunca criar:

```text
██████████
█        █
█  PLAYER█
█        █
██████████
```

quando o corredor visualmente permite movimento.

Colisões invisíveis são bugs de game feel.

---

# 16. PIXEL ART — PADRÃO DEFINITIVO

Personagens:

**48×48 pixels por frame.**

Manter:

- fundo transparente;
- baseline consistente;
- pés alinhados;
- pivot coerente;
- escala consistente;
- proporções consistentes;
- silhueta legível.

Não misturar:

```text
personagem 32px
personagem 48px
personagem 64px
```

sem uma decisão artística deliberada.

---

# 17. PERSONAGENS

Cada personagem importante deve possuir identidade.

Não gerar apenas:

> "homem de camisa"

Criar conceitos como:

- Hunter veterano;
- comerciante excêntrico;
- aprendiz de Nen;
- examinador;
- viajante;
- lutador;
- médico;
- cozinheiro;
- treinador;
- informante;
- rival;
- mercenário.

Cada personagem importante deve possuir:

- silhueta;
- roupa;
- paleta;
- personalidade visual;
- função narrativa.

---

# 18. USO DO PIXELLAB PARA PERSONAGENS

Quando possível:

1. criar personagem base;
2. completar 8 direções;
3. verificar consistência;
4. criar estados;
5. criar animações;
6. integrar no Godot.

Não gerar cada animação como um personagem independente.

Usar o mesmo personagem como origem para manter identidade.

---

# 19. DIREÇÕES

Personagens principais devem preferencialmente utilizar:

**8 direções**

- south;
- south-east;
- east;
- north-east;
- north;
- north-west;
- west;
- south-west.

Não aceitar inconsistência entre direções.

---

# 20. ANIMAÇÕES

Personagens importantes devem evoluir para:

```text
IDLE
WALK
RUN
ATTACK
DASH
HIT
DEATH
SPECIAL
```

Nem todo NPC precisa de todas.

NPC comum pode possuir:

```text
IDLE
WALK
```

Player e personagens importantes devem receber tratamento maior.

---

# 21. GAME FEEL DO PLAYER

O player deve transmitir:

- velocidade;
- peso;
- direção;
- impacto;
- controle.

Movimento:

```text
INPUT
 ↓
MOVIMENTO
 ↓
ANIMAÇÃO
```

Ataque:

```text
INPUT
 ↓
PREPARAÇÃO
 ↓
DASH
 ↓
GOLPE
 ↓
IMPACTO
 ↓
RECUPERAÇÃO
```

---

# 22. DASH

Dash de ataque deve:

- ser curto;
- rápido;
- direcionado;
- respeitar colisões;
- não atravessar paredes;
- não ser teleport;
- possuir parâmetros configuráveis.

Parâmetros devem ser centralizados.

---

# 23. ONDA DE AR

Ataques físicos rápidos podem produzir efeitos visuais como:

- ondas;
- linhas de pressão;
- ar deslocado;
- poeira;
- partículas;
- pequenos arcos;
- impacto.

O efeito deve comunicar:

> "esse golpe deslocou o ar."

Não transformar automaticamente em habilidade ranged.

---

# 24. EFEITOS DE COMBATE

Criar assets reutilizáveis:

```text
ATTACK_WIND
ATTACK_IMPACT
DASH_TRAIL
DUST_IMPACT
```

Os efeitos devem:

```text
SPAWN
 ↓
PLAY
 ↓
FINISH
 ↓
CLEANUP/REUSE
```

Evitar vazamento de Nodes.

---

# 25. DESIGN DE MAPAS COM PIXELLAB

Para terrenos top-down, utilizar as ferramentas apropriadas do PixelLab MCP.

Priorizar tilesets que possam ser conectados.

Quando houver transições:

```text
TERRENO A
   ↓
TRANSIÇÃO
   ↓
TERRENO B
```

Manter:

- mesma perspectiva;
- mesma escala;
- mesma paleta;
- mesmo nível de detalhe.

---

# 26. TERRENOS

Exemplos de evolução:

```text
cidade
 ↓
estrada de terra
 ↓
grama
 ↓
floresta
 ↓
pântano
 ↓
ruínas
```

As transições devem parecer parte do mesmo mundo.

---

# 27. CONSISTÊNCIA VISUAL

Antes de aceitar qualquer asset novo, comparar com os assets existentes.

Verificar:

### PERSPECTIVA

É a mesma?

### ESCALA

O personagem parece do mesmo tamanho?

### PALETA

As cores pertencem ao mesmo universo?

### SOMBREAMENTO

A iluminação é coerente?

### OUTLINE

É coerente?

### DETALHE

Possui o mesmo nível de informação?

### SILHUETA

Funciona mesmo em tamanho pequeno?

Se falhar:

refazer.

---

# 28. CRIATIVIDADE CONTROLADA

O agente deve propor ideias próprias.

Porém cada ideia deve passar por:

```text
CRIATIVIDADE
 ↓
COERÊNCIA COM HUNTER ONLINE
 ↓
COERÊNCIA COM HUNTER X HUNTER
 ↓
COERÊNCIA COM GAMEPLAY
 ↓
COERÊNCIA VISUAL
 ↓
IMPLEMENTAÇÃO
```

Não implementar ideias apenas porque parecem bonitas.

---

# 29. WORLD STORYTELLING

O ambiente deve contar histórias sem depender sempre de diálogo.

Exemplos:

- prédio destruído;
- treinamento marcado no chão;
- cartazes;
- mercado movimentado;
- área abandonada;
- equipamento de Hunter;
- acampamento;
- vestígios de batalha;
- caminhos bloqueados;
- pequenas construções.

O jogador deve perceber que o mundo possui história.

---

# 30. NPC DESIGN

NPCs não devem ser simplesmente obstáculos.

Cada NPC importante deve ter:

- função;
- localização lógica;
- personalidade;
- aparência própria;
- possibilidade de expansão narrativa.

NPCs comuns podem ser simples.

NPCs importantes devem ser memoráveis.

---

# 31. CONSTRUÇÃO POR FASES

Sempre trabalhar na menor unidade que possa ser finalizada.

Exemplo:

## Fase 1

Finalizar:

- praça;
- colisões;
- player;
- NPCs básicos;
- Hunter Association.

## Fase 2

Adicionar:

- comércio;
- residência;
- treinamento;
- novos NPCs.

## Fase 3

Adicionar:

- saída;
- estrada;
- transição de terreno.

## Fase 4

Adicionar:

- floresta;
- inimigos;
- exploração.

## Fase 5

Adicionar:

- primeira dungeon.

Cada fase permanece no projeto.

---

# 32. NÃO AVANÇAR DEMAIS

Não gerar:

- 10 mapas de uma vez;
- 50 NPCs;
- 100 inimigos;
- centenas de sprites.

Faça uma pequena parte.

Finalize.

Teste.

Depois expanda.

---

# 33. LOOP DE PRODUÇÃO

Para cada nova área:

```text
1. AUDITAR
2. DEFINIR FUNÇÃO
3. DEFINIR IDENTIDADE
4. CRIAR TERRENO
5. CRIAR LANDMARKS
6. CRIAR COLISÕES
7. CRIAR NPCS
8. CRIAR INTERAÇÕES
9. TESTAR NAVEGAÇÃO
10. REFINAR
11. DOCUMENTAR
12. MARCAR COMO FINAL
```

---

# 34. QA OBRIGATÓRIO

Antes de considerar uma área pronta:

### COLISÃO

- player não atravessa paredes;
- player não fica preso;
- corredores funcionam;
- objetos sólidos funcionam;
- NPCs funcionam.

### VISUAL

- nenhuma área quebrada;
- nenhum tile desalinhado;
- nenhuma borda estranha;
- nenhuma escala incompatível.

### GAMEPLAY

- player consegue navegar;
- NPCs podem ser encontrados;
- saídas funcionam;
- câmera funciona.

### PERFORMANCE

- sem Nodes acumulando;
- sem erros;
- sem warnings graves;
- sem efeitos vazando.

---

# 35. REGRA SOBRE TESTES

Testes podem ser temporários.

CONTEÚDO NÃO.

Um teste pode verificar:

> "o player consegue atravessar esta ponte?"

Mas a ponte criada para esse teste deve ser a ponte definitiva se ela for mantida no jogo.

Não criar um "mapa de teste da ponte" para depois jogar fora.

---

# 36. DOCUMENTAÇÃO

Após cada fase relevante:

atualizar a documentação existente.

Registrar:

- mapas;
- conexões;
- NPCs;
- assets;
- colisões;
- animações;
- decisões;
- problemas;
- soluções;
- PixelLab IDs;
- referências utilizadas.

Não criar documentação duplicada.

---

# 37. REGISTRO DE ASSETS

Sempre que um asset importante for criado pelo PixelLab, registrar:

```text
Asset:
Tipo:
PixelLab ID:
Descrição:
Tamanho:
Direções:
Animações:
Mapa:
Local no projeto:
Referência utilizada:
Observações:
```

Isso permite regenerar ou atualizar assets futuramente.

---

# 38. USO EFICIENTE DO PIXELLAB

O agente deve evitar desperdício de gerações.

Antes de criar:

- verificar se já existe;
- verificar personagens existentes;
- verificar tilesets existentes;
- verificar se pode reutilizar;
- verificar se pode criar uma variação;
- verificar se pode usar referência.

Não gerar novamente algo que já está correto.

---

# 39. REFERÊNCIAS VISUAIS

Quando houver um asset definitivo que represente o estilo:

usar esse asset como referência para novos assets quando a ferramenta permitir.

Objetivo:

```text
STYLE REFERENCE
      ↓
NOVO ASSET
      ↓
MESMA LINGUAGEM VISUAL
```

Não permitir que cada geração invente um estilo diferente.

---

# 40. PLAYER COMO STYLE ANCHOR

O player definitivo deve ser uma das principais referências visuais do projeto.

Novos:

- NPCs;
- inimigos;
- personagens;

devem ser comparados visualmente com ele.

O player define:

- escala;
- perspectiva;
- nível de detalhe;
- proporções;
- linguagem de pixel art.

---

# 41. REGRA DE ESCALA

Antes de integrar qualquer personagem:

verificar:

```text
FRAME = 48x48
```

Verificar também:

- tamanho visual;
- altura aparente;
- pés;
- largura;
- pivot.

Um personagem não deve parecer gigante apenas porque possui mais pixels transparentes.

---

# 42. REGRA DE HITBOX + SPRITE

Nunca assumir:

```text
sprite_size == collision_size
```

A colisão deve ser baseada no espaço físico.

Para player:

```text
visual ≠ hitbox

visual
████████
████████
  ████
  ████
  ████
   ██
  ████ ← collision/base
```

---

# 43. REGRA DE MAPA FINAL

Cada mapa deve ser considerado parte da continuidade do mundo.

Perguntar:

- De onde o jogador veio?
- Para onde pode ir?
- Por que esse local existe?
- Quem vive aqui?
- O que acontece aqui?
- O que pode ser descoberto?
- O que pode mudar futuramente?

---

# 44. REGRA DE EXPANSÃO FUTURA

Não fechar mapas de forma que futuras sagas fiquem impossíveis.

Sempre que possível deixar:

- estradas;
- portões;
- caminhos;
- portos;
- cavernas;
- passagens;
- regiões distantes;
- áreas bloqueadas narrativamente.

Isso permite expansão futura.

---

# 45. PROGRESSÃO DO MUNDO

O mundo deve crescer junto com o jogo.

Primeiro:

```text
CIDADE
```

Depois:

```text
CIDADE
 ↓
ESTRADA
 ↓
FLORESTA
```

Depois:

```text
REGIÃO
 ↓
DUNGEON
 ↓
NOVA CIDADE
```

Depois:

```text
CONTINENTE
 ↓
NOVAS REGIÕES
 ↓
NOVAS SAGAS
```

O design deve permitir crescimento contínuo.

---

# 46. CRITÉRIO FINAL

Uma fase só está pronta quando:

- possui identidade;
- possui função;
- possui navegação;
- possui colisões corretas;
- possui escala correta;
- possui assets coerentes;
- possui integração com o jogo;
- não é placeholder;
- não quebra sistemas existentes;
- foi testada;
- foi documentada.

---

# 47. RELATÓRIO OBRIGATÓRIO

Ao finalizar cada fase, produzir:

## IMPLEMENTADO

## MAPAS

## NPCS

## PLAYER

## ANIMAÇÕES

## PIXELLAB

## HITBOXES

## COLISÕES

## GAMEPLAY

## TESTES

## ERROS ENCONTRADOS

## CORREÇÕES

## ASSETS CRIADOS

## DOCUMENTAÇÃO ATUALIZADA

## PENDÊNCIAS

## PRÓXIMA FASE

---

# 48. REGRA FINAL PARA O AGENTE

Não tente terminar o jogo inteiro de uma vez.

Construa o mundo permanentemente.

Cada pequena vitória deve permanecer.

A filosofia é:

> **Pouco conteúdo, mas definitivo.**

Depois:

> **Mais conteúdo, mantendo a mesma qualidade.**

E eventualmente:

```text
UMA CIDADE
 ↓
UM MUNDO
 ↓
UM CONTINENTE
 ↓
UM MMORPG
```

O objetivo final é que Hunter Online pareça um mundo grande porque ele foi construído com consistência, não porque recebeu centenas de assets aleatórios.

Sempre priorize:

1. qualidade;
2. consistência;
3. jogabilidade;
4. colisões;
5. identidade;
6. expansão futura;
7. performance;
8. documentação.

Não sacrificar qualidade apenas para produzir mais conteúdo.