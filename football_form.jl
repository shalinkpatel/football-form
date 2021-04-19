module FootballForm

using Turing, CSV, Plots, StatsPlots, OnlineStats, DataFrames, DataFramesMeta, Dates, Pipe, ProgressMeter
Turing.setadbackend(:tracker)

include("data.jl")
include("game.jl")
include("model.jl")
include("util.jl")

export run_form_analysis, log_all_plots, load_games, load_league

end