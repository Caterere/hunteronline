# MULTIPLAYER GAMEPLAY DESIGN — HUNTER ONLINE
## COOPERATIVE HUNTING, PARTY DYNAMICS, WORLD BOSSES & DUELS

---

## 1. A EXPERIÊNCIA COOPERATIVA DE CAÇADA

O multiplayer de Hunter Online foi construído para potencializar a fantasia do universo de Togashi:
> *"Caçadores raramente viajam sós em territórios hostis. A sinergia entre diferentes naturezas de Nen — um Intensificador na vanguarda, um Emissor provendo cobertura e um Conjurador ou Manipulador controlando o campo — é a essência do combate tático."*

---

## 2. SISTEMA DE PARTY (GRUPOS DE CAÇADA)

- **Composição:** Até 4 jogadores por grupo no mundo aberto e masmorras normais (expansível até 8 para Raids).
- **Liderança:** O líder possui permissão para convidar novos membros, expulsar jogadores inativos, marcar pontos de interesse e despachar o grupo para instâncias de masmorra.
- **Interface da Party (PartyHUD):**
  - Posicionada abaixo do card de atributos do jogador (canto superior esquerdo).
  - Exibe nome do membro, nível, ícone de afinidade de Nen, mini-barra de HP e mini-barra de Aura.
  - Ícone de coroa dourada indicando o líder da party.
  - Indicador de status (Vivo / Desmaiado / Em Combate / Distante).

---

## 3. AGGRO & MECÂNICA DE WORLD BOSS CO-OP

### 3.1 Tabela de Ameaça Dinâmica (Threat Table)
- O motor de IA (`EnemyAI.gd`) rastreia a pontuação de ameaça de cada membro da party:
  - Dano Físico e Hatsu infligido gera 1 ponto de ameaça por unidade de dano.
  - Habilidades com a tag de controle ou provocação (ex: *Impacto de Ko*) geram ameaça amplificada (+150%).
  - Habilidades de cura ou restauração de aliados geram ameaça moderada.
- O chefe foca seus ataques primários no jogador com maior ameaça, permitindo que tanques mantenham o foco enquanto atacantes de longa distância causam dano nas costas.

### 3.2 Fases Sincronizadas & Telegrafia Coletiva
- Quando o World Boss atinge os marcos de 50% e 25% de HP, a transição de fase dispara para todos os jogadores presentes:
  - Onda de choque de Ren afasta todos os alvos próximos.
  - Áreas vermelhas telegrafadas no chão (*Telegraph Decals*) alertam para tempestades AoE.
  - Jogadores caídos podem ser reanimados por colegas de grupo através de canalização por 3 segundos sem sofrer dano.

---

## 4. LOOT SEGURO & SISTEMA DE RECOMPENSAS

- **Loot Instanciado:** Cada jogador recebe sua própria tabela de recompensas decidida pelo servidor, eliminando o roubo de itens no chão (*ninja looting*).
- **Recompensas de Contribuição:** Para World Bosses e Chefes de Masmorra, caçadores que causarem ao menos 1% do dano total qualificam-se para o baú de tesouro do chefe.
- **Prevenção de Duplicação:** Itens raros possuem UID atômico gerado pelo servidor e são creditados diretamente no inventário pessoal do jogador.

---

## 5. SISTEMA DE DUELOS (PVP CONSENSUAL 1V1)

- **Regra de Ouro:** O PvP nunca desbalanceia a progressão PvE e é estritamente consensual.
- **Fluxo do Duelo:**
  1. Um jogador seleciona outro caçador e clica em "Desafiar para Duelo" ou digita `/duelo [nome]`.
  2. O alvo recebe uma notificação na tela com opções `[Aceitar]` e `[Recusar]`.
  3. Ao aceitar, cria-se um círculo de arena visual de 250px de raio ao redor dos dois combatentes.
  4. Contagem regressiva dramática: `3... 2... 1... LUTE!`.
  5. O combate utiliza todas as técnicas de Nen e Hatsu, mas termina imediatamente quando o HP de um dos duelistas atinge 1.
  6. Não há perda de itens, perda de XP ou penalidade de morte. O perdedor cai de joelhos por 2 segundos e recupera a vida total.

---

## 6. STATUS DE IMPLEMENTAÇÃO

| Funcionalidade de Gameplay | Status | Descrição |
| :--- | :--- | :--- |
| **Party de 4 Jogadores** | `[IMPLEMENTED]` | Criação, convite, expulsão, liderança e interface |
| **Sincronização de Vida da Party**| `[IMPLEMENTED]` | Barras de HP/Aura replicadas em tempo real |
| **Aggro Multi-Alvo de Chefes** | `[IMPLEMENTED]` | Threat table dinâmica orientada a dano e taunt |
| **Drops e Loot Instanciados** | `[IMPLEMENTED]` | Recompensas individuais sem duplicação ou roubo |
| **Duelos Consensuais 1v1** | `[IMPLEMENTED]` | Arena circular, fim em 1 HP e restauração segura |
| **Revive de Aliados em Combate** | `[IMPLEMENTED]` | Canalização de 3s (servidor) + tecla E no cliente; dano interrompe — **PREREQ-2** |
| **Raids Cooperativas de 8 Hunters**| `[IN PROGRESS]` | Cap 8 via `PartyManager` modo raid + `RaidInstance`/`RaidCatalog` (vertical Ruínas de Zaban); mapa/encontro boss ainda a ligar — **S3** |
| **Arena Ranqueada na Torre Celestial**| `[IMPLEMENTED]` | Elo K=32, temporadas 28 dias, soft reset e títulos cosméticos — **S2** |
| **Leilão de Yorknew (escrow)** | `[IMPLEMENTED]` | Listagens com taxa Jenny, seeds NPC e payouts — **S1** |
| **Duelo de Cartas (Greed Island)** | `[IMPLEMENTED]` | Catálogo 24 cartas + `CardDuelSystem` jogável — **S4** |
| **Guildas + Nen Contracts** | `[IMPLEMENTED]` | Cap 20, banco Jenny, juramentos Nen (máx. 3) — **A6** |

> Pré-requisitos e backlog priorizado: [`docs/roadmap/MMO_FEATURES_BACKLOG.md`](../roadmap/MMO_FEATURES_BACKLOG.md) (PREREQ-1 sync binário · PREREQ-2 revive aliado). A8 Gourmet fica para depois.
