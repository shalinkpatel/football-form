@model function form_model(y :: Vector{Float64})
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

function run_form_analysis(games :: Dict{String, Vector{Game}})
    results = Dict{String, Pair}()
    teams = [team for team ∈ keys(games)]
    pbar = Progress(length(teams))
    Threads.@threads for team ∈ teams
        N = 100
        g = NUTS()
        samples = sample(form_model(discounted_score.(games[team])), g, N);

        s = @pipe describe(group(samples, :s))[1][:, :mean] |> vec
        s_σ = @pipe describe(group(samples, :s))[1][:, :std] |> vec

        results[team] = Pair(s, s_σ)
        next!(pbar)
    end
    return results
end