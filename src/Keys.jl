module Keys

import RecurUnroll
import RecurUnroll: getindex_unrolled
import TypedBools

export Key
struct Key{K} end

"""
    Key(s::Symbol)

A key used for indexing.

```jldoctest
julia> using Keys, Base.Test

julia> @inferred (() -> Key(:a))()
.a
```
"""
Base.@pure Key(s::Symbol) = Key{s}()

function Base.show(io::IO, key::Key{K}) where K
    print(io, ".")
    print(io, K)
end

export Keyed
"""
    const Keyed{K}

A keyed value
"""
const Keyed{K} = Tuple{Key{K}, V} where {K, V}

export key
"""
    key(keyed::Keyed)

Get the key of a [`Keyed`](@ref) value.

```jldoctest
julia> using Keys, Base.Test

julia> @inferred map(key, keyed_tuple(a = 1, b = 2.0))
(.a, .b)
```
"""
key(k::Keyed) = k[1]

export value
"""
    value(key::Keyed)

Get the value of a [`Keyed`](@ref) value.

```jldoctest
julia> using Keys, Base.Test

julia> @inferred map(value, keyed_tuple(a = 1, b = 1.0))
(1, 1.0)
```
"""
value(k::Keyed) = k[2]

keyed(t::Tuple{A, B} where {A <: Symbol, B}) = (Key(t[1]), t[2])

export KeyedTuple
"""
    const KeyedTuple

A tuple with only [`Keyed`](@ref) values.
"""
const KeyedTuple = NTuple{N, Keyed} where N

@noinline keyed_tuple(v::AbstractVector) = (map(keyed, v)...,)

export keyed_tuple
"""
    keyed_tuple(; args...)

Construct a [`KeyedTuple`](@ref). You can index them with [`Key`](@ref)s as
if they were a Dict. On 0.7, you can also access values with `.`. Duplicated
keys are allowed; will return the first match.

```jldoctest
julia> using Keys, Base.Test

julia> k = keyed_tuple(a = 1, b = 1.0)
((.a, 1), (.b, 1.0))

julia> @inferred k[Key(:b)]
1.0

julia> k[Key(:c)]
ERROR: Key .c not found
[...]

julia> @inferred haskey(k, Key(:b))
TypedBools.True()

julia> @inferred Base.setindex(k, 1//1, Key(:b))
((.a, 1), (.b, 1//1))

julia> if VERSION > v"0.6.2"
            @inferred (k -> k.b)(k)
        else
            2.0
        end
2.0
```
"""
keyed_tuple(; args...) = keyed_tuple(args)

match_key(::Keyed{K}, ::Key{K}) where K = TypedBools.True()
match_key(::Keyed, ::Key) = TypedBools.False()

first_error(::Tuple{}, key::Key) = error("Key $key not found")
first_error(keyed_tuple::KeyedTuple, key::Key) = value(first(keyed_tuple))

which_key(keyed_tuple::KeyedTuple, key::Key) = map(
    let key = key
        keyed -> match_key(keyed, key)
    end,
    keyed_tuple
)

Base.getindex(keyed_tuple::KeyedTuple, key::Key) =
    first_error(getindex_unrolled(keyed_tuple, which_key(keyed_tuple, key)), key)

Base.haskey(keyed_tuple::KeyedTuple, key::Key) = RecurUnroll.reduce_unrolled(|, which_key(keyed_tuple, key))

Base.setindex(keyed_tuple::KeyedTuple, avalue, key::Key) = map(
    let key = key, avalue = avalue
        keyed -> ifelse(match_key(keyed, key), (key, avalue), keyed)
    end,
    keyed_tuple
)

export delete
"""
    delete(key::KeyedTuple, key::Key)

Delete all values matching key

```jldoctest
julia> using Keys, Base.Test

julia> @inferred delete(keyed_tuple(a = 1, b = 2.0), Key(:b))
((.a, 1),)
```
"""
delete(keyed_tuple::KeyedTuple, key::Key) =
    getindex_unrolled(keyed_tuple, map(not, which_key(keyed_tuple, key)))

export push
"""
    push(k::KeyedTuple; args...)

Add keys to a [`KeyedTuple`](@ref).

```jldoctest
julia> using Keys

julia> push(keyed_tuple(a = 1, b = 1.0), c = 1 // 1)
((.a, 1), (.b, 1.0), ((.c, 1//1),))
```
"""
push(k::KeyedTuple; args...) = (k..., keyed_tuple(args))

@static if VERSION > v"0.6.2"
    """
    ```jldoctest
    julia> using Keys, Base.Test

    julia> @inferred keyed_tuple(a = 1, b = 1.0)
    ```
    """
    keyed_tuple(n::NamedTuple) = map(
        let n = n
            key -> (Key(key), Base.getproperty(n, key))
        end,
        keys(n)
    )

    keyed_tuple(b::Base.Iterators.Pairs) =
        keyed_tuple(b.data)

    Base.getproperty(key::KeyedTuple, s::Symbol) = getindex(key, Key(s))
end

export map_values
"""
    map_values(f, key::KeyedTuple)

Map f over the values of a keyed tuple.

```jldoctest
julia> using Keys, Base.Test

julia> @inferred map_values(x -> x + 1, keyed_tuple(a = 1, b = 1.0))
((.a, 2), (.b, 2.0))
```
"""
map_values(f, k::KeyedTuple) = map(
    let f = f
        keyed -> (key(keyed), f(value(keyed)))
    end,
    k
)

end
