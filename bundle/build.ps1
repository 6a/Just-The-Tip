# Builds the CurseForge zip: JustTheTip/<runtime files>
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$repo = Split-Path $PSScriptRoot -Parent
$tocPath = Join-Path $repo "JustTheTip.toc"
$version = "0.0.0"
foreach ($line in Get-Content -LiteralPath $tocPath) {
    if ($line -match '^## Version:\s*(.+)\s*$') {
        $version = $Matches[1].Trim()
        break
    }
}

$files = @(
    "JustTheTip.toc",
    "JustTheTip.lua",
    "icon.png"
)

$zipPath = Join-Path $PSScriptRoot "JustTheTip-$version.zip"
if (Test-Path -LiteralPath $zipPath) {
    Remove-Item -LiteralPath $zipPath -Force
}

$zip = [System.IO.Compression.ZipFile]::Open($zipPath, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($name in $files) {
        $src = Join-Path $repo $name
        if (-not (Test-Path -LiteralPath $src)) {
            throw "Missing $name"
        }
        $entry = $zip.CreateEntry("JustTheTip/$name", [System.IO.Compression.CompressionLevel]::Optimal)
        $fileStream = [System.IO.File]::OpenRead($src)
        try {
            $entryStream = $entry.Open()
            try {
                $fileStream.CopyTo($entryStream)
            } finally {
                $entryStream.Dispose()
            }
        } finally {
            $fileStream.Dispose()
        }
    }
} finally {
    $zip.Dispose()
}

Write-Output $zipPath
