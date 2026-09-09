const https = require('https');
const fs = require('fs');
const path = require('path');

const TOKEN = process.env.PIXELLAB_API_TOKEN;
if (!TOKEN) {
  console.error('Defina a variável de ambiente PIXELLAB_API_TOKEN (veja .env.example / .env).');
  process.exit(1);
}

function request(pathUrl, method = 'GET', body = null) {
  return new Promise((resolve, reject) => {
    const dataString = body ? JSON.stringify(body) : null;
    const options = {
      hostname: 'api.pixellab.ai',
      port: 443,
      path: pathUrl,
      method: method,
      headers: {
        'Authorization': `Bearer ${TOKEN}`,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'HunterOnline-PixelLab/1.0'
      }
    };
    if (dataString) {
      options.headers['Content-Length'] = Buffer.byteLength(dataString);
    }

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          resolve({ statusCode: res.statusCode, data: json });
        } catch (e) {
          resolve({ statusCode: res.statusCode, raw: data });
        }
      });
    });

    req.on('error', reject);
    if (dataString) req.write(dataString);
    req.end();
  });
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
  console.log('====================================================');
  console.log('PIXELLAB TILESET GENERATOR — HUNTER ONLINE LOBBY');
  console.log('====================================================');

  const payload = {
    lower_description: "vibrant lush green mmorpg grass with subtle moss and tiny flowers",
    upper_description: "ancient polished cobblestone stone pavement for mmorpg city plaza",
    transition_description: "cobblestone stones naturally blending into lush green grass",
    tile_size: { width: 16, height: 16 },
    transition_size: 0.25,
    view: "high top-down"
  };

  console.log('[*] Enviando requisição de geração para PixelLab v2...');
  console.log('Lower:', payload.lower_description);
  console.log('Upper:', payload.upper_description);

  const initRes = await request('/v2/create-tileset', 'POST', payload);
  console.log('Status de Criação:', initRes.statusCode);
  console.log('Resposta:', initRes.data);

  if (!initRes.data || !initRes.data.tileset_id) {
    console.error('[-] Falha ao obter tileset_id:', initRes);
    process.exit(1);
  }

  const tilesetId = initRes.data.tileset_id;
  const jobId = initRes.data.background_job_id;
  console.log(`[+] Job registrado! Tileset ID: ${tilesetId}, Job ID: ${jobId}`);
  console.log('[*] Aguardando processamento da IA no PixelLab (geralmente ~60-120 segundos)...');

  const outDir = path.resolve(__dirname, '../../assets/sprites/tilesets/pixellab');
  fs.mkdirSync(outDir, { recursive: true });

  const maxAttempts = 50;
  for (let i = 1; i <= maxAttempts; i++) {
    await sleep(6000);
    const poll = await request(`/v2/tilesets/${tilesetId}`);
    process.stdout.write(`[Tentativa ${i}/${maxAttempts}] HTTP Status: ${poll.statusCode}\r`);

    if (poll.statusCode === 200 && poll.data && poll.data.tileset) {
      console.log('\n[SUCCESS] Tileset gerado com sucesso pelo PixelLab!');
      const tiles = poll.data.tileset.tiles || [];
      console.log(`[+] Total de tiles recebidos: ${tiles.length}`);

      // Salvar os metadados JSON
      const metaPath = path.join(outDir, 'pixellab_lobby_tileset_meta.json');
      fs.writeFileSync(metaPath, JSON.stringify(poll.data, null, 2));
      console.log(`[+] Metadados salvos em: ${metaPath}`);

      // Salvar cada tile em PNG individual
      const tilesDir = path.join(outDir, 'tiles');
      fs.mkdirSync(tilesDir, { recursive: true });

      for (let idx = 0; idx < tiles.length; idx++) {
        const t = tiles[idx];
        let base64Data = '';
        if (t.image && t.image.base64) {
          base64Data = t.image.base64;
        } else if (t.image_data && t.image_data.includes('base64,')) {
          base64Data = t.image_data.split('base64,')[1];
        }

        if (base64Data) {
          const tileFile = path.join(tilesDir, `tile_${String(idx).padStart(2, '0')}_${t.name || 'tile'}.png`);
          fs.writeFileSync(tileFile, Buffer.from(base64Data, 'base64'));
        }
      }
      console.log(`[+] ${tiles.length} tiles individuais salvos em: ${tilesDir}`);

      // Salvar resumo com sucesso
      console.log('====================================================');
      console.log('PROCESSO DE GERAÇÃO PIXELLAB CONCLUÍDO!');
      console.log('====================================================');
      return;
    } else if (poll.statusCode === 423) {
      // 423 significa still processing
      continue;
    } else if (poll.statusCode >= 400 && poll.statusCode !== 423) {
      console.log('\n[-] Resposta inesperada ao consultar tileset:', poll);
    }
  }

  console.error('\n[-] Timeout aguardando geração do tileset no PixelLab.');
}

main().catch(console.error);
