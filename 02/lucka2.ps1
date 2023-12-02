[CmdletBinding()]
param(
    [ValidateNotNull()]
    [String]$Path
)

function round([string]$Round, [int]$Red, [int]$Green, [int]$Blue) {
    Write-Information "Round: $Round"
    foreach ($ColorItem in ($Round -split ",").trim()) {
        Write-Information "ColorItem: $ColorItem"
        $Count, $Color = $ColorItem -split " "
        Write-Information "Color: $Count, $Color"
        switch ($Color) {
            "red" {
                if ([int]$Count -gt $Red) {
                    $Red = $Count
                }
            }
            "green" {
                if ([int]$Count -gt $Green) {
                    $Green = $Count
                }
            }
            "blue" {
                if ([int]$Count -gt $Blue) {
                    $Blue = $Count
                }
            }
        }
    }
    $Red, $Green, $Blue
}


function leastGame($GameLine) {
    Write-Information "Game: $GameLine"
    $Red, $Green, $Blue = 0, 0, 0

    foreach ($Round in ($GameLine -split ";").trim()) {
        $Red, $Green, $Blue = round $Round $Red $Green $Blue
        Write-Information "Least: $Red, $Green, $Blue"
    }
    $Red, $Green, $Blue 
}


Get-Content $Path | ForEach-Object {
    $Line = $_

    $Line -match "^Game (?<id>[0-9]*):" | Out-Null
    $GameId = $Matches.id

    $GameLine = ($Line -split (":"))[1]
    $Red, $Green, $Blue = leastGame $GameLine
    Write-Information "Least of Game: $Red, $Green, $Blue"
    $Power = $Red * $Green * $Blue
    Write-Information "Power: $Power"
    $Sum += $Power
}

$Sum
