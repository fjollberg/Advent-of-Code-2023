[CmdletBinding()]
param(
    [ValidateNotNull()]
    [String]$Path,

    [int]$Jump = 1
)

$MapsKeys = $(
    "humidity-to-location"
    "temperature-to-humidity"
    "light-to-temperature"
    "water-to-light"
    "fertilizer-to-water"
    "soil-to-fertilizer"
    "seed-to-soil"
)

$Data = Get-Content $Path

$ReverseMap = foreach ($MapKey in $MapsKeys) {
    $Key = $MapKey + " map:"
    $Index = $Data.IndexOf($Key)
    $Maps = $()

    While ($Data[++$Index]) {
        $DestRangeStart, $SourceRangeStart, $RangeLength = [long[]]($Data[$Index] -split " ")
        $Map = @{
            RangeStart = $DestRangeStart
            RangeEnd   = $DestRangeStart + $RangeLength
            Transform  = - ($DestRangeStart - $SourceRangeStart)
        }
        $Maps += , $($Map)
    }
    , $Maps
}

function Invoke-Map {
    param (
        [long]$Location
    )
    Foreach ($Map in $ReverseMap) {
        Foreach ($SubMap in $Map) {
            if ($Location -ge $SubMap.RangeStart -and $Location -le $SubMap.RangeEnd) {
                $Location += $SubMap.Transform
                break
            }
        }
    }
    $Location
}


function Test-Seed {
    param (
        [long]$Seed
    )
    Write-Debug ("Testing Seed: {0}" -f $Seed)
    for ([int]$i = 0; $i -lt $SeedsInput.Length; $i += 2) {
        if (($Seed -ge $Seeds[$i]) -and ($Seed -le ($Seeds[$i + 1]))) {
            return $true  
        }
    }
    return $false
}


$Data = Get-Content $Path
$SeedsInput = [long[]]((($Data[0] -split ":")[1]).trim() -split " ")
$Seeds = for ([int]$i = 0; $i -lt $SeedsInput.Length; $i += 2) {
    $SeedsInput[$i]
    $SeedsInput[$i] + $SeedsInput[$i + 1]
}
Write-Debug ("SeedsInput: {0}" -f ($SeedsInput -join ","))
Write-Debug ("Seeds: {0}" -f ($Seeds -join ","))


function Find-Seed {
    param (
        $Location,
        $Jump
    )
    while ($true) {
        Write-Debug ("Testing: {0}" -f $Location)
        $Seed = Invoke-Map $Location

        if (Test-Seed $Seed) {
            $Location
            break
        }
        $Iteration++
        $Location += $Jump
    }
}

do {
    $Location = Find-Seed $Location $Jump

    if ($Jump -eq 1 ) {
        break
    }
    else {
        $Location -= $Jump
        $Jump = $Jump / 2
        Write-Debug ("Restarting from {0} using jump {1}" -f $Location, $Jump)
    }
} while ($true)

$Location
