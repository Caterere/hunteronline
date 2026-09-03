# ADR-001: ARQUITETURA HÍBRIDA DE NEN (5 PASSIVOS + 3 ATIVOS)

## Contexto
Anteriormente, o sistema de Nen oscilou entre tratamentos puramente passivos (sem nenhum botão de ativação) ou stances complexas de teclas manuais. A obra original Hunter x Hunter estabelece claramente que técnicas como Ten e Ren tornam-se estados naturais contínuos do corpo após o despertar, enquanto Zetsu, En e Gyo são acionadas intencionalmente para fins táticos de furtividade, percepção espacial e foco sensorial.

## Decisão
Dividir formalmente o Nen em duas camadas:
1. **5 Passivas:** Ten, Ren, Shu, Ko e Ryu são gerenciadas por `PassiveNenController.gd`, operando através de modificadores permanentes da Skill Tree sem botões manuais.
2. **3 Ativas Especiais:** Zetsu, En e Gyo são gerenciadas por `ActiveNenController.gd`, possuindo botões de toggle via `InputMap` (`nen_zetsu`, `nen_en`, `nen_gyo`).
3. Zetsu, En e Gyo **NÃO** ocupam slots de Hatsu (que são dedicados exclusivamente às habilidades ativas 1 a 4).

## Consequências
- O combate básico permanece ágil e limpo com 2 pilares: Ataque Físico + 4 Hatsu.
- Zetsu implementa stealth real calculável por fórmulas matemáticas em vez de invisibilidade genérica.
- En e Gyo ganham mecânicas distintas de debuff de área e revelação de segredos multi-tier.
