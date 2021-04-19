function load_league(league :: String)
    mkpath("form/$league")
    df = CSV.File(download("https://projects.fivethirtyeight.com/soccer-api/club/spi_matches.csv")) |> DataFrame
    return @linq df |> where(:league .== league)
end