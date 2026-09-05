# NPC DESIGN BIBLE
## HUNTER ONLINE — LIVING WORLD, SOCIAL MATRIX & DIALOGUE

---

## 1. PRINCÍPIO DO MUNDO VIVO

> **"NPCs não são blocos de texto estáticos com funções coladas em um único script gigante. Eles são habitantes com rotinas, afiliações e reações orgânicas à reputação do Hunter."**

---

## 2. ARQUITETURA DE UM NPC MODERNO

Cada NPC no jogo é composto por nós e recursos modulares especializados:

```text
                        NPC (CharacterBody2D / Area2D)
                                      │
        ┌───────────────┬─────────────┼─────────────┬───────────────┐
        │               │             │             │               │
     NPCData       DialogueBox    Schedule      QuestLink     SocialReactor
   (Identidade)    (Falas/Sagas)  (Rotina Dia)  (Entregas)    (Facção/Preços)
```

1. **NPCData (Resource):**
   - Nome, Título, Facção natal, Nível moral e Retrato visual.
2. **DialogueBox / Interator:**
   - Consulta o estado atual em `StoryManager` e `QuestManager` para exibir diálogos contextuais em vez de repetições cegas.
3. **SocialReactor:**
   - Altera saudação e atitude baseado na reputação do jogador:
     - `Amigável (>300):` Acesso a mercadorias raras e dicas de segredos.
     - `Neutro (-100 a 300):` Atendimento padrão de balcão.
     - `Hostil (<-100):` Recusa de serviço, ameaças verbais e acionamento de guardas.
4. **Story Gateway Dispatcher (`StoryGatewayNPC`):**
   - NPC especializado na praça do Hub World (Lobby) encarregado de despachar o jogador para a missão ativa do checkpoint sem expor botões crus de debug.

---

## 3. HIERARQUIA CANÔNICA DE NPCS (6 TIERS)

A arquitetura de NPCs utiliza o enum formal `LivingNPCBehavior.NPCHierarchy`:

1. **COMMON (Aldeões & Transeuntes):**
   - Diálogos leves, fofocas e rumores de taverna.
   - Rotina completa: caminham de dia, recolhem-se às casas à noite e abrigam-se sob toldos na chuva.
2. **FUNCTIONAL (Comerciantes & Artesãos):**
   - Vendedor do Empório, Ferreiro Duran.
   - Fornecem serviços vitais (compra, venda, forja de equipamentos com trade-offs).
   - Fecham suas lojas à noite e reagem a crimes na vila.
3. **RECURRING (Personagens Recorrentes):**
   - Nicol, Tonpa.
   - Aparecem em múltiplas regiões comentando o progresso do exame ou as provações do jogador.
4. **IMPORTANT (Mentores & Guardiões):**
   - Mestre Wing, Guardião da Floresta.
   - Possuem memória contextual no `WorldState`, ensinam técnicas de Nen (Ten, Ren, Gyo) e oferecem missões de progressão.
5. **STORY (Figuras Centrais da Trama):**
   - Recepcionista Elena, Examinador Satotz, Biscuit Krueger, Netero.
   - Atuam como Story Gates e marcos de avanço de sagas.
6. **BOSS / ANTAGONISTAS:**
   - Guardião Ancestral de Zaban, Líder da Matilha Quimera.
   - Possuem falas dramáticas via `BattlePersonality`, transição de fases de Nen e mecânicas próprias.

---

## 4. INTEGRAÇÃO COM CLIMA E CICLO SOLAR
- **Noite (`NIGHT`):** Guardas aumentam o raio de patrulha e vigília (+15% velocidade); mercadores recolhem suas barracas.
- **Chuva (`CHUVA`):** Redução na velocidade de caminhada, retorno para abrigos e toldos de edifícios.
- **Tempestade de Aura (`TEMPESTADE_AURA`):** Cidadãos expressam espanto diante do fenômeno raro de Nen atmosférico.

