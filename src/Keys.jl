module Keys

import RecurUnroll
import RecurUnroll: getindex_unrolled, reduce_unrolled
import TypedBools
import DataFrames

export Key
struct Key{K} end

const SomeKeys = NTuple{N, Key} where N
const KeyOrKeys = Union{Key, SomeKeys}

# x = keyed_table(a = [1, 2], b = ["a", "b"])

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

# hack into dataframe printing
struct PrintWrapper{T} <: DataFrames.AbstractDataFrame
    x::T
end

DataFrames.eachcol(p::PrintWrapper) = p.x
DataFrames.nrow(p::PrintWrapper) =
    max(map(keyed -> length(value(keyed)), p.x)...)
DataFrames.ncol(p::PrintWrapper) = length(p.x)
DataFrames._names(p::PrintWrapper) = map(key, p.x)
Base.getindex(p::PrintWrapper, j) = value(p.x[j])
Base.getindex(p::PrintWrapper, i, j) = getindex(p, j)[i]
Base.collect(k::KeyedTuple) = map_values(collect, k)

function Base.summary(p::PrintWrapper) # -> String
    nrows, ncols = size(p)
    return @sprintf("%d×%d %s", nrows, ncols, "KeyedTuple")
end

# technically type piracy
DataFrames.isna(a1, a2) = false

function Base.show(io::IO, k::KeyedTuple)
    print(io, '\n')
    show(io, PrintWrapper(map_values(collect, k)), true, :Row, false)
end

@noinline keyed_tuple(v::AbstractVector) = (map(keyed, v)...,)

export keyed_tuple
"""
    keyed_tuple(; args...)

Construct a [`KeyedTuple`](@ref). You can index them with [`Key`](@ref)s as
if they were a Dict. On 0.7, you can also access values with `.`. Duplicated
keys are allowed; will return the first match.

```jldoctest
julia> using Keys, Base.Test

julia> k = if VERSION > v"0.6.2"
            @inferred keyed_tuple(a = 1, b = 1.0)
        else
            keyed_tuple(a = 1, b = 1.0)
        end
│ Row │ .a │ .b  │
├─────┼────┼─────┤
│ 1   │ 1  │ 1.0 │

julia> if VERSION > v"0.6.2"
            @inferred (k -> k.b)(k)
        else
            @inferred k[Key(:b)]
        end
1.0

julia> @inferred getindex(k, (Key(:a), Key(:b)))
│ Row │ .a │ .b  │
├─────┼────┼─────┤
│ 1   │ 1  │ 1.0 │

julia> k[Key(:c)]
ERROR: Key .c not found
[...]

julia> @inferred haskey(k, Key(:b))
TypedBools.True()

julia> @inferred Base.setindex(k, 1//1, Key(:b))
│ Row │ .a │ .b   │
├─────┼────┼──────┤
│ 1   │ 1  │ 1//1 │
```
"""
keyed_tuple(; args...) = keyed_tuple(args)

match_key(::Keyed{K}, ::Key{K}) where K = TypedBools.True()
match_key(::Keyed, ::Key) = TypedBools.False()

# import Base: |

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

Base.getindex(a_keyed_tuple::KeyedTuple, key::Key) =
    first_error(_getindex(a_keyed_tuple, key), key)

#Base.getindex(a_keyed_tuple::KeyedTuple, row, key::Key) =
#    getindex(a_keyed_tuple[key], row)

Base.getindex(a_keyed_tuple::KeyedTuple, keys::SomeKeys) =
    _getindex(a_keyed_tuple, keys)

Base.haskey(a_keyed_tuple::KeyedTuple, key::Key) = RecurUnroll.reduce_unrolled(|, which_key(a_keyed_tuple, key))

Base.setindex(a_keyed_tuple::KeyedTuple, avalue, key::Key) = map(
    let key = key, avalue = avalue
        keyed -> ifelse(match_key(keyed, key), (key, avalue), keyed)
    end,
    a_keyed_tuple
)

export delete
"""
    delete(key::KeyedTuple, key::Key)

Delete all values matching key

```jldoctest
julia> using Keys, Base.Test

julia> @inferred delete(keyed_tuple(a = 1, b = 2.0), Key(:b))
│ Row │ .a │
├─────┼────┤
│ 1   │ 1  │

julia> @inferred delete(keyed_tuple(a = 1, b = 2.0), (Key(:a), Key(:b)))
()
```
"""
delete(a_keyed_tuple::KeyedTuple, key::KeyOrKeys) =
    getindex_unrolled(a_keyed_tuple, map(
        TypedBools.not,
        which_key(a_keyed_tuple, key)))

export push
"""
    push(k::KeyedTuple; args...)

Add keys to a [`KeyedTuple`](@ref).

```jldoctest
julia> using Keys

julia> push(keyed_tuple(a = 1, b = 1.0), c = 1 // 1)
│ Row │ .a │ .b  │ .c   │
├─────┼────┼─────┼──────┤
│ 1   │ 1  │ 1.0 │ 1//1 │
```
"""
push(k::KeyedTuple; args...) = (k..., keyed_tuple(args)...)

@static if VERSION > v"0.6.2"
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
│ Row │ .a │ .b  │
├─────┼────┼─────┤
│ 1   │ 2  │ 2.0 │
```
"""
map_values(f, k::KeyedTuple) = map(
    let f = f
        keyed -> (key(keyed), f(value(keyed)))
    end,
    k
)

end
