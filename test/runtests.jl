using Keys
using Base.Test

import Documenter
Documenter.makedocs(
    modules = [Keys],
    format = :html,
    sitename = "Keys.jl",
    root = joinpath(dirname(dirname(@__FILE__)), "docs"),
    pages = Any["Home" => "index.md"],
    strict = true,
    linkcheck = true,
    checkdocs = :exports,
    authors = "Brandon Taylor"
)

@keyword_definition test2(a, b) = a + b;
@keywords test2(1, 2)

@keyword_definition function test3(a, b; c = 3, d = 4)
    a + b + c + d
end
@keywords test3(1, 2, c = 4)

@keyword_definition function test4(a, b)
    a + b
end
@keywords test4(1, 2)
