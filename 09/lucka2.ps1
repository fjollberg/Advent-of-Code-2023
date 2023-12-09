[CmdletBinding()]
param(
    [ValidateNotNull()]
    [String]$Path,

    [int]$Stop = 0
)

$Data = Get-Content $Path

function Get-Next {
    param (
        [int[]]$Sequence
    )

    Write-Debug ("Sequence: {0}" -f ($Sequence -join " "))

    if (($Sequence | Sort-Object -Unique).Count -eq 1) {
        $Sequence[0]
    } else {
        $NewSequence = for ([int]$i = 1; $i -lt $Sequence.Length; $i++) {
            $Sequence[$i] - $Sequence[$i-1]
        }
        $Sequence[0] - (Get-Next $NewSequence)
    }
}

foreach ($line in $Data) {
    $Next = Get-Next ($line -split " +")
    Write-Debug ("line: {0}, next {1}" -f (1+$i++), $Next)
    $Sum += $Next
    if ($Stop -and $i -gt $Stop) {
        break
    }
}

$Sum
