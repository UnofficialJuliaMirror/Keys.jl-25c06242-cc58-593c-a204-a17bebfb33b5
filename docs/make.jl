import Documenter
import Keys

Documenter.makedocs(
    modules = [Keys],
)

Documenter.deploydocs(
    repo = "github.com/bramtayl/Keys.jl.git",
)
