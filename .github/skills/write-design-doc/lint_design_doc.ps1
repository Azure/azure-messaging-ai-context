<#
.SYNOPSIS
Checks the mechanical rules of design_doc_guidelines.md. Prints one line per issue and exits 1 if there are any.
.PARAMETER Path
The design doc to check.
.PARAMETER Existing
The doc is an existing doc being edited, so its outline is not checked.
#>
param(
    [Parameter(Mandatory)] [string] $Path,
    [switch] $Existing
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
        if ($level -gt 3) { Add-Issue $n 'heading deeper than 3 levels' }
        if ($title -match '^\d+[.)]') { Add-Issue $n 'numbered heading' }
        if (($title -replace '^\d+[.)]\s*', '') -match $planHeading) { Add-Issue $n "plan content heading '$title'" }
        if ($level -eq 2) { $h2 += [pscustomobject]@{ Line = $n; Title = $title.ToLower() } }
        continue
    }
    if ($l.Length -gt 120 -and $l -notmatch '\]\(|https?://') {
        Add-Issue $n "line longer than 120 characters ($($l.Length))"
    }
}
Test-Table $table

if (-not ($lines -match '^Status: \w[\w ]* \(last updated \d{4}-\d{2}-\d{2}\)\s*$')) {
    Add-Issue 1 "missing 'Status: <state> (last updated YYYY-MM-DD)' line"
}

if (-not $Existing) {
    $last = -1
    foreach ($h in $h2) {
        $idx = -1
        for ($k = 0; $k -lt $outline.Count; $k++) { if ($h.Title.StartsWith($outline[$k])) { $idx = $k; break } }
        if ($idx -lt 0) { Add-Issue $h.Line "section '$($h.Title)' is not in the outline" }
        elseif ($idx -lt $last) { Add-Issue $h.Line "section '$($h.Title)' is out of outline order" }
        else { $last = $idx }
    }
}

$issues | ForEach-Object { $_ }
if ($issues.Count) { exit 1 }
