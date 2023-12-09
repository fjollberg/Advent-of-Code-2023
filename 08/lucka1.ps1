[CmdletBinding()]
param(
    [ValidateNotNull()]
    [String]$Path
)

$Data = Get-Content $Path

$Sequence = $Data[0].ToCharArray()
$Map = @{}

Write-Debug ("Sequence {0}" -f ($Sequence -join ","))

for ([int]$i = 2; $i -lt $Data.Length; $i++) {
    $Data[$i] -match "^(?<pos>[A-Z]{3}) = \((?<L>[A-Z]{3}), (?<R>[A-Z]{3})\)$" | Out-Null
    Write-Debug ("Got {0} = {1},{2}" -f $Matches.pos, $Matches.L, $Matches.R)
    $Map[$Matches.pos] = @{
        L = $Matches.L
        R = $Matches.R
    }
}

$Steps = 0
$Position = 'AAA'

do {
    $Step = $Steps % $Sequence.Length

    $Direction = $Sequence[$Step]
    $Next = ($Map[$Position])[[string]$Direction]

    Write-Debug ("{0}, {1}: {2} Direction {3} -> {4}" -f $Steps, $Step, $Position, $Direction, $Next)

    $Steps++
    $Position = $Next

    if ($Position -eq 'ZZZ') {
        $Done = $true
    }
} while (-not $Done)

$Steps