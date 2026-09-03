# ADR-005: CAMADA CENTRAL DE PERCEPÇÃO E SENTIDOS (PERCEPTIONSYSTEM)

## Contexto
O cálculo de detecção de alvos e furtividade estava sendo implementado de forma descentralizada dentro do script `EnemyAI.gd`. Isso dificultava estender sentidos para múltiplos tipos de IA (como arqueiros, cães farejadores ou mestres de Nen) e forçava cada inimigo a conhecer detalhes de implementação de Zetsu e Ren.

## Decisão
1. Criar a camada central `PerceptionSystem.gd`, responsável por calcular a detecção física, sensorial e de aura.
2. `EnemyAI.gd` delega suas consultas de detecção e awareness para o `PerceptionSystem`.
3. O `PerceptionSystem` também fornece o serviço de avaliação de visibilidade de segredos e pistas no mundo para o componente `GyoInspectable.gd`.

## Consequências
- Desacoplamento completo entre a IA dos inimigos e as técnicas ativas do jogador.
- Centralização das fórmulas de stealth e detecção de aura em um único ponto testável.
