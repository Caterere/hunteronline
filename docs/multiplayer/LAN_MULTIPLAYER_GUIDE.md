# GUIA OFICIAL DE MULTIPLAYER LAN & RADMIN VPN
## Hunter MMORPG — Como Jogar Cooperativo em Rede Local ou VPN Virtual

---

## 1. INTRODUÇÃO

Bem-vindo ao guia oficial de conexão multiplayer de **Hunter MMORPG**!

Diferente de muitos jogos onde um jogador precisa ser o "host" e sofre com sobrecarga de processamento ou lentidão se o computador dele travar, o Hunter MMORPG utiliza uma **arquitetura de servidor dedicado (`HunterServer`)**.

O servidor roda de forma totalmente independente dos jogadores. Isso significa que:
- O mundo continua vivo e sincronizado mesmo se um jogador fechar o jogo.
- Todos os caçadores conectam em igualdade de condições.
- O anfitrião pode jogar no mesmo computador em que o servidor está rodando, ou colocar o servidor num PC secundário.

---

## 2. REQUISITOS PARA JOGAR

1. **Godot Engine 4.6** (ou o executável compilado do Hunter MMORPG).
2. **Conexão de Rede**:
   - Para quem está na **mesma casa / mesmo roteador Wi-Fi**: Apenas a rede local (LAN).
   - Para quem está jogando com **amigos pela internet**: **Radmin VPN** (recomendado, gratuito e sem cadastro complexo).
3. **Portas de Rede Utilizadas**:
   - `7777 UDP`: Porta principal de tráfego de jogo (ENet).
   - `7778 UDP`: Porta de anúncio de descoberta automática de LAN (Broadcast).

---

## 3. PASSO A PASSO COM RADMIN VPN (JOGANDO PELA INTERNET)

Se você e seus amigos não dividem o mesmo Wi-Fi, o método mais rápido e estável é o **Radmin VPN**.

### Passo 1: Instalar o Radmin VPN
1. Acesse o site oficial do [Radmin VPN](https://www.radmin-vpn.com/pt/) e faça o download gratuito.
2. Instale o software em seu computador e nos computadores de todos os amigos que vão jogar.

### Passo 2: Criar a Sala (Apenas o Host / Quem vai ligar o servidor)
1. Abra o Radmin VPN e clique no botão de **Ligar** (Power).
2. Clique em **Rede** → **Criar Nova Rede**.
3. Escolha um nome para a rede (ex: `Hunter-Bando-Gon`) e defina uma senha.
4. Clique em **Criar**.

### Passo 3: Amigos Entram na Sala
1. Seus amigos abrem o Radmin VPN e clicam no botão de **Ligar**.
2. Clicam em **Rede** → **Entrar em Rede Existente**.
3. Digitam o nome da rede e a senha que o Host criou.
4. Agora todos os participantes verão uma lista com os nomes e os **endereços IP virtuais (iniciados com 26.x.x.x)**.

---

## 4. INICIANDO O SERVIDOR DEDICADO (`HunterServer`)

Quem for o anfitrião da partida precisa apenas iniciar o servidor dedicado:

### Método 1: Pelo Inicializador Rápido — Recomendado

**Windows** (`iniciar_servidor_lan.bat`):
```cmd
iniciar_servidor_lan.bat
```
Define `GODOT_BIN` se o Godot não estiver no PATH.

**Linux / macOS** (`iniciar_servidor_lan.sh`):
```bash
chmod +x iniciar_servidor_lan.sh
./iniciar_servidor_lan.sh
# opcional:
GODOT_BIN=/caminho/godot ./iniciar_servidor_lan.sh -- --port 7777 --name "Hunter LAN"
```

### Método 2: Pelo Próprio Menu do Jogo
1. Abra o cliente do jogo.
2. No menu principal, clique no botão **MULTIPLAYER / LAN**.
3. Na seção de Servidor Local, clique em **INICIAR SERVIDOR LAN DEDICADO**.
4. O servidor será inicializado imediatamente em segundo plano.

> Nota: o botão do menu roda o servidor **no mesmo processo** (este PC não joga). Para LAN real, use o script dedicado em uma máquina e os clientes nas outras.

---

## 5. COMO OS JOGADORES SE CONECTAM

### Opção A: Conexão Direta por IP (Recomendado para Radmin VPN)
1. No Radmin VPN, o amigo clica com o botão direito sobre o nome do **Host** e seleciona **Copiar endereço IP** (será um IP como `26.142.88.19`).
2. Abra o Hunter MMORPG e escolha seu Caçador na tela de Seleção de Personagem.
3. Clique em **LAN / VPN >**.
4. No campo **IP do Servidor / Host**, cole o IP copiado (ex: `26.142.88.19`).
5. A porta padrão já vem preenchida com `7777`.
6. Se o servidor tiver senha, digite-a no campo Senha.
7. Clique em **CONECTAR VIA IP**.
8. O jogo realizará o handshake de validação e você nascerá no mundo junto aos seus amigos!

> **Nota para o Host:** Se você for jogar no mesmo computador onde iniciou o servidor, você pode se conectar digitando o IP `127.0.0.1` (localhost) ou o seu próprio IP do Radmin VPN.

### Opção B: Descoberta Automática de Servidores (Para quem está no mesmo Wi-Fi)
1. Abra o jogo e clique em **MULTIPLAYER / LAN**.
2. Clique na aba **BUSCAR SERVIDORES LAN**.
3. O jogo escutará a rede local através de UDP Broadcast na porta `7778`.
4. Assim que o servidor for detectado, ele aparecerá na lista com seu Nome, Quantidade de Caçadores online e Ping estimado.
5. Clique em **ENTRAR NO SERVIDOR**.

---

## 6. RECURSOS DISPONÍVEIS NO MULTIPLAYER CO-OP

Quando conectados ao servidor dedicado, todos os sistemas do Hunter MMORPG operam de forma cooperativa sincronizada:

- **Mundo Persistente Compartilhado**: Você e seus amigos vêem uns aos outros andando, correndo e ativando técnicas de Nen.
- **Sincronização Visual de Nen**: Se um aliado ativar **Ren**, uma aura dourada flamejante cerca seu corpo; se ativar **Gyo**, os olhos brilham; se usar **Zetsu**, a aura é completamente suprimida.
- **Grupos de Caçada (Party)**:
  - Pressione `P` para abrir a interface de Party.
  - Convide amigos pelo nome.
  - Veja a barra de vida (HP) e localização de cada membro da equipe em tempo real.
- **World Bosses e Ameaça (Aggro)**:
  - Enfrente chefes de mundo cooperativos.
  - O chefe possui inteligência que foca o jogador com maior geração de ameaça (Threat) ou dano contínuo.
  - O XP e o saque são distribuídos entre todos os participantes.
- **Dungeons Cooperativas com Portões de Equipe**:
  - Salas secretas exigem que todos os membros da equipe fiquem sobre as placas de pressão para destrancar os portões.
  - Sistema anti-duplicação: Cada jogador recebe seu próprio drop individualizado pelo servidor.
- **Duelos Amigáveis (PvP 1v1 Consensual)**:
  - Desafie outro caçador pelo menu social.
  - O duelo começa com contagem regressiva de 3 segundos.
  - O combate é 100% seguro: a vida para exatamente em 1 HP, impedindo mortes acidentais ou perda de itens.
- **Chat Social**:
  - Pressione `Enter` para falar no canal global ou de equipe.
- **Painel de Diagnóstico de Rede**:
  - Pressione `F4` a qualquer momento para abrir o **Network Debug Overlay**, que mostra seu Ping, perda de pacotes, TPS do servidor e largura de banda consumida.

---

## 7. RESOLUÇÃO DE PROBLEMAS (TROUBLESHOOTING)

### "Erro: Não foi possível conectar ao servidor"
- **Verifique o Radmin VPN:** Confirme se a bolinha ao lado do nome do Host está **verde**. Se estiver azul ou cinza, há bloqueio de conexão P2P.
- **Firewall do Windows:** 
  1. No computador do Host, abra o Iniciar e digite `Firewall do Windows`.
  2. Clique em `Permitir um aplicativo pelo Firewall`.
  3. Localize o `Godot` ou adicione uma regra de entrada para as portas `7777 UDP` e `7778 UDP`.
- **IP Incorreto:** Certifique-se de que digitou o IP do Radmin VPN do Host (`26.x.x.x`) e não o IP interno da máquina dele (`192.168.x.x`).

### "Erro: Versão do cliente incompatível"
- Todos os jogadores e o servidor devem estar na mesma versão do jogo (atualmente `1.2.0-dedicated`). Atualize os arquivos se necessário.

### "Lag ou teleporte dos personagens"
- O sistema possui interpolação amortecida de 50ms a 100ms para garantir suavidade.
- Se o ping estiver muito alto no painel `F4` (> 200ms), feche downloads, torrents ou vídeos em streaming na máquina que está hospedando o servidor.

### "Meu jogo solo offline ainda funciona?"
- **Sim, com 100% de autonomia!**
- O Hunter MMORPG preserva o modo offline totalmente intacto. Se você clicar em **SOLO >** na seleção de personagens, o jogo não abre conexões de rede, não consome internet e roda localmente com latência zero.
