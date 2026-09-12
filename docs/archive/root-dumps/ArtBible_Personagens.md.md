# 📖 BÍBLIA DE ARTE: Projeto RPG Top-Down (Estilo Hunter x Hunter)

## 1. Visão Geral do Estilo Visual
Todos os assets gerados devem seguir estritamente o estilo visual âncora do projeto.
*   **Estilo Base:** Pixel Art 2D Retro (estilo 16-bits/32-bits).
*   **Perspectiva da Câmera:** Visão Top-Down (perspectiva 3/4, clássica de RPGs de ação).
*   **Proporção Anatômica:** Chibi (A cabeça deve representar cerca de 40-50% do tamanho total do corpo). Corpos achatados, braços e pernas curtos.
*   **Contornos (Outlines):** Todo personagem DEVE ter um contorno externo preto e espesso (Thick black outline).
*   **Sombreamento:** Apenas cores chapadas (flat colors) e cell-shading em blocos. Zero gradientes, zero desfoques, zero texturas HD.

## 2. Padrões de Grade (Grid) e Sprite Sheet
Para que as animações funcionem na engine do jogo, os quadros (frames) devem estar perfeitamente alinhados em uma grade matemática.
*   **Tamanho do Frame Individual:** 64x64 pixels (ou 48x48 pixels). O personagem deve estar centralizado no quadro.
*   **Fundo (Background):** Obrigatoriamente uma cor sólida (Magenta #FF00FF ou Verde #00FF00) ou totalmente transparente.

## 3. Diretrizes de Animação (Frame-by-Frame)
Ao gerar animações, o layout do Sprite Sheet deve seguir a seguinte contagem de quadros dispostos horizontalmente (da esquerda para a direita):

*   **Idle (Parado):** 4 frames.
    *   *Descrição:* Movimento sutil de respiração, leve oscilação dos ombros e do cabelo.
*   **Walk Cycle (Andar):** 4 frames ou 6 frames.
    *   *Descrição:* Movimento clássico de RPG. Braços e pernas se alternando. Um frame de repouso, um passo direito, repouso, passo esquerdo.
*   **Attack (Atacar):** 4 frames.
    *   *Descrição:* 
        *   Frame 1: Antecipação (puxando a arma ou punho para trás).
        *   Frame 2: O golpe (extensão máxima).
        *   Frame 3: Impacto/VFX (rastro de energia, se for o caso do Nen).
        *   Frame 4: Recuperação (voltando à base).

## 4. Adaptação da IP (Hunter x Hunter)
Ao receber uma imagem de referência de um personagem (ex: Gon, Killua, Kurapika):
*   **Roupas e Cores:** Extraia a paleta de cores exata da roupa e do cabelo.
*   **Simplificação:** Reduza os detalhes excessivos da roupa para que fiquem nítidos na resolução em pixel art chibi.
*   **Assinatura Visual:** Mantenha o formato do cabelo (ex: os espetos do Gon, a leveza do cabelo do Killua) pois é a principal forma de reconhecimento em formato Chibi.

## 5. 🛑 RESTRIÇÕES CRÍTICAS (Negative Prompts)
O agente gerador ESTÁ PROIBIDO de:
*   Gerar proporções de anime tradicional (corpos realistas, pernas longas).
*   Gerar artes conceituais ilustradas. A saída DEVE SER sempre um Sprite Sheet em pixel art.
*   Adicionar cenários ou sombras de chão abaixo do personagem (isso será feito na engine).
*   Mudar a perspectiva para visão lateral (side-scroller) ou isométrica verdadeira. Mantenha Top-Down 3/4.