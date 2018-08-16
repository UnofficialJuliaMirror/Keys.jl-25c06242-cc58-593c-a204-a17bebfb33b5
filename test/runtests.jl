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
t0 = ()
switch = (True(), True(), False())
new = (4, 5)

@test_throws ArgumentError reduce_unrolled(+, t0)

@test getindex_unrolled(x, t0) == t0
@test getindex_unrolled(t0, switch) == t0

@test setindex_unrolled(t0, t0, switch) == t0
@test setindex_unrolled(t0, new, t0) == t0
@test setindex_unrolled(t0, new, switch) == t0
@test setindex_unrolled(x, t0, t0) == x
@test setindex_unrolled(x, t0, switch) == x
@test setindex_unrolled(x, new, t0) == t0
@test setindex_unrolled(t0, t0, t0) == t0
