function log_all_plots(results :: Dict{String, Pair}, games :: Dict{String, Vector{Game}}, league_name :: String)
    teams = [team for team ∈ keys(games)]
    gr()
    for team ∈ teams
        plot(map(x -> x.date, games[team]), results[team].first, ribbon=2 .* results[team].second, fillalpha=0.15, legend=false, title="$(team) Form", xlabel="Matches", ylabel="Form Index", size=(1000,500))
        savefig("form/$(league_name)/$(team)_form.png")
    end

    plt = plot(size = (2000, 1000), legend=:outertopright, title="Form Comparison $(league_name)", xlabel="Matches", ylabel="Form Index")
    for team ∈ teams
        plot!(plt, map(x -> x.date, games[team]), results[team].first, ribbon=2 .* results[team].second, fillalpha=0.15, labels=team)
    end
    savefig("form/$(league_name)/all_form.png")

    plotly()
    plt = plot(size = (1500, 750), legend=:outertopright, title="Form Comparison $(league_name)", xlabel="Matches", ylabel="Form Index")
    for team ∈ teams
        plot!(plt, map(x -> x.date, games[team]), results[team].first, ribbon=2 .* results[team].second, fillalpha=0.15, labels=team)
    end
    display(plt)
    savefig(plt, "form/$(league_name)/all_form.html")
    savefig(plt, "docs/all_form_$(replace(league_name, " " => "")).html")
end