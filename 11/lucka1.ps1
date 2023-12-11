[CmdletBinding()]
param(
    [ValidateNotNull()]
    [String]$Path
)

$Data = Get-Content $Path

$Data = Get-Content $Path

$Universe = @()

foreach ($line in $Data) {
    $Universe += , ($line.ToCharArray())
}

Write-Debug ("Universe:")
for ([int]$i = 0; $i -lt $Universe.Length; $i++) {
    Write-Debug ("{0}" -f ($Universe[$i] -join ''))
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

function Get-ExpandedUniverseByRow {
    param(
        [int]$Row,
        [char[][]]$Universe
    )

    for ([int]$r = 0; $r -lt $Row; $r++) {
        , $Universe[$r]
    }

    , ('.' * $Universe[0].Length).ToCharArray()

    for ([int]$r = $Row; $r -lt $Universe.Length; $r++) {
        , $Universe[$r]
    }
}


function Get-ExpandedUniverseByCol {
    param(
        [int]$Col,
        [char[][]]$Universe
    )

    $Length = $Universe[0].Length

    for ([int]$r = 0; $r -lt $Universe.Length; $r++) {
        , ($Universe[$r][0..$Col] + $Universe[$r][$Col..($Length-1)])
    }
}

for ([int]$i = 0; $i -lt $ExpandableRows.Length; $i++) {
    $Universe = Get-ExpandedUniverseByRow ($ExpandableRows[$i]+$i) $Universe
}

for ([int]$i = 0; $i -lt $ExpandableColumns.Length; $i++) {
    $Universe = Get-ExpandedUniverseByCol ($ExpandableColumns[$i]+$i) $Universe
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

[int[][]]$Stars = Get-Stars $Universe

for ([int]$i = 0; $i -lt $Stars.Length; $i++) {
    for ([int]$j = $i + 1; $j -lt $Stars.Length; $j++) {
        $Distanse += [Math]::Abs($Stars[$j][0] - $Stars[$i][0]) + [Math]::Abs($Stars[$j][1] - $Stars[$i][1])
    }
}

$Distanse
