"""
PixelLab API Generator & Downloader for Hunter Online
Integração com https://api.pixellab.ai/mcp e API v2

Permite criar tilesets Wang top-down (grama, pedra, caminhos, água, etc.)
e baixá-los diretamente para a pasta de assets do Godot.
"""

import os
import sys
import time
import json
import argparse
import urllib.request
import urllib.error

BASE_URL = "https://api.pixellab.ai/v2"

def get_token(cli_token: str | None) -> str:
    token = cli_token or os.environ.get("PIXELLAB_API_TOKEN")
    if not token:
        # Tenta ler do mcp_config.json
        mcp_path = os.path.expanduser(r"~\.gemini\config\mcp_config.json")
        if os.path.exists(mcp_path):
            try:
                with open(mcp_path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    token = data.get("mcpServers", {}).get("pixellab", {}).get("headers", {}).get("Authorization", "")
                    if token.startswith("Bearer "):
                        token = token.replace("Bearer ", "").strip()
                    if token == "YOUR_API_TOKEN":
                        token = None
            except Exception:
                pass

    if not token:
        print("[-] ERRO: Token da PixelLab não configurado!")
        print("[*] Obtenha seu token em: https://api.pixellab.ai/mcp")
        print("[*] Passe via --token SEU_TOKEN ou defina a variável PIXELLAB_API_TOKEN")
        sys.exit(1)
    return token

def make_request(endpoint: str, method: str = "GET", data: dict | None = None, token: str = "") -> dict:
    url = f"{BASE_URL}{endpoint}"
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
        "User-Agent": "HunterOnline-PixelLab/1.0"
    }
    body = json.dumps(data).encode("utf-8") if data else None
    req = urllib.request.Request(url, data=body, headers=headers, method=method)
    
    try:
        with urllib.request.urlopen(req) as resp:
            resp_data = resp.read().decode("utf-8")
            return json.loads(resp_data) if resp_data else {}
    except urllib.error.HTTPError as e:
        err_msg = e.read().decode("utf-8")
        print(f"[-] Erro na requisição HTTP {e.code}: {err_msg}")
        raise e

def create_topdown_tileset(lower: str, upper: str, token: str, tile_size: int = 16) -> str:
    print(f"[*] Solicitando criação de tileset Wang: '{lower}' -> '{upper}' (tamanho {tile_size}px)...")
    payload = {
        "lower_description": lower,
        "upper_description": upper,
        "tile_size": {"width": tile_size, "height": tile_size},
        "mode": "standard",
        "view": "high top-down"
    }
    res = make_request("/create-topdown-tileset", method="POST", data=payload, token=token)
    tileset_id = res.get("tileset_id") or res.get("id")
    print(f"[+] Job criado com sucesso! Tileset ID: {tileset_id}")
    return tileset_id

def poll_and_download_tileset(tileset_id: str, out_dir: str, token: str, filename: str = "pixellab_tileset.png"):
    print(f"[*] Aguardando processamento do tileset {tileset_id} (leva ~1-2 minutos)...")
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, filename)

    for attempt in range(60):
        time.sleep(5)
        res = make_request(f"/topdown-tilesets/{tileset_id}", method="GET", token=token)
        status = res.get("status")
        print(f"[{attempt*5}s] Status atual: {status}")

        if status == "completed" or "download_url" in res:
            download_url = res.get("download_url") or f"https://api.pixellab.ai/mcp/tilesets/{tileset_id}/download"
            print(f"[+] Download pronto! Baixando de {download_url} para {out_path}...")
            urllib.request.urlretrieve(download_url, out_path)
            print(f"[SUCCESS] Tileset salvo com sucesso em: {out_path}")
            return out_path
        elif status in ("failed", "error"):
            print(f"[-] Erro no processamento: {res.get('error', 'Desconhecido')}")
            sys.exit(1)

    print("[-] Timeout aguardando geração do tileset.")
    sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description="PixelLab Generator para Hunter Online")
    parser.add_argument("--token", help="PixelLab Bearer API Token")
    parser.add_argument("--lower", default="vibrant green mmo grass", help="Terreno inferior")
    parser.add_argument("--upper", default="cobblestone plaza pavement", help="Terreno superior")
    parser.add_argument("--size", type=int, default=16, help="Tamanho dos tiles (16 ou 32)")
    parser.add_argument("--out", default="assets/sprites/tilesets/pixellab", help="Pasta de saída")
    parser.add_argument("--name", default="lobby_wang_tileset.png", help="Nome do arquivo")

    args = parser.parse_args()
    token = get_token(args.token)
    
    # Criar e baixar
    tileset_id = create_topdown_tileset(args.lower, args.upper, token, args.size)
    poll_and_download_tileset(tileset_id, args.out, token, args.name)

if __name__ == "__main__":
    main()
