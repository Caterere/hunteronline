# Como gerar o .exe do Hunter Online (estilo Steam)

Guia rápido para exportar o jogo e mandar para amigos jogarem **fora do editor Godot**, em tela cheia (~1920×1080).

---

## O que você precisa

1. **Godot 4.6** (mesmo major/minor do projeto)
2. **Export Templates 4.6** instalados:
   - No editor: `Editor → Manage Export Templates… → Download and Install`
3. Este repositório com o preset já criado em `export_presets.cfg`

O jogo usa viewport lógico **640×360** (pixel art) e escala para a tela com stretch. No `.exe` o `GameManager` força **fullscreen** automaticamente.

---

## Exportar pelo editor (mais fácil)

1. Abra o projeto no Godot 4.6
2. Menu **Project → Export…**
3. Selecione o preset **Windows Desktop**
4. Clique **Export Project…**
5. Salve em algo como:
   - `build/windows/HunterOnline.exe`
6. (Opcional) Exporte também **Windows Dedicated Server** → `HunterServer.exe`

### Pasta para enviar aos amigos

Envie a pasta inteira do export (não só o `.exe` se o PCK estiver separado). Com `embed_pck=true` no preset, o ideal é:

```text
HunterOnline/
  HunterOnline.exe          ← cliente (fullscreen)
  (e se separado) HunterOnline.pck
```

Para LAN:

```text
HunterOnline/
  HunterOnline.exe          ← cada amigo joga com este
  HunterServer.exe          ← um PC host roda o servidor
  iniciar_servidor_lan.bat  ← atalho (opcional, se incluir)
  config/
    server_config.json
    server_list.json
```

**Fluxo típico LAN**
1. No PC host: rode `HunterServer.exe` (ou `iniciar_servidor_lan.bat`)
2. Nos clientes: `HunterOnline.exe` → Multiplayer → IP do host `:7777`
3. Firewall do host: liberar **UDP 7777** (e 7778 se usar discovery LAN)

---

## Exportar pela linha de comando

```bash
# Windows (PowerShell), na pasta do projeto:
godot --headless --export-release "Windows Desktop" build/windows/HunterOnline.exe
godot --headless --export-release "Windows Dedicated Server" build/windows/HunterServer.exe
```

```bash
# Linux:
godot --headless --export-release "Linux Desktop" build/linux/HunterOnline.x86_64
```

---

## Resolução / tela cheia

| Setting | Valor | Motivo |
|---|---|---|
| Viewport | 640×360 | Arte/pixel consistente |
| Window override | 1920×1080 | Escala desktop |
| Stretch | `canvas_items` + `expand` | Preenche o monitor |
| Standalone | `WINDOW_MODE_FULLSCREEN` | No `.exe` abre cheio (não no editor) |

Para sair da tela cheia no jogo: `Alt+Enter` (comportamento padrão do Godot) ou feche a janela.

---

## Chat (resumo)

- **Enter** abre o campo; **Enter** de novo envia; **Esc** cancela
- Limite: **120 caracteres** por mensagem
- Canais: Local / Party / Geral (botão à esquerda)
- Mensagens longas quebram por **palavra**, não por letra

---

## Dicas

- Primeira exportação demora (empacota assets). Depois fica mais rápido.
- Antivirus às vezes alerta em `.exe` sem assinatura de código — normal em builds indie.
- HUD “grande demais”: ajuste depois (combinado). Por enquanto o chat ficou mais compacto no canto inferior esquerdo.
- Não precisa Steam para LAN: basta pasta + IP. Steam/Itch.io entram depois se quiser distribuição pública.
