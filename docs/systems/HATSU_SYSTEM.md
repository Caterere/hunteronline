# HATSU SYSTEM ARCHITECTURE
## HUNTER ONLINE — MODULAR HATSU CREATION, HEXAGON & VOWS

### 1. Visão Geral
O Hatsu é a expressão máxima e individual da personalidade de um Hunter. O sistema opera baseado no hexágono canônico de afinidades:
* **Intensificação (Enhancement):** 100% de eficiência física.
* **Transformação (Transmutation):** Muda propriedades da aura (ex: eletricidade).
* **Emissão (Emission):** Projeta aura à distância.
* **Conjuração (Conjuration):** Materializa objetos físicos independentes.
* **Manipulação (Manipulation):** Controla matéria orgânica ou inorgânica.
* **Especialização (Specialization):** Habilidades únicas e anômalas (ex: roubo de habilidades).

### 2. Validação Rigorosa de Créditos de Poder (Power Budget)
* Cada Hatsu criado possui um orçamento estrito de pontos (Power Credits).
* Parâmetros como Dano, Raio de Área, Duração, Efeitos de Status e Penetração de Defesa consom créditos.
* Juramentos e Restrições (*Vows & Limitations*) severos (ex: ativação restrita a alvos específicos, sacrifício de HP, Zetsu forçado após uso) concedem créditos adicionais, multiplicando o poder da técnica de acordo com o risco assumido.

### 3. Habilidades Roubadas (Skill Hunter / Steal Chain)
* Habilidades roubadas ou copiadas através de Hatsu Especialista devem validar rigorosamente:
  1. Condições estritas de roubo atendidas (`steal_conditions`).
  2. Custo de aura do proprietário temporário.
  3. Descarte ou tempo de expiração após execução.

### 3.1 Assinaturas Ultimate (feel MMO → Nen)
* `HatsuSignatureKit` padroniza cast telegraph + callout + impacto para:
  * **Skill Hunter** (Chrollo) — biblioteca / roubo
  * **Devour** (Meruem) — absorção com diminishing returns
  * **Terpsichora** (Pitou) — buff corporal temporário
  * **Doctor Blythe** (Pitou) — cura médico-nível
* Boss AI (`EnemyAI`) usa as mesmas assinaturas com mecânica real (não só balão).

### 3.2 Feel canalizado por tipo Nen
Hold-to-charge nos slots 1–4; a barra escala um parâmetro diferente por categoria:

| Tipo | Barra | Parâmetro |
|------|-------|-----------|
| Intensificação | `PWR` | Poder / dano do golpe |
| Emissão | `ALC` | Mira (mouse) + alcance |
| Transformação | `DUR` | Duração do buff/efeito |
| Conjuração | `MAT` | Tamanho / permanência |
| Manipulação | `CTRL` | Área / duração do controle |
| Especialização | `RISK` | Poder ↔ custo de aura |

Implementação: `HatsuData.FeelMode` + `HatsuSystem._executar_feel_canalizado` + HUD com rótulo por tipo.

### 3.3 Evolução do mesmo Hatsu (anti-grind)
Maestria em **6 ranks** com meta curta e legível no inspetor `[H]`:

| Rank | Mastery | Nome | Sensação |
|------|---------|------|----------|
| 1 | M0 | Despertar | rascunho (~30% poder) |
| 2 | M20 | Prática | conjuração começa a fluir |
| 3 | M40 | Afiação | feel do tipo responde |
| 4 | M60 | Domínio | **meta de combate sério** |
| 5 | M80 | Virtuose | polish |
| 6 | M100 | ★ Mestre | ápice opcional / instantâneo |

- Barra do inspetor = progresso até o **próximo marco**, não 0–100 opaco
- Toast grande só em **rank up**; entre marcos o float mostra “faltam N”
- Curva de XP mais rápida no início; 81–100 é prestígio, não obrigação

