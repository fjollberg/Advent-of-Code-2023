[CmdletBinding()]
param(
    [ValidateNotNull()]
    [String]$Path
)

$Data = Get-Content $Path
$Columns = $Data[0].length
$Rows = $Data.length
