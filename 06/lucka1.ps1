[CmdletBinding()]
param(
    [ValidateNotNull()]
    [String]$Path
)

$Data = Get-Content $Path
$Columns = $Data[0].Length
$Rows = $Data.Length

$Time = [long[]]((($Data[0] -split ":")[1]).trim() -split "\W+")
$Distance = [long[]]((($Data[1] -split ":")[1]).trim() -split "\W+")
$Wins = new-object long[] $Time.Count

Write-Debug ("Time: {0}" -f ($Time -join ","))
Write-Debug ("Distance: {0}" -f ($Distance -join ","))
Write-Debug ("Wins: {0}" -f ($Wins -join ","))

$Product = 1

for ([int]$Race = 0; $Race -lt $Time.Count; $Race++) {
    for ([int]$Push = 1; $Push -lt $Time[$Race]; $Push++) {
        $D = $Push * ($Time[$Race] - $Push)

        if ($D -gt $Distance[$Race]) {
            $Wins[$Race]+=1
        }
    }
    Write-Debug ("Wins: {0},{1}" -f $Race, $Wins[$Race])
    $Product *= $Wins[$Race]
}

Write-Debug ("Wins: {0}" -f ($Wins -join ","))
Write-Debug ("Product: {0}" -f $Product)
