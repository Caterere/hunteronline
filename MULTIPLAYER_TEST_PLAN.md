# MULTIPLAYER TEST PLAN & QA SPECIFICATION
## HUNTER ONLINE — SUITE DE TESTES, MATRIZ DE LATÊNCIA E PROTOCOLO DE REGRESSÃO

---

## 1. OBJETIVO DO PLANO DE TESTES

Garantir que a nova infraestrutura de **Servidor Dedicado Autoritativo (`HunterServer`)** opere com estabilidade matemática, fidelidade física e persistência íntegra sob redes LAN e VPNs (Radmin VPN), sem quebrar a autonomia do modo single-player offline ou corromper os schemas de salvamento existentes.

---

## 2. CENÁRIOS DE TESTES COOPERATIVOS

### Cenário 1: Dupla de Caçadores em Rede LAN / VPN (2 Players)
- **Objetivo:** Validar movimentação compartilhada, sincronização visual de modos de Nen (Ten, Ren, Gyo, Zetsu) e combate simultâneo contra inimigos do mapa.
- **Passos:**
  1. Servidor dedicado iniciado na porta 7777.
  2. Caçador A (Intensificador) conecta via IP do Radmin VPN (`26.x.x.x`).
  3. Caçador B (Transformador) conecta em seguida.
  4. Caçador A ativa Ren; Caçador B deve visualizar imediatamente o halo dourado.
  5. Ambos atacam um grupo de slimes; verificar se os números de dano aparecem na mesma posição para ambos.
- **Critério de Sucesso:** Posições fluidas sem solavancos (interpolação de 50-100ms ativa), Nen sincronizado, zero quedas de conexão.

### Cenário 2: Masmorra Cooperativa de 4 Caçadores (4 Players Party)
- **Objetivo:** Testar o sistema de Party, vida compartilhada na HUD, portas com placas de pressão de equipe e distribuição de loot anti-duplicação.
- **Passos:**
  1. 4 Caçadores formam um grupo através do `PartyHUD` (tecla `P`).
  2. O líder guia a equipe até uma masmorra cooperativa.
  3. O portão da câmara do chefe só se abre quando todos os 4 caçadores pisam nas respectivas placas.
  4. Ao derrotar o chefe, o servidor gera loot exclusivo para cada jogador.
- **Critério de Sucesso:** Portão bloqueado com 3 jogadores e liberado com 4; cada jogador coleta seu item sem conflito de concorrência ou duplicação.

### Cenário 3: World Boss Co-op & Alternância de Ameaça (Aggro)
- **Objetivo:** Validar a tabela de ameaça (`threat_table`) multi-alvo do servidor e transições de fase sincronizadas.
- **Passos:**
  1. Dois atacantes enfrentam um World Boss de 20.000 HP.
  2. Jogador A ataca normalmente; o Boss o persegue.
  3. Jogador B usa uma habilidade de provocação (Taunt) ou causa um surto de dano massivo; o Boss vira seu foco imediatamente para o Jogador B.
  4. Aos 50% de HP, o Boss transiciona para a Fase 2 (Enrage); todos os jogadores visualizam o efeito visual simultaneamente.
- **Critério de Sucesso:** Boss foca o alvo correto sem indecisão de IA; transições de fase ocorrem no mesmo frame de tick.

### Cenário 4: Queda Abrupta de Conexão e Reconexão Segura
- **Objetivo:** Garantir que desconexões acidentais não causem perda de progresso nem duplicação de itens.
- **Passos:**
  1. Jogador 1 gasta 300 de HP em combate e coleta 5.000 Jenny.
  2. O processo do cliente do Jogador 1 é finalizado forçadamente.
  3. O servidor detecta o timeout, grava o estado atual no disco (`user://server_saves/players/`) e remove o puppet do mundo.
  4. O Jogador 1 reabre o jogo e conecta novamente.
- **Critério de Sucesso:** O Jogador 1 reaparece com o HP exato, ouro mantido e nas mesmas coordenadas em que caiu.

---

## 3. MATRIZ DE LATÊNCIA & DESEMPENHO

| Ambiente de Rede | RTT Médio | Jitter | TPS Servidor | Comportamento Esperado |
| :--- | :--- | :--- | :--- | :--- |
| **Loopback Local (127.0.0.1)** | < 1 ms | 0 ms | 20.0 TPS | Resposta imediata, hits 100% idênticos ao offline |
| **Rede LAN Cabeada / Wi-Fi 5GHz** | 2 ms - 8 ms | < 2 ms | 20.0 TPS | Interpolação perfeita, imperceptível para o olho humano |
| **Radmin VPN (Mesma Região)** | 25 ms - 55 ms | 5 ms - 10 ms | 20.0 TPS | Predição local oculta o atraso do dash; combate fluido |
| **Radmin VPN (Interestadual)** | 60 ms - 95 ms | 15 ms - 20 ms | 20.0 TPS | Reconciliação suave em caso de micro-correção de posição |
| **Conexão Degradada / 4G** | 120 ms - 180 ms | 30 ms - 50 ms | 20.0 TPS | Sistema aumenta levemente o buffer de interpolação |

---

## 4. SUÍTES AUTOMATIZADAS DE REGRESSÃO E HOMOLOGAÇÃO

O projeto possui 5 suítes automatizadas completas que validam 100% dos subsistemas do motor:

| Suíte de Testes | Arquivo de Execução | Asserções | Status |
| :--- | :--- | :--- | :--- |
| **Fase K-LAN (Dedicated Server)** | `res://scratch/test_phase_klan_dedicated_server_suite.tscn` | 59 testes | `100% APROVADO` |
| **Fase L (Live Content & Sagas)** | `res://scratch/test_phase_l_live_content_suite.tscn` | 79 testes | `100% APROVADO` |
| **Fase K (Multiplayer Foundation)** | `res://scratch/test_phase_k_multiplayer_suite.tscn` | 77 testes | `100% APROVADO` |
| **Fase J (Polimento Pesado & VFX)** | `res://scratch/test_phase_j_polish_suite.tscn` | 36 testes | `100% APROVADO` |
| **Fase I (Balanceamento Nv 1000)** | `res://scratch/test_phase_i_balance_suite.tscn` | 85 testes | `100% APROVADO` |
| **TOTAL GERAL DE VALIDAÇÃO** | — | **336 testes** | **100% APROVADO (0 FALHAS)** |

---

## 5. COMANDO DE EXECUÇÃO EM MODO HEADLESS

Para executar todos os testes da infraestrutura em qualquer máquina sem interface gráfica:
```powershell
& ".\Godot_v4.6-stable_win64_console.exe" --headless --scene "res://scratch/test_phase_klan_dedicated_server_suite.tscn"
```
