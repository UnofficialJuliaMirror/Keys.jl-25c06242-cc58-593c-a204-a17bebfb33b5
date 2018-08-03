module Keys

import Base: getindex, haskey, merge, tail, convert, &, |
import Base.Meta: quot

include("typed_bools.jl")
include("recur_unroll.jl")

export Key
"""
    struct Key{K}

A typed key
```
"""
struct Key{K} end

inner_value(k::Key{K}) where K = K

export @__str
"""
    @__str

Make a key

```jldoctest
julia> using Keys

julia> _"a"
.a
```
"""
macro __str(s::String)
    esc(:($Key{$(quot(Symbol(s)))}()))
end

const SomeKeys = NTuple{N, Key} where N
const PairOfKeys = Pair{T1, T2} where {T1 <: Key, T2 <: Key}

function Base.show(io::IO, key::Key{K}) where K
    print(io, :.)
    print(io, K)
end

export Keyed
"""
    struct Keyed{K, V}

An alias for a key-value pair.
"""
const Keyed{K, V} = Pair{Key{K}, V} where {K, V}

export key
"""
    key(keyed::Keyed)

Get the key of a [`Keyed`](@ref) value.

```jldoctest
julia> using Keys

julia> key.((_"a" => 1, _"b" => 2))
(.a, .b)
```
"""
key(::Keyed{K}) where K = Key{K}()

export value
"""
    value(key::Keyed)

Get the value of a [`Keyed`](@ref) value.

```jldoctest
julia> using Keys

julia> value.((_"a" => 1, _"b" => 2))
(1, 2)
```
"""
value(keyed_tuple::Keyed) = keyed_tuple.second

export KeyedTuple
"""
    const KeyedTuple

A tuple with only [`Keyed`](@ref) values. You can index them with keys; on 0.7, y
ou can also access values with `.`. Duplicated keys are allowed; will return the
first match.

```jldoctest
julia> using Keys

julia> keyed_tuple = (_"a" => 1, _"b" => 2)
(.a => 1, .b => 2)

julia> keyed_tuple.b
2

julia> keyed_tuple[(_"a", _"b")]
(.a => 1, .b => 2)

julia> keyed_tuple.c
ERROR: Key .c not found
[...]

julia> haskey(keyed_tuple, _"b")
True()

julia> merge(keyed_tuple, (_"a" => 4, _"c" => 3))
(.b => 2, .a => 4, .c => 3)
```
"""
const KeyedTuple = Tuple{Keyed, Vararg{Keyed}}

match_key(::Keyed{K}, ::Key{K}) where K = True()
match_key(::Keyed, ::Key) = False()

function match_key(keyed::Keyed, keys::SomeKeys)
    reduce_unrolled(|, map(
        let keyed = keyed
            key -> match_key(keyed, key)
        end,
        keys
    ))
end

first_error(::Tuple{}, key::Key) = error("Key $key not found")
first_error(keyed_tuple::KeyedTuple, key::Key) = value(first(keyed_tuple))

which_key(keyed_tuple::KeyedTuple, key::Union{Key, SomeKeys}) = map(
    let key = key
        keyed -> match_key(keyed, key)
    end,
    keyed_tuple
)

_getindex(keyed_tuple, keys) =
    getindex_unrolled(keyed_tuple, which_key(keyed_tuple, keys))

getindex(keyed_tuple::KeyedTuple, key::Key) =
    first_error(_getindex(keyed_tuple, key), key)

getindex(keyed_tuple::KeyedTuple, keys::SomeKeys) =
    _getindex(keyed_tuple, keys)

haskey(keyed_tuple::KeyedTuple, key::Key) =
    reduce_unrolled(|, which_key(keyed_tuple, key))

export delete
"""
    delete(keyed_tuple::KeyedTuple, keys::Key...)

Delete all keyed values matching keys.

```jldoctest
julia> using Keys

julia> delete((_"a" => 1, _"b" => 2), _"a")
(.b => 2,)
```
"""
delete(keyed_tuple::KeyedTuple, keys::Key...) =
    getindex_unrolled(keyed_tuple, map(
        not,
        which_key(keyed_tuple, keys)))

export push
"""
    push(k1::KeyedTuple, args...)

Push the pairs in args into `k1`, replacing common keys.

```jldoctest
julia> using Keys

julia> push((_"a" => 1, _"b" => 2), _"b" => 4, _"c" => 3)
(.a => 1, .b => 4, .c => 3)
```
"""
push(k1::KeyedTuple, k2::Keyed...) = delete(k1, key.(k2)...)..., k2...

@inline Base.getproperty(key::KeyedTuple, s::Symbol) = getindex(key, Key{s}())

export map_values
"""
    map_values(f, key::KeyedTuple)

Map f over the values of a keyed tuple.

```jldoctest
julia> using Keys

julia> map_values(x -> x + 1, (_"a" => 1, _"b" => 2))
(.a => 2, .b => 3)
```
"""
map_values(f, keyed_tuple::KeyedTuple) = map(
    let f = f
        keyed -> key(keyed) => f(value(keyed))
    end,
    keyed_tuple
)

rename_one(replacement::Keyed{New, Key{Old}}, old_keyed::Keyed{Old}) where {Old, New} =
    replacement.first => old_keyed.second
rename_one(replacement::PairOfKeys, old_keyed::Keyed) = old_keyed

rename_single(replacement::PairOfKeys, ::Tuple{}) = ()
rename_single(replacement::PairOfKeys, keyed_tuple::KeyedTuple) =
    rename_one(replacement, first(keyed_tuple)),
    rename_single(replacement, tail(keyed_tuple))...

rename(keyed_tuple::KeyedTuple) = keyed_tuple

export rename
"""
    rename(keyed_tuple::KeyedTuple, replacements::PairOfKeys...)

Replacements should be pairs of keys; where the first key matches in
`keyed_tuple`, it will be replaced by the second.

```jldoctest
julia> using Keys

julia> rename((_"a" => 1, _"b" => 2), _"c" => _"a")
(.c => 1, .b => 2)
```
"""
rename(keyed_tuple::KeyedTuple, replacements::PairOfKeys...) =
    rename(rename_single(first(replacements), keyed_tuple), tail(replacements)...)

common_keys(x::KeyedTuple, y::KeyedTuple) =
    first.(filter_unrolled(pair -> same_type(pair[1], pair[2]), product_unrolled(key.(x), key.(y))))

merge(a::KeyedTuple, b::KeyedTuple) =
    (delete(a, common_keys(a, b)...)..., b...)

#=
@require DataFrames begin

    import DataFrames: DataFrame

    (::Type{KeyedTuple})(d::DataFrame) = (map(
        (name, column) -> Key{name}() => (column),
        names(d),
        d.columns
    )...)

    DataFrame(k::KeyedTuple) =
        DataFrame(map(x -> inner_value(x.first) => x.second, k)...)

end
=#

end
