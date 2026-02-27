using Documenter
using Buff

makedocs(;
    modules   = [Buff],
    sitename  = "Buff.jl",
    authors   = "Buff Contributors",
    format    = Documenter.HTML(;
        prettyurls = get(ENV, "CI", nothing) == "true",
        canonical  = "https://viallww.github.io/Buff",
    ),
    pages = [
        "Home"     => "index.md",
        "API"      => [
            "Outliers"     => "api/outliers.md",
            "Interpolate"  => "api/interpolate.md",
            "Filter"       => "api/filter.md",
            "LTTB"         => "api/lttb.md",
            "Upsample"     => "api/upsample.md",
            "Trend"        => "api/trend.md",
            "Plots"        => "api/plots.md",
        ],
    ],
)

deploydocs(;
    repo   = "github.com/viallww/Buff.git",
    target = "build",
    branch = "gh-pages",
    push_preview = true,
)
