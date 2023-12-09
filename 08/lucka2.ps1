[CmdletBinding()]
param(
    [ValidateNotNull()]
    [String]$Path,

    [int]$Stop
)


function Get-LCMofArray {
    param (
        [long[]]$Numbers
    )

    if ($Numbers.Length -eq 2) {
        Get-LCM $Numbers[0] $Numbers[1]
    } else {
        Get-LCM $Numbers[0] (Get-LCMofArray $Numbers[1..($Numbers.Length-1)])
    }
}


function Get-LCM {
    param (
        [long]$A,
        [long]$B
    )
    
    ($A * $B) / (Get-GCD $A $B)
}


function Get-GCD {
    param (
        [long]$A,
        [long]$B
    )
    while ($B) {
        $X = $B
        $B = ($A % $B)
        $A = $X
    }
    $A
}


$Data = Get-Content $Path

$Sequence = $Data[0].ToCharArray()
$Map = @{}
$Positions = [System.Collections.ArrayList]::new()

Write-Debug ("Sequence {0}" -f ($Sequence -join ","))
Write-Debug ("Sequence Length {0}" -f $Sequence.Count)

for ([int]$i = 2; $i -lt $Data.Length; $i++) {
    $Data[$i] -match "^(?<pos>\w{3}) = \((?<L>\w{3}), (?<R>\w{3})\)$" | Out-Null
    Write-Debug ("Got {0} = {1},{2}" -f $Matches.pos, $Matches.L, $Matches.R)

    $Map[$Matches.pos] = @{
        L = $Matches.L
        R = $Matches.R
    }

    if (($Matches.pos).EndsWith("A")) {
        $Positions += $Matches.pos
    }
}

Write-Debug ("Starting positions {0}" -f ($Positions -join ","))

$Numbers = foreach ($Position in $Positions) {
    $Step = 0

    Write-Debug ("Starting with {0}" -f $Position)

    while ($true) {
        $Direction = $Sequence[$Step++ % $Sequence.Length]
        $Position = ($Map[$Position])[[string]$Direction]
    
        if ($Position.EndsWith('Z')) {
            Write-Debug ("Ending with {0}" -f $Position)
            $Step
            break
        }
    }
}

Write-Debug ("Ending positions {0}" -f ($Positions -join ","))

Write-Debug ("Got Numbers {0}" -f ($Numbers -join ","))

# The path for these maps and starting points are repetetive.
# Not sure why, actually, just noted they are.
# Hence we can derive the number from the least common multiple,
# once I implemented an algorithm efficient enough.
Get-LCMofArray $Numbers