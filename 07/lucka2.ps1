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
        If (-Not($that -is [Hand])) {
            Throw "Not comparable!!"
        }

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
        'J' {1; break}
        'T' {10; break}
        'Q' {11; break}
        'K' {12; break}
        'A' {13; break}
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

    if (($Groups.Length -eq 1) -or (-not ($Groups.name -contains 'J'))) {
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
    } else {
        $OtherCards = $Groups | Where-Object -Property Name -NE -Value 'J' | Sort-Object -Property Count -Descending

        Write-Debug ("Found other cards: {0} in {1}" -f ($OtherCards.Name -join ','), $Cards)

        switch ($OtherCards[0].Count) {
            {$_ -ge 3} {
                Get-Hand ($Cards -replace 'J', $OtherCards[0].Name)
                break;
            }
            default {
                $Max = $OtherCards[0]
                Foreach ($Group in ($OtherCards | Where-Object -Property Count -EQ $OtherCards[0].Count)) {
                    if ((Get-Value $Group.Name) -gt (Get-Value $Max.Name)) {
                        $Max = $Group                        
                    }
                }
                Get-Hand ($Cards -replace 'J', $Max.Name)
                break
            }
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
