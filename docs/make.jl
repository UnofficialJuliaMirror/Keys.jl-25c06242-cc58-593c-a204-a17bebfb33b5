import Documenter

Documenter.makedocs(
    modules = [Keys],
)

Documenter.deploydocs(
    repo = "github.com/bramtayl/Keys.jl.git",
)
