# JSON to Bicep parameters file
[cmdletBinding()]
Param(
  [string][Parameter()]
  $InputFilePath
)

$outputFilePath = Join-Path (Split-Path $InputFilePath -Parent) ("bicep-" + (Split-Path $InputFilePath -Leaf))

$c = Get-Content -Raw $InputFilePath
$j = $c | ConvertFrom-Json -AsHashtable
$result = [ordered]@{
  "`$schema"       = "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#"
  "contentVersion" = "1.0.0.0"
  "parameters"     = [ordered]@{}
}
$j.Keys | ForEach-Object { $result.parameters[$_] = @{value = $j[$_] } }
$result | ConvertTo-Json -Depth 10 | Set-Content -Path $outputFilePath -Encoding utf8NoBOM

Write-Output $outputFilePath
