# Script to accurately calculate total nodes and total SP to max out SkillTreeDatabase
$content = Get-Content 'scripts/systems/skill_tree/SkillTreeDatabase.gd' -Raw

$nodes = @{} # id -> @{ cost=1; max_rank=1; type=""; region=""; name="" }

# Helper to add node
function Add-Node($id, $name, $cost, $max_rank, $type, $region) {
    $nodes[$id] = @{
        id = $id
        name = $name
        cost = $cost
        max_rank = $max_rank
        type = $type
        region = $region
    }
}

# 1. Nexus center: cost 0, max_rank 1 (starter node)
Add-Node "nexus_center" "Despertar da Essência" 0 1 "KEYSTONE" "nexus"

# Let's parse all _add_node(SkillTreeNodeData.new( ... ))
# We can find all occurrences in the file
$pattern = 'SkillTreeNodeData\.new\(\s*&?["'']?([^,"''\s]+)["'']?\s*,\s*["'']([^"'']+)["'']\s*,\s*["'']([^"'']*)["'']\s*,\s*&?["'']?([^,"''\s]+)["'']?\s*,\s*SkillTreeNodeData\.NodeType\.(\w+)\s*,\s*[^,]+,\s*(\d+)\s*,\s*(\d+)'
$matches = [regex]::Matches($content, $pattern)
foreach ($m in $matches) {
    $id = $m.Groups[1].Value
    $name = $m.Groups[2].Value
    $region = $m.Groups[4].Value
    $type = $m.Groups[5].Value
    $cost = [int]$m.Groups[6].Value
    $max_rank = [int]$m.Groups[7].Value
    if ($id -ne "nexus_center" -and $id -ne "node_id" -and $id -ne "gw_id") {
        Add-Node $id $name $cost $max_rank $type $region
    }
}

# Also gateways: gw_id is used with variables. Let's find:
# var gw_id := &"body_gateway"
# _add_node(SkillTreeNodeData.new(gw_id, "Portal da Fortaleza", ..., cost, max_rank))
$gw_pattern = 'var\s+gw_id\s*:=\s*&?["'']([^"'']+)["''].*?SkillTreeNodeData\.new\(\s*gw_id\s*,\s*["'']([^"'']+)["'']\s*,\s*["'']([^"'']*)["'']\s*,\s*&?["'']?([^,"''\s]+)["'']?\s*,\s*SkillTreeNodeData\.NodeType\.(\w+)\s*,\s*[^,]+,\s*(\d+)\s*,\s*(\d+)'
$gw_matches = [regex]::Matches($content, $gw_pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
foreach ($m in $gw_matches) {
    $id = $m.Groups[1].Value
    $name = $m.Groups[2].Value
    $region = $m.Groups[4].Value
    $type = $m.Groups[5].Value
    $cost = [int]$m.Groups[6].Value
    $max_rank = [int]$m.Groups[7].Value
    Add-Node $id $name $cost $max_rank $type $region
}

# Now parse all _generate_cluster_branch calls!
# _generate_cluster_branch(&"body", gw_id, "body_hp", "Vitalidade Corpórea", "vida_max", 0.015, base_dir, normal * -140.0, 14, SkillTreeNodeData.NodeType.SMALL)
$branch_pattern = '_generate_cluster_branch\(\s*&?["'']([^"'']+)["'']\s*,\s*[^,]+,\s*["'']([^"'']+)["'']\s*,\s*["'']([^"'']+)["'']\s*,\s*["'']([^"'']+)["'']\s*,\s*[^,]+,\s*[^,]+,\s*[^,]+,\s*(\d+)\s*,\s*SkillTreeNodeData\.NodeType\.(\w+)'
$branch_matches = [regex]::Matches($content, $branch_pattern)
Write-Host "Found $($branch_matches.Count) cluster branches."

foreach ($bm in $branch_matches) {
    $region = $bm.Groups[1].Value
    $prefix = $bm.Groups[2].Value
    $title = $bm.Groups[3].Value
    $stat = $bm.Groups[4].Value
    $count = [int]$bm.Groups[5].Value
    $btype = $bm.Groups[6].Value

    for ($i = 1; $i -le $count; $i++) {
        $node_id = "{0}_{1:D2}" -f $prefix, $i
        $n_type = $btype
        $max_rk = 1
        $cost = 1
        if ($i % 4 -eq 0) {
            $n_type = "MEDIUM"
            $max_rk = 3
        }
        Add-Node $node_id ("$title $i") $cost $max_rk $n_type $region
    }
}

$total_sp = 0
$type_counts = @{}
$region_counts = @{}
$region_sp = @{}

foreach ($kv in $nodes.GetEnumerator()) {
    $n = $kv.Value
    $sp_needed = $n.cost * $n.max_rank
    $total_sp += $sp_needed

    $t = $n.type
    if (-not $type_counts.ContainsKey($t)) { $type_counts[$t] = 0 }
    $type_counts[$t]++

    $r = $n.region
    if (-not $region_counts.ContainsKey($r)) { $region_counts[$r] = 0; $region_sp[$r] = 0 }
    $region_counts[$r]++
    $region_sp[$r] += $sp_needed
}

Write-Host "=========================================="
Write-Host "TOTAL DE NÓS: $($nodes.Count)"
Write-Host "TOTAL DE SKILL POINTS (SP) PARA MAXIMIZAR 100%: $total_sp SP"
Write-Host "=========================================="
Write-Host "DISTRIBUIÇÃO POR TIPO DE NÓ:"
foreach ($t in $type_counts.Keys) {
    Write-Host " - $t : $($type_counts[$t]) nós"
}
Write-Host "=========================================="
Write-Host "DISTRIBUIÇÃO POR REGIÃO (Nós / SP necessário):"
foreach ($r in $region_counts.Keys) {
    Write-Host " - Região [$r] : $($region_counts[$r]) nós | $($region_sp[$r]) SP"
}
