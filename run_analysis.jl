include("football_form.jl")
using ..FootballForm

leagues = [
    "Barclays Premier League",
    "French Ligue 1",
    "German Bundesliga",
    "Italy Serie A",
    "Spanish Primera Division",
    "UEFA Champions League",
    "UEFA Europa League"
]

for league ∈ leagues
    games = load_league(league) |> load_games
    results = run_form_analysis(games)
    log_all_plots(results, games, league)
end

run(`git add -A`)
run(`git commit -a -m "Finished Run"`)
run(`git push`)