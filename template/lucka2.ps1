[CmdletBinding()]
param(
    [ValidateNotNull()]
    [String]$Path
)

$RowLength = (Get-Content $Path -ReadCount 1).Length

