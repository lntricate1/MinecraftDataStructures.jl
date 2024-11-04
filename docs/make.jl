using MinecraftDataStructures
using Documenter

DocMeta.setdocmeta!(MinecraftDataStructures, :DocTestSetup, :(using MinecraftDataStructures); recursive=true)

makedocs(;
    modules=[MinecraftDataStructures],
    authors="contributors",
    sitename="MinecraftDataStructures.jl",
    format=Documenter.HTML(;
        canonical="https://lntricate1.github.io/MinecraftDataStructures.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/lntricate1/MinecraftDataStructures.jl",
    devbranch="main",
)
