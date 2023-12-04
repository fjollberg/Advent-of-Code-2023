[CmdletBinding()]
param(
    [ValidateNotNull()]
    [String]$Path
)


Get-Content $Path | ForEach-Object {
    if (-not ($_ -match "Card\W*(?<nr>[0-9]+):\W*(?<winning>[0-9|\W]*)\W*\|\W*(?<draws>[0-9|\W]*)")) {
        throw "Bad expression"
    }
    $Draws = $Matches.draws.trim() -split "[^0-9]+" | Foreach-Object {[int]$_}
    $Winning = $Matches.winning.trim() -split "[^0-9]+" | Foreach-Object {[int]$_}

    Write-Debug ("Card {0}; winning: {1}; draws: {2}" -f $Matches.nr, ($Winning -join ","), ($Draws -join ","))

    $Points = 0
    foreach ($Draw in $Draws) {
        if ($Winning -contains $Draw) {
            if (-not $Points) {
                $Points = 1
            } else {
                $Points += $Points
            }
        }
    }
    $Sum += $Points
}

$Sum