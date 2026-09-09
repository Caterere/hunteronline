$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$outDir = 'assets/sprites/characters'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$cell = 48
$dirs = @('south','south-east','east','north-east','north','north-west','west','south-west')

$chars = @(
  @{
    id='9f024283-f8da-4717-89c0-aeff7ac77b7c'
    name='enemy_sentinela_pedra'
    ts='1788921056'
  },
  @{
    id='463b74e6-082b-413f-af14-9425f04333d6'
    name='npc_melody'
    ts='1788921048'
  },
  @{
    id='7269c311-12d6-4a00-a7a4-ba68753fdada'
    name='npc_battera'
    ts='1788921074'
  },
  @{
    id='749a8764-0389-44ef-b121-e98322929410'
    name='npc_tsezguerra'
    ts='1788921073'
  }
)

foreach ($c in $chars) {
  $tmp = Join-Path $outDir ("{0}_rotations" -f $c.name)
  New-Item -ItemType Directory -Force -Path $tmp | Out-Null
  $sheet = New-Object System.Drawing.Bitmap ($cell * 8), $cell
  $g = [System.Drawing.Graphics]::FromImage($sheet)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
  $g.Clear([System.Drawing.Color]::Transparent)

  for ($di = 0; $di -lt $dirs.Count; $di++) {
    $d = $dirs[$di]
    $url = "https://backblaze.pixellab.ai/file/pixellab-characters/6527f45e-b81b-4b1c-a5a3-7b422bb6a2ce/$($c.id)/rotations/$d.png?t=$($c.ts)"
    $dest = Join-Path $tmp "$d.png"
    curl.exe -sL -o $dest $url
    if (-not (Test-Path $dest) -or (Get-Item $dest).Length -lt 100) { throw "Failed $dest" }
    $src = [System.Drawing.Image]::FromFile((Resolve-Path $dest))
    $destRect = New-Object System.Drawing.Rectangle (($di * $cell), 0, $cell, $cell)
    $g.DrawImage($src, $destRect)
    $src.Dispose()
  }
  $g.Dispose()
  $outPath = Join-Path $outDir ("{0}_8dir.png" -f $c.name)
  $sheet.Save((Join-Path (Get-Location) $outPath), [System.Drawing.Imaging.ImageFormat]::Png)
  $sheet.Dispose()
  Write-Host "WROTE $outPath $((Get-Item $outPath).Length)b"
}
