# ============================================================
# HUNTER ONLINE — LIVING WORLD BIBLE (FASE F)
# ============================================================
# Ecologia Urbana, Comportamento de NPCs Vivos e Rotinas
# Godot 4.4 / GDScript Estritamente Tipado
# ============================================================

## 1. Visão Geral e Filosofia do Mundo Vivo
O mundo de *Hunter x Hunter* pulsa com vida orgânica: cidades movimentadas como Zaban e Yorkshin possuem mercadores, transeuntes curiosos, apostadores e aspirantes a Hunter com motivações próprias.

Nenhum NPC deve se comportar como um poste estático esperando eternamente por um clique. Cada entidade viva possui rotinas espaciais, estados de atividade, culling de desempenho inteligente e diálogos altamente reativos ao estado do mundo e às escolhas do jogador.

---

## 2. Taxonomia de Status de Implementação
- **IMPLEMENTED**: Código em produção, integrado ao runtime e coberto por testes unitários.
- **PARTIAL**: Sistema funcional com expansões visuais ou de conteúdo agendadas.
- **PLANNED**: Modelado formalmente para arcos posteriores.
- **DEFERRED**: Considerado fora do escopo ou prejudicial ao foco central do jogo.
- **LEGACY**: Padrões antigos descontinuados.

---

## 3. Matriz de Componentes do Mundo Vivo

| Componente | Status | Arquivo / Classe | Descrição |
|---|---|---|---|
| **LivingNPCBehavior** | `IMPLEMENTED` | `entities/npc/LivingNPCBehavior.gd` | Controlador modular acoplável a qualquer CharacterBody2D. |
| **Rotinas e Waypoints Agendados** | `IMPLEMENTED` | `schedule_waypoints` | Percurso de waypoints com pausas aleatórias naturais (1.5s a 4.0s). |
| **Otimização por Distance Culling** | `IMPLEMENTED` | `dist_jogador > 480.0` | Suspende cálculo de navegação física quando longe do jogador (economia de CPU). |
| **Diálogos Reativos e Condicionais** | `IMPLEMENTED` | `obter_dialogo_reativo()` | Fala contextualmente sobre escolhas feitas (ex: desmascarar Tonpa, avanços de saga). |
| **Interface de Treinamento com Mestres** | `IMPLEMENTED` | `pode_treinar()` / `executar_treinamento()` | Integração direta de NPCs mestres com o `TrainingSystem`. |
| **Reação a Rumores e Facções** | `IMPLEMENTED` | `RumorSystem` / `FactionManager` | Propagação de fofocas locais e atitude conforme reputação do jogador. |
| **Ciclo Dia/Noite com Troca de Rotinas** | `PARTIAL` | `WorldState.gd` | Estados de relógio mundiais existem; iluminação e troca de turnos em expansão visual. |
| **Simulação de Multidão em Pânico (Yorknew)** | `PLANNED` | `CrowdDensityManager` | Dispersão tática de multidões durante invasões da Trupe Fantasma. |
| **Economia Autônoma de Simulação NPC** | `DEFERRED` | N/A | Postergado para focar em combate, Nen e narrativa em vez de microssimulação mercantil. |
| **NPCs Estáticos com Texto Único** | `LEGACY` | Antigos nós de NPC | Substituídos integralmente por `LivingNPCBehavior`. |

---

## 4. Estrutura de Comportamento de NPC (`LivingNPCBehavior`)

### 4.1 Estados de Vida
- `IDLE`: Parado observando o ambiente, olhando ao redor ou descansando.
- `PATROL`: Caminhando suavemente entre os waypoints definidos para seu distrito.
- `TALKING`: Interagindo ativamente com o jogador, virado para a face do avatar.
- `FLEEING`: Fugindo de perigos iminentes, disparos de Nen hostis ou bestas selvagens.
- `CUSTOM`: Ação roteirizada para eventos de cutscene ou treinamento.

### 4.2 Otimização de Performance
Para suportar dezenas de NPCs por mapa sem comprometer a taxa de quadros (60 FPS):
- Se a distância entre o NPC e o jogador for superior a 480 pixels, o processamento de física e raycasts é suspenso, mantendo o ator em repouso.
- Ao entrar no raio de 480 pixels, a simulação retoma imediatamente sem engasgos.
