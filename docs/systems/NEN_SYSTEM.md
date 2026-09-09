# NEN SYSTEM ARCHITECTURE
## HUNTER ONLINE — THE 9 CANONICAL TECHNIQUES & FLOW MATRIX

### 1. Visão Geral
O sistema de Nen modela com rigor canônico a energia vital (Aura) e suas 9 técnicas fundamentais descritas por Yoshihiro Togashi:

1. **Ten (Envolver):** Manto de contenção que reduz dano recebido em até 60% e estanca a perda natural de aura.
2. **Ren (Expandir):** Expansão explosiva da aura, amplificando o poder de ataque físico e técnico ao custo de drenagem por segundo.
3. **Zetsu (Suprimir):** Fechamento absoluto dos nós de aura. Zera a presença (stealth invisível a radares), acelera a recuperação de HP, mas anula toda defesa física (dano recebido 2.5x).
4. **Gyo (Focar):** Concentração de aura nos olhos. Permite enxergar técnicas ocultas com In e alvos furtivos.
5. **Shu (Extensão):** Extensão da aura para objetos e armas empunhadas.
6. **In (Ocultar):** Forma avançada de Zetsu aplicada a técnicas de Nen já emitidas.
7. **En (Círculo):** Expansão da aura em raio esférico (150px a 300px), detectando instantaneamente qualquer entidade dentro da área.
8. **Ko (Concentração Máxima):** 100% da aura concentrada em um único ponto (ex: punho). Dano catastrófico, deixando o restante do corpo totalmente desprotegido.
9. **Ryu (Distribuição Dinâmica):** Alocação percentual em tempo real (ex: 80/20 Ofensivo, 20/80 Defensivo, 50/50 Equilibrado).

### 2. Desacoplamento da UI
* O `NenSystem` calcula custos, regeneração e modificadores puramente como nó de simulação física e matemática.
* A interface (`PlayerHUD`, `NenBar`, `NenWheel`) apenas lê o estado através de propriedades ou sinais (`aura_changed`, `tecnica_alterada`).
