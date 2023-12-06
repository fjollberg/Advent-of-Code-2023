[CmdletBinding()]
param(
    [ValidateNotNull()]
    [String]$Path
)

$Data = Get-Content $Path
$Seeds = [long[]]((($Data[0] -split ":")[1]).trim() -split " ")

Write-Debug ("Seeds: {0}" -f ($Seeds -join ","))

function Invoke-Map {
    param (
        [string]$Map,
        [long[]]$Seeds
    )
    $Key = $Map + " map:"
 
    Foreach ($Point in $Seeds) {
        $Res = $false

        $Index = $Data.IndexOf($Key)
        While ($Data[++$Index]) {
            $DestRangeStart, $SourceRangeStart, $RangeLength = [long[]]($Data[$Index] -split " ")
            Write-Debug ("{0} {1}: {2},{3},{4}" -f $Map, $Index, $SourceRangeStart, $DestRangeStart, $RangeLength)

            if ($Point -ge $SourceRangeStart -and ($Point -le ($SourceRangeStart + $RangeLength))) {
                $Res = $DestRangeStart + ($Point - $SourceRangeStart)
                Write-Debug ("Found {0} -> {1}" -f $Point, $Res)
                break
            }
        }
        if ($Res) {
            $Res
        } else {
            $Point
        }
    }
}

$Seeds = Invoke-Map "seed-to-soil" $Seeds
$Seeds = Invoke-Map "soil-to-fertilizer" $Seeds
$Seeds = Invoke-Map "fertilizer-to-water" $Seeds
$Seeds = Invoke-Map "water-to-light" $Seeds
$Seeds = Invoke-Map "light-to-temperature" $Seeds
$Seeds = Invoke-Map "temperature-to-humidity" $Seeds
$Seeds = Invoke-Map "humidity-to-location" $Seeds

($Seeds | Sort-Object)[0]
