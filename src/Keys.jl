module Keys

import RecurUnroll: getindex_unrolled, reduce_unrolled
import TypedBools: True, False, not
import Base: getindex, haskey, merge
import MacroTools: @match
import Base.Meta: quot

export Key
"""
    struct Key{K}

A typed key.

```jldoctest
julia> using Keys

julia> Key(:a)
.a
```
"""
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

export Keyed
"""
    struct Keyed{K, V}

A keyed value.

```jldoctest
julia> using Keys

julia> Keyed{:a}(1)
a = 1

julia> Keyed(Key(:a), 1)
a = 1
```
"""
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

julia> map(key, @keyed_tuple(a = 1, b = 2.0))
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

julia> map(value, @keyed_tuple(a = 1, b = 1.0))
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

export @keyed_tuple
"""
    @keyed_tuple(args...)

Construct a [`KeyedTuple`](@ref). You can index them with symbols as
if they were a Dict. On 0.7, you can also access values with `.`. Duplicated
keys are allowed; will return the first match.

```jldoctest
julia> using Keys

julia> k = @keyed_tuple(a = 1, b = 1.0)
(a = 1, b = 1.0)

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

julia> merge(@keyed_tuple(a = 1, b = 1.0), @keyed_tuple(b = "a", c = 1 // 1))
(a = 1, b = "a", c = 1//1)
```
"""
macro keyed_tuple(args...)
    esc(:($(map(args) do arg
        @match arg begin
            (akey_ = avalue_) => :($Keyed{$(quot(akey))}($avalue))
            any_ => error("Must be an assignment")
        end
    end...),))
end

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

julia> delete(@keyed_tuple(a = 1, b = 2.0), :b)
(a = 1,)

julia> delete(@keyed_tuple(a = 1, b = 2.0), (:a, :b))
()
```
"""
delete(a_keyed_tuple::KeyedTuple, keys::KeyOrKeys) =
    getindex_unrolled(a_keyed_tuple, map(
        not,
        which_key(a_keyed_tuple, keys)))

@inline delete(a_keyed_tuple::KeyedTuple, ss::SymbolOrSymbols) =
    delete(a_keyed_tuple, to_keys(ss))

function merge(k1::KeyedTuple, k2::KeyedTuple)
    delete(k1, key.(k2))..., k2...
end

if VERSION > v"0.6.2"
    @inline Base.getproperty(key::KeyedTuple, s::Symbol) = getindex(key, Key(s))
end

export map_values
"""
    map_values(f, key::KeyedTuple)

Map f over the values of a keyed tuple.

```jldoctest
julia> using Keys

julia> map_values(x -> x + 1, @keyed_tuple(a = 1, b = 1.0))
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
