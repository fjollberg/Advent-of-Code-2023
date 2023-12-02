[CmdletBinding()]
param(
    [ValidateNotNull()]
    [String]$Path,

    [int]$Red = 0,
    [int]$Green = 0,
    [int]$Blue = 0
)

function possibleRound($Round) {
    foreach ($ColorItem in ($Round -split ",").trim()) {
        Write-Information "ColorItem: $ColorItem"
        $Count, $Color = $ColorItem -split " "
        Write-Information "Color: $Count, $Color"
        switch ($Color) {
            "red" {
                if ([int]$Count -gt $Red) {
                    return $false
                }
            }
            "green" {
                if ([int]$Count -gt $Green) {
                    return $false
                }
            }
            "blue" {
                if ([int]$Count -gt $Blue) {
                    return $false
                }
            }
        }
    }

    return $true
}


function possibleGame($GameLine) {
    foreach ($Round in ($GameLine -split ";").trim()) {
        Write-Information "Round: $Round"
        if (-not (possibleRound $Round)) {
            return $false
        }
    }
    return $true
}


Get-Content $Path | ForEach-Object {
    $Line = $_

    $Line -match "^Game (?<id>[0-9]*):" | Out-Null
    $GameId = $Matches.id

    $GameLine = ($Line -split (":"))[1]
    if (possibleGame $GameLine) {
        Write-Information "Possible: $GameId $GameLine"
        $Sum += [int]$GameId
    }
}

$Sum