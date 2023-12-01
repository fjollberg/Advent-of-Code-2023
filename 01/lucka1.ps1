[CmdletBinding()]
param(
    [ValidateNotNull()]
    [String]$Path
)

Get-Content $Path | ForEach-Object {
    $_ -match "^[a-z]*(?<first>[0-9])" | Out-Null
    $first = $Matches.first

    $_ -match "(?<last>[0-9])[a-z]*$" | Out-Null
    $last = $Matches.last

    $Sum += [int]("{0}{1}" -f $first, $last)
}

"Sum is {0}" -f $Sum