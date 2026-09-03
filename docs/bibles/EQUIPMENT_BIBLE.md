# EQUIPMENT DESIGN BIBLE
## HUNTER ONLINE — GEAR, NEN CATALYSTS & BUILDS

---

## 1. O PAPEL DO EQUIPAMENTO EM HUNTER ONLINE

> **"Equipamentos no Hunter Online não transformam o jogo em um gerador aleatório de números sem sentido. Eles funcionam como extensões táteis da build e catalisadores para a aplicação de Shu e Hatsu."**

No cânone de Hunter x Hunter, grandes mestres (como Netero, Gon ou Kurapika) utilizam equipamentos simples ou canalizadores específicos (correntes, varas de pesca, espadas reforçadas por Shu). O equipamento complementa o Nen, nunca o substitui.

---

## 2. SLOTS DE EQUIPAMENTO

O Hunter dispõe de 6 slots essenciais:

```text
[Cabeça]    Faixas de concentração, capuzes de furtividade (bônus em Zetsu/Gyo)
[Corpo]     Trajes leves, quimonos ou coletes reforçados (bônus em Ten/Defesa)
[Mão Princ.] Arma branca ou catalisador físico (canaliza o dano de Shu)
[Mão Sec.]   Escudo leve, adaga de parry ou foco secundário de aura
[Acessório] Anel de foco, pingente de clã (bônus em Aura Máxima / Regeneração)
[Licença]   Licença Hunter física (concede livre trânsito e descontos mundiais)
```

---

## 3. APLICAÇÃO DE SHU EM EQUIPAMENTOS

- Armas empunhadas no slot principal recebem o bônus contínuo do **Passivo Shu** (`PassiveNenController.obter_bonus_shu_equipamento()`).
- O dano físico da arma é convertido e amplificado em dano de Nen perfurante.
- Equipamentos não possuem durabilidade degradante irritante; seu valor reside nas propriedades táticas e compatibilidade com a natureza natal de Nen do Hunter.
