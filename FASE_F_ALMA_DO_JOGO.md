# FASE F — ALMA DO JOGO
## Hunter MMORPG — Story Experience, Living World e Imersão

> Objetivo: transformar o projeto de um protótipo funcional em uma experiência de RPG 2D realmente imersiva, narrativa, viva e com sensação de aventura.

## 0. Diretrizes

- Jogador = protagonista da própria versão da história.
- Participa dos acontecimentos canônicos junto de Gon, Killua e outros personagens.
- Possui trajetória própria por escolhas, lobby, side quests, treinamentos e atividades.
- O mundo deve incentivar exploração, conversa, treinamento e descoberta.
- Objetivo principal sempre claro, mesmo quando o jogador se desvia para atividades secundárias.
- Ritmo mais lento quando a narrativa pedir: mais diálogos, cenas, viagens, acontecimentos e momentos de respiro.
- NPCs importantes devem parecer personagens, não máquinas de quest.
- Combate continua importante, mas não pode ser o único meio de progresso.
- Hatsu deve ser um dos principais elementos estratégicos do combate.
- Nen continua como Skill Tree passiva; não reintroduzir o sistema antigo de ativação manual.
- Combate NÃO deve copiar Xenoverse: usar filosofia de MMORPG 2D em tempo real com ataques, esquiva, ataque forte/lento, status effects, IA e Hatsus.
- Não criar sistemas gigantes prematuramente. Priorizar experiência.

## 1. Auditoria inicial

Antes de implementar, auditar o código e cenas reais de:

- Story Mode
- cutscenes e diálogos
- DialogueBox
- quests e objetivos
- Quest Tracker
- NPCs
- mapas, portais e transições
- lobby
- combate
- Hatsu
- Nen Skill Tree
- save/load
- progressão
- câmera
- áudio/música/efeitos
- triggers e flags

Criar `docs/GAME_EXPERIENCE_AUDIT.md` com:
- IMPLEMENTED
- PARTIAL
- ABSENT
- LEGACY
- CONFLICT
- PRIORITY S/A/B/C

Não inventar funcionalidades como implementadas.

## 2. Story Experience System

Criar arquitetura data-driven capaz de alternar entre:

`gameplay → diálogo → cutscene → exploração → combate → evento → treinamento → escolha → gameplay`

A cena deve suportar atores, diálogo, movimento, câmera, espera, animação, áudio, efeitos, condições, escolhas e próximo passo.

Evitar hardcode de cada cena em um script monolítico.

## 3. Cutscene System

Criar sistema reutilizável com:

- bloquear/liberar input
- mover NPCs
- fazer NPC olhar para outro personagem
- movimentar jogador quando necessário
- câmera e foco
- zoom
- shake
- fade/transições
- animações
- waits
- música/sons
- efeitos
- diálogo
- branching simples
- triggers
- retorno ao gameplay

Cutscenes curtas também são válidas. Não transformar todo diálogo em uma cinematic.

## 4. Story Pacing

Evitar constantemente:

`dialogue → kill enemies → reward → next mission`

Permitir variação:

`CUTSCENE → EXPLORAÇÃO → NPC → DIÁLOGO → ACONTECIMENTO → MISSÃO → VIAGEM → TREINAMENTO → COMBATE → CONSEQUÊNCIA → CUTSCENE → NOVO OBJETIVO`

Não aplicar rigidamente; a meta é variedade de ritmo.

Criar momentos sem combate:
- conversar
- caminhar
- observar
- treinar
- comprar
- investigar
- descobrir
- viajar
- esperar evento
- retornar
- encontrar personagem

## 5. Objetivo principal vs atividades

Criar hierarquia clara:

```text
HISTÓRIA PRINCIPAL
○ Encontrar Wing
Progresso: ██████░░░░ 60%

ATIVIDADES
○ Treinamento
○ Side Quest
○ Exploração
○ Evento
○ Hatsu
```

O jogador pode passar bastante tempo em atividades sem perder o objetivo principal.

Criar fonte única de verdade para saga, capítulo, objetivo, progresso, flags e conteúdo desbloqueado.

## 6. Living World / NPCs

NPCs importantes devem possuir:
- rotina
- localização
- profissão
- relações
- estados
- horários
- eventos
- mudanças por progresso
- diálogo contextual
- memória básica
- quests
- treinamento

Começar com 5–10 NPCs para validar.

Schedules podem ser simples, por exemplo:
`08:00 mercado → 12:00 restaurante → 15:00 treinamento → 18:00 casa`

NPCs devem reagir à história:
- antes: diálogo inicial
- depois de missão: reconhecimento
- depois de evento: reação
- depois de saga: mudança de local/comportamento

Não usar IA pesada em centenas de NPCs por frame. Preferir timers, eventos, estados e processamento por proximidade.

## 7. Protagonista e canon

Não recontar Hunter x Hunter simplesmente.

Usar:

`CANON EVENT → jogador participa → possui perspectiva própria → possui missões próprias → pode ter experiências diferentes`

Gon/Killua podem estar envolvidos enquanto o jogador:
- luta junto
- chega antes/depois
- investiga outro ponto
- recebe missão paralela
- descobre informação
- enfrenta outro inimigo
- participa das consequências

Lobby = Living World persistente.
Story Scenes = experiência narrativa mais controlada.

## 8. Combat 2.0

Não transformar em Xenoverse.

Adicionar/refinar:
- ataque normal
- ataque forte e lento
- esquiva
- recuperação
- hit reaction
- status effects
- alcance
- velocidade
- padrões
- IA
- melee
- ranged
- tático
- inimigos com Hatsu
- bosses
- cooldowns
- posicionamento

Inimigos devem ter identidade:
- Brute: lento, pesado, resistente
- Assassin: rápido, flanqueia
- Ranged: mantém distância
- Tactician: reage ao jogador
- Nen User: usa Hatsu e condições
- Boss: fases/padrões

Não depender apenas de level. Habilidade, inteligência, Hatsu, condições, posicionamento e preparação devem importar.

## 9. Inimigos usando Hatsu

Permitir que inimigos tenham `HatsuDefinition` e usem o mesmo pipeline de execução do Hatsu do jogador quando possível.

Estrutura conceitual:

```text
Enemy
 ├── stats
 ├── behavior
 ├── nen_profile
 └── hatsu[]
```

Não criar um segundo sistema de habilidades separado.

## 10. Progressão multifatorial

O jogador deve ter motivos para ficar forte além de XP:

- level
- Nen Skill Tree
- masterização de Hatsu
- equipamentos
- treinamento
- NPC trainers
- quests
- itens especiais
- exploração
- eventos
- descobertas
- recompensas narrativas

A pergunta deve ser "como posso ficar mais forte?", não apenas "onde farmo XP?".

## 11. Nen Skill Tree

Preservar 8 caminhos principais saindo de Nen.

Cada caminho deve ter:
- nós
- tiers
- requisitos
- Skill Points
- locked/available/unlocked/maxed
- conectores
- sinergias
- nós superiores
- identidade

Nós superiores ajudam a definir a "classe" sem classes rígidas.

Masterização deve produzir sensação de:
> "Esse é o tipo de Hunter que eu construí."

Não reintroduzir técnicas Nen como toggles ativos.

## 12. Level 1000

Planejamento:

`Início → sagas → fim da história ≈ LV700+ → endgame → exploração/masterização/eventos → LV1000`

Não fazer LV1000 ser alcançável cedo. Isso preserva espaço para novas sagas.

## 13. Hatsu Creator — preparação

A arquitetura definitiva deve seguir:

`INTENÇÃO → QUÃO PODEROSO? → CUSTO → CONDIÇÕES → RESTRIÇÕES → JURAMENTOS → PREPARAÇÃO → CUSTO FINAL → VALIDAÇÃO → HATSU`

Primeira pergunta relevante:
> Quão poderoso você quer que esse Hatsu seja?

O poder desejado gera uma dívida em créditos. O jogador reduz essa dívida por limitações.

Exemplo:

```text
Poder desejado: 80
Custo: 82

Restrição: -20
Condição: -15
Juramento: -25
Preparação: -10

Restante: 12
```

Draft pode existir; finalização exige requisitos válidos.

Não implementar toda a biblioteca definitiva antes da biblioteca de possibilidades ser criada.

## 14. Specialist

Specialist não deve ser uma sexta categoria normal.

Criar posteriormente fluxo próprio, mais anômalo e flexível, com custos, riscos, condições e restrições proporcionais ao poder.

## 15. Hatsu tipo Skill Hunter

O "livro" será um Hatsu normal criado pelo jogador, inspirado no conceito de roubo de Hatsus.

Deve permitir:
- capturar/roubar Hatsus
- armazenar no Hatsu Archive
- usar dois Hatsus simultaneamente
- respeitar compatibilidade
- respeitar requisitos/restrições

Separar `stored`, `equipped` e `active`.

## 16. Eventos e side quests

Criar arquitetura para eventos contextuais:
- NPC atacado
- Hunter procurando alguém
- comerciante chegando
- grupos discutindo
- criatura rara
- treinamento
- evento de saga
- evento pós-missão

Side quests:
- investigação
- entrega
- conversa
- escolta
- busca
- treinamento
- descoberta
- coleta
- combate
- decisão
- relacionamento
- evento
- exploração

Não limitar tudo a "mate X inimigos".

## 17. Treinamento

Treinamento deve possuir propósito:
- Skill Tree
- Hatsu
- melhoria
- conhecimento
- item
- técnica
- acesso
- lore

Não reduzir tudo a "ganhe XP".

## 18. Momentos narrativos

Criar categorias:
- Micro-scene: 5–20s
- Character Scene: 20–60s
- Story Scene: 1–3min
- Major Cutscene: 3+min somente quando necessária

Adicionar:
- primeira aparição
- encontro
- descoberta
- derrota/vitória
- revelação
- treinamento
- humor
- tensão
- preparação de boss
- aftermath
- despedida
- mudança de cidade

Hunter x Hunter também possui humor e cotidiano. Nem toda cena precisa avançar a trama.

## 19. Viagens

Evitar teleportes constantes.

Quando fizer sentido:

`Cidade A → estrada → pequena área → NPC/evento → Cidade B`

Fast travel pode existir depois, mas descoberta deve ser valorizada.

## 20. Arquitetura e segurança

Tudo deve ser:
- data-driven
- modular
- reutilizável
- testável
- desacoplado
- compatível com save/load
- preparado para conteúdo futuro

Evitar condições rígidas como `if player.level == 53`.

Usar flags, requirements, conditions, events e data definitions.

Antes de alterar sistemas:
1. identificar dependências
2. criar/ajustar testes
3. implementar
4. executar testes
5. validar cenas
6. validar save/load
7. validar Story Mode
8. atualizar documentação

## 21. Vertical Slice obrigatório

Antes de expandir para uma saga inteira, construir um trecho jogável de 20–40 minutos contendo:

- 1 exploração
- 1 NPC importante
- 1 NPC secundário
- 1 side quest
- 1 treinamento
- 1 combate normal
- 1 combate com IA inteligente
- 1 cena narrativa
- 1 cutscene
- 1 escolha
- 1 consequência
- retorno ao objetivo principal

Se esse trecho parecer uma aventura real, aplicar a arquitetura às demais sagas.

## 22. Testes

Criar testes para:
- StoryState
- flags
- objetivos
- conclusão/falha
- diálogo condicional
- branches
- cutscene
- interrupção/retorno
- schedules
- NPC state
- quest progress
- Hatsu cost/requirements/conditions/cooldown
- save/load

## 23. Documentação

Criar ou atualizar, sem duplicar Bibles existentes:

```text
docs/GAME_EXPERIENCE_AUDIT.md
docs/STORY_EXPERIENCE_BIBLE.md
docs/CUTSCENE_SYSTEM_BIBLE.md
docs/LIVING_WORLD_BIBLE.md
docs/COMBAT_2_BIBLE.md
docs/PROGRESSION_BIBLE.md
docs/HATSU_CREATOR_BIBLE.md
docs/FASE_F_IMPLEMENTATION.md
```

Sempre separar:
`IMPLEMENTED / PARTIAL / PLANNED / DEFERRED / LEGACY`

Nunca declarar planejado como implementado.

## 24. Ordem

### F0 — AUDIT
Auditoria, arquitetura e dependências.

### F1 — STORY FOUNDATION
StoryState, objectives, flags, progression.

### F2 — CUTSCENE FOUNDATION
Timeline, actors, movement, camera, dialogue, effects.

### F3 — STORY PACING
Respiros, viagens, eventos, diálogos, objetivos.

### F4 — LIVING NPC
Schedules, states, contextual dialogue.

### F5 — QUEST EXPERIENCE
Main vs side, objective hierarchy, contextual quests.

### F6 — COMBAT 2.0
Ataques, esquiva, status, IA, enemy Hatsus.

### F7 — PROGRESSION
Training, equipment, Nen refinement, Hatsu mastery.

### F8 — POLISH
Áudio, câmera, transições, efeitos, pacing, UX.

## 25. Critério de sucesso

Ao finalizar o vertical slice, verificar:

### Jogador sabe:
- onde está?
- por que está ali?
- quem são os personagens?
- o que precisa fazer?
- por que precisa fazer?
- o que pode fazer além da história?

### Mundo:
- parece vivo?
- reage?
- é explorável?

### Protagonista:
- parece único?
- pertence à história?
- possui trajetória própria?

### Combate:
- é estratégico?
- legível?
- variado?
- Hatsu e inteligência importam?

### História:
- respira?
- possui momentos memoráveis?
- não parece uma esteira de combates?

Se não, não expandir conteúdo massivo ainda.

## 26. Regra de ouro

Antes de adicionar qualquer feature:

> "Isso aumenta a sensação de que estou vivendo uma aventura dentro de Hunter x Hunter?"

Se não:
- adiar
- simplificar
- ou remover

Prioridades:

**ALMA > QUANTIDADE**

**EXPERIÊNCIA > SISTEMAS**

**PERSONAGENS > QUEST VENDING MACHINES**

**HISTÓRIA > FARM**

**EXPLORAÇÃO > TELEPORTES**

**ESTRATÉGIA > POWER CREEP**

## 27. Entregáveis

Ao concluir:
1. código
2. cenas
3. vertical slice jogável
4. testes
5. auditoria
6. Bibles atualizadas
7. IMPLEMENTED
8. PARTIAL
9. PLANNED
10. DEFERRED
11. LEGACY
12. próximos passos

Status final:

```text
FASE F — STATUS

Story Experience: X%
Cutscene System: X%
Living World: X%
Quest Experience: X%
Combat 2.0: X%
Progression: X%
Hatsu Foundation: X%
Polish: X%

Tests: PASS / FAIL
Known Issues: ...
Next Priority: ...
```

# INSTRUÇÃO FINAL AO AGENT

Não trate esta tarefa como "adicionar algumas cutscenes".

Trate-a como uma transformação da experiência.

O objetivo é fazer o Hunter MMORPG parecer um RPG de verdade, onde pessoas vivem no mundo, eventos acontecem, o protagonista possui uma história, a história canônica acontece ao redor dele, escolhas possuem peso, treinamento possui propósito, Hatsus possuem identidade, combates possuem estratégia, exploração possui recompensa e o jogador possui motivos para continuar.

**Primeiro audite. Depois projete. Depois implemente. Depois teste. Depois jogue o vertical slice. Só então expanda para o restante do jogo.**
