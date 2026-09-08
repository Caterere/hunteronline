const https = require('https');
const fs = require('fs');
const path = require('path');

const TOKEN = '9cb7f030-0cb6-48c2-ac83-58d0d0ff9d2d';

function downloadFile(url, dest) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(dest);
    https.get(url, (response) => {
      if (response.statusCode >= 300 && response.statusCode < 400 && response.headers.location) {
        return downloadFile(response.headers.location, dest).then(resolve).catch(reject);
      }
      if (response.statusCode !== 200) {
        return reject(new Error(`Failed to download ${url}: status ${response.statusCode}`));
      }
      response.pipe(file);
      file.on('finish', () => {
        file.close(() => resolve(dest));
      });
    }).on('error', (err) => {
      fs.unlink(dest, () => reject(err));
    });
  });
}

function requestJson(endpoint) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'api.pixellab.ai',
      port: 443,
      path: endpoint,
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${TOKEN}`,
        'Accept': 'application/json',
        'User-Agent': 'HunterOnline/1.0'
      }
    };
    https.get(options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(body));
        } catch (e) {
          resolve({ raw: body, status: res.statusCode });
        }
      });
    }).on('error', reject);
  });
}

async function main() {
  const characters = [
    { id: 'd1d5f211-b3e6-457f-89a1-58f38171dc2c', name: 'npc_ferreiro_mestre' },
    { id: 'c91dcdc3-9cc0-4d58-bcae-20b1e766788a', name: 'npc_vendedor_mercador' },
    { id: '7f50559e-5032-4787-a776-3dbe9e9121d4', name: 'npc_discipulo_zushi' }
  ];

  const outBase = path.resolve(__dirname, '../../assets/sprites/characters');
  fs.mkdirSync(outBase, { recursive: true });

  for (const c of characters) {
    console.log(`[*] Baixando dados do personagem ${c.name} (${c.id})...`);
    const details = await requestJson(`/v2/characters/${c.id}`);
    const rotUrls = details.rotation_urls || details.rotations || {};
    
    // Baixar a rotação South principal como sprite base
    const southUrl = rotUrls.south;
    if (southUrl) {
      const dest = path.join(outBase, `${c.name}.png`);
      await downloadFile(southUrl, dest);
      console.log(`[+] Sprite principal salvo em: ${dest}`);
    }

    // Baixar todas as 8 rotações em pasta individual
    const rotDir = path.join(outBase, c.name + '_rotations');
    fs.mkdirSync(rotDir, { recursive: true });
    for (const [dir, url] of Object.entries(rotUrls)) {
      const dest = path.join(rotDir, `${dir}.png`);
      await downloadFile(url, dest);
    }
    console.log(`[+] 8 direções salvas em: ${rotDir}`);
  }
  console.log('[SUCCESS] Todos os personagens foram baixados com sucesso!');
}

main().catch(console.error);
