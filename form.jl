using Turing, CSV, Plots, StatsPlots, OnlineStats, DataFrames, DataFramesMeta, Dates, Pipe, ProgressMeter, Zygote
Turing.setadbackend(:tracker)

league_name = "UEFA Europa League"
mkpath("form/$(league_name)")
df = CSV.File(download("https://projects.fivethirtyeight.com/soccer-api/club/spi_matches.csv")) |> DataFrame
league = @linq df |> where(:league .== league_name)

struct Game
    date :: Date
    opponent :: String
    team_spi :: Float64
    opp_spi :: Float64
    team_score :: Float64
    opp_score :: Float64
end

games = Dict{String, Vector{Game}}()
for row ∈ eachrow(league[:, :team1])
    games[row[1, 1]] = Vector{Game}()
end

for row ∈ eachrow(league[:, [:date, :team1, :team2, :spi1, :spi2, :xg1, :xg2, :score1, :score2]])
    if !ismissing(row[:xg1])
        push!(games[row[:team1]], Game(row[:date], row[:team2], row[:spi1], row[:spi2], row[:xg1], row[:xg2]))
        push!(games[row[:team2]], Game(row[:date], row[:team1], row[:spi2], row[:spi1], row[:xg2], row[:xg1]))
    end
end

discounted_score(g :: Game) = (g.team_score - g.opp_score) * (g.opp_spi / g.team_spi)

@model form_model(y :: Vector{Float64}) = begin
    N = length(y)
    s = Vector(undef, N)

    start ~ Uniform(-1, 1)

    s[1] ~ Normal(start, 0.05)
    y[1] ~ Normal(s[1], 0.5)

    for i ∈ 2:N
        s[i] ~ Normal(s[i-1], 0.05)
        y[i] ~ Normal(s[i], 0.5)
    end
end

results = Dict{String, Pair}()
teams = [team for team ∈ keys(games)]
pbar = Progress(length(teams))
Threads.@threads for team ∈ teams
    N = 500

    g = NUTS()
    samples = sample(form_model(discounted_score.(games[team])), g, N);

    s = @pipe describe(group(samples, :s))[1][:, :mean] |> vec
    s_σ = @pipe describe(group(samples, :s))[1][:, :std] |> vec

    results[team] = Pair(s, s_σ)
    next!(pbar)
end

gr()
for team ∈ teams
    plot(map(x -> x.date, games[team]), results[team].first, ribbon=2 .* results[team].second, fillalpha=0.15, legend=false, title="$(team) Form", xlabel="Matches", ylabel="Form Index", size=(1000,500))
    savefig("form/$(league_name)/$(team)_form.png")
end

plt = plot(size = (2000, 1000), legend=:outertopright, title="Form Comparison $(league_name)", xlabel="Matches", ylabel="Form Index")
for team ∈ teams
    plot!(plt, map(x -> x.date, games[team]), results[team].first, ribbon=2 .* results[team].second, fillalpha=0.15, labels=team)
end
display(plt)
savefig("form/$(league_name)/all_form.png")

plotlyjs()
plt = plot(size = (1500, 750), legend=:outertopright, title="Form Comparison $(league_name)", xlabel="Matches", ylabel="Form Index")
for team ∈ teams
    plot!(plt, map(x -> x.date, games[team]), results[team].first, ribbon=2 .* results[team].second, fillalpha=0.15, labels=team)
end
display(plt)
savefig("form/$(league_name)/all_form.html")
savefig("docs/all_form_$(replace(league_name, " " => "")).html")