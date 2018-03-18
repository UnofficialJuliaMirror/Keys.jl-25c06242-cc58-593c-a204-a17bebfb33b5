module Keys

import RecurUnroll: getindex_unrolled, reduce_unrolled
import TypedBools: True, False, not
import Base: getindex, haskey, @pure

struct Key{K} end

const Some{T} = NTuple{N, T} where N

const SomeKeys = Some{Key}
const KeyOrKeys = Union{Key, SomeKeys}

@inline Key(s::Symbol) = Key{s}()

const SymbolOrSymbols = Union{Symbol, Some{Symbol}}

@inline to_keys(s::Symbol) = Key(s)
@inline to_keys(ss::Some{Symbol}) = map(Key, ss)

function Base.show(io::IO, key::Key{K}) where K
    print(io, ".")
    print(io, K)
end

struct Keyed{K, V}
    value::V
end

Keyed{K}(v::V) where {K, V} = Keyed{K, V}(v)
Keyed(k::Key{K}, value::V) where {K, V} = Keyed{K, V}(value)

export key
"""
    key(keyed::Keyed)

Get the key of a [`Keyed`](@ref) value.

```jldoctest
julia> using Keys

julia> map(key, keyed_tuple(a = 1, b = 2.0))
(.a, .b)
```
"""
key(k::Keyed{K}) where K = Key{K}()

export value
"""
    value(key::Keyed)

Get the value of a [`Keyed`](@ref) value.

```jldoctest
julia> using Keys

julia> map(value, keyed_tuple(a = 1, b = 1.0))
(1, 1.0)
```
"""
value(k::Keyed) = k.value

function Base.show(io::IO, k::Keyed{K}) where K
    print(io, K)
    print(io, " = ")
    show(io, value(k))
end

export KeyedTuple
"""
    const KeyedTuple

A tuple with only [`Keyed`](@ref) values.
"""
const KeyedTuple = Union{
    NTuple{1, Keyed},
    NTuple{2, Keyed},
    NTuple{3, Keyed},
    NTuple{4, Keyed},
    NTuple{5, Keyed},
    NTuple{6, Keyed},
    NTuple{7, Keyed},
    NTuple{8, Keyed},
    NTuple{9, Keyed},
    NTuple{10, Keyed},
    NTuple{11, Keyed},
    NTuple{12, Keyed},
    NTuple{13, Keyed},
    NTuple{14, Keyed},
    NTuple{15, Keyed},
    NTuple{16, Keyed}
}

Keyed(t::Tuple{A, B}) where {A <: Symbol, B} = Keyed{t[1], B}(t[2])
keyed_tuple(v::AbstractVector) = (map(Keyed, v)...,)

export keyed_tuple
"""
    keyed_tuple(; args...)

Construct a [`KeyedTuple`](@ref). You can index them with symbols as
if they were a Dict. On 0.7, you can also access values with `.`. Duplicated
keys are allowed; will return the first match.

```jldoctest
julia> using Keys

julia> k = keyed_tuple(a = 1, b = 1.0)
((.a, 1), (.b, 1.0))

julia> if VERSION > v"0.6.2"
            k.b
        else
            k[:b]
        end
1.0

julia> getindex(k, (:a, :b))
(a = 1, b = 1.0)

julia> k[:c]
ERROR: Key .c not found
[...]

julia> haskey(k, :b)
TypedBools.True()
```
"""
keyed_tuple(; args...) = keyed_tuple(args)

match_key(::Keyed{K}, ::Key{K}) where K = True()
match_key(::Keyed, ::Key) = False()

match_key(keyed::Keyed, keys::SomeKeys) = reduce_unrolled(|, map(
    let keyed = keyed
        key -> match_key(keyed, key)
    end,
    keys
))

first_error(::Tuple{}, key::Key) = error("Key $key not found")
first_error(a_keyed_tuple::KeyedTuple, key::Key) = value(first(a_keyed_tuple))

which_key(a_keyed_tuple::KeyedTuple, key::KeyOrKeys) = map(
    let key = key
        keyed -> match_key(keyed, key)
    end,
    a_keyed_tuple
)

_getindex(a_keyed_tuple, keys) =
    getindex_unrolled(a_keyed_tuple, which_key(a_keyed_tuple, keys))

getindex(a_keyed_tuple::KeyedTuple, key::Key) =
    first_error(_getindex(a_keyed_tuple, key), key)

getindex(a_keyed_tuple::KeyedTuple, keys::SomeKeys) =
    _getindex(a_keyed_tuple, keys)

@inline getindex(a_keyed_tuple::KeyedTuple, ss::SymbolOrSymbols) =
    getindex(a_keyed_tuple, to_keys(ss))

haskey(a_keyed_tuple::KeyedTuple, key::Key) =
    reduce_unrolled(|, which_key(a_keyed_tuple, key))

@inline haskey(a_keyed_tuple::KeyedTuple, s::Symbol) =
    haskey(a_keyed_tuple, Key(s))

export delete
"""
    delete(key::KeyedTuple, key::Key)

Delete all values matching key

```jldoctest
julia> using Keys

julia> delete(keyed_tuple(a = 1, b = 2.0), :b)
(a = 1,)

julia> delete(keyed_tuple(a = 1, b = 2.0), (:a, :b))
()
```
"""
delete(a_keyed_tuple::KeyedTuple, keys::KeyOrKeys) =
    getindex_unrolled(a_keyed_tuple, map(
        not,
        which_key(a_keyed_tuple, keys)))

@inline delete(a_keyed_tuple::KeyedTuple, ss::SymbolOrSymbols) =
    delete(a_keyed_tuple, to_keys(ss))

export push
"""
    push(k::KeyedTuple; args...)

Add keys to a [`KeyedTuple`](@ref). Will overwrite keys.

```jldoctest
julia> using Keys

julia> push(keyed_tuple(a = 1, b = 1.0), b = "a", c = 1 // 1)
(a = 1, b = "a", c = 1//1)
```
"""
function push(k::KeyedTuple; args...)
    add = keyed_tuple(args)
    delete(k, key.(add))..., add...
end

if VERSION > v"0.6.2"
    keyed_tuple(n::NamedTuple) = map(
        let n = n
            key -> (Key(key), Base.getproperty(n, key))
        end,
        keys(n)
    )

    keyed_tuple(b::Base.Iterators.Pairs) =
        keyed_tuple(b.data)

    @inline Base.getproperty(key::KeyedTuple, s::Symbol) = getindex(key, Key(s))
end

export map_values
"""
    map_values(f, key::KeyedTuple)

Map f over the values of a keyed tuple.

```jldoctest
julia> using Keys

julia> map_values(x -> x + 1, keyed_tuple(a = 1, b = 1.0))
(a = 2, b = 2.0)
```
"""
map_values(f, k::KeyedTuple) = map(
    let f = f
        keyed -> Keyed(key(keyed), f(value(keyed)))
    end,
    k
)

end
