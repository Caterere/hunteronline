# HUNTER ONLINE — PROFESSIONAL QUALITY GAP (LACUNAS DE QUALIDADE)

## 1. Metodologia de Avaliação
Auditoria orientada a identificar discrepâncias entre a **arquitetura técnica existente** e a **percepção de acabamento profissional pelo jogador**.

Escala de Prioridades:
* **S (Essencial)**: Afeta diretamente a clareza central ou causa frustração imediata.
* **A (Muito Importante)**: Eleva o engajamento e a profundidade perceptível.
* **B (Importante)**: Refinamento de ritmo e variedade de conteúdo.
* **C (Polimento)**: Melhorias audiovisuais e fluidez secundária.
* **D (Opcional)**: Funcionalidades adicionais futuras.

---

## 2. Tabela Master de Gaps de Qualidade

| ÁREA | SCORE (0-10) | PROBLEMA IDENTIFICADO | PRIORIDADE | RECOMENDAÇÃO / SOLUÇÃO |
|---|---|---|---|---|
| **Combate** | 8.5 / 10 | Dano e stagger funcionam muito bem, mas falta variação de silhueta nos monstros básicos. | **A** | Criar 2 novos sprites/modelos para monstros da Floresta (Lobo da Floresta e Fera Alada). |
| **Nen no Mundo** | 8.0 / 10 | O jogador usa muito Ten e Ko em combate, mas Zetsu e En têm menor visibilidade fora de quests. | **S** | Adicionar sensores de Nen em acampamentos e cofres que exigem Zetsu para se aproximar sem disparar alarme. |
| **NPCs** | 8.5 / 10 | Mestre Wing e Duran têm falas contextuais, mas NPCs secundários parecem um pouco estáticos. | **B** | Adicionar rotinas visuais de caminhada periódica entre lojas e praça nos horários de transição do TimeManager. |
| **Quests** | 8.0 / 10 | A cadeia principal é sólida (22 passos), mas algumas missões secundárias usam o clássico 'mate X'. | **A** | Adicionar objetivos investigativos com Gyo (rastrear pegadas de aura) e quebra de obstáculos com Ko. |
| **Ritmo / Pacing** | 9.0 / 10 | Tempo até 1º combate (~18s) e até 1º NPC (~1.2s) são excelentes e evitam o tédio inicial. | **GOOD** | Manter os parâmetros atuais do ContentDirector e espaçamento de 300-600px. |
| **Exploração** | 8.0 / 10 | Existem POIs marcantes, mas algumas clareiras secundárias na Floresta têm baixa recompensa. | **B** | Inserir pequenos baús de itens consumíveis (Poções e Pedras de Aura) nas clareiras periféricas. |
| **UX / Clareza** | 8.5 / 10 | O minimapa e overlay são muito úteis; falta apenas um feedback sonoro ao revelar pistas com Gyo. | **B** | Tocar um som sutil de ressonância de Nen (`audio_gyo_detect.wav`) ao revelar pistas ocultas. |
| **Chefes** | 9.0 / 10 | As 3 fases do Guardião Ancestral (Normal -> Escudo Nen -> Stagger KO) são excelentes e canônicas. | **EXCELLENT** | Preservar a estrutura de fases como padrão mestre para futuros chefes. |
| **Save / Load** | 10 / 10 | Sincroniza 100% de atributos, Nen, títulos, reputação e posição sem regressões. | **EXCELLENT** | Sistema totalmente consolidado em nível de produção. |

---

## 3. Conclusão da Auditoria
*Hunter Online* possui uma base técnica e arquitetural de nível excelente (10/10 nos testes automatizados). O principal *Quality Gap* atual reside em **alimentar os sensores de mundo já existentes (Gyo, Ko, Zetsu)** com mais instâncias contextuais no mapa para transformar a exploração em uma experiência viva.
