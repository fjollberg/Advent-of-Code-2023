[CmdletBinding()]
param(
    [ValidateNotNull()]
    [String]$Path,

    [ValidateSet(10,140)]
    [int]$RowLength = 10
)

$Data = (Get-Content $Path).ToCharArray()
$CurrentChar = 0

function AdjacentSymbol([int]$CurrentSymbol) {
    $Chars = $()

    if ($CurrentSymbol - $RowLength -lt 0) {
        # Första raden
        if ($CurrentSymbol % $RowLength -eq 0) {
            # Första kolumnen
            $Chars = $(
                $Data[$CurrentSymbol + 1],
                $Data[$CurrentSymbol + $RowLength],
                $Data[$CurrentSymbol + $RowLength + 1]
            )
        } elseif ($CurrentSymbol % $RowLength -eq ($RowLengt - 1)) {
            # Sita kolumnen
            $Chars = $(
                $Data[$CurrentSymbol - 1],
                $Data[$CurrentSymbol + $RowLength - 1],
                $Data[$CurrentSymbol + $RowLength]
            )
        } else {
            $Chars = $(
                $Data[$CurrentSymbol - 1],
                $Data[$CurrentSymbol + 1],
                $Data[$CurrentSymbol + $RowLength - 1],
                $Data[$CurrentSymbol + $RowLength],
                $Data[$CurrentSymbol + $RowLength + 1]
            )
        }
    } elseif ($CurrentSymbol + $RowLength -gt $Data.Count) {
        # Sista raden
        if ($CurrentSymbol % $RowLength -eq 0) {
            # Första kolumnen
            $Chars = $(
                $Data[$CurrentSymbol - $RowLength],
                $Data[$CurrentSymbol - $RowLength + 1],
                $Data[$CurrentSymbol + 1]
            )
        } elseif ($CurrentSymbol % $RowLength -eq ($RowLengt - 1)) {
            # Sita kolumnen
            $Chars = $(
                $Data[$CurrentSymbol - $RowLength - 1],
                $Data[$CurrentSymbol - $RowLength],
                $Data[$CurrentSymbol - 1]
            )
        } else {
            $Chars = $(
                $Data[$CurrentSymbol - $RowLength - 1],
                $Data[$CurrentSymbol - $RowLength],
                $Data[$CurrentSymbol - $RowLength + 1]
                $Data[$CurrentSymbol - 1],
                $Data[$CurrentSymbol + 1]
            )
        }
    } else {
        # Andra rader
        if ($CurrentSymbol % $RowLength -eq 0) {
            # Första kolumnen
            $Chars = $(
                $Data[$CurrentSymbol - $RowLength],
                $Data[$CurrentSymbol - $RowLength + 1],
                $Data[$CurrentSymbol + 1]
                $Data[$CurrentSymbol + $RowLength],
                $Data[$CurrentSymbol + $RowLength + 1]
            )
        } elseif ($CurrentSymbol % $RowLength -eq ($RowLengt - 1)) {
            # Sita kolumnen
            $Chars = $(
                $Data[$CurrentSymbol - $RowLength - 1],
                $Data[$CurrentSymbol - $RowLength],
                $Data[$CurrentSymbol - 1]
                $Data[$CurrentSymbol + $RowLength - 1],
                $Data[$CurrentSymbol + $RowLength]
            )
        } else {
            $Chars = $(
                $Data[$CurrentSymbol - $RowLength - 1],
                $Data[$CurrentSymbol - $RowLength],
                $Data[$CurrentSymbol - $RowLength + 1],
                $Data[$CurrentSymbol - 1]
                $Data[$CurrentSymbol + 1]
                $Data[$CurrentSymbol + $RowLength - 1],
                $Data[$CurrentSymbol + $RowLength],
                $Data[$CurrentSymbol + $RowLength + 1]
            )
        }
    }
    Write-Information "Adjacent: $Chars"
    -join $Chars -match "[^0-9\.]"
}

function NewLine([int]$CurrentChar) {
    return ($CurrentChar % $RowLength -eq 0)
}

function Reset() {
    return "", $false
}

foreach ($c in $Data) {

    if (NewLine $CurrentChar) {
        Write-Information "NewLine: $CurrentChar"
        if ($CurrentNumberString -and $Valid) {
            $Sum += [int]$CurrentNumberString
            Write-Information "Current: $CurrentNumberString, Sum $Sum"
        }

        $CurrentNumberString, $Valid = Reset
    }

    Write-Information "CurrentChar: $c"

    if ($c -match "[0-9]") {
        $CurrentNumberString += $c
        $Valid = $Valid -or (AdjacentSymbol $CurrentChar)
    } else {
        if ($CurrentNumberString -and $Valid) {
            $Sum += [int]$CurrentNumberString
            Write-Information "Current: $CurrentNumberString, Sum $Sum"
        }

        $CurrentNumberString, $Valid = Reset
    }
    $CurrentChar++
}

$Sum