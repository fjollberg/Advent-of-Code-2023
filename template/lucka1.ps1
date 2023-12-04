[CmdletBinding()]
param(
    [ValidateNotNull()]
    [String]$Path
)

$Columns = (Get-Content $Path -ReadCount 1).Length
$Rows = (Get-Content $Path).Count
