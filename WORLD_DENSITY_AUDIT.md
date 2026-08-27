# HUNTER ONLINE — WORLD DENSITY AUDIT (AUDITORIA DE DENSIDADE REAL)

## 1. Visão Geral da Região (512x512 Tiles / 16x16 Setores)
A análise foi executada com o motor de `WorldDensityHeatmap` dividindo o mapa de 8192x8192 pixels em 256 setores de 512x512 pixels (32x32 tiles).

| Tipo de Setor | Quantidade | Percentual | Diagnóstico |
|---|---|---|---|
| **🔥 Zonas Ativas / Densas** | 18 | 7.0% | Concentração de vilas, estradas, chefes e POIs chave. |
| **⚡ Zonas de Trânsito / Média Densidade** | 34 | 13.3% | Corredores de exploração com encontros dinâmicos. |
| **💀 Zonas Mortas (Sem Conteúdo Ativo)** | 204 | 79.7% | Áreas periféricas e florestas de transição limpas para expansão. |

---

## 2. Auditoria Setorial Detalhada

| REGION | SECTOR (X, Y) | NPC | PVE | EVENT | DISCOVERY | CLASSIFICAÇÃO | PROBLEMA IDENTIFICADO | RECOMENDAÇÃO |
|---|---|---|---|---|---|---|---|---|
| **Vila de Padokia** | [2, 7] | 5 | 0 | 1 | 1 | **OVERDENSE (URBANO)** | NPCs muito agrupados na praça central. | Espalhar NPCs pelos prédios periféricos e dojo. |
| **Vila Exterior** | [2, 6] | 1 | 0 | 0 | 0 | **UNDERDENSE** | Quase nenhum motivo para explorar atrás das casas. | Adicionar baú secreto ou glifo de Gyo. |
| **Estrada Real Oeste** | [4, 7] | 0 | 1 | 1 | 1 | **GOOD ZONE** | Ritmo equilibrado de viagem e perigo moderado. | Manter densidade e preservar anti-spam. |
| **Ponte de Pedra** | [5, 7] | 1 | 2 | 1 | 1 | **GOOD ZONE** | Ponto de estrangulamento tático excelente. | Adicionar guarda da Associação Hunter com diálogo. |
| **Floresta dos Vestígios** | [8, 6] | 0 | 3 | 2 | 1 | **GOOD ZONE** | Atmosfera densa com matilhas de lobos e segredos. | Introduzir obstáculos de Ko bloqueando clareiras. |
| **Floresta Profunda** | [9, 5] | 0 | 1 | 0 | 0 | **DEAD ZONE** | Setor amplo com apenas 1 monstro e sem pontos de referência. | Adicionar ninho de criaturas ou evento noturno. |
| **Ruínas de Zaban (Entrada)**| [12, 2] | 0 | 2 | 1 | 1 | **GOOD ZONE** | Transição ameaçadora para a masmorra. | Adicionar aviso sonoro e runas de Gyo. |
| **Sala do Trono (Boss)** | [13, 2] | 0 | 1 | 1 | 1 | **EXCELLENT** | Arena limpa para batalha de múltiplas fases do Boss. | Preservar espaço para esquivas e projéteis. |
| **Ravina da Névoa (Norte)** | [10, 10] | 0 | 2 | 1 | 1 | **GOOD ZONE** | Risco alto de dano ambiental mitigado por TEN. | Indicar visualmente que Ten previne o dano corrosivo. |
| **Borda do Mapa (Sul/Leste)**| [15, 15] | 0 | 0 | 0 | 0 | **INTENTIONAL BOUNDARY** | Borda intencional do mapa mundial. | Adicionar barreira natural (montanhas/penhascos). |

---

## 3. Diretrizes de Balanceamento Espacial
1. **Evitar o "Vazio sem Propósito"**: Toda caminhada de mais de 10 segundos em linha reta deve conter ao menos:
   * Uma pista visual de Gyo (`GyoInspectable`).
   * Um recurso coletável ou baú escondido.
   * Um som ou rastro de criatura.
2. **Preservar Zonas de Respiro**: Não encher 100% dos setores de monstros; o jogador precisa de pausas de 4-8 segundos para gerenciar inventário e avaliar o minimapa.
