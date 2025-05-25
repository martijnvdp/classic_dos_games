param([string]$GAME)

Function Read-Choice {
    param(
        [Parameter(Mandatory = $true)]
        $Options,
        [string]$Prompt = "Make a selection"
    )
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host "  " -NoNewline
        Write-Host ($i + 1) -NoNewline -ForegroundColor Green
        Write-Host ". $($Options[$i])"
    }
    do {
        $answer = Read-Host -Prompt $Prompt
        if ($answer -match '^\d+$' -and $answer -ge 1 -and $answer -le $Options.Count) {
            return $Options[$answer - 1]
        }
        Write-Host "Invalid choice '$answer'. Please try again or press Ctrl+C to quit." -ForegroundColor Yellow
    } while ($true)
}
$dockerfile = "Dockerfile"
$games = Get-Content .\games.json | ConvertFrom-Json

if (!$GAME) {
    $GAME = Read-Choice -Options $games.PSObject.Properties.Name
}

$selected_game = $games.($GAME)
if ($selected_game.GAME_URL.Contains("local:")) {
    $dockerfile = "Dockerfile.local"
}

docker build `
    --no-cache `
    --build-arg GAME_URL=$($selected_game.GAME_URL -replace "local:") `
    --build-arg GAME_ARGS=$($selected_game.GAME_ARGS) `
    --build-arg GAME_DIR=$($selected_game.GAME_DIR) `
    --build-arg GAME_NAME=$($GAME) `
    -f $dockerfile `
    -t $GAME .

docker run --name $GAME -d -p 8000:8000 --rm $GAME
Write-Output "open game http://localhost:8000"
Start-Process "http://localhost:8000"
read-host “Pres any key to exit game”
docker stop $GAME
