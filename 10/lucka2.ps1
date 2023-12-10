[CmdletBinding()]
param(
    [ValidateNotNull()]
    [String]$Path
)

$Data = Get-Content $Path
$Cols = $Data[0].length
$Rows = $Data.length

$Tiles = @()

foreach ($line in $Data) {
    $Tiles += , ($line.ToCharArray())
}

Write-Debug ("Tiles:")
for ([int]$i = 0; $i -lt $Tiles.Length; $i++) {
    Write-Debug ("{0}" -f ($Tiles[$i] -join ''))
}

$Slabs = @()
for ([int]$i = 0; $i -lt $Tiles.Length; $i++) {
    $Slabs += ,(' ' * $Tiles[0].Length).ToCharArray()
}


function Get-NextCoordinate {
    param (
        [int]$PrevRow,
        [int]$PrevCol,
        [int]$ThisRow,
        [int]$ThisCol
    )
    $Tile = $Tiles[$Thisrow][$ThisCol]

    switch -exact ($Tile) {
        '|' {
            if ($PrevRow -lt $ThisRow) {
                ($ThisRow + 1), $ThisCol
            } else {
                ($ThisRow - 1), $ThisCol
            }
            break
        }
        '-' {
            if ($PrevCol -lt $ThisCol) {
                $ThisRow, ($ThisCol + 1)
            } else {
                $ThisRow, ($ThisCol - 1)
            }
            break
        }
        'L' {
            if ($PrevRow -eq $ThisRow) {
                ($ThisRow - 1), $ThisCol
            } else {
                $ThisRow, ($ThisCol + 1)
            }
            break
        }
        'J' {
            if ($PrevRow -eq $ThisRow) {
                ($ThisRow - 1), $ThisCol
            } else {
                $ThisRow, ($ThisCol - 1)
            }
            break
        }
        '7' {
            if ($PrevRow -eq $ThisRow) {
                ($ThisRow + 1), $ThisCol
            } else {
                $ThisRow, ($ThisCol - 1)
            }
            break
        }
        'F' {
            if ($PrevRow -eq $ThisRow) {
                ($ThisRow + 1), $ThisCol
            } else {
                $ThisRow, ($ThisCol + 1)
            }
            break
        }
        'S' {
            -1, -1
        }
        '.' {
            throw "Out of bounds"
        }
    }
}

function Find-Start {
    for ([int]$i = 0; $i -lt $Tiles.Length; $i++) {
        if ($Tiles[$i] -contains 'S') {
            $i, ($Tiles[$i]).IndexOf([char]'S')
            break
        }
    }
}

function Find-Path {
    param (
        [int]$CurrentRow,
        [int]$CurrentCol
    )

    Write-Debug ("Current point {0},{1}" -f $CurrentRow, $CurrentCol)

    $NextRow, $NextCol = 
        if ($Tiles[$CurrentRow][$CurrentCol + 1] -in "-7J".ToCharArray()) {
            $CurrentRow, ($CurrentCol + 1)
        } elseif ($Tiles[$CurrentRow][$CurrentCol - 1] -in "-FL".ToCharArray()) {
            $CurrentRow, ($CurrentCol - 1)
        } elseif ($Tiles[$CurrentRow-1][$CurrentCol] -in "|F7".ToCharArray()) {
            ($CurrentRow - 1), $CurrentCol
        } elseif ($Tiles[$CurrentRow+1][$CurrentCol] -in "|LJ".ToCharArray()) {
            ($CurrentRow + 1), $CurrentCol
        } else {
            throw "Error"
        }    

    Write-Debug ("Next point: {0},{1}" -f $NextRow, $NextCol)

    $Tiles[$CurrentRow][$CurrentCol]
    $Tiles[$NextRow][$NextCol]
    $Slabs[$CurrentRow][$CurrentCol] = $Tiles[$CurrentRow][$CurrentCol]
    $Slabs[$NextRow][$NextCol] = $Tiles[$NextRow][$NextCol]

    while ($true) {
        $R, $C = Get-NextCoordinate $CurrentRow $CurrentCol $NextRow $NextCol
        if ($R -lt 0) {
            break
        }
        $Tiles[$R][$C]
        $Slabs[$R][$C] = $Tiles[$R][$C]
        $CurrentRow, $CurrentCol = $NextRow, $NextCol
        $NextRow, $NextCol = $R, $C
    }
}

[int]$StartRow, [int]$StartCol = Find-start

Write-Debug ("Starting point: {0},{1}" -f $StartRow, $StartCol)

[char[]]$Path = Find-Path $StartRow $StartCol

Write-Debug ("Slabs:")
for ([int]$i = 0; $i -lt $Slabs.Length; $i++) {
    Write-Debug ("{0}" -f ($Slabs[$i] -join ''))
}


function Test-Contained {
    param (
        [int]$Row,
        [int]$Col
    )

    $Segments = 0
    for ([int]$i = 0; $i -lt $Col; $i++) {

        #
        # Note: This is just because I can visually confirm that 'S'
        # corresponds to a vertical bar in my input. Your mileage may
        # vary.
        #

        if ($Slabs[$Row][$i] -in '|S'.ToCharArray()) {
                $Segments++
        } elseif ($Slabs[$Row][$i] -in 'FL'.ToCharArray()) {
            [char]$prev = $Slabs[$Row][$i]
            while (-not ($Slabs[$Row][$i] -in 'J7'.ToCharArray())) {
                $i++
            }
            if ((($prev, $Slabs[$Row][$i]) -join '') -in ('FJ', 'L7')) {
                $Segments++
            }
        }
    }
    $Segments % 2 -ne 0
}

for ([int]$i = 0; $i -lt $Tiles.Length; $i++) {
    Write-Debug ("Pondering: {0}" -f ($Tiles[$i] -join ''))
    Write-Debug ("Slab:      {0}" -f ($Slabs[$i] -join ''))
    for ([int]$t = 0; $t -lt $Tiles[0].Length; $t++) {
        if (($Slabs[$i][$t] -eq [char]' ')) {
            if (Test-Contained $i $t) {
                $Count+=1
                Write-Debug ("Found {0},{1} count {2}" -f $i, $t, $Count)
            }
        }
    }        
}

$Count