using ImageNetDataset
using Documenter

DocMeta.setdocmeta!(
    ImageNetDataset, :DocTestSetup, :(using ImageNetDataset); recursive=true
)

makedocs(;
    modules=[ImageNetDataset],
    authors="Adrian Hill <gh@adrianhill.de>",
    sitename="ImageNetDataset.jl",
    format=Documenter.HTML(;
        canonical="https://adrhill.github.io/ImageNetDataset.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Installation" => "installation.md",
        "API Reference" => "api.md",
    ],
)

deploydocs(; repo="github.com/adrhill/ImageNetDataset.jl", devbranch="main")
