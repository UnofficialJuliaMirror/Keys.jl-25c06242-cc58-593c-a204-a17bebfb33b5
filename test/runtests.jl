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

using Test

x = (1, 2, 3)
empty = ()
switch = (True(), True(), False())
new = (4, 5)

@test_throws ArgumentError reduce_unrolled(+, empty)

@test getindex_unrolled(x, empty) == empty
@test getindex_unrolled(empty, switch) == empty

@test setindex_many_unrolled(empty, empty, switch) == empty
@test setindex_many_unrolled(empty, new, empty) == empty
@test setindex_many_unrolled(empty, new, switch) == empty
@test setindex_many_unrolled(x, empty, empty) == empty
@test setindex_many_unrolled(x, empty, switch) === (missing, missing, 3)
@test setindex_many_unrolled(x, new, empty) == empty
@test setindex_many_unrolled(empty, empty, empty) == empty
