# HUNTER MMORPG
# TASKS — RPG 2D UI / UX / SKILL TREE / GAME FEEL TRANSFORMATION

**Status:** PLANEJAMENTO  
**Objetivo:** Transformar a interface e a experiência de progressão do Hunter MMORPG em algo que pareça um RPG 2D completo, profundo e produzido como um jogo real.

---

# 0. VISÃO DO PROJETO

O projeto atual possui sistemas funcionais, porém algumas partes ainda apresentam aparência de protótipo técnico.

O objetivo desta etapa NÃO é simplesmente:

- deixar menus bonitos;
- mudar cores;
- aumentar fontes;
- colocar bordas;
- adicionar efeitos.

O objetivo é criar uma **linguagem visual e de UX de RPG**.

O jogador deve sentir que:

> "Estou jogando um RPG."

e não:

> "Estou usando uma ferramenta que possui vários sistemas."

A interface deve comunicar progressão, poder, descoberta e identidade.

---

# 1. REFERÊNCIAS DE EXPERIÊNCIA

Usar como referências conceituais:

- IconicQuest
- Path of Exile 
- RPGs 2D tradicionais
- MMORPGs
- Action RPGs
- jogos com Skill Trees famosas
- sistemas de progressão de RPG
- interfaces de jogos de aventura
- estética e linguagem de Hunter x Hunter

NÃO copiar interfaces.

Absorver princípios:

- clareza;
- hierarquia;
- feedback;
- sensação de progressão;
- identidade;
- descoberta;
- recompensa;
- navegação;
- consistência.

---

# 2. REFERÊNCIA TÉCNICA — GODOT

A interface deve utilizar corretamente o sistema de UI do Godot.

Priorizar:

- Control;
- Containers;
- Anchors;
- Theme;
- Theme Overrides;
- Theme Type Variations;
- Custom Controls;
- Fontes;
- NinePatchRect quando apropriado;
- TextureProgressBar quando apropriado;
- animações/Tweens;
- shaders apenas quando trouxerem benefício real.

Evitar posicionamento manual excessivo de elementos.

Evitar dezenas de estilos hardcoded em scripts.

Criar um Design System centralizado.

---

# 3. FASE 1 — AUDITORIA COMPLETA

## TASK 1.1 — Ler documentação

[ ] Ler todas as Bibles/MDs relevantes.

Pesquisar especialmente:

- Lore
- Nen
- Hatsu
- Skill Tree
- Combat
- Quest
- NPC
- Progression
- UI
- HUD
- World
- Architecture

---

## TASK 1.2 — Comparar documentação e código

Criar uma tabela:

| Sistema | Documentado | Implementado | Divergência |
|---|---|---|---|
| Nen | ? | ? | ? |
| Skill Tree | ? | ? | ? |
| Hatsu | ? | ? | ? |
| HUD | ? | ? | ? |
| Quest | ? | ? | ? |
| Progression | ? | ? | ? |

---

## TASK 1.3 — Mapear UI

Localizar:

- PlayerHUD
- StatusMenu
- Nen UI
- Skill Tree UI
- Hatsu UI
- Quest Tracker
- Target Frame
- NPC dialogue
- menus
- popups
- notifications
- debug menus

Identificar componentes duplicados.

---

# 4. FASE 2 — LIMPEZA DO LEGADO

## TASK 2.1 — Remover conceito antigo de NEN LEVEL

[ ] Localizar todas as referências a:

`Nen Level`

[ ] Descobrir origem.

[ ] Remover referências obsoletas.

[ ] Verificar:

- HUD;
- StatusMenu;
- Skill Tree;
- PlayerData;
- NenSystem;
- Progression;
- Debug;
- Save/Load.

NÃO simplesmente esconder o Label.

Eliminar o conceito legado quando realmente estiver obsoleto.

---

# 5. FASE 3 — DESIGN SYSTEM

Criar ou evoluir:

`HunterUIStyle.gd`

O Design System deve centralizar:

## Typography

- Title
- Heading
- Body
- Small
- Micro
- Numeric
- Damage
- Notification

---

## Panels

- MainPanel
- SubPanel
- Tooltip
- Popup
- Card
- QuestPanel
- SkillPanel

---

## Buttons

- Normal
- Hover
- Pressed
- Disabled
- Selected
- Danger
- Special

---

## States

- Locked
- Available
- Active
- Completed
- Selected
- Disabled
- Warning

---

## TASK 3.1

[ ] Nenhuma tela importante deve criar estilos completamente independentes.

[ ] Estilos compartilhados devem vir do Design System.

---

# 6. FASE 4 — IDENTIDADE VISUAL HUNTER

A UI não deve parecer uma UI genérica.

Criar linguagem inspirada no universo de Hunter x Hunter.

Conceitos:

Hunter Association
→ documentos, selos, badges, registros.

Nen
→ aura, fluxo, energia, expansão.

Hatsu
→ individualidade.

Treinamento
→ progressão e domínio.

Hunter Exam
→ registros, objetivos e avaliação.

Missões
→ contratos, objetivos, recompensa.

NPCs
→ cargos, identidade e informação.

---

# 7. FASE 5 — NEN COMO LINGUAGEM VISUAL

Cada conceito de Nen deve possuir identidade.

## TEN

Sensação:

- proteção;
- estabilidade;
- aura controlada.

---

## ZETSU

Sensação:

- ausência;
- silêncio;
- stealth;
- redução.

---

## REN

Sensação:

- intensidade;
- expansão;
- poder.

---

## GYO

Sensação:

- foco;
- percepção;
- análise.

---

## SHU

Sensação:

- aura aplicada a objetos.

---

## KO

Sensação:

- concentração extrema;
- explosão ofensiva.

---

## EN

Sensação:

- expansão;
- território;
- percepção espacial.

---

## RYU

Sensação:

- distribuição;
- equilíbrio;
- troca entre ataque e defesa.

---

# 8. FASE 6 — SKILL TREE REBUILD

Esta é uma das prioridades máximas.

A Skill Tree não deve parecer:

```
Label
Label
Label
Button
Label
```

Ela deve parecer:

```
              ROOT
               |
        ┌──────┴──────┐
        |             |
      OFFENSE       DEFENSE
        |             |
     ┌──┴──┐       ┌──┴──┐
     |     |       |     |
    KO    RYU     TEN   ZETSU
```

---

# 9. SKILL NODE

Criar um componente:

`SkillNodeUI`

Cada node deve possuir:

- ícone;
- nome;
- tier;
- estado;
- custo;
- nível;
- requisitos;
- tooltip;
- feedback.

---

# 10. ESTADOS DO NODE

## LOCKED

Visual:

- escurecido;
- baixa intensidade;
- cadeado;
- requisitos visíveis.

---

## AVAILABLE

Visual:

- destaque;
- animação sutil;
- indicação de que pode ser comprado.

---

## UNLOCKED

Visual:

- iluminado;
- conexão ativa;
- nível atual.

---

## MAXED

Visual:

- estado completo;
- feedback de conclusão.

---

# 11. SKILL TREE CONNECTIONS

Criar conexões visuais entre nodes.

As conexões devem representar progressão.

Estados:

LOCKED
→ linha apagada.

AVAILABLE
→ linha destacada.

UNLOCKED
→ linha ativa.

Isso deve permitir que o jogador enxergue a build.

---

# 12. SKILL TREE CAMERA

Se a árvore ficar grande:

Adicionar:

- zoom;
- pan;
- centralização;
- reset camera;
- foco no node selecionado.

A árvore deve poder crescer muito sem quebrar a UI.

---

# 13. SKILL TREE TABS

Criar categorias visualmente distintas.

Possível estrutura:

### FUNDAMENTALS

- Ten
- Zetsu
- Ren
- Gyo

### ADVANCED

- Shu
- Ko
- En
- Ryu

### SPECIALIZATION

- Offensive
- Defensive
- Mobility
- Control
- Perception
- Hatsu Synergy

Não tratar isso como obrigatório.

O layout deve ser derivado da Bible atual.

---

# 14. SKILL TREE BUILD IDENTITY

O jogador deve conseguir visualizar:

"Minha build."

Exemplo:

OFFENSIVE HUNTER

REN
████████

KO
██████

RYU
████

---

Outro jogador:

TACTICAL HUNTER

GYO
████████

EN
██████

ZETSU
██████

---

Outro:

DEFENSIVE HUNTER

TEN
████████

RYU
██████

SHU
████

A Skill Tree deve permitir builds diferentes sem necessariamente criar classes rígidas.

---

# 15. SKILL POINTS

Sempre mostrar:

`SKILL POINTS`

`12`

O número deve ter destaque.

Quando ganhar ponto:

`+1 SKILL POINT`

com feedback visual.

---

# 16. SKILL NODE TOOLTIP

Criar tooltip informativo.

Exemplo:

```
────────────────────────
GYO — FOCUSED PERCEPTION
────────────────────────

Tier II

Cost
3 Skill Points

Effect
+8% Perception

Additional Effect
Weak Points become visible
for longer.

Requirements
Gyo I

Synergy
EN Detection

────────────────────────
[UNLOCK]
────────────────────────
```

Não transformar tudo em texto corrido.

---

# 17. SKILL TREE PREVIEW

Quando selecionar uma habilidade:

Mostrar no painel lateral:

- nome;
- descrição;
- efeito;
- custo;
- requisitos;
- sinergias;
- próximo nível.

---

# 18. SKILL TREE FEEDBACK

Ao desbloquear:

1. node anima;
2. conexão anima;
3. contador de pontos atualiza;
4. pequeno efeito visual;
5. toast opcional;
6. som, se existir sistema de áudio apropriado.

---

# 19. FASE 7 — STATUS MENU

Reestruturar.

Não utilizar somente:

```
Level: 10
HP: 500/500
Força: 20
Defesa: 15
Aura: 100/100
```

Criar categorias.

---

## CHARACTER

HP

Aura

Força

Defesa

Velocidade

---

## PROGRESSION

Level

XP

Nen XP

Skill Points

---

## BUILD

Nen Skills

Hatsu

Build Type

---

# 20. STATUS VISUAL

Utilizar:

- cards;
- barras;
- ícones;
- números;
- divisores;
- hierarquia.

Os números importantes devem chamar mais atenção que os labels.

---

# 21. FASE 8 — PLAYER HUD

A HUD de gameplay deve ser minimalista.

Prioridade:

1. HP
2. Aura
3. Target
4. Hatsu
5. Quest
6. Condições

---

# 22. PLAYER FRAME

Criar:

```
┌──────────────────────┐
│ PLAYER               │
│ Level 42             │
│ HP █████████░  82%   │
│ AU ████████░░  74%   │
└──────────────────────┘
```

Não necessariamente usar exatamente esse layout.

---

# 23. TARGET FRAME

Quando houver alvo:

```
ENEMY
Swamp Beast
Lv. 37

HP ███████░░░

[ELITE]
```

Boss:

```
BOSS
Hunter Killer

████████████████

PHASE II
```

---

# 24. FASE 9 — HATSU HUD

Quando Hatsu for ativado:

mostrar:

`GODSPEED`

`ACTIVE`

ou:

`GODSPEED ON`

Preferir:

- ícone;
- texto;
- status;
- duração.

---

# 25. HATSU CONDITION TRACKER

Para habilidades condicionais:

```
GODSPEED

✓ Target Found
✓ HP < 50%
○ Stay within EN
✓ Hit 3 times

3 / 4
```

Esse sistema deve ser reutilizável.

---

# 26. CONDITION COMPONENT

Criar:

`ConditionTrackerUI`

Pode ser utilizado por:

- Hatsu;
- quests;
- bosses;
- eventos;
- achievements futuros.

---

# 27. FASE 10 — COMBAT FEEDBACK

Criar feedback para:

- Damage;
- Critical;
- Dodge;
- Block;
- Heal;
- Weak Point;
- Stagger;
- Knockback.

Exemplos:

`-1250`

`CRITICAL`

`DODGE`

`WEAK POINT`

`+850`

---

# 28. DAMAGE NUMBER SYSTEM

Criar sistema configurável.

Permitir:

- tamanho;
- duração;
- movimento;
- prioridade;
- agrupamento;
- critic;
- tipo de dano.

Evitar spam.

---

# 29. FASE 11 — OVERHEAD BADGES

Estados importantes:

- EN
- STEALTH
- MARKED
- GODSPEED
- BERSERK

Não mostrar permanentemente.

Usar somente quando necessário.

---

# 30. FASE 12 — QUEST UI

Criar Quest Tracker com hierarquia.

```
QUEST

Hunter Exam

✓ Find the entrance
✓ Talk to Wing
○ Defeat 3 creatures

Optional
○ Discover hidden area
```

---

# 31. QUEST OBJECTIVE STATES

Suportar visualmente:

LOCKED

ACTIVE

COMPLETED

FAILED

OPTIONAL

---

# 32. FASE 13 — NPC UI

NPCs importantes devem possuir identidade.

Overhead:

```
WING
Nen Master
```

ou:

```
BISCUIT
Hunter
```

Utilizar badges diferentes para:

- quest;
- merchant;
- trainer;
- story;
- important NPC.

---

# 33. FASE 14 — MENUS

Revisar:

- Main Menu;
- Pause;
- Status;
- Inventory;
- Hatsu;
- Skill Tree;
- Quest;
- Map;
- Settings.

Todos devem parecer parte do mesmo jogo.

---

# 34. NAVEGAÇÃO

A interface deve possuir fluxo lógico:

Pause
↓
Status
↓
Nen
↓
Skill Tree
↓
Hatsu
↓
Quest
↓
Map

Não criar menus isolados.

---

# 35. MENU TRANSITIONS

Adicionar transições consistentes:

- fade;
- slide;
- scale;
- highlight.

Evitar animações longas.

---

# 36. FASE 15 — MICROINTERAÇÕES

Adicionar pequenas respostas:

Hover
→ highlight.

Click
→ feedback.

Unlock
→ animation.

Level Up
→ animation.

Skill Point
→ notification.

Quest Complete
→ banner.

Hatsu Active
→ feedback.

---

# 37. FASE 16 — LORE-DRIVEN UI

Ler novamente as Bibles depois da primeira implementação.

Perguntar:

"Existe algum conceito da lore que pode virar elemento visual?"

Exemplos:

Hunter License
→ card de licença.

Hunter Association
→ interface institucional.

Quest
→ documento/contrato.

Nen Training
→ painel de treinamento.

Hatsu
→ registro individual.

Hunter Rank
→ badge.

Exame
→ avaliação/progressão.

---

# 38. FASE 17 — VISUAL SEM DEPENDÊNCIA DE SPRITES

Não depender de grandes quantidades de novos sprites.

Utilizar:

- Control;
- Panels;
- StyleBox;
- Gradients;
- particles;
- shaders;
- fonts;
- icons;
- procedural UI;
- animações.

A interface deve conseguir parecer sofisticada usando recursos já disponíveis.

---

# 39. FASE 18 — ICON SYSTEM

Criar sistema consistente de ícones.

Categorias:

Nen
Hatsu
Combat
Quest
NPC
Item
Progression
Status

Os ícones precisam possuir:

- tamanho consistente;
- alinhamento;
- estado;
- tooltip.

---

# 40. FASE 19 — TYPOGRAPHY

Definir hierarquia.

Exemplo:

TITLE
→ grande.

SECTION
→ médio.

BODY
→ legível.

SMALL
→ informação secundária.

MICRO
→ detalhes.

NUMERIC
→ números importantes.

Nunca usar 20 tamanhos de fonte diferentes sem motivo.

---

# 41. FASE 20 — RESPONSIVIDADE

Testar:

640x360

1280x720

1920x1080

ou as resoluções realmente suportadas pelo projeto.

Verificar:

- anchors;
- containers;
- clipping;
- overflow;
- scale;
- spacing.

Não resolver problema de layout simplesmente aumentando a resolução.

---

# 42. FASE 21 — UI SCALING

Todos os elementos importantes devem permanecer proporcionais.

Testar:

100%

125%

150%

200%

Evitar HUD gigantesca.

---

# 43. FASE 22 — INPUT

A Skill Tree deve funcionar com:

- mouse;
- teclado;
- eventualmente controle.

Suportar:

- focus;
- selected;
- hover;
- navigation;
- confirm;
- back.

---

# 44. FASE 23 — PERFORMANCE

Não atualizar toda a UI em `_process()` sem necessidade.

Preferir:

signals;
eventos;
dirty flags;
atualizações por mudança.

Evitar recriar nodes continuamente.

---

# 45. FASE 24 — DATA / SYSTEM / UI

Separar:

```
DATA
 ↓
SYSTEM
 ↓
UI
```

Exemplo:

```
NenSkillTreeSystem
        ↓
SkillTreeData
        ↓
NenSkillTreeUI
        ↓
SkillNodeUI
```

UI não deve ser responsável pela regra de negócio.

---

# 46. FASE 25 — DEBUG TOOLS

Criar ferramentas de teste:

Add Nen XP

Add Skill Points

Unlock Skill

Reset Skill Tree

Set Level

Spawn Enemy

Spawn Elite

Spawn Boss

Test Hatsu

Test Condition

Test Quest

Isso reduz drasticamente o tempo de desenvolvimento.

---

# 47. FASE 26 — SAVE / LOAD

Verificar persistência:

- Skill Tree;
- Skill Points;
- Nen XP;
- Hatsu;
- Progression.

Testar:

Unlock
↓
Save
↓
Close
↓
Open
↓
Load
↓
Verify

---

# 48. FASE 27 — TESTES AUTOMATIZADOS

Adicionar testes para:

## Skill Tree

[ ] Loading

[ ] Unlock

[ ] Requirements

[ ] Cost

[ ] Synergy

[ ] Save

[ ] Load

[ ] Reset

---

## HUD

[ ] HP

[ ] Aura

[ ] Level

[ ] Nen XP

[ ] Skill Points

[ ] Target

[ ] Hatsu

[ ] Conditions

---

## UI

[ ] Open

[ ] Close

[ ] Reopen

[ ] Resize

[ ] Navigation

[ ] Focus

---

# 49. FASE 28 — UX REVIEW

Depois de implementar:

Abrir o jogo como se fosse um jogador que nunca viu o projeto.

Perguntar:

"Eu sei onde estou?"

"Eu sei quanto HP tenho?"

"Eu sei quanto Aura tenho?"

"Eu sei qual é minha build?"

"Eu sei quantos Skill Points tenho?"

"Eu sei quais skills posso desbloquear?"

"Eu sei por que uma skill está bloqueada?"

"Eu sei qual Hatsu está ativo?"

"Eu sei o que minha quest pede?"

Se alguma resposta for "não", corrigir.

---

# 50. FASE 29 — POLISH

Depois que tudo funcionar:

Adicionar:

- sombras;
- bordas;
- highlights;
- gradients;
- pequenos glows;
- animações;
- transições;
- feedback.

Polish vem DEPOIS da estrutura.

Não usar efeitos para esconder problemas de UX.

---

# 51. FASE 30 — AUDITORIA VISUAL FINAL

Comparar todas as telas.

Perguntar:

- usam mesma fonte?
- mesma hierarquia?
- mesmos espaçamentos?
- mesmas bordas?
- mesmos painéis?
- mesmas animações?
- mesma linguagem?
- mesmos estados?
- mesmos ícones?

Corrigir inconsistências.

---

# 52. FASE 31 — BIBLES

Depois da implementação:

Atualizar os MDs.

Obrigatórios quando aplicável:

`NEN_SKILL_TREE_BIBLE.md`

`HATSU_BIBLE.md`

`UI_HUD_BIBLE.md`

`PROGRESSION_BIBLE.md`

`COMBAT_BIBLE.md`

`ARCHITECTURE.md`

Documentar:

- novos componentes;
- regras;
- estados;
- integrações;
- design decisions;
- arquitetura;
- extensões futuras.

---

# 53. NÃO DOCUMENTAR FICÇÃO

Nunca documentar como implementado algo que ainda não existe.

Separar:

IMPLEMENTED

PLANNED

FUTURE

---

# 54. FASE 32 — CODE QUALITY

Após o redesign:

[ ] remover código morto;

[ ] remover referências antigas;

[ ] remover Labels obsoletos;

[ ] remover sistemas duplicados;

[ ] corrigir warnings relevantes;

[ ] corrigir erros de sintaxe;

[ ] padronizar nomes;

[ ] verificar sinais duplicados;

[ ] verificar referências quebradas.

---

# 55. FASE 33 — FINAL RPG FEEL TEST

Executar o seguinte teste:

Criar personagem.

Entrar no mundo.

Abrir HUD.

Abrir Status.

Abrir Skill Tree.

Ganhar Skill Point.

Desbloquear skill.

Abrir Hatsu.

Ativar Hatsu.

Entrar em combate.

Receber dano.

Usar habilidade.

Completar condição.

Completar quest.

Ganhar Nen XP.

Voltar ao menu.

Salvar.

Fechar jogo.

Abrir novamente.

Carregar.

Verificar tudo.

---

# 56. CRITÉRIO DE QUALIDADE

A transformação estará aprovada somente quando:

### HUD

[ ] parece HUD de RPG.

### STATUS

[ ] parece tela de personagem.

### SKILL TREE

[ ] parece Skill Tree de RPG.

### HATSU

[ ] parece sistema de habilidade.

### QUEST

[ ] parece sistema de missão.

### COMBAT

[ ] possui feedback visual.

### NPC

[ ] possui identidade.

### WORLD

[ ] UI conversa com a lore.

### PROGRESSION

[ ] jogador entende evolução.

### UX

[ ] jogador entende o que fazer.

---

# 57. PRINCÍPIO MAIS IMPORTANTE

Não transformar o jogo em uma planilha bonita.

Uma interface pode ter:

- números;
- barras;
- porcentagens;
- atributos;
- requisitos;

e ainda assim parecer uma planilha.

O objetivo é transformar:

DATA

em:

GAMEPLAY INFORMATION.

---

# 58. PRINCÍPIO DE PROFUNDIDADE

Sempre que possível:

INFORMAÇÃO
↓
DECISÃO
↓
CONSEQUÊNCIA

Exemplo:

Skill disponível
↓
jogador escolhe
↓
build muda
↓
combate muda
↓
Hatsu interage diferente.

---

# 59. PRINCÍPIO DE DESCOBERTA

Nem toda informação precisa aparecer imediatamente.

Exemplo:

Gyo desbloqueia:

Enemy Analysis
↓
Weak Point
↓
Hidden Stats
↓
Hatsu Interaction

Isso cria sensação de progressão.

---

# 60. PRINCÍPIO DE IDENTIDADE

O jogador não deve apenas aumentar números.

Ele deve poder dizer:

"Minha build é diferente."

Exemplo:

Hunter ofensivo.

Hunter defensivo.

Hunter de percepção.

Hunter de controle.

Hunter de mobilidade.

Hunter de Hatsu.

Hunter híbrido.

---

# 61. PRINCÍPIO DE ESCALABILIDADE

Tudo deve permitir expansão.

Hoje:

8 técnicas de Nen.

Amanhã:

20+ sistemas derivados.

Hoje:

10 nodes.

Amanhã:

100+ nodes.

Hoje:

10 Hatsus.

Amanhã:

centenas.

A arquitetura não pode depender de hardcode individual.

---

# 62. PRINCÍPIO DE PERFORMANCE

Mesmo que o projeto utilize muitos créditos/tempo para implementar corretamente:

Priorizar qualidade.

Não sacrificar arquitetura para terminar rápido.

Não criar soluções descartáveis.

---

# 63. ORDEM FINAL DE EXECUÇÃO

## BLOCK 1
Auditoria

## BLOCK 2
Legacy cleanup

## BLOCK 3
Design System

## BLOCK 4
Skill Tree

## BLOCK 5
Status

## BLOCK 6
Player HUD

## BLOCK 7
Hatsu HUD

## BLOCK 8
Quest UI

## BLOCK 9
Target UI

## BLOCK 10
Combat feedback

## BLOCK 11
NPC UI

## BLOCK 12
Lore visual integration

## BLOCK 13
Responsive UI

## BLOCK 14
Input/navigation

## BLOCK 15
Performance

## BLOCK 16
Save/Load

## BLOCK 17
Debug

## BLOCK 18
Tests

## BLOCK 19
Documentation

## BLOCK 20
Final polish

---

# 64. REGRA PARA O AGENTE

Não quero que você simplesmente "complete as tasks".

Quero que você raciocine como:

- Game Designer;
- UI/UX Designer;
- Gameplay Programmer;
- Technical Designer;
- Godot Developer;
- QA.

Cada alteração deve responder:

1. Isso melhora o gameplay?
2. Isso melhora a compreensão?
3. Isso melhora a identidade?
4. Isso escala?
5. Isso é reutilizável?
6. Isso é performático?
7. Isso está integrado ao restante do jogo?
8. Isso está documentado?
9. Isso está testado?

---

# 65. REGRA SOBRE CRÉDITOS / TEMPO

NÃO otimizar a implementação para gastar menos créditos se isso comprometer qualidade.

É preferível:

- auditar profundamente;
- investigar;
- refatorar corretamente;
- criar componentes reutilizáveis;
- testar;
- documentar;

do que criar uma solução rápida que precisará ser refeita posteriormente.

---

# 66. RESULTADO FINAL DESEJADO

Quero que o Hunter MMORPG chegue ao ponto em que:

Ao abrir o jogo:

→ parece um RPG.

Ao abrir Status:

→ parece tela de personagem.

Ao abrir Skill Tree:

→ parece sistema de progressão.

Ao abrir Hatsu:

→ parece sistema de habilidades.

Ao entrar em combate:

→ HUD comunica o combate.

Ao completar quest:

→ existe feedback.

Ao desbloquear skill:

→ existe sensação de progresso.

Ao explorar:

→ a interface reforça o mundo.

Ao olhar para tudo:

→ todas as telas parecem pertencer ao mesmo jogo.

---

# 67. DEFINITION OF DONE

A tarefa NÃO está concluída simplesmente porque o código funciona.

Está concluída quando:

[ ] Código funciona.

[ ] Bugs críticos corrigidos.

[ ] Skill Tree não possui loading infinito.

[ ] Skill Tree possui nodes visuais.

[ ] Skill Tree possui conexões.

[ ] Skill Tree possui estados.

[ ] Skill Points são intuitivos.

[ ] Nen XP está correto.

[ ] Nen Level legado removido.

[ ] HUD possui hierarquia.

[ ] Hatsu HUD funciona.

[ ] Condition Tracker funciona.

[ ] Status Menu possui identidade.

[ ] Quest UI possui identidade.

[ ] Target Frame funciona.

[ ] Combat feedback funciona.

[ ] UI é responsiva.

[ ] Navegação funciona.

[ ] Save/Load funciona.

[ ] Debug tools funcionam.

[ ] Testes passam.

[ ] Bibles estão atualizadas.

[ ] Código está limpo.

[ ] UI possui identidade própria.

[ ] O jogo parece um RPG 2D e não um protótipo.

---

# 68. REGRA FINAL

Não buscar apenas:

"funciona".

Buscar:

"parece um jogo."

E depois:

"parece um jogo que possui identidade."

E finalmente:

"parece um RPG que eu gostaria de continuar jogando."