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

import Base.Test: @inferred
if VERSION > v"0.6.2"
    test1() = keyed_tuple(a = 1, b = 1.0)
    k = @inferred test1()
    test2(k) = k[:a]
    @inferred test2(k)
    test3(k) = getindex(k, (:a, :b))
    @inferred test3(k)
    test4(k) = haskey(k, :b)
    @inferred test4(k)
    test5(k) = Base.setindex(k, 1//1, :b)
    @inferred test5(k)
    test6(k) = delete(k, :b)
    @inferred test6(k)
end
