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
