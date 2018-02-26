module Keys

using TypedBools
using RecurUnroll

struct Key{K} end

export Key
"""
    Key(k)

A key for indexing tuples
"""
Base.@pure Key(k) = Key{k}()

function Base.show(io::IO, k::Key{K}) where K
    print(io, ".")
    print(io, K)
end

struct Keyed{K, V}
    value::V
end

"""
    Keyed(key, value)

If tuples contain Keyed values, you can index them with [`Keys`](@ref) as if
they were a Dict.

```jldoctest
julia> using Keys, TypedBools, Base.Test

julia> k = (Keyed(:a, 1), 2.0, Keyed(:c, "c"))
(a = 1, 2.0, c = "c")

julia> @inferred k[Key(:c)]
"c"

julia> k[Key(:d)]
ERROR: Key .c not found
[...]

julia> @inferred haskey(k, Key(:c))
TypedBools.True()

julia> @inferred Base.setindex(k, 3//1, Key(:c))
(a = 1, 2.0, c = 3//1)
```
"""
Base.@pure Keyed(key, value::V) where V = Keyed{key, V}(value)

function Base.show(io::IO, k::Keyed{K}) where K
    print(io, K)
    print(io, " = ")
    show(io, k.value)
end
KeyedTuple(; args...) = KeyedTuple(args)

value(k::Keyed) = k.value

match_key(::Keyed{K}, ::Key{K}) where K = True()
match_key(any, ::Key) = False()

first_error(::Tuple{}, k::Key) = error("Key $k not found")
first_error(t::Tuple, k::Key) = value(first(t))

which_key(t::Tuple, k::Key) = map(t) do keyed
    match_key(keyed, k)
end

Base.getindex(t::Tuple, k::Key) =
    first_error(getindex_unrolled(t, which_key(t, k)), k)
Base.haskey(t::Tuple, k::Key) = reduce_unrolled(|, which_key(t, k))

Base.setindex(t::Tuple, value::V, k::Key{K}) where {K, V} =
    map(t) do keyed
        ifelse(match_key(keyed, k), Keyed{K, V}(value), keyed)
    end

export delete
"""
    delete(k::KeyedTuple, key::Key)

Delete all values matching k

```jldoctest
julia> using Keys, Base.Test

julia> @inferred delete((Keyed(:a, 1), Keyed(:b, 2.0)), Key(:b))
(b = 2,)
```
"""
delete(t::Tuple, k::Key) = getindex_unrolled(t, map(!, which_key(t, k)))

end
