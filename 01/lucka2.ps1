[CmdletBinding()]
param(
    [ValidateNotNull()]
    [String]$Path
)

function reverse([string]$str) {
    $RevA = $str.ToCharArray()
    [array]::Reverse($RevA)
    -join $RevA
}

function DigitTo-Int([string]$str) {
    switch -regex ($str) {
        "[0-9]" {
            [int]$str
            break
        }
        "one" {
            1
            break
        }
        "two" {
            2
            break
        }
        "three" {
            3
            break
        }
        "four" {
            4
            break
        }
        "five" {
            5
            break
        }
        "six" {
            6
            break
        }
        "seven" {
            7
            break
        }
        "eight" {
            8
            break
        }
        "nine" {
            9
            break
        }
    }    
}

$Digits = "one|two|three|four|five|six|seven|eight|nine"
$ReverseDigits = reverse $Digits

Get-Content $Path | ForEach-Object {
    $_ -match ("(?<digit>[1-9]|{0})" -f $Digits) | Out-Null
    $first = $Matches.digit

    $reverseline = reverse $_
    $reverseline -match ("(?<digit>[1-9]|{0})" -f $ReverseDigits) | Out-Null
    $last = reverse $Matches.digit

    $Sum += [int]("{0}{1}" -f (DigitTo-Int $first), (DigitTo-Int $last))
}

"Sum is {0}" -f $Sum