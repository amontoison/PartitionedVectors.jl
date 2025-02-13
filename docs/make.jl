using Documenter, PartitionedVectors

makedocs(
  modules = [PartitionedVectors],
  doctest = true,
  # linkcheck = true,
  strict = true,
  format = Documenter.HTML(
    assets = ["assets/style.css"],
    prettyurls = get(ENV, "CI", nothing) == "true",
  ),
  sitename = "PartitionedVectors.jl",
  pages = Any["Home" => "index.md", "Tutorial" => "tutorial.md", "Reference" => "reference.md"],
)

deploydocs(
  repo = "github.com/JuliaSmoothOptimizers/PartitionedVectors.jl.git",
  push_preview = true,
  devbranch = "main",
)
