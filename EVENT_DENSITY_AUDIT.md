# HUNTER ONLINE — EVENT DENSITY AUDIT (AUDITORIA DO CONTENT DIRECTOR)

## 1. Visão Geral do Diretor de Conteúdo
O `ContentDirector` avalia candidatos a eventos dinâmicos baseando-se em:
- **Grau de Risco da Zona (0 = SAFE até 4 = DANGER)**
- **Domínio de Nen do Jogador (Nen Lv 0..4)**
- **Ciclo Solar (Dia vs Noite)**
- **Cooldown Temporal & Anti-Spam Espacial**

---

## 2. Matriz de Avaliação por Região (Accepted vs Rejected)

### 2.1 Vila de Padokia (SAFE - Risco 0)
* **Status**: 1 Evento Aceito | 7 Rejeitados
* **Aceitos**: `Feira Especial de Mercadores de Yorknew` (Chance 40%)
* **Rejeitados e Causa**:
  * `Emboscada de Salteadores`: *Zona incompatível (Requer risco 1..2, atual: 0)*
  * `Matilha de Lobos`: *Zona incompatível (Requer risco 2..3, atual: 0)*
  * `Duelo Tático: Andarilho de Nen`: *Zona incompatível (Requer risco 2..4, atual: 0)*
  * `Fera Quimera Noturna`: *Zona incompatível (Requer risco 2..4, atual: 0)*
  * `Guardião Ancestral`: *Zona incompatível (Requer risco 3..4, atual: 0)*
  * `Erupção de Miasma`: *Zona incompatível (Requer risco 4..4, atual: 0)*
  * `Caravana Médica`: *Zona incompatível (Requer risco 1..4, atual: 0)*
* **Diagnóstico**: O filtro de Zona Segura é 100% eficaz em proteger os NPCs e a vila de ataques indevidos.

### 2.2 Estrada Real (LOW RISK - Risco 1)
* **Status**: 2 Eventos Aceitos | 6 Rejeitados
* **Aceitos**: `Emboscada de Salteadores da Estrada`, `Caravana Médica Itinerante`
* **Rejeitados**: Feras de Nen e Bosses rejeitados por exigirem zonas de perigo superior.
* **Diagnóstico**: Perfeito para o início da jornada do jogador novato.

### 2.3 Floresta dos Vestígios (MEDIUM RISK - Risco 2)
* **Status**: 4 Eventos Aceitos | 4 Rejeitados
* **Aceitos**: `Emboscada de Salteadores`, `Matilha de Lobos`, `Duelo Tático de Nen`, `Caravana Médica`
* **Rejeitados**:
  * `Fera Quimera Noturna`: *Rejeitado durante o dia (Requer fase NIGHT)*.
  * `Erupção de Miasma` & `Guardião Ancestral`: *Exigem risco 3 ou 4*.
* **Diagnóstico**: Excelente variedade de encontros; o gatilho noturno confere alto valor de replay.

### 2.4 Ruínas de Zaban (HIGH RISK - Risco 3) & Ravina da Névoa (DANGER - Risco 4)
* **Status**: 4 Eventos Aceitos | 4 Rejeitados
* **Aceitos**: `Guardião Ancestral Desperto`, `Erupção de Miasma`, `Duelo Tático de Nen`, `Caravana Médica`
* **Rejeitados**: Eventos pacíficos e ladrões fracos são suprimidos.
* **Diagnóstico**: Periculosidade condizente com a progressão avançada de Nen.

---

## 3. Conclusões e Recomendações
1. **Diretor Equilibrado**: O `ContentDirector` não está excessivamente agressivo nem excessivamente conservador. Ele respeita o ritmo de 300-600px entre encontros.
2. **Gatilhos Noturnos**: O evento `Fera Quimera Noturna` adiciona incentivo tangível para caçar à noite devido ao bônus de +25% de XP.
3. **Recomendação**: Adicionar 1 evento social/diplomático entre facções na Estrada Real (ex: disputa de jurisdição entre Guardas da Cidade e Caçadores da Associação).
