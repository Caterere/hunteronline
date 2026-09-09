$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$outDir = 'assets/sprites/characters'
$tmp = Join-Path $outDir 'enemy_lobo_sombras_walk_frames'
New-Item -ItemType Directory -Force -Path $tmp | Out-Null

$cell = 48
$dirs = @(
  'south', 'south-east', 'east', 'north-east',
  'north', 'north-west', 'west', 'south-west'
)

$base = 'https://backblaze.pixellab.ai/file/pixellab-characters/6527f45e-b81b-4b1c-a5a3-7b422bb6a2ce/4c51b634-5219-46bd-9b25-e249b8a7b38b/animations'
$animIds = @{
  'south' = 'bc4de270-5b7a-496a-84a1-277ea2d9fdda'
  'south-east' = '689bf0e4-f606-439f-b13b-89a9ded3a69c'
  'east' = 'ebd6fad5-42c0-4f55-94df-8e9456b09f46'
  'north-east' = '5eca9558-f98b-4783-bda4-a52aba8cdc6c'
  'north' = 'bbfaeff1-cf9b-4029-8f93-1320e02c22fb'
  'north-west' = '1314349a-e893-4f6e-9105-43e9f64bdcf8'
  'west' = '82974aba-1856-4004-bbda-d3602cecd334'
  'south-west' = '271f2118-2a5d-4c54-bce9-99e9b8749cd9'
}
$ts = '1788918816705'

$sheet = New-Object System.Drawing.Bitmap ($cell * 8), ($cell * 8)
$g = [System.Drawing.Graphics]::FromImage($sheet)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$g.Clear([System.Drawing.Color]::Transparent)

for ($di = 0; $di -lt $dirs.Count; $di++) {
  $d = $dirs[$di]
  $aid = $animIds[$d]
  Write-Host "dir $d ..."
  for ($fi = 0; $fi -lt 8; $fi++) {
    $url = "$base/$aid/$d/$fi.png?t=$ts"
    $dest = Join-Path $tmp "$d`_$fi.png"
    curl.exe -sL -o $dest $url
    if (-not (Test-Path $dest) -or (Get-Item $dest).Length -lt 100) {
      throw "Failed $dest"
    }
    $src = [System.Drawing.Image]::FromFile((Resolve-Path $dest))
    $destRect = New-Object System.Drawing.Rectangle (($fi * $cell), ($di * $cell), $cell, $cell)
    $g.DrawImage($src, $destRect)
    $src.Dispose()
  }
  Write-Host "dir $d done"
}

$g.Dispose()
$outPath = Join-Path $outDir 'enemy_lobo_sombras_walk_8x8.png'
$sheet.Save((Join-Path (Get-Location) $outPath), [System.Drawing.Imaging.ImageFormat]::Png)
$sheet.Dispose()
Write-Host "WROTE $outPath $((Get-Item $outPath).Length)b"
