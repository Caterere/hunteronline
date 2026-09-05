# AUDIO & SOUND DESIGN BIBLE
## HUNTER ONLINE — SOUNDSCAPE, CANONICAL OSTS & PROCEDURAL SYNTHESIS

---

## 1. PRINCÍPIOS DO DESIGN SONORO

O universo sonoro de Hunter Online é fundamentado em duas camadas complementares:
1. **Trilha Sonora Canônica:** Faixas orquestrais e sinfônicas originais de Yoshihisa Hirano e Toshihiko Sahashi, evocando a grandiosidade, o mistério e a tensão tática do anime.
2. **Síntese Sonora Procedural (Zero-Asset Fallback):** Um motor de áudio procedural (`AudioSynth.gd`) capaz de sintetizar buffers WAV em tempo de execução via equações harmônicas e moduladores de frequência, garantindo que o jogo seja 100% sonoro mesmo na ausência de arquivos `.wav`/`.ogg` externos.

---

## 2. ARQUITETURA DO AUDIOMANAGER

O `AudioManager` é um Autoload Singleton que opera com:
- **Canal Duplo de Música (A/B Crossfade):** Dois nós `AudioStreamPlayer` independentes executam transições suaves de volume (fade out / fade in) de 1.0 a 1.5 segundos entre temas de exploração, combate e chefes.
- **Dicionário Canônico de Faixas:** 28 faixas cadastradas com IDs canônicos:
  - `departure`, `hunting_for_your_dream`, `legend_of_the_martial_artist`, `lacrimosa`, `kingdom_of_predators`, `in_the_palace_agitato`, `riot`, `elegy_of_the_dynast`, `the_last_mission`.
- **Seleção Dinâmica por Chefe:**
  - Chrollo Lucilfer ➔ `lacrimosa`
  - Meruem ➔ `in_the_palace_agitato`
  - Hisoka Morow ➔ `legend_of_the_martial_artist`
  - Guardas Reais Quimera ➔ `kingdom_of_predators`
  - Outros Chefes ➔ `riot`

---

## 3. MOTOR PROCEDURAL AUDIOSYNTH (SFX RUNTIME)

Implementado em `autoload/AudioSynth.gd`, gera amostras de 44.1kHz / 16-bit com decay exponencial e modulações senoidais/ruído branco:

| ID de Som | Onda Base / Modulação | Frequência | Propósito |
| :--- | :--- | :--- | :--- |
| `footstep_grass` | White noise filtrado + tom baixo | 180 Hz | Passos na grama |
| `footstep_stone` | Estalo percussivo agudo | 420 Hz | Passos na pedra |
| `hurt` | Tom descendente senoidal + distorção | 190 ➔ 90 Hz | Dano sofrido pelo Hunter |
| `block` | Impacto ressonante metálico | 650 ➔ 450 Hz | Bloqueio de golpe |
| `ui_error` | Beep duplo dissonante descendente | 220 ➔ 140 Hz | Falha de ativação de Hatsu |
| `boss_intro` | Fanfarra tríade maior ascendente | C4-E4-G4-C5 | Apresentação cinemática de chefe |
| `boss_phase` | Pulso sub-grave de Ren expansivo | 65 ➔ 140 Hz | Transição de fase de chefe |
| `hatsu_enhancer` | Punch sub-bass encorpado | 90 Hz | Liberação de Intensificação |
| `hatsu_transmuter`| Zumbido elétrico modulado em serra | 440 Hz FM | Eletricidade / Transmutação |
| `hatsu_emitter` | Disparo de projétil supersônico | 880 ➔ 300 Hz | Rajada de Emissão |
| `hatsu_manipulator`| Pulso magnético oscilante | 320 Hz | Controle / Manipulação |
| `hatsu_conjurer` | Ressonância cristalina cintilante | 780 Hz sine | Materialização de objeto |
| `hatsu_specialist` | Ondulação misteriosa com tremolo | 260 Hz AM | Poder Único / Especialização |

---

## 4. MATRIZ DE STATUS DE IMPLEMENTAÇÃO (FASE J)

| Subsistema de Áudio | Status | Detalhes & Componentes |
| :--- | :--- | :--- |
| **Crossfade Musical Suave (1.5s)**| `[IMPLEMENTED]` | `AudioManager._executar_crossfade()` com 2 players |
| **Músicas de Boss Canônicas** | `[IMPLEMENTED]` | `AudioManager.tocar_musica_boss()` |
| **Passos Cadenciados por Piso** | `[IMPLEMENTED]` | `AudioManager.tocar_passo("grass" / "stone")` |
| **SFX de Dano & Bloqueio** | `[IMPLEMENTED]` | `AudioManager.tocar_hurt()`, `tocar_bloqueio()` |
| **SFX das 6 Naturezas de Nen** | `[IMPLEMENTED]` | `AudioManager.tocar_hatsu_categoria()` |
| **Fanfarra de Boss Intro & Fase**| `[IMPLEMENTED]` | `AudioManager.tocar_boss_intro()`, `tocar_boss_phase()` |
| **Feedback de Erro UI** | `[IMPLEMENTED]` | `AudioManager.tocar_ui_error()` ao falhar Hatsu |
| **Pool de Vozes para Diálogos** | `[IN PROGRESS]` | Sintetizador de murmúrios curtos estilo Animal Crossing / Zelda |
| **Áudio Posicional 3D / Espacial**| `[PLANNED]` | `AudioStreamPlayer2D` com atenuação de distância para cachoeiras e passos de monstros |
| **Orquestra Dinâmica Adaptativa**| `[FUTURE]` | Músicas em camadas que adicionam percussão conforme a vida cai |
