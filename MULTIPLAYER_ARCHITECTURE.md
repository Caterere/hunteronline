# MULTIPLAYER ARCHITECTURE — HUNTER ONLINE
## DEDICATED SERVER FOUNDATION & SERVER-AUTHORITATIVE ARCHITECTURE

---

## 1. INTRODUÇÃO & FILOSOFIA DE DESIGN

O sistema multiplayer de Hunter Online é fundamentado no princípio:
> **"Single-player intacto → Servidor Dedicado Autoritativo → Co-op estável → Conteúdo cooperativo → Escalabilidade → PvP por último."**

O jogo foi projetado desde a base para operar sem dependência obrigatória de internet ou servidores dedicados. No modo `OFFLINE_SINGLEPLAYER`, todo o pipeline de rede é transparente, mantendo latência 0ms e autoridade local direta.

A partir da **Fase K-LAN**, o multiplayer opera sobre uma arquitetura de **Servidor Dedicado Autoritativo (`HunterServer`)**, eliminando a figura frágil do "jogador host". O servidor é um processo independente responsável por toda a simulação do mundo.

```text
┌─────────────────────────────────────────────────────────────┐
│                 HUNTER ONLINE ENGINE TOPOLOGY               │
├──────────────────────────────┬──────────────────────────────┤
│     OFFLINE SINGLEPLAYER     │       DEDICATED SERVER       │
│  - Autoridade Local Direta   │  - Servidor Dedicado (Hunter)│
│  - 0ms Latência / Sem Rede   │  - 20 TPS World Simulation   │
│  - PlayerData é Autoridade   │  - Validação Server-Side     │
│  - Sem Overhead de Pacotes   │  - Descoberta UDP Broadcast  │
└──────────────────────────────┴──────────────────────────────┘
```

---

## 2. TOPOLOGIA DO SISTEMA DEDICADO

```text
                        ┌─────────────────────────────────────┐
                        │      HunterServer (Processo CLI)    │
                        │  - ServerWorldCoordinator (20 TPS)  │
                        │  - AntiCheatValidator               │
                        │  - ServerStorageManager (Disk)      │
                        │  - LanDiscoveryBroadcaster (UDP)    │
                        └──────────────▲───────▲──────────────┘
                                       │       │
                      ENet UDP (Porta 7777)   ENet UDP (Porta 7777)
                                       │       │
         ┌─────────────────────────────┴┐     ┌┴────────────────────────────┐
         │       Hunter Client 1        │     │       Hunter Client 2       │
         │  - Player (Entidade Local)   │     │  - Player (Entidade Local)  │
         │  - NetworkPlayer (Remote)    │     │  - NetworkPlayer (Remote)   │
         │  - Prediction & Interpolação │     │  - Prediction & Interpolação│
         │  - Camera, VFX & Áudio       │     │  - Camera, VFX & Áudio      │
         └──────────────────────────────┘     └─────────────────────────────┘
```

---

## 3. DIVISÃO RIGOROSA DE RESPONSABILIDADES

Nenhum cliente possui autoridade de escrita sobre valores críticos de jogo. O cliente é um terminal de visualização, predição cosmética e envio de intenções:

| Domínio de Dados | Autoridade | Responsabilidade do Servidor Dedicado | Responsabilidade do Cliente |
| :--- | :--- | :--- | :--- |
| **Simulação do Mundo** | **SERVIDOR** | Roda o loop a 20 TPS, integra inputs e física | Renderiza a 60 FPS com interpolação |
| **HP & Dano** | **SERVIDOR** | Calcula mitigação, defesa e reduz HP | Exibe números de dano e hit flash |
| **Aura & Técnicas de Nen**| **SERVIDOR** | Valida consumo de aura e modos de Nen | Exibe brilho visual de aura (Ten/Ren/Gyo/Zetsu)|
| **Hatsu & Votos** | **SERVIDOR** | Valida condições, cooldowns e custos | Animação imediata (client prediction)|
| **Posição & Física** | **SERVIDOR** | Valida velocidade, colisões e paredes | Predição local + Reconciliação suave |
| **Inimigos & IA** | **SERVIDOR** | Move monstros, calcula threat e persegue | Interpola posição e espelha animações |
| **XP, Nível & Drops** | **SERVIDOR** | Gera drops individuais e distribui XP| Atualiza barras de progresso na HUD |
| **Quests & Objetivos** | **SERVIDOR** | Sincroniza progresso compartilhado | Exibe notificações e rastreador |
| **Saves Persistentes** | **SERVIDOR** | Salva atomicamente em `user://server_saves/`| Mantém cópia de cache local offline |

---

## 4. COMPONENTES DO SUBSISTEMA DE REDE DEDICADO

### 4.1 HunterServerMain (`server/HunterServerMain.gd`) & `HunterServer.tscn`
- Ponto de entrada do processo de servidor dedicado.
- Inicializa o motor de rede em modo headless ou janela de console dedicada.
- Imprime o banner ASCII de status com portas, tick rate e capacidade.

### 4.2 ServerWorldCoordinator (`scripts/network/ServerWorldCoordinator.gd`)
- Núcleo de simulação autoritativa do servidor executando a 20 TPS (`_physics_process`).
- Mantém a lista de entidades vivas (jogadores, inimigos, chefes).
- Consome filas de intenções de input recebidas dos clientes.
- Executa a IA de monstros (Patrulha, Perseguição, Ataque) com Threat Table multi-alvo.
- Empacota e transmite snapshots delta do mundo a cada 50ms para todos os clientes conectados.

### 4.3 LanDiscoveryBroadcaster & LanDiscoveryListener (`scripts/network/`)
- **Broadcaster:** Roda no servidor emitindo anúncios UDP na porta `7778` a cada 1.5s com metadados da sala (nome, jogadores atuais, mapa, versão).
- **Listener:** Roda no cliente na aba "Buscar Servidores LAN", capturando beacons e listando salas disponíveis na rede local.

### 4.4 ServerStorageManager (`scripts/network/ServerStorageManager.gd`)
- Camada de persistência em disco exclusiva do servidor.
- Salva dados em `user://server_saves/players/hunter_<Nome>_<Slot>.json` e `world_state.json`.
- Evita perda de dados e duplicação de itens em caso de queda de conexão.

### 4.5 NetworkManager (`autoload/NetworkManager.gd`)
- Autoload unificado que transiciona entre:
  - `OFFLINE_SINGLEPLAYER`
  - `DEDICATED_SERVER`
  - `CLIENT_PEER`
- Gerencia o protocolo de Handshake com autenticação de versão e senha.
- Coordena o despacho de intenções de input e o recebimento de snapshots.

### 4.6 NetworkPlayer (`scripts/network/NetworkPlayer.gd`)
- Entidade que representa outros jogadores na tela do cliente ("Puppets").
- Interpolação suave de posição amortecida por buffer temporal.
- Sincronização em tempo real de animações, direção, Nameplate, vida e técnica de Nen ativa.

### 4.7 AntiCheatValidator (`scripts/network/AntiCheatValidator.gd`)
- Validador em tempo de execução de física e lógica:
  - Detecção de speedhack e teleporte anômalo.
  - Rate limiting de ataques básicos contra macros.
  - Verificação server-side de pool de aura antes do cast de Hatsu.
  - Clamping matemático do dano de acordo com os limites teóricos de atributos.

---

## 5. PIPELINE DE TICK DO SERVIDOR DEDICADO

A cada 50ms (20 TPS), o `ServerWorldCoordinator` executa o seguinte pipeline ordenado:

```text
1. FLUSH DE ENTRADA
   └── Esvazia a fila de pacotes ENet recebidos dos clientes.

2. APLICAÇÃO DE INTENÇÕES
   └── Valida e aplica intenções de movimento dos jogadores através da física.

3. IA DE INIMIGOS & AGGRO
   └── Calcula distâncias, alvos de maior ameaça e executa ataques dos monstros.

4. RESOLUÇÃO DE COMBATE
   └── Processa colisões de dano, mitigações por Ten/Ken e reduções de HP.

5. EMPACOTAMENTO DE SNAPSHOT
   └── Coleta posições, estados de animação, modos de Nen e HPs de todas as entidades.

6. BROADCAST DE REDE
   └── Envia o snapshot a todos os clientes via canal UNRELIABLE_ORDERED.
```

---

## 6. STATUS DE IMPLEMENTAÇÃO

| Módulo | Status | Descrição |
| :--- | :--- | :--- |
| **Topologia Dual (Single/Dedicated)** | `[IMPLEMENTED]` | Desacoplamento transparente de offline e online |
| **Servidor Dedicado Autônomo** | `[IMPLEMENTED]` | Processo headless `HunterServer` com inicializador .bat |
| **Simulação Autoritativa 20 TPS** | `[IMPLEMENTED]` | `ServerWorldCoordinator` com IA de inimigos e aggro |
| **Descoberta LAN Automática (UDP)** | `[IMPLEMENTED]` | Beacon na porta 7778 e busca na UI |
| **Handshake & Validação de Acesso** | `[IMPLEMENTED]` | Checagem de versão, senha e alocação de peer |
| **Persistência Server-Side** | `[IMPLEMENTED]` | Saves atômicos em `user://server_saves/` |
| **Interpolação de Puppets** | `[IMPLEMENTED]` | Movimento suave a 60 FPS com espelhamento de Nen |
| **Combate & Anti-Cheat Autoritativo** | `[IMPLEMENTED]` | Clamping de dano, taxa de ataque e bloqueio de speedhack |
| **Overlay de Diagnóstico F4** | `[IMPLEMENTED]` | Painel em tempo real de Ping, TPS, Pacotes e Banda |
| **Autonomia Single-Player** | `[IMPLEMENTED]` | 100% autônomo offline com 0ms de latência |
