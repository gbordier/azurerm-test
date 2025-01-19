[cmdletBinding()]
Param(
  [string][Parameter()]
  $InputFilePath
)

$outputFilePath = Join-Path (Split-Path $InputFilePath -Parent) ("bicep-" + (Split-Path $InputFilePath -Leaf))

# Bicep parameters file to JSON
$c = Get-Content -Raw $InputFilePath
$j = $c | ConvertFrom-Json -AsHashtable
$result = [ordered]@{}
$j.parameters.Keys | ForEach-Object { $result[$_] = $j.parameters[$_].value }
$result | ConvertTo-Json -Depth 10 | Set-Content -Path $outputFilePath -Encoding utf8NoBOM

Write-Output $outputFilePath
