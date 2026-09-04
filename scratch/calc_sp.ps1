$content = Get-Content 'scripts/systems/skill_tree/SkillTreeDatabase.gd' -Raw

Write-Output "Analyzing SkillTreeDatabase.gd..."

# Let's inspect loops or helper methods in SkillTreeDatabase.gd
$lines = Get-Content 'scripts/systems/skill_tree/SkillTreeDatabase.gd'
$in_func = ""
$total_cost = 0
$node_count = 0

# Check how nodes are created
$loop_matches = [regex]::Matches($content, 'for\s+i\s+in\s+range\(\s*(\d+)\s*\):')
Write-Output "Loops found: $($loop_matches.Count)"

# Let's write a parser in powershell to track _add_node calls
$add_node_matches = [regex]::Matches($content, '_add_node\s*\(([^;]+?)\)\s*(?=\r?\n\t\S|\r?\n\t#|\r?\nfunc|\r?\n\r?\n)')
Write-Output "Add node matches: $($add_node_matches.Count)"
