# COMBAT DESIGN BIBLE
## HUNTER ONLINE — DEFINITIVE GAMEPLAY DIRECTION

---

## 1. OS DOIS PILARES DO COMBATE

O sistema de combate de Hunter Online é estruturado sobre dois pilares fundamentais e independentes:

```text
               SISTEMA DE COMBATE
                       │
       ┌───────────────┴───────────────┐
       │                               │
  ATAQUE BÁSICO                   SISTEMA DE HATSU
(Combate Confiável)              (Skills Ativas 1 a 4)
```

O jogador **NUNCA** deve depender exclusivamente de Hatsu para lutar. O combate físico básico é completo, fluido e letal por si só.

---

## 2. PILAR 1: O ATAQUE BÁSICO (BASIC ATTACK)

### Características Obrigatórias:
- **Input:** Configurado no InputMap (`basic_attack` — Botão Esquerdo do Mouse ou Espaço).
- **Sem Custo de Aura:** O ataque básico não consome aura vital.
- **Cadência / Attack Speed:** O intervalo entre golpes é escalonado pelo atributo `Velocidade` do personagem.
- **Hit Detection Precisa:** Hitbox conectada diretamente à animação do golpe, gerando feedback de impacto e stagger nos alvos.
- **Sistema de Combo (3 Golpes):**
  - Golpe 1: Dano base (1.0x).
  - Golpe 2: Golpe rápido (1.25x).
  - Golpe 3 (Finalizador): Impacto pesado (1.80x), fortalecido pelo domínio passivo de **Ko**.
- **Evolução Contínua:**
  - Força: Aumenta o dano físico base.
  - Ren (Passivo): Multiplica o dano de todos os ataques físicos.
  - Shu (Passivo): Imbui armas empunhadas com aura cortante ou esmagadora.

---

## 3. PILAR 2: SISTEMA DE HATSU (MAGIAS / SKILLS ATIVAS)

Hatsu opera como as magias e habilidades táticas de classes de RPGs clássicos, ocupando os 4 slots dedicados:

```text
[Slot 1] Hatsu Primário (Tecla 1 / hatsu_1)
[Slot 2] Hatsu Secundário (Tecla 2 / hatsu_2)
[Slot 3] Hatsu Especial (Tecla 3 / hatsu_3)
[Slot 4] Hatsu Supremo / Trunfo (Tecla 4 / hatsu_4)
```

### Anatomia de um Hatsu:
1. **Aura Cost:** Quantidade exata de energia consumida na ativação.
2. **Cooldown:** Tempo de recarga antes de nova invocação.
3. **Range & Forma:** Projétil, golpe de contato, área (AoE) ou cúpula.
4. **Damage & Efeito:** Dano, empurrão, atordoamento, sangramento, queima ou desaceleração.
5. **Categoria Natal:** Intensificação, Transformação, Emissão, Materialização, Manipulação ou Especialização.
6. **Juramentos & Votos:** Bônus de potência obtidos por restrições autoimpostas.

---

## 4. REGRA DE OURO: SEPARAÇÃO ENTRE NEN ATIVO E HATSU

> **Zetsu, En e Gyo NÃO ocupam os Slots 1 a 4 de Hatsu.**
> Elas são técnicas de Nen independentes com seus próprios atalhos (`nen_zetsu`, `nen_en`, `nen_gyo`).
> Os Slots 1 a 4 pertencem estritamente às habilidades criadas ou equipadas de Hatsu.

---

## 5. SISTEMA CANÔNICO DE BARRA DE DEFESA & QUEBRA DE GUARDA (GUARD BREAK)

O combate corpo-a-corpo e contra chefes utiliza o sistema reativo de **Barra de Defesa (Defense Gauge)**:
- **Independência de Ativação Manual:** Não há necessidade de o jogador ativar técnicas especiais como Ko para quebrar a postura do inimigo. O sistema é 100% orgânico e integrado ao fluxo de golpes físicos normais e pesados.
- **Mecânica de Drenagem da Guarda:**
  - **Golpe Forte (Heavy Attack):** Drena massivamente **50% da barra de defesa** em um único golpe carregado. Dois golpes fortes consecutivos resultam em quebra imediata de guarda.
  - **Sequência de Golpes Fracos (Combo Cadenciado):** Golpes rápidos drenam progressivamente a defesa ($15\% \rightarrow 20\% \rightarrow 30\%$). Uma sequência agressiva de 4 a 5 acertos esvazia a barra por completo.
- **Regeneração Fora de Combate:** Se o alvo permanecer sem receber ataques por mais de $2.5\,\text{s}$, sua defesa se regenera gradualmente a uma taxa de $25.0\,\text{pts/s}$, recompensando pressão contínua.
- **Estado de Defesa Quebrada (Vulnerabilidade):**
  - Ao atingir 0 de guarda, o inimigo sofre quebra de postura imediata com estilhaço de aura e balão `💥 DEFESA QUEBRADA!`.
  - **Janela de Vulnerabilidade:** Dura $3.5\,\text{s}$ (ou $4.0\,\text{s}$ para chefes).
  - **Multiplicador de Dano (+80%):** Todo golpe desferido durante a janela de vulnerabilidade recebe amplificação de dano de $1.80\times$.
  - Após o término do timer, a guarda é totalmente restaurada e o alvo retoma sua compostura defensiva.

