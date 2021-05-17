using VectorizedStatistics
using Documenter

DocMeta.setdocmeta!(VectorizedStatistics, :DocTestSetup, :(using VectorizedStatistics); recursive=true)

makedocs(;
    modules=[VectorizedStatistics],
    authors="C. Brenhin Keller",
    repo="https://github.com/brenhinkeller/VectorizedStatistics.jl/blob/{commit}{path}#{line}",
    sitename="VectorizedStatistics.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://brenhinkeller.github.io/VectorizedStatistics.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/brenhinkeller/VectorizedStatistics.jl",
    devbranch = "main",
)
