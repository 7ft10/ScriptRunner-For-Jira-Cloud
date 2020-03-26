Param(
    [Parameter(Mandatory = $true)]
    [bool]$IsReleaseBuild
)

function Show-Completed {
    param(
        [double]$Percentage,
        [string]$Title = "",
        [string]$Status = "Processing"
    )
    Write-Progress -Activity $Title -Status $Status -percentComplete $Percentage
    Write-Host "`r$([math]::floor($Percentage).ToString().PadLeft(3, " "))% Completed" -NoNewline
}

Write-Host "*******************************`r`n** Due to ScriptRunner's limitation of 32kb for 'Release' builds groovy scripts will be minified.`r`n*******************************`r`n" -ForegroundColor "Green"

Write-Host "Building " -NoNewline
Write-Host "All versions + Clients " -ForegroundColor "Green" -NoNewline
Write-Host "($(if ($IsReleaseBuild) { "Release" } else { "Debug" }))" -ForegroundColor "DarkMagenta"

Show-Completed -Percentage 1 -Title "Build" -Status "Creating Folders"

if (!(Test-Path -Path './obj/')) {
    New-Item -ItemType directory -Path './obj/'
}
if (!(Test-Path -Path './obj/release')) {
    New-Item -ItemType directory -Path './obj/release'
}
if (!(Test-Path -Path './obj/debug')) {
    New-Item -ItemType directory -Path './obj/debug'
}

if ($IsReleaseBuild) {
    Show-Completed -Percentage 5 -Title "Build" -Status "Cleaning"
    Get-ChildItem -Path './obj/release' -Include * -File -Recurse | ForEach-Object { $_.Delete() }

    Show-Completed -Percentage 10 -Title "Copying"
    Copy-Item -Path './src/*' -Destination './obj/release/' -Force -Recurse

    ## Minify
    $i = 0; $files = Get-ChildItem -Path './obj/release' -Include *.groovy -File -Recurse
    $files | ForEach-Object {
        & "./scripts/Minify-Groovy.ps1" -file $_
        Show-Completed -Percentage (10 + ($i++ / ($files.Count) * 100) * 0.9) -Title "Minifying" -Status "Joining dot line breaks in $($_.BaseName).$($_.Extension)"
    }
} else {
    Show-Completed -Percentage 33 -Title "Cleaning"
    Get-ChildItem -Path './obj/debug' -Include * -File -Recurse | ForEach-Object { $_.Delete() }

    Show-Completed -Percentage 66 -Title "Copying"
    Copy-Item -Path './src/*' -Destination './obj/debug/' -Force -Recurse
}

Show-Completed -Percentage 100 -Title "Build" -Status "Completed"