# FACTION & REPUTATION SYSTEM BIBLE
## HUNTER ONLINE — DEFINITIVE GAMEPLAY DIRECTION

---

## 1. AS 6 GRANDES FACÇÕES DO UNIVERSO HUNTER

O mundo é povoado por grupos com ideologias, interesses e morais conflitantes. O jogador desenvolve sua reputação individual com cada uma delas:

1. **🏛️ Associação Hunter Oficial:**
   - A organização de Caçadores licenciados liderada pelo Presidente Netero e pelos Zodíacos.
   - Valoriza: Conclusão do Exame Hunter, honra, proteção da humanidade e missões canônicas.
2. **🕷️ Genei Ryodan (Trupe Fantasma & Submundo de Meteor City):**
   - Ladrões de elite liderados por Chrollo Lucilfer.
   - Valoriza: Desdém por autoridades, lealdade à Aranha, roubo de itens raros e brutalidade.
3. **⚡ Clã Zoldyck (Assassinos da Montanha Kukuroo):**
   - A família de elite dos maiores assassinos do mundo (Silva, Zeno, Illumi, Killua).
   - Valoriza: Disciplina estrita, força silenciosa, maestria em Nen e resistência à tortura.
4. **💼 Sindicato da Máfia das 10 Famílias (Yorknew City):**
   - Cartéis criminosos que controlam o leilão subterrâneo e a economia paralela.
   - Valoriza: Ouro, negócios ilegais e eliminação de rivais comerciais.
5. **🍖 Guilda dos Hunters Gourmet:**
   - Mestres da culinária de elite e exploração de ingredientes lendários (Menchi & Buhara).
   - Valoriza: Coleta de ingredientes perigosos e culinária exótica.
6. **⚖️ Caçadores da Lista Negra (Blacklist Hunters):**
   - Agentes de elite especializados em caçar criminosos procurados e bestas proibidas.
   - Valoriza: Cumprimento de mandados de captura e contratos do `BountySystem`.

---

## 2. A ESCALA DE REPUTAÇÃO (-1000 A +1000)

| Faixa de Pontos | Nível de Relacionamento | Consequências no Mundo |
| :--- | :--- | :--- |
| **+750 a +1000** | **Lenda / Aliado de Honra** | Acesso ao quartel-general, 25% de desconto nas lojas da facção, missões secretas. |
| **+400 a +749** | **Respeitado** | 15% de desconto, saudação reverente de NPCs da facção, guardas prestam assistência. |
| **+100 a +399** | **Favorável** | 5% de desconto, acesso a contratos de recompensa intermediários. |
| **-99 a +99** | **Neutro** | Preços padrão, interação comercial básica sem regalias. |
| **-399 a -100** | **Desconfiado** | 10% de acréscimo em preços, recusa em oferecer missões importantes. |
| **-749 a -400** | **Hostil** | 25% de acréscimo, NPCs recusam diálogo, guardas vigiam o jogador de perto. |
| **-1000 a -750** | **PROCURADO (Inimigo Mortal)** | Caçadores de recompensa da facção atacam à vista nas rotas abertas. |

---

## 3. IMPACTO REAL NO GAMEPLAY (SEM NÚMEROS VAZIOS)

- **Economia Dinâmica:** O `ReputationSystem.obter_multiplicador_preco_loja()` afeta os preços de itens em tempo real.
- **Diálogos Contextuais:** NPCs alteram suas saudações iniciais dependendo do respeito ou medo pelo jogador.
- **Acesso a Portais e Áreas:** Certas rotas secretas (ex: Becos de Meteor City ou Portão de Teste dos Zoldyck) exigem reputação mínima comprovada.
- **Persistência Total:** Os dados de reputação de todas as 6 facções são salvos e restaurados em 100% dos slots de save.
