import Documenter
import Keys

Documenter.makedocs(
    modules = [Keys],
    sitename = "Keys.jl",
)

Documenter.deploydocs(
    repo = "github.com/bramtayl/Keys.jl.git",
)
