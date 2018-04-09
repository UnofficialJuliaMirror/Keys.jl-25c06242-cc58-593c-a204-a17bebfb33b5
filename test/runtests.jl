using Keys

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

import Base.Test: @test
@test @keys Ref(1).x == 1
