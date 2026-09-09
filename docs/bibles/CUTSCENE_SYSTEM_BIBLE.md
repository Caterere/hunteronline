# ============================================================
# HUNTER ONLINE — CUTSCENE SYSTEM BIBLE (FASE F)
# ============================================================
# Motor de Cutscenes, Micro-Scenes Cinematográficas e Atores
# Godot 4.4 / GDScript Estritamente Tipado
# ============================================================

## 1. Visão Geral
O sistema de cenas narrativas do Hunter Online foi projetado para elevar a apresentação visual do jogo, substituindo transições abruptas e caixas de texto soltas por sequências data-driven ricas, fluidas e cinematográficas.

O motor permite encenar tanto micro-cenas rápidas (ex: descoberta de uma pista, reação surpresa de um NPC) quanto sequências de grande porte (ex: abertura dos portões do Exame Hunter, chegada à Arena Celestial, revelação do Nen por Wing).

---

## 2. Taxonomia de Status de Implementação
- **IMPLEMENTED**: Totalmente funcional no runtime, com validação na suíte automatizada.
- **PARTIAL**: Funcionalidade em execução com refinamentos estéticos programados.
- **PLANNED**: Especificado para implementação na ferramenta do editor Godot.
- **DEFERRED**: Descartado ou postergado por incompatibilidade com fidelidade técnica.
- **LEGACY**: Abordagens obsoletas descontinuadas em favor do novo motor.

---

## 3. Matriz de Recursos do Motor de Cutscenes

| Recurso | Status | Implementação | Descrição |
|---|---|---|---|
| **CutsceneSequenceRunner** | `IMPLEMENTED` | `scripts/cutscenes/CutsceneSequenceRunner.gd` | Motor data-driven em GDScript para execução sequencial de passos. |
| **Passos Data-Driven (15 Tipos)** | `IMPLEMENTED` | `StepType` Enum | Suporte a 15 ações narrativas sem necessidade de compilação de código de cena. |
| **Trava e Destrava Segura de Input** | `IMPLEMENTED` | `StepType.LOCK_INPUT` | Congela os controles do jogador e garante destrava ao término ou cancelamento. |
| **Movimentação e Orientação de Atores** | `IMPLEMENTED` | `StepType.MOVE_ACTOR` / `FACE_ACTOR` | Interpolação suave e virada de sprite em direção ao alvo. |
| **Controle de Câmera Cinematográfica** | `IMPLEMENTED` | `CinematicCameraController.gd` | Foco em nós ou coordenadas, zoom suave (close-ups) e restauração limpa. |
| **Screen Shake Cinematográfico** | `IMPLEMENTED` | `StepType.CAMERA_SHAKE` | Tremores com intensidade e duração ajustáveis despachados via EventBus. |
| **Diálogos e Balões em Quadrinhos** | `IMPLEMENTED` | `StepType.DIALOGUE` | Apresentação com avatar do personagem, texto datilografado e avanço por clique. |
| **Escolhas Narrativas com Feedback** | `IMPLEMENTED` | `StepType.CHOICE` | Opções de ramificação contextual integradas ao StoryManager. |
| **Execução de Áudio (SFX e BGM)** | `IMPLEMENTED` | `StepType.AUDIO_SFX` / `AUDIO_BGM` | Disparo seguro de efeitos e troca de faixas musicais canônicas. |
| **Cards de Mangá e Efeitos de Impacto** | `PARTIAL` | `StepType.EFFECT_FX` | Flash de tela e cartas de impacto ativos; animações de retícula de mangá em polimento. |
| **Editor Visual de Linha do Tempo** | `PLANNED` | Godot Editor Plugin | Interface gráfica no editor para arrastar e soltar blocos de cutscene. |
| **Cutscenes Pré-Renderizadas em Vídeo (.mp4)**| `DEFERRED` | N/A | Postergado para garantir que o visual do avatar personalizado do Caçador seja sempre preservado. |
| **Cenas Rígidas de AnimationPlayer por Mapa**| `LEGACY` | Antigas cenas em `world/maps/` | Cenas embutidas diretamente em AnimationPlayer de salas individuais. |

---

## 4. Catálogo de Tipos de Passos (`StepType`)

1. `LOCK_INPUT`: Trava (`lock: true`) ou destrava (`lock: false`) controles do jogador.
2. `MOVE_ACTOR`: Movimenta ator ou jogador até coordenadas especificadas com velocidade ajustável.
3. `FACE_ACTOR`: Faz o ator olhar em direção a outro nó (`target_node`) ou direção vetorial (`direction`).
4. `CAMERA_FOCUS`: Suaviza a câmera do jogo em direção ao alvo cinematográfico.
5. `CAMERA_ZOOM`: Modifica a ampliação da câmera (ex: `1.3x` para momentos de tensão).
6. `CAMERA_SHAKE`: Tremor de tela com intensidade (`intensity`) e duração (`duration`).
7. `DIALOGUE`: Apresenta fala de personagem com speaker e texto.
8. `CHOICE`: Ramifica a narrativa com opções interativas.
9. `PLAY_ANIMATION`: Executa animação no `AnimationPlayer` ou `AnimationTree` do ator.
10. `WAIT`: Pausa dramática com tempo em segundos (`seconds`).
11. `AUDIO_SFX`: Executa efeito sonoro via `AudioManager`.
12. `AUDIO_BGM`: Altera a trilha sonora ambiente para tema específico da cena.
13. `EFFECT_FX`: Dispara efeitos visuais, flashes e partículas.
14. `SET_FLAG`: Grava flag de progresso no `StoryManager`.
15. `TRIGGER`: Executa um `Callable` arbitrário para integração com sistemas complexos.

---

## 5. Exemplo de Definição Data-Driven
```gdscript
var passos: Array[Dictionary] = [
	{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": true},
	{"type": CutsceneSequenceRunner.StepType.CAMERA_ZOOM, "zoom": Vector2(1.25, 1.25), "duration": 0.4},
	{"type": CutsceneSequenceRunner.StepType.DIALOGUE, "speaker": "Satotz", "text": "Bem-vindos à 1ª Fase do Exame Hunter."},
	{"type": CutsceneSequenceRunner.StepType.SET_FLAG, "flag": "exame_iniciado", "value": true},
	{"type": CutsceneSequenceRunner.StepType.LOCK_INPUT, "lock": false}
]
CutsceneSequenceRunner.executar(get_tree(), passos, "Abertura_Exame")
```
