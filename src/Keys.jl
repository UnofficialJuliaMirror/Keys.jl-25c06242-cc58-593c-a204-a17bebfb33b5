module Keys

import RecurUnroll: T0, getindex_unrolled, setindex_unrolled, reduce_unrolled

export KeyedTuple
"""
    struct KeyedTuple{K <: Unroll, V <: Unroll}

A keyed tuple can be indexed only with `Key`s (create
with [`@key`](@ref) or [`@keys`](@ref)). Keyed tuples can be manipulated
in a type-stable way because the keys are directly encoded into the type.
You can use repeated keys. `getindex` will take the last match when trying
to index at a repeated key; for all matches, use [`match_key`](@ref)
instead. A keyed table is simply an vector of keyed tuples all name. A keyed
table will conveniently print as a markdown table.

```jldoctest
julia> using Keys, TypedBools, Base.Test

julia> test() = KeyedTuple(; a = 1, b = 2.0, c = "a").a

julia> @inferred test()
1

julia> test() = KeyedTuple(; a = 1, b = 2.0, c = "a")[(true, true, false)]

julia> @inferred test()
(.a = 1, .b = 2.0)

julia> test() =
            if haskey(KeyedTuple(; a = 1, b = 2.0, c = "a"), :a)
                1
            else
                1.0
            end;

julia> @inferred test()

julia> test() = merge(KeyedTuple(; a = 1, b = 2.0), KeyedTuple(; c = "c", d = :d))

julia> @inferred test()
(.a = 1, .b = 2.0, .a = "a", .c = 3, .d = "4")
```
"""
struct KeyedTuple{K, T}
    values::T
end

KeyedTuple(keys, values) =
    KeyedTuple{keys, typeof(values)}(values)

function KeyedTuple(n::NamedTuple)
    my_keys = keys(n)
    KeyedTuple(my_keys, map(key -> getfield(n, key), my_keys))
end
KeyedTuple(; args...) = KeyedTuple(args)

Base.keys(k::KeyedTuple{K}) where K = K
Base.values(k::KeyedTuple) = getfield(k, :values)
Base.pairs(k::KeyedTuple) =
    map(keys(k), values(k)) do key, value
        key => value
    end

Base.show(io::IO, k::KeyedTuple) = show(io, pairs(k))

# needed for constant propagation
Base.@pure which_key(tuple::NTuple{N, Symbol}, key::Symbol) where N =
    map(x -> x == key, tuple)

export match_key
"""
    match_key(keyed_tuple, key)

Find all values matching key.

```jldoctest
julia> using Keys

julia> using Test: @inferred

julia> test() = match_key(KeyedTuple(; a = 1, b = "a", a = 1.0), :a);

julia> @inferred test()
(1, 1.0)
```
"""
match_key(keyed_tuple, key) =
    getindex_unrolled(values(keyed_tuple), which_key(keys(keyed_tuple), key))

Base.getindex(k::KeyedTuple, key) =
    if haskey(k, key)
        last(match_key(k, key))
    else
        error("Key $key not found")
    end

Base.setindex(k::KeyedTuple, value, key) =
    KeyedTuple(keys(k), setindex_unrolled(values(k), value, which_key(keys(k), key)))

Base.getproperty(k::KeyedTuple, key) = getindex(k, key)
Base.getproperty(k::KeyedTuple, key::Symbol) = getindex(k, key)

Base.merge(k1::KeyedTuple, k2::KeyedTuple) =
    KeyedTuple((keys(k1)..., keys(k2)...), (values(k1)..., values(k2)...))

Base.getindex(k::KeyedTuple, switches::Tuple) =
    KeyedTuple(
        getindex_unrolled(keys(k), switches),
        getindex_unrolled(values(k), switches)
    )

export delete
"""
    delete(k::KeyedTuple, key)

Delete all values matching k

```jldoctest
julia> using Keys

julia> using Test: @inferred

julia> test() = delete(KeyedTuple((:a, :b), (1, 2)), :a);

julia> @inferred test()
(.b = 2,)
```
"""
delete(k::KeyedTuple, key) = k[map(!, which_key(keys(k), key))]

Base.haskey(k::KeyedTuple, key) =
    reduce_unrolled(|, false, which_key(keys(k), key))

end
