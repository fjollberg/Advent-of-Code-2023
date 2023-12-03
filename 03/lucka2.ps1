[CmdletBinding()]
param(
    [ValidateNotNull()]
    [String]$Path
)

function AdjacentStars([int]$CurrentSymbol) {
    $Positions = $()

    if ($CurrentSymbol - $RowLength -lt 0) {
        # Första raden
        if ($CurrentSymbol % $RowLength -eq 0) {
            # Första kolumnen
            $Positions = $(
                $CurrentSymbol + 1
                $CurrentSymbol + $RowLength
                $CurrentSymbol + $RowLength + 1
            )
        } elseif ($CurrentSymbol % $RowLength -eq ($RowLengt - 1)) {
            # Sita kolumnen
            $Positions = $(
                $CurrentSymbol - 1
                $CurrentSymbol + $RowLength - 1
                $CurrentSymbol + $RowLength
            )
        } else {
            $Positions = $(
                $CurrentSymbol - 1
                $CurrentSymbol + 1
                $CurrentSymbol + $RowLength - 1
                $CurrentSymbol + $RowLength
                $CurrentSymbol + $RowLength + 1
            )
        }
    } elseif ($CurrentSymbol + $RowLength -gt $Data.Count) {
        # Sista raden
        if ($CurrentSymbol % $RowLength -eq 0) {
            # Första kolumnen
            $Positions = $(
                $CurrentSymbol - $RowLength
                $CurrentSymbol - $RowLength + 1
                $CurrentSymbol + 1
            )
        } elseif ($CurrentSymbol % $RowLength -eq ($RowLengt - 1)) {
            # Sita kolumnen
            $Positions = $(
                $CurrentSymbol - $RowLength - 1
                $CurrentSymbol - $RowLength
                $CurrentSymbol - 1
            )
        } else {
            $Positions = $(
                $CurrentSymbol - $RowLength - 1
                $CurrentSymbol - $RowLength
                $CurrentSymbol - $RowLength + 1
                $CurrentSymbol - 1
                $CurrentSymbol + 1
            )
        }
    } else {
        # Andra rader
        if ($CurrentSymbol % $RowLength -eq 0) {
            # Första kolumnen
            $Positions = $(
                $CurrentSymbol - $RowLength
                $CurrentSymbol - $RowLength + 1
                $CurrentSymbol + 1
                $CurrentSymbol + $RowLength
                $CurrentSymbol + $RowLength + 1
            )
        } elseif ($CurrentSymbol % $RowLength -eq ($RowLengt - 1)) {
            # Sita kolumnen
            $Positions = $(
                $CurrentSymbol - $RowLength - 1
                $CurrentSymbol - $RowLength
                $CurrentSymbol - 1
                $CurrentSymbol + $RowLength - 1
                $CurrentSymbol + $RowLength
            )
        } else {
            $Positions = $(
                $CurrentSymbol - $RowLength - 1
                $CurrentSymbol - $RowLength
                $CurrentSymbol - $RowLength + 1
                $CurrentSymbol - 1
                $CurrentSymbol + 1
                $CurrentSymbol + $RowLength - 1
                $CurrentSymbol + $RowLength
                $CurrentSymbol + $RowLength + 1
            )
        }
    }
    Write-Debug "Adjacent Positions: $Positions"
    foreach ($Position in $Positions) {
        if ($Data[$Position] -eq '*') {
            $Position
        }
    }
}

function NewLine([int]$CurrentChar) {
    return ($CurrentChar % $RowLength -eq 0)
}

function Reset() {
    return "", $false, @()
}

$RowLength = (Get-Content $Path -ReadCount 1).Length

$Data = (Get-Content $Path).ToCharArray()
$CurrentChar = 0
$StarPositions = @()
$Stars = @{}

foreach ($c in $Data) {
    Write-Debug "CurrentChar: $c"

    if (($c -match "[^0-9]") -or (NewLine $CurrentChar)) {
        if ($CurrentNumberString) {
            Write-Information "Current: $CurrentNumberString"
            Write-Information ("Adjacent Stars: $StarPositions")
            $StarPositions | Sort-Object -Unique | ForEach-Object {
                $Stars[$_] += , [int]$CurrentNumberString
            }
        }

        $CurrentNumberString, $Valid, $StarPositions = Reset
    }

    if ($c -match "[0-9]") {
        $CurrentNumberString += $c
        $StarPositions += , (AdjacentStars $CurrentChar)
    }

    $CurrentChar++
}

$Stars

Foreach ($Star in $Stars.Keys) {
    if ($Stars[$Star].Count -eq 2) {
        $GearRatio = $Stars[$Star][0] * $Stars[$Star][1]
        $Sum += $GearRatio
    }
}

$Sum