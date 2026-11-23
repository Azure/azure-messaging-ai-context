<#
.SYNOPSIS
Checks the mechanical rules of design_doc_guidelines.md. Prints one line per issue and exits 1 if there are any.
.PARAMETER Path
The design doc to check.
.PARAMETER Existing
The doc is an existing doc being edited, so its outline, line wrapping and top status line are not checked.
.PARAMETER ExistingDesign
The doc describes an existing design (the document-existing-design skill): it needs a verified line instead of a
status line,
has no proposal outline, a shorter core, and every identifier in backticks must exist in the repo's code.
#>
param(
    [Parameter(Mandatory)] [string] $Path,
    [switch] $Existing,
    [switch] $ExistingDesign
)

$outline = 'summary', 'problem', 'how it works today', 'design', 'compatibility and rollout', 'test', 'alternative',
    'open questions', 'appendix', 'references'
$planHeading = '(?i)(\bfiles? (to (change|modify|touch)|changed)\b|\bfile structure\b|\bimplementation (plan|order|' +
    'phases?)\b|\bwork breakdown\b|\bmodules touched\b|^(phases?|changes|tasks?|pr plan|approval|test plan|' +
    'testing strategy)$|\bphase \d)'

$lines = @(Get-Content -LiteralPath $Path -Encoding utf8)
$issues = [System.Collections.Generic.List[string]]::new()
function Add-Issue([int] $line, [string] $text) { $issues.Add("${Path}:${line}: $text") }

function Test-Table($rows) {
    if ($rows.Count -eq 0) { return }
    $shapes = $rows | ForEach-Object { (([regex]::Matches($_.Text, '(?<!\\)\|') | ForEach-Object Index) -join ',') }
    if (@($shapes | Sort-Object -Unique).Count -gt 1) {
        Add-Issue $rows[0].Line 'table columns are not aligned in plain text'
    }
    foreach ($r in $rows) {
        $long = $r.Text -split '(?<!\\)\|' | Where-Object { @($_.Trim() -split '\s+').Count -gt 8 }
        if ($long) {
            Add-Issue $r.Line 'table cell longer than a few words; use a list instead'
            break
        }
    }
}

$inCode = $false
$codeLang = ''
$table = @()
$h2 = @()
for ($i = 0; $i -lt $lines.Count; $i++) {
    $l = $lines[$i]
    $n = $i + 1

    if ($l -match '[^\x00-\x7F]') { Add-Issue $n "non-ASCII character '$($Matches[0])'" }

    if ($l.TrimStart().StartsWith('```')) {
        if (-not $inCode) { $codeLang = $l.Trim().Substring(3).Trim() }
        $inCode = -not $inCode
        continue
    }
    if ($inCode) {
        if ($codeLang -eq '' -and $l -match '\+[-=]{3,}\+|[-=]{3,}>|<[-=]{3,}') {
            Add-Issue $n 'ASCII art; use a mermaid diagram'
        }
        continue
    }

    if ($l.TrimStart().StartsWith('|')) {
        $table += [pscustomobject]@{ Line = $n; Text = $l.TrimEnd() }
        continue
    }
    Test-Table $table
    $table = @()

    if ($l -match '^(=+|-{3,})\s*$' -and $i -gt 0 -and $lines[$i - 1].Trim() -and $lines[$i - 1] -notmatch '^\s*[-*|]') {
        Add-Issue $n 'underlined heading; use a # heading'
    }
    if ($l -match '^(#+)\s+(.*)$') {
        $level = $Matches[1].Length
        $title = $Matches[2].Trim()
        $name = $title -replace '^\d+(\.\d+)*[.)]?\s+', ''
        if ($name -match $planHeading) { Add-Issue $n "plan content heading '$title'" }
        if ($level -eq 2) { $h2 += [pscustomobject]@{ Line = $n; Title = $name.ToLower() } }
        continue
    }
    if ($l.Length -gt 120 -and $l -notmatch '\]\(|https?://') {
        Add-Issue $n "line longer than 120 characters ($($l.Length))"
    }
}
Test-Table $table

# A line that ends well before the rest of its paragraph or list item was broken early, usually by an edit that
# wasn't rewrapped. Comparing with the paragraph's own widest line works for any wrap width. A link or code span that
# starts the next line counts as one word, 20 characters of slack allow for approximate wrapping, and lines that end a
# sentence are skipped (one sentence per line is a valid style).
function Test-Wrap($para) {
    if ($para.Count -lt 2) { return }
    $width = [Math]::Min(120, ($para | ForEach-Object { $_.Text.Length } | Measure-Object -Maximum).Maximum)
    for ($k = 0; $k -lt $para.Count - 1; $k++) {
        $text = $para[$k].Text.TrimEnd()
        if ($para[$k].Text -match '(  |\\)$' -or $text -match '[.:?!]$') { continue }
        $next = [regex]::Match($para[$k + 1].Text.Trim(), '^(!?\(?\[[^\]]*\]\([^)]*\)|`[^`]*`)?\S*').Value
        if ($text.Length + 1 + $next.Length + 20 -le $width) {
            Add-Issue $para[$k].Line 'line ends early; rewrap the paragraph'
        }
    }
}
if (-not $Existing) {
    $inCode = $false
    $para = @()
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $l = $lines[$i]
        $fence = $l.TrimStart().StartsWith('```')
        if ($fence) { $inCode = -not $inCode }
        $isText = -not $inCode -and -not $fence -and $l.Trim() -and $l -notmatch '^\s*(#|\||>|<|=+\s*$|-{3,}\s*$)'
        if (-not $isText -or $l -match '^\s*([-*+]|\d+[.)])\s') {
            Test-Wrap $para
            $para = @()
        }
        if ($isText) { $para += [pscustomobject]@{ Line = $i + 1; Text = $l } }
    }
    Test-Wrap $para
}

$statusLine = '^Status: \w[\w ]* \(last updated \d{4}-\d{2}-\d{2}\)\s*$'
$verifiedLine = '^Verified against code at [0-9a-f]{7,40} \(\d{4}-\d{2}-\d{2}\)\s*$'
if ($ExistingDesign) {
    if (-not ($lines -match $verifiedLine)) {
        Add-Issue 1 "missing 'Verified against code at <commit> (YYYY-MM-DD)' line"
    }
}
elseif (-not $Existing -and -not ($lines -match $statusLine)) {
    Add-Issue 1 "missing 'Status: <state> (last updated YYYY-MM-DD)' line"
}
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^#+ .*\(proposed\)') {
        $next = $lines[($i + 1)..($lines.Count - 1)] | Where-Object { $_.Trim() } | Select-Object -First 1
        if ($next -notmatch $statusLine) { Add-Issue ($i + 1) 'proposed section needs a status line under its heading' }
    }
}

# Relative links must resolve.
$docDir = Split-Path -Parent (Resolve-Path -LiteralPath $Path)
$inCode = $false
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i].TrimStart().StartsWith('```')) { $inCode = -not $inCode; continue }
    if ($inCode) { continue }
    foreach ($m in [regex]::Matches($lines[$i], '\]\(([^)\s]+)\)')) {
        $target = $m.Groups[1].Value
        if ($target -match '^(https?:|mailto:|#)') { continue }
        $file = [uri]::UnescapeDataString(($target -split '#')[0])
        if ($file -and -not (Test-Path -LiteralPath (Join-Path $docDir $file))) {
            Add-Issue ($i + 1) "broken link '$target'"
        }
    }
}

if ($ExistingDesign) {
    $h2 | Where-Object { $_.Title -match '^(problem|alternatives?\b|open questions|testing)' } |
        ForEach-Object {
            Add-Issue $_.Line "proposal section '$($_.Title)'; an existing-design doc describes what is built"
        }

    # Identifiers in backticks (snake_case names, or file names) must exist in the repo's code.
    $root = git -C $docDir rev-parse --show-toplevel 2>$null
    if ($root) {
        $seen = @{}
        $inCode = $false
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i].TrimStart().StartsWith('```')) { $inCode = -not $inCode; continue }
            if ($inCode) { continue }
            foreach ($m in [regex]::Matches($lines[$i], '`([^`]+)`')) {
                $id = $m.Groups[1].Value.Trim() -replace '\(\)$', ''
                if ($seen.ContainsKey($id)) { continue }
                $seen[$id] = $true
                if ($id -match '^[\w./-]+\.(c|h|cpp|hpp|cs|rs)$') {
                    if (-not (git -C $root ls-files -- "*$(Split-Path -Leaf $id)")) {
                        Add-Issue ($i + 1) "file ``$id`` not found in the repo"
                    }
                }
                elseif ($id -match '^[A-Za-z_][A-Za-z0-9_]{3,}$' -and $id.Contains('_')) {
                    git -C $root grep -q -w -F -e $id -- . ':(exclude)*.md' 2>$null
                    if ($LASTEXITCODE -ne 0) { Add-Issue ($i + 1) "identifier ``$id`` not found in the code" }
                }
            }
        }
    }
}

if (-not $Existing) {
    if (-not $ExistingDesign) {
        $last = -1
        foreach ($h in $h2) {
            $idx = -1
            for ($k = 0; $k -lt $outline.Count; $k++) { if ($h.Title.StartsWith($outline[$k])) { $idx = $k; break } }
            if ($idx -lt 0) { Add-Issue $h.Line "section '$($h.Title)' is not in the outline" }
            elseif ($idx -lt $last) { Add-Issue $h.Line "section '$($h.Title)' is out of outline order" }
            else { $last = $idx }
        }
    }

    # Core length: words from the first section up to the optional trailing sections, not counting mermaid diagrams.
    $coreMax = if ($ExistingDesign) { 1500 } else { 2500 }
    $coreName = if ($ExistingDesign) { 'core (before Future work)' } else { 'core (Summary through Testing)' }
    $trailing = if ($ExistingDesign) { '^(future work|references|appendix)' }
        else { '^(alternative|open questions|appendix|references)' }
    $start = if ($h2) { $h2[0].Line - 1 } else { 0 }
    $after = $h2 | Where-Object { $_.Title -match $trailing } | Select-Object -First 1
    $stop = if ($after) { $after.Line - 1 } else { $lines.Count }
    $words = 0
    $fence = ''
    for ($i = $start; $i -lt $stop; $i++) {
        $t = $lines[$i].Trim()
        if ($t.StartsWith('```')) { $fence = if ($fence) { '' } else { 'x' + $t.Substring(3).Trim() }; continue }
        if ($fence -ne 'xmermaid') { $words += @($t -split '\s+' | Where-Object { $_ }).Count }
    }
    if ($words -gt $coreMax) {
        Add-Issue ($start + 1) "$coreName is $words words, over $coreMax; cut it or move detail to a separate doc"
    }
}

$issues | ForEach-Object { $_ }
exit [int]($issues.Count -gt 0)
