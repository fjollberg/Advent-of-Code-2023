[CmdletBinding()]
param(
    [ValidateNotNull()]
    [String]$Path
)


enum Hands {
    HighCard
    OnePair
    TwoPair
    ThreeOfAKind
    FullHouse
    FourOfAKind
    FiveOfAKind
}


class Hand : System.IComparable {
    [string]$Cards
    [Hands]$Hand
    [int]$Bid

    Hand([string]$Cards, [int]$Bid) {
        $this.Cards = $Cards
        $this.Bid = $Bid
        $this.Hand = Get-Hand $Cards
    }

    [int] CompareTo($that) {
        if ($this.Hand -ne $that.Hand) {
            return $this.Hand - $that.Hand            
        }

        for ([int]$i = 0; $i -lt $this.Cards.Length; $i++) {
            if ($this.Cards[$i] -ne $that.Cards[$i]) {
                return (Get-Value $this.Cards[$i]) - (Get-Value $that.Cards[$i])
            }
        }
        return 0
    }

    [string] ToString() {
        return $this.Cards
    }
}


function Get-Value {
    param (
        [string]$Card
    )
    switch -exact ($Card) {
        'T' {10; break}
        'J' {11; break}
        'Q' {12; break}
        'K' {13; break}
        'A' {14; break}
        default {
            [int]$Card
        }
    }
}


function Get-Hand {
    param (
        [string]$Cards
    )
    $Groups = $Cards.ToCharArray() | Group-Object
    switch -exact ($Groups.Length) {
        5 {
            [Hands]::HighCard
            break
        }
        4 {
            [Hands]::OnePair
            break
        }
        3 {
            if ($Groups | Where-Object {$_.Count -eq 3}) {
                [Hands]::ThreeOfAKind
            } else {
                [Hands]::TwoPair
            }
            break
        }
        2 {
            if ($Groups | Where-Object {$_.Count -eq 4}) {
                [Hands]::FourOfAKind
            } else {
                [Hands]::FullHouse
            }
            break
        }
        1 {
            [Hands]::FiveOfAKind
            break
        }
    }
}


Get-Content $Path | Foreach-Object {
    $Deal, $Bid = $_ -split "\W+"
    New-Object -TypeName Hand -ArgumentList $Deal, $Bid
} | Sort-Object | Foreach-Object {
    $Rank++
    $TotalWinnings += $Rank * $_.Bid
}

$TotalWinnings
