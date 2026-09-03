# HATSU SYSTEM BIBLE
## HUNTER ONLINE — DEFINITIVE GAMEPLAY DIRECTION

---

## 1. NATUREZA DO HATSU: MAGIAS / SKILLS ATIVAS DE RPG

No Hunter Online, o Hatsu é a expressão máxima do poder sobrenatural do Caçador, operando conceitualmente como as **magias e habilidades ativas de classes em RPGs clássicos**:

```text
Ataque Básico (Cooldown por Velocidade)
      +
Hatsu 1 (Skill Ativa — Tecla 1)
Hatsu 2 (Skill Ativa — Tecla 2)
Hatsu 3 (Skill Ativa — Tecla 3)
Hatsu 4 (Skill Ativa — Tecla 4 / Ultimate)
```

Cada habilidade equipada possui:
- **Custo de Aura:** Quantidade de energia vital consumida no momento do lançamento.
- **Cooldown:** Tempo de recarga necessário antes de nova conjuração.
- **Alcance / Área:** Projétil, golpe corpo-a-corpo, aura de área (AoE) ou buff temporário.
- **Dano & Efeito:** Dano elemental/de choque, atordoamento, empurrão, sangramento, veneno ou criação de objetos/clones.

---

## 2. AS 6 CATEGORIAS NATALÍCIAS E COMPATIBILIDADE

O hexágono canônico de afinidades define a eficiência e facilidade de conjuração de cada tipo de Hatsu:

1. **Intensificação (Enhancement):** Maior dano bruto, regeneração e robustez física (ex: *Jajanken: Rock*).
2. **Transformação (Transmutation):** Modificação das propriedades da aura em substâncias físicas (ex: *Kanmuru/Godspeed*, *Bungee Gum*).
3. **Emissão (Emission):** Projeção de aura à distância descolada do corpo (ex: *Emitted Aura Blast*, *Jajanken: Paper*).
4. **Materialização (Conjuration):** Criação de objetos reais com propriedades especiais e juramentos (ex: *Correntes de Kurapika*).
5. **Manipulação (Manipulation):** Controle de objetos, armas ou seres vivos (ex: *Shalnark Black Voice*, *Agulhas de Illumi*).
6. **Especialização (Specialization):** Habilidades únicas que não se encaixam em nenhuma das categorias padrão (ex: *Skill Hunter de Chrollo*).

### Tabela de Eficiência de Afinidade:
| Categoria Natal | Categoria Alvo | Eficiência de Dano | Custo de Aura Adicional |
| :--- | :--- | :--- | :--- |
| **Natal** | Mesma Categoria | **100%** | +0% |
| **Adjacente 1** | Categoria Vizinha | **80%** | +20% |
| **Adjacente 2** | Categoria a 2 passos | **60%** | +40% |
| **Oposta** | Categoria Oposta no Hexágono | **40%** | +70% |
| **Especialização** | Por não-especialistas | **0%** (Bloqueado) | — |

---

## 3. VOWS & LIMITATIONS (CONDIÇÕES E JURAMENTOS)

Hatsus podem incorporar juramentos que multiplicam dramaticamente sua potência:
- **Exclusividade de Alvo:** Aumenta o poder contra uma facção específica (ex: Trupe Fantasma), mas pune severamente se usada contra outros alvos.
- **Requisito de Postura:** Habilidade só pode ser disparada após esquiva perfeita ou em HP crítico.
- **Custo Sacrificial:** Dano auto-infligido ou consumo de vida em troca de dano avassalador.

---

## 4. CICLO DE EXECUÇÃO EM COMBATE

```text
Jogador pressiona tecla [1..4]
      │
      ▼
HatsuSystem valida:
├── Slot possui Hatsu equipado?
├── Jogador possui Aura suficiente?
├── Habilidade não está em Cooldown?
└── Condições de juramento atendidas?
      │
      ├── [NÃO] ──► Emite som de falha / Toast de aviso
      │
      └── [SIM] ──► Consome Aura ──► Executa Efeito / Projétil / Animação ──► Inicia Cooldown
```
