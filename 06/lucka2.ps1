[CmdletBinding()]
param(
    [ValidateNotNull()]
    [String]$Path
)

$Data = Get-Content $Path

$Time = [long]((($Data[0] -split ":")[1]).trim() -replace "\W+", "")
$Distance = [long]((($Data[1] -split ":")[1]).trim() -replace "\W+", "")

Write-Debug ("Time: {0}" -f ($Time -join ","))
Write-Debug ("Distance: {0}" -f ($Distance -join ","))

for ([int]$Push = 1; $Push -lt $Time; $Push++) {
    if (($Push * ($Time - $Push)) -gt $Distance) {
        $Wins++
    }
}

$Wins
