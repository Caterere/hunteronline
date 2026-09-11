# DEDICATED SERVER SETUP & HOSTING MANUAL
## Hunter MMORPG — Configuração, Portas, Modo Headless e Operação de Servidores

---

## 1. INTRODUÇÃO & FILOSOFIA

O servidor dedicado do Hunter MMORPG (`HunterServer`) foi concebido como um processo autônomo, desacoplado de qualquer cliente de visualização gráfica. 

Ele pode ser executado:
1. Em uma máquina local comum enquanto o host também joga o cliente.
2. Em um computador secundário dentro da rede LAN.
3. Em um servidor virtual privado (VPS) rodando Windows ou Linux em modo `--headless` (sem interface gráfica ou GPU).

---

## 2. ARQUIVO DE CONFIGURAÇÃO (`config/server_config.json`)

Ao iniciar, o servidor tenta ler o arquivo `res://config/server_config.json` ou `user://server_config.json`. Se o arquivo não existir, o servidor cria automaticamente a configuração padrão:

```json
{
  "server_name": "Hunter Dedicated LAN",
  "server_port": 7777,
  "discovery_port": 7778,
  "max_players": 16,
  "tick_rate": 20,
  "password": "",
  "default_map": "res://world/lobby.tscn",
  "allow_pvp": true,
  "pvp_damage_factor": 0.5,
  "save_interval_sec": 60,
  "motd": "Bem-vindo ao servidor LAN de Hunter Online!"
}
```

### Explicação dos Parâmetros

| Parâmetro | Tipo | Padrão | Descrição |
| :--- | :--- | :--- | :--- |
| `server_name` | String | `"Hunter Dedicated LAN"` | Nome visível na lista de servidores descobertos via LAN. |
| `server_port` | Int | `7777` | Porta UDP principal para comunicação de jogo via protocolo ENet. |
| `discovery_port` | Int | `7778` | Porta UDP utilizada para emissão de pacotes broadcast de descoberta na rede local. |
| `max_players` | Int | `16` | Capacidade máxima simultânea de caçadores no mundo. |
| `tick_rate` | Int | `20` | Frequência de simulação autoritativa do mundo (Ticks Por Segundo - TPS). |
| `password` | String | `""` | Senha de acesso. Se vazia, qualquer caçador pode conectar livremente. |
| `default_map` | String | `"res://world/lobby.tscn"` | Caminho da cena do mapa onde novos caçadores são inseridos. |
| `allow_pvp` | Bool | `true` | Habilita ou desabilita o sistema de duelos consensuais 1v1. |
| `pvp_damage_factor` | Float | `0.5` | Redutor de dano aplicado em duelos para combates equilibrados. |
| `save_interval_sec`| Int | `60` | Intervalo em segundos para salvamento automático de todos os jogadores no disco do servidor. |
| `motd` | String | `...` | Mensagem do dia enviada aos jogadores logo após a validação do handshake. |

---

## 3. EXECUTANDO O SERVIDOR VIA LINHA DE COMANDO (HEADLESS / CLI)

O servidor pode ser iniciado a partir de qualquer terminal (PowerShell, CMD, Bash) sem carregar janelas gráficas, economizando memória RAM e CPU:

### Windows (Console)
```powershell
& ".\Godot_v4.6-stable_win64_console.exe" --headless --scene "res://server/HunterServer.tscn"
```

### Linux (Server)
```bash
./godot.x86_64 --headless --scene res://server/HunterServer.tscn
```

### Sobrescrita de Parâmetros via Linha de Comando (CLI Flags)
O `ServerConfig` analisa argumentos passados na inicialização e sobrescreve as opções do JSON:

```powershell
& ".\Godot_v4.6-stable_win64_console.exe" --headless --scene "res://server/HunterServer.tscn" `
    --port 7799 `
    --discovery-port 7780 `
    --max-players 32 `
    --name "Servidor Hunter Pro" `
    --password "nen123" `
    --tick-rate 30
```

---

## 4. INICIALIZADOR POR LOTE (`iniciar_servidor_lan.bat`)

Para maior comodidade no Windows, utilize o arquivo `iniciar_servidor_lan.bat` localizado na raiz do projeto:

```cmd
@echo off
title Hunter MMORPG - Dedicated Server
echo ============================================================
echo        HUNTER MMORPG - SERVIDOR DEDICADO LAN
echo ============================================================
echo Inicializando o processo autoritativo do mundo...
Godot_v4.6-stable_win64_console.exe --headless --scene res://server/HunterServer.tscn
pause
```

---

## 5. REDE, PORTAS E FIREWALL

Para permitir que outros computadores se conectem ao servidor:

### Regras de Firewall do Windows (PowerShell Administrador)
Execute o seguinte comando para liberar o tráfego das portas do Hunter MMORPG:
```powershell
New-NetFirewallRule -DisplayName "Hunter MMORPG Server (ENet UDP)" -Direction Inbound -LocalPort 7777 -Protocol UDP -Action Allow
New-NetFirewallRule -DisplayName "Hunter MMORPG Discovery (Broadcast UDP)" -Direction Inbound -LocalPort 7778 -Protocol UDP -Action Allow
```

### Redes LAN vs Radmin VPN vs VPS Público
- **Rede Local (Mesmo Wi-Fi/Switch):** Não requer configuração de roteador (Port Forwarding). A descoberta automática por broadcast na porta 7778 funcionará nativamente.
- **Radmin VPN:** Cria um túnel P2P virtual criptografado. O broadcast UDP pode ser filtrado em alguns casos pelo software, portanto a conexão direta pelo IP `26.x.x.x` na porta `7777` é a mais confiável.
- **VPS / Hospedagem na Nuvem (DigitalOcean, AWS, Linode, Oracle Cloud):**
  - Libere a porta `7777 UDP` no Security Group / UFW da máquina virtual.
  - Aponte os jogadores diretamente para o IP público da VPS (ou DNS).
  - Em `config/server_config.json` (ou CLI):
    - `"public_host": "hunter.seudominio.com"`
    - `"enable_lan_discovery": false` (ou `--no-lan-discovery`) — broadcast UDP não funciona na internet.
    - `"bind_address": "*"` para escutar em todas as interfaces.
  - Discovery na porta `7778` pode ficar fechada no firewall público.

### Checklist rápido: LAN hoje → host depois
1. **Hoje (mesma rede):** `./iniciar_servidor_lan.sh` no PC host → clientes em IP `192.168.x.x:7777` ou lista LAN.
2. **Depois (VPS):** mesmo binário/projeto, abrir UDP 7777, setar `public_host`, desligar discovery, clientes conectam por IP/DNS.
3. **Lista DNS no cliente:** edite `config/server_list.json` (ou `user://server_list.json`) com o host do VPS; o menu Multiplayer mostra em **SERVIDORES PÚBLICOS / DNS**.
4. **Escalabilidade de banda:**
   - `interest_radius` (padrão 900) + `snapshot_delta` (padrão true) enviam só o que mudou perto do peer.
   - `snapshot_send_hz` (padrão 10) limita envio mesmo com tick 20 TPS.
   - `snapshot_compress` (padrão true) aplica DEFLATE em pacotes ≥ `snapshot_compress_min_bytes`.
   - Overlay **F4** mostra `SNAP: Hz | KB/s | ratio | pkt/s`.
   - Relatório headless: `res://scratch/test_snapshot_bandwidth_stress_suite.tscn`.
5. **Master registry (opcional):** UDP `7780` — `./iniciar_servidor_lan.sh -- --master-registry 7780` e game servers com `--master-announce --master-host <ip>`.

---

## 6. ARMAZENAMENTO E SAVES DO SERVIDOR (`ServerStorageManager`)

O servidor mantém seus próprios arquivos de persistência de forma independente dos arquivos locais de cada cliente:

```text
user://server_saves/
├── world_state.json                 <- Estado global do mundo (tempo, eventos ativos)
└── players/
    ├── hunter_Gon_s1.json           <- Dados autoritativos do caçador Gon
    ├── hunter_Killua_s1.json        <- Dados autoritativos do caçador Killua
    └── hunter_Kurapika_s1.json      <- Dados autoritativos do caçador Kurapika
```

### Formato do Save do Jogador no Servidor
```json
{
  "nome": "Gon",
  "level": 35,
  "hp": 2400,
  "max_hp": 2400,
  "aura": 1200.0,
  "max_aura": 1200.0,
  "nen_affinity": "ENHANCEMENT",
  "pos_x": 320.0,
  "pos_y": 480.0,
  "gold": 15000,
  "inventory": [],
  "equipped": {},
  "timestamp_servidor": 1772884900
}
```

- Quando o jogador se desconecta voluntariamente ou perde conexão, o servidor grava imediatamente o estado atual no disco.
- Ao reconectar, o jogador retoma seu HP, aura, inventário e posição exata onde estava no mapa.

---

## 7. TELEMETRIA E MONITORAMENTO

Ao pressionar `F4` em qualquer cliente ou monitorar os logs do console do servidor:
- **TPS (Ticks Por Segundo):** Deve se manter em 20 TPS estáveis.
- **RTT / Ping:** Latência média em milissegundos.
- **Packet In/Out:** Número de pacotes transmitidos e recebidos por segundo.
- **Anti-Cheat Alerts:** Avisos instantâneos caso pacotes anômalos de speedhack ou injeção de dano sejam descartados.
