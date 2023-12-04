[CmdletBinding()]
param(
    [ValidateNotNull()]
    [String]$Path
)


function Get-Wins {
    param (
        [int]$ScratchCard
    )
    process {
        $Count = 0
        foreach ($Draw in $Data[$ScratchCard].Draws) {
            if ($Data[$ScratchCard].Winning -contains $Draw) {
                $Count++
            }
        }
        Write-Debug ("Wins {0}: {1}" -f $ScratchCard, $Count)
        $Count
    }
}

function Get-ScratchCards {
    param (
        [int]$ScratchCard
    )
    process {
        if (-not $Data[$ScratchCard].Done) {
            Write-Debug "Calculating $ScratchCard"

            $Data[$ScratchCard].Wins = 1
            $Wins = Get-Wins $ScratchCard

            for ([int]$i = 0; $i -lt $Wins; $i++) {
                $Data[$ScratchCard].Wins += Get-ScratchCards ($ScratchCard + $i + 1)
            }

            $Data[$ScratchCard].Done = $true
        }
        $Data[$ScratchCard].Wins
    }
}


$Data = [Object[]]::new((Get-Content $Path).Count+1)

Get-Content $Path | ForEach-Object {
    if (-not ($_ -match "Card\W*(?<nr>[0-9]+):\W*(?<winning>[0-9|\W]*)\W*\|\W*(?<draws>[0-9|\W]*)")) {
        throw "Bad expression"
    }
    $Draws = $Matches.draws.trim() -split "[^0-9]+" | Foreach-Object {[int]$_}
    $Winning = $Matches.winning.trim() -split "[^0-9]+" | Foreach-Object {[int]$_}

    Write-Debug ("Card {0}, winning: {1}, draws: {2}" -f $Matches.nr, ($Winning -join ","), ($Draws -join ","))

    $Data[[int]$Matches.nr] = @{
        Draws = $Draws
        Winning = $Winning
        Wins = 0
        Done = $False
    }
}

for ($i = 1; $i -lt $Data.Length; $i++) {
    $Sum += Get-ScratchCards $i
}

$Sum