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

## 3. CATEGORIAS DE NPCS

- **Mestres de Treino:** Wing (Despertar de Ten/Ren), Biscuit Krueger (Treino de Hatsu), Netero (Avaliação suprema).
- **Mercadores & Corretores:** Venda de itens de suporte, equipamentos, catalisadores e informações de contratos.
- **Oficiais da Associação:** Registro de licença Hunter, entrega de missões de exame e ranqueamento.
- **Informantes do Submundo:** NPCs que cobram Jenny por rumores sobre chefes de área e rotas secretas.
- **Cidadãos Comuns:** Provedores de missões secundárias locais e contexto de lore.
