# GUIA DE CONTEÚDO DE HATSU — HATSU CONTENT GUIDE

> **Manual de Criação, Categorias de Nen e Integração de Hatsus no Hunter MMORPG**
> **Versão:** 1.0 (Fase L) | **Engine:** Godot 4.6 Stable

---

## 1. ESTRUTURA DO RECURSO DE HATSU (HatsuData)

Hatsus no Hunter MMORPG são modelados estritamente sobre as regras canônicas de Nen de Hunter x Hunter via recurso HatsuData (es://resource/hatsu/HatsuData.gd).

### 1.1 Exemplo de Construção em GDScript:
`gdscript
var hatsu := HatsuData.new()
hatsu.hatsu_id =  impacto_selvagem
hatsu.nome = Impacto Selvagem
hatsu.categoria = HatsuData.Categoria.INTENSIFICACAO # Intensificação, Transformação, Emissão, etc.
hatsu.objetivo = HatsuData.ObjetivoPrincipal.DANO    # Dano, Defesa, Cura, Suporte, etc.
hatsu.forma = HatsuData.Forma.AREA                   # Projétil, Área, Toque, Zona, etc.
hatsu.alvo = HatsuData.Alvo.INIMIGO_UNICO
hatsu.poder_base = 280.0
hatsu.custo_aura_base = 35.0
hatsu.cooldown_base = 4.5

# Registro de Juramento ou Condição (Opcional)
hatsu.condicoes = [HatsuData.Condicao.PARADO_CANALIZACAO] # Aumenta poder mediante canalização
`

---

## 2. INTEGRAÇÃO COM O CÓDEX E PROGRESSÃO

Ao desbloquear ou dominar um Hatsu durante o jogo:
1. **Descoberta no Códex:**
   `gdscript
   CollectionManager.register_discovery(hatsu, impacto_selvagem)
   `
2. **Registro no HatsuProgressionManager:**
   O slot de Hatsu do jogador equipa a habilidade permitindo seu disparo através do canal de combate correto (OFFENSIVE, DEFENSIVE, etc.).

---

## 3. O QUE ESTÁ IMPLEMENTADO

* **6 Categorias Canônicas de Nen:** Intensificação, Transformação, Emissão, Conjuração, Manipulação e Especialização.
* **10 Grandes Arquétipos:** Suporte a dados, moedas, arsenal aleatório (Crazy Slots), territórios de En e roubo/arquivo de habilidades.
* **Power Budget Engine:** Balanceamento matemático entre custo de aura, tempo de recarga, área de impacto e poder destrutivo.
* **Persistência no Schema v2.4:** Hatsus desbloqueados salvos de forma retrocompatível.

---

## 4. O QUE ESTÁ PLANEJADO

1. **Hatsus de Drop Raro de Chefes:** Tomos de treinamento como recompensa exclusiva de chefes de raid.
2. **Evolução de Hatsu com Maestria:** Subida de nível da habilidade pelo uso contínuo (Lv 1 ao Lv 100), reduzindo cooldown e refinando efeitos visuais.
3. **Árvore de Variantes por Hatsu:** Escolha entre 2 especializações ao atingir maestria máxima na técnica.

---

## 5. O QUE É FUTURO

1. **Sistema de Juramentos Criados pelo Jogador (Custom Vows):** IA interna analisando restrições digitadas pelo jogador para calcular multiplicadores de dano e penalidades de morte justas.
2. **Troca e Empréstimo de Hatsu entre Jogadores:** Arquétipos de Especialização capazes de guardar habilidades de amigos temporariamente para batalhas em grupo.
