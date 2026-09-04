# ============================================================
# HUNTER ONLINE — HATSU CREATOR BIBLE (FASE F)
# ============================================================
# Criação de Habilidades, Afinidades, Juramentos e Slots de Hatsu
# Godot 4.4 / GDScript Estritamente Tipado
# ============================================================

## 1. Visão Geral e Filosofia do Hatsu
O Hatsu é a manifestação pessoal e individual da mente, desejos e espírito do usuário de Nen. Ao contrário de feitiços padronizados de RPGs genéricos, cada habilidade de Hatsu em *Hunter x Hunter* obedece a regras rígidas de afinidade no Hexágono de Nen, balanceamento de custos e o poder avassalador de **Juramentos e Condições (Vows & Limitations)**.

Esta Bible documenta a arquitetura do **Hatsu Creator**, o pipeline unificado de execução entre Jogador e Inimigos, e o modelo de desbloqueio canônico dos 4 Slots de Hatsu.

---

## 2. Taxonomia de Status de Implementação
- **IMPLEMENTED**: Totalmente funcional, integrado à engine de combate e validado na suíte de testes.
- **PARTIAL**: Mecânica ativa que receberá expansões de shaders visuais e polimento de UI.
- **PLANNED**: Funcionalidades de contrato e trocas planejadas para expansões futuras.
- **DEFERRED**: Ideias rejeitadas por quebrar o equilíbrio competitivo ou o cânone de Togashi.
- **LEGACY**: Habilidades engessadas em armas legadas substituídas pelo sistema de Hatsu.

---

## 3. Matriz de Componentes do Hatsu Creator

| Componente | Status | Arquivo / Classe | Descrição |
|---|---|---|---|
| **HatsuData (Resource Base)** | `IMPLEMENTED` | `scripts/resources/HatsuData.gd` | Estrutura data-driven pura contendo afinidades, custos, dano e efeitos. |
| **Hexágono de Afinidades (6 Tipos)** | `IMPLEMENTED` | `AfinidadeNen` Enum | Reforço, Emissão, Transmutação, Manipulação, Materialização, Especialização. |
| **4 Slots Canônicos de Hatsu** | `IMPLEMENTED` | `HatsuProgressionManager.gd` | Desbloqueio atrelado a Greed Island e Níveis 600, 800 e 1000. |
| **Arquivo de Técnicas (Archive 12 Slots)** | `IMPLEMENTED` | `HatsuProgressionManager.gd` | Biblioteca de criação do Caçador para alternar técnicas preparadas. |
| **Juramentos e Condições (Vows)** | `IMPLEMENTED` | `HatsuData.condicoes` | Multiplicadores exponenciais de dano e área balanceados por restrições severas. |
| **Execução Unificada (Player / Inimigos)** | `IMPLEMENTED` | `CombatEngine.gd` | Inimigos e jogadores processam habilidades exatamente pela mesma engine. |
| **Shader & Efeitos Visuais Personalizados**| `PARTIAL` | `ui/hatsu/HatsuCreatorUI.gd` | Cores e partículas ativas; editor de curva de ruído em polimento estético. |
| **Contratos de Nen Entre Caçadores** | `PLANNED` | `NenContractManager` | Vínculos de juramento cooperativos entre membros de guilda. |
| **Slots Ilimitados de Criação Concorrente** | `DEFERRED` | N/A | Descartado; limite de 4 slots ativos preserva o foco tático e o equilíbrio do jogo. |
| **Feitiços Mágicos Genéricos em Armas** | `LEGACY` | Antigo `WeaponSkillData` | Substituído integralmente pelo modelo canônico de Hatsu. |

---

## 4. O Hexágono de Afinidades e Eficiência
A afinidade primária do Caçador dita a eficiência de aprendizado de técnicas de outras categorias conforme a distância no hexágono canônico:
- **Afinidade Primária**: 100% de eficiência.
- **Afinidades Adjacentes**: 80% de eficiência.
- **Afinidades a Dois Passos**: 60% de eficiência.
- **Afinidade Oposta**: 40% de eficiência.
- **Especialização**: 0% de acesso (exceto para usuários cuja categoria nativa seja Especialização ou em condições extremas de transição).

---

## 5. Juramentos e Limitações (Vows & Limitations)
A multiplicação do poder de um Hatsu cresce exponencialmente com o risco da restrição assumida:
- **Condição Simples** (ex: *Só pode ser usado com o alvo a menos de 2 metros*): +15% a +25% de poder.
- **Condição Tática** (ex: *Exige explicar o funcionamento da habilidade ao oponente*): +35% a +50% de poder.
- **Condição Severa** (ex: *Alvo deve ser um membro da Trupe Fantasma*): +100% a +200% de poder.
- **Punição por Quebra de Voto**: Morte instantânea do usuário, perda permanente da habilidade ou selamento dos nós de Nen.
