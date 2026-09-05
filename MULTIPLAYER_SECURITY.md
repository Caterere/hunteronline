# MULTIPLAYER SECURITY & ANTI-CHEAT SPECIFICATION
## HUNTER ONLINE — DEDICATED SERVER ZERO-TRUST THREAT MODEL & SANITY RULES

---

## 1. MODELO DE AMEAÇAS & FILOSOFIA ZERO-TRUST

Com a transição para a arquitetura de **Servidor Dedicado**, o Hunter MMORPG adota a filosofia de **Confiança Zero no Cliente (Zero-Trust Client)**:
> *"O cliente nunca informa ao servidor o que aconteceu; o cliente apenas informa o que ele gostaria de fazer (intenção). O servidor decide o que de fato acontece."*

### Vetores de Ameaça Mitigados:
1. **Speedhack & Teleporte:** Envio de pacotes com posições forjadas ou alteração do relógio do cliente para cobrir distâncias impossíveis.
2. **Attack Spam & Macros:** Envio de dezenas de solicitações de ataque por segundo ignorando animações e pausas canônicas de combate.
3. **Bypass de Cooldown & Hatsu Infinito:** Invocação de habilidades poderosas sem ter aura disponível ou durante o cooldown.
4. **Damage Injection (One-Shot):** Alteração de pacotes de ataque para enviar 999.999 de dano e abater chefes instantaneamente.
5. **Item / Currency Duplication:** Manipulação de arquivos locais de save ou duplicação de requisições de drop de monstros.
6. **Invulnerabilidade Forjada:** Ignorar mensagens de dano recebido enviadas pelo mundo.

---

## 2. REGRAS DE VALIDAÇÃO SERVER-SIDE (SANITY CHECKS)

### 2.1 Validação Cinemática de Deslocamento (Anti-Speedhack)
No servidor dedicado, o `AntiCheatValidator` monitora o delta temporal e espacial de cada jogador:
$$\Delta \text{dist} = \|\text{Pos}_{\text{nova}} - \text{Pos}_{\text{anterior}}\|$$
$$\text{MaxDistPermitida} = (\text{VelocidadeBase} \times \text{MultiplicadorSprint} \times \text{BonusNen}) \times \Delta t \times 1.30$$

- O fator `1.30` (30% de tolerância) absorve pequenas variações de jitter de rede e perda de pacotes momentânea.
- **Detecção:** Se $\Delta \text{dist} > \text{MaxDistPermitida}$, a posição é classificada como anômala.
- **Ação Autoritativa:** O servidor descarta o deslocamento, mantém o caçador na última posição legítima e registra um log com carimbo de data/hora (`Time.get_ticks_msec()`).

### 2.2 Validação de Cadência de Ataque (Rate Limiting)
- O servidor rastreia o timestamp do último ataque autorizado para cada peer (`_ultimos_ataques[peer_id]`).
- A janela mínima aceita é calculada como:
  $$\Delta t_{\text{min}} = \text{CooldownNominal} \times 0.70$$
- Se um novo ataque chegar antes dessa janela (spam de macro ou script externo), a requisição é **rejeitada sumariamente**.

### 2.3 Autoridade de Aura & Restrição de Hatsu
- O cliente **nunca** diz quanto de dano seu Hatsu causa nem quanto de aura foi consumida.
- O cliente envia apenas o identificador da habilidade e o vetor de mira (`slot_index`, `direction`).
- O servidor consulta a base de dados canônica `HatsuData`:
  1. Verifica se $\text{AuraAtual} \ge \text{CustoAura}$.
  2. Deduz a aura diretamente no `ServerWorldCoordinator`.
  3. Spawna a hitbox autoritativa que atinge os alvos no espaço do servidor.
- Se o jogador não tiver aura suficiente, o cast é bloqueado e o evento é registrado no log de segurança.

### 2.4 Clamping Matemático de Dano (Anti-Damage Injection)
- Para impedir que clientes adulterem o dano de armas ou ataques através de modificadores de memória (ex: Cheat Engine):
  $$\text{TetoTeorico} = \max(50, \text{ForcaBase} \times 6.0)$$
- Se um valor de dano for reportado acima desse limite físico, o método `validar_dano_maximo()` intervém:
  - Restringe o dano exatamente ao teto teórico.
  - Registra um alerta crítico de segurança: `[ANTI-CHEAT] Peer X: Dano excessivo interceptado: Y (Teto: Z)`.

### 2.5 Persistência Isolada & Prevenção de Duplicação de Loot
- Os drops de inimigos e chefes de mundo são calculados e sorteados **exclusivamente no servidor**.
- Cada caçador conectado recebe uma instância única e não-compartilhada de loot.
- Os dados são salvos diretamente pelo `ServerStorageManager` em `user://server_saves/players/`.
- Nenhum cliente tem permissão de enviar um inventário arbitrário para ser aceito pelo servidor na conexão; o servidor apenas carrega o estado previamente arquivado em seu próprio disco.

---

## 3. AUDITORIA EM TEMPO REAL (AUDIT TRAIL)

O `AntiCheatValidator` mantém um buffer circular das últimas 50 ocorrências de segurança:

```text
[ANTI-CHEAT] Peer 3: Deslocamento anômalo: 800.0 px em 0.050 s (Max: 20.8 px) (Hora: 1777)
[ANTI-CHEAT] Peer 2: Ataque rápido suspeito: intervalo de 0 ms (Mínimo: 280 ms) (Hora: 1805)
[ANTI-CHEAT] Peer 1: Cast de Hatsu sem aura: disponível 10.0, custo 35.0 (Hora: 1782)
[ANTI-CHEAT] Peer 1: Dano excessivo interceptado: 999999 (Teto matemático: 300) (Hora: 1781)
```

Esses dados alimentam a telemetria do jogo e permitem que administradores do servidor identifiquem tentativas maliciosas em tempo real.

---

## 4. STATUS DE IMPLEMENTAÇÃO DE SEGURANÇA

| Mecanismo de Segurança | Status | Descrição |
| :--- | :--- | :--- |
| **Sanity Check Cinemático** | `[IMPLEMENTED]` | Bloqueio imediato de teleporte e velocidade excessiva |
| **Cadência de Ataque Server-Side** | `[IMPLEMENTED]` | Rejeição de macros e scripts de clique rápido |
| **Autoridade de Hatsu & Aura** | `[IMPLEMENTED]` | Validação de custo no servidor antes de instanciar hitbox |
| **Clamping Matemático de Dano** | `[IMPLEMENTED]` | Teto físico intransponível baseado nos atributos reais |
| **Loot Instanciado por Jogador** | `[IMPLEMENTED]` | Zero concorrência e impossibilidade de duplicação |
| **Saves Persistentes no Servidor** | `[IMPLEMENTED]` | Disco do servidor é a autoridade de armazenamento |
| **Handshake com Senha e Versão** | `[IMPLEMENTED]` | Rejeição de conexões incompatíveis ou não autorizadas |
