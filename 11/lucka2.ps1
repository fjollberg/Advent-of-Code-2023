[CmdletBinding()]
param(
    [ValidateNotNull()]
    [String]$Path,

    $Count = 1
)

$Data = Get-Content $Path

$Universe = @()

foreach ($line in $Data) {
    $Universe += , ($line.ToCharArray())
}

Write-Debug ("Universe:")
for ([int]$i = 0; $i -lt $Universe.Length; $i++) {
    Write-Debug ("{0}" -f ($Universe[$i] -join ''))
}


function Get-Stars {
    param (
        [char[][]]$Universe
    )

    for ([int]$r = 0; $r -lt $Universe.Length; $r++) {
        for ([int]$c = 0; $c -lt $Universe[0].Length; $c++) {
            if ($Universe[$r][$c] -eq [char]'#') {
                , ($r, $c)
            }
        }
    }
}


function Get-Distance {
    param (
        [int[][]]$Stars
    )
    for ([int]$i = 0; $i -lt $Stars.Length; $i++) {
        for ([int]$j = $i + 1; $j -lt $Stars.Length; $j++) {
            $Distance += [Math]::Abs($Stars[$j][0] - $Stars[$i][0]) + [Math]::Abs($Stars[$j][1] - $Stars[$i][1])
        }
    }
    $Distance
}

function Test-Expandable {
    param (
        [char[]]$CharArray
    )
    $Reduce = $CharArray | Sort-Object -Unique
    ($Reduce.Length -eq 1) -and ($Reduce[0] -eq [char]'.')
}


$ExpandableRows = for ([int]$r = 0; $r -lt $Universe.Length; $r++) {
    if (Test-Expandable $Universe[$r]) {
        $r        
    }
}

$ExpandableColumns = for ([int]$c = 0; $c -lt $Universe[0].Length; $c++) {
    $Column = for ([int]$r = 0; $r -lt $Universe.Length; $r++) {
        $Universe[$r][$c]
    }

    if (Test-Expandable $Column) {
        $c
    }
}

Write-Debug ("Expandable Rows: {0} Columns: {1}" -f ($ExpandableRows -join ','), ($ExpandableColumns -join ','))

$OriginalDistance = Get-Distance (Get-Stars $Universe)

function Get-ExpandedUniverseByRow {
    param(
        [int]$Row,
        [char[][]]$Universe,
        $Steps
    )

    $Universe[0..($Row)]

    while ($Steps--) {
        , ('.' * $Universe[0].Length).ToCharArray()
    }

    $Universe[($Row + 1)..($Universe.Length-1)]
}


function Get-ExpandedUniverseByCol {
    param(
        [int]$Col,
        [char[][]]$Universe,
        $Steps 
    )

    $Length = $Universe[0].Length

    for ([int]$r = 0; $r -lt $Universe.Length; $r++) {
        , ($Universe[$r][0..($Col-1)] + ('.' * (1+$Steps)).ToCharArray() + $Universe[$r][($Col+1)..($Length-1)])
    }
}

$Steps = 1

for ([int]$i = 0; $i -lt $ExpandableRows.Length; $i++) {
    $Universe = Get-ExpandedUniverseByRow ($ExpandableRows[$i]+($Steps*$i)) $Universe $Steps
}

for ([int]$i = 0; $i -lt $ExpandableColumns.Length; $i++) {
    $Universe = Get-ExpandedUniverseByCol ($ExpandableColumns[$i]+($Steps*$i)) $Universe $Steps
}

$NewDistance = Get-Distance (Get-Stars $Universe)

#
# Note: Empirical testing shows that distance increase linearly to expansion.
#
($NewDistance - $OriginalDistance) * ($Count - 1) + $OriginalDistance