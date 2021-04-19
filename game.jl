struct Game
    date :: Date
    opponent :: String
    team_spi :: Float64
    opp_spi :: Float64
    team_score :: Float64
    opp_score :: Float64
end

function load_games(games_df :: DataFrame)
    games = Dict{String, Vector{Game}}()
    for row ∈ eachrow(games_df[:, :team1])
        games[row[1, 1]] = Vector{Game}()
    end

    for row ∈ eachrow(games_df[:, [:date, :team1, :team2, :spi1, :spi2, :xg1, :xg2, :score1, :score2]])
        if !ismissing(row[:xg1])
            push!(games[row[:team1]], Game(row[:date], row[:team2], row[:spi1], row[:spi2], row[:xg1], row[:xg2]))
            push!(games[row[:team2]], Game(row[:date], row[:team1], row[:spi2], row[:spi1], row[:xg2], row[:xg1]))
        end
    end
    return games
end

discounted_score(g :: Game) = (g.team_score - g.opp_score) * (g.opp_spi / g.team_spi)