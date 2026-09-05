# NETWORK PROTOCOL SPECIFICATION
## Hunter MMORPG — Opcodes, Estrutura de Pacotes e Ciclo de Comunicação

---

## 1. CAMADA DE TRANSPORTE & TOPOLOGIA

O Hunter MMORPG opera sobre a camada de transporte **ENet (UDP confiável e não-confiável)** fornecida nativamente pela Godot Engine 4.6, além de um socket UDP puro para descoberta local.

### Topologia de Rede
```text
┌──────────────────────────────────────────────────────────────┐
│                    HUNTER DEDICATED SERVER                   │
│          (Authoritative Simulation Loop — 20 TPS)            │
│            ServerWorldCoordinator + AntiCheat                │
└──────────────▲───────────────────────────────▲───────────────┘
               │                               │
        ENet (UDP 7777)                 ENet (UDP 7777)
    (Intents, Snapshots, RPCs)      (Intents, Snapshots, RPCs)
               │                               │
┌──────────────▼───────────────┐┌──────────────▼───────────────┐
│       HUNTER CLIENT A        ││       HUNTER CLIENT B        │
│   (Predictive / Render)      ││   (Predictive / Render)      │
└──────────────────────────────┘└──────────────────────────────┘
```

---

## 2. CANAIS DE TRANSMISSÃO ENET

| Canal | Modo de Transferência | Propósito | Exemplo de Dados |
| :--- | :--- | :--- | :--- |
| **Canal 0** | `RELIABLE` | Eventos de estado críticos e autenticação | Handshake, Entrada/Saída de Jogadores, Troca de Mapa, Morte de Entidades, Formação de Party |
| **Canal 1** | `UNRELIABLE_ORDERED` | Fluxo contínuo de simulação temporal | Envio de Intenções de Input do Jogador (60 Hz / 20 Hz), Snapshots do Mundo pelo Servidor (20 Hz) |
| **Canal 2** | `UNRELIABLE` | Efeitos cosméticos e telemetria volátil | Ping/Pong RTT, partículas visuais efêmeras |

---

## 3. PROTOCOLO DE DESCOBERTA LAN (UDP BROADCAST)

### Porta: `7778 UDP` | Frequência: 1.5 segundos
O servidor dedicado emite periodicamente pacotes de broadcast para a sub-rede local (`255.255.255.255:7778`).

### Estrutura do Pacote de Descoberta:
```text
[Magic Header: 24 bytes String] + [JSON Payload UTF-8]
```
- **Magic Header:** `HUNTER_LAN_BROADCAST_v1`
- **JSON Payload Exemplo:**
```json
{
  "nome": "Hunter Dedicated LAN",
  "porta": 7777,
  "jogadores": 2,
  "max_jogadores": 16,
  "versao": "1.2.0-dedicated",
  "mapa": "res://world/lobby.tscn",
  "requer_senha": false
}
```

O cliente escuta a porta `7778` através do `LanDiscoveryListener`, calcula o tempo de resposta e exibe o servidor na lista com um clique para conexão direta.

---

## 4. PROTOCOLO DE HANDSHAKE & AUTENTICAÇÃO

Ao estabelecer o socket de rede inicial com o servidor, o cliente não entra diretamente no mundo. O cliente deve primeiro autenticar-se.

```text
CLIENTE                                                      SERVIDOR
   │                                                            │
   │──── (RPC Confiável) rpc_requisitar_handshake(dados) ──────>│
   │     - token_versao: "1.2.0-dedicated"                      │
   │     - character_name: "Gon"                                │
   │     - player_level: 35                                     │
   │     - character_class: "ENHANCEMENT"                       │
   │     - password_hash: "..."                                 │
   │                                                            │
   │                                                            │── Valida versão compatível
   │                                                            │── Valida capacidade (< max_players)
   │                                                            │── Valida senha de acesso
   │                                                            │── Carrega/cria save no servidor
   │                                                            │
   │<─── (RPC Confiável) rpc_handshake_aceito(payload) ─────────│ (Sucesso)
   │     - peer_id: ID atribuído pelo servidor                  │
   │     - tick_rate: 20                                        │
   │     - spawn_x, spawn_y                                     │
   │     - world_map: "res://world/lobby.tscn"                  │
   │                                                            │
   │  OU                                                        │
   │<─── (RPC Confiável) rpc_handshake_rejeitado(motivo) ───────│ (Falha)
   │     - motivo: "Versão incompatível" / "Senha incorreta"    │
```

---

## 5. FLUXO DE INTENÇÃO DE INPUT (CLIENTE -> SERVIDOR)

Os clientes não transmitem posições absolutas aceitas. Eles transmitem **intenções de input** a cada frame:

### RPC: `rpc_enviar_intencao_input(intent_data: Dictionary)`
- **Modo:** `UNRELIABLE_ORDERED`
- **Campos:**
```json
{
  "seq": 4821,
  "input_vector": [0.707, -0.707],
  "sprint": true,
  "nen_mode": "REN",
  "target_direction": [1.0, 0.0],
  "timestamp": 1772885002100
}
```

O `ServerWorldCoordinator` no servidor consome essa intenção:
1. Submete a intenção ao `AntiCheatValidator`.
2. Integra a velocidade do personagem baseada em seus atributos reais e bônus de Nen.
3. Resolve colisões contra o mapa autoritativo.
4. Atualiza as coordenadas autoritativas do caçador no mundo.

---

## 6. SNAPSHOTS DO ESTADO MUNDIAL (SERVIDOR -> CLIENTES)

A cada tick de simulação (20 TPS / a cada 50ms), o servidor empacota o estado completo do mundo e envia a todos os caçadores:

### RPC: `rpc_receber_snapshot_mundo(snapshot_data: Dictionary)`
- **Modo:** `UNRELIABLE_ORDERED`
- **Campos:**
```json
{
  "tick": 19482,
  "timestamp": 1772885002150,
  "players": {
    "1": {
      "px": 340.5,
      "py": 412.0,
      "vx": 120.0,
      "vy": -80.0,
      "hp": 2400,
      "max_hp": 2400,
      "aura": 1180.0,
      "nen": "REN",
      "anim": "run"
    },
    "2": {
      "px": 500.0,
      "py": 415.0,
      "vx": 0.0,
      "vy": 0.0,
      "hp": 1800,
      "max_hp": 1800,
      "aura": 900.0,
      "nen": "TEN",
      "anim": "idle"
    }
  },
  "enemies": {
    "slime_01": {
      "px": 360.0,
      "py": 410.0,
      "hp": 45,
      "target_peer": 1,
      "state": "ATTACK"
    }
  }
}
```

Nos clientes, os nós `NetworkPlayer` recebem o snapshot e executam **interpolação amortecida** entre o snapshot anterior e o atual, garantindo 60 FPS visuais sem solavancos.

---

## 7. PROTOCOLO DE COMBATE E SINCRONIZAÇÃO DE NEN

### Requisição de Ataque Básico:
```text
CLIENTE                                              SERVIDOR
   │──── (RPC) rpc_requisitar_ataque(arma, dir) ────>│
   │                                                 │── Valida cooldown de ataque
   │                                                 │── Valida alcance físico
   │                                                 │── Computa mitigação de dano
   │                                                 │── Aplica dano ao inimigo
   │<─── (RPC) rpc_confirmar_dano(dano, critico) ────│
```

### Requisição de Hatsu (Habilidade de Nen):
```text
CLIENTE                                              SERVIDOR
   │──── (RPC) rpc_requisitar_hatsu(slot_idx, dir) ─>│
   │                                                 │── Consulta HatsuData canônico
   │                                                 │── Valida se AuraAtual >= CustoAura
   │                                                 │── Deduz Aura no servidor
   │                                                 │── Spawna projétil/hitbox autoritativa
   │<─── (RPC) rpc_confirmar_hatsu_cast(ok, aura) ───│
```

---

## 8. PROTOCOLO DE DESCONEXÃO E PERSISTÊNCIA

1. **Desconexão Voluntária:**
   - O cliente envia `rpc_requisitar_desconexao()`.
   - O servidor consolida o estado do jogador no disco (`user://server_saves/players/`).
   - O servidor notifica os demais peers para destruírem o `NetworkPlayer` correspondente.
   - O socket é finalizado graciosamente.

2. **Queda Abrupta (Timeout / Perda de Conexão):**
   - O ENet detecta falta de pacotes após `connection_timeout` (padrão: 5000ms).
   - O sinal `peer_disconnected` é disparado no servidor.
   - O servidor salva imediatamente o último estado conhecido do jogador.
   - O mundo continua rodando sem interrupção.
