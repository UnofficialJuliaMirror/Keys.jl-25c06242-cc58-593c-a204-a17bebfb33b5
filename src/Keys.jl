module Keys

import RecurUnroll: getindex_unrolled, reduce_unrolled
import TypedBools: True, False, not
import Base: getindex, haskey, merge, tail
import MacroTools: @match
import Base.Meta: quot

export Key
"""
    struct Key{K}

A typed key
```
"""
struct Key{K} end

const SomeKeys = NTuple{N, Key} where N
const PairOfKeys = Pair{T1, T2} where {T1 <: Key, T2 <: Key}

function Base.show(io::IO, key::Key{K}) where K
    print(io, :.)
    print(io, K)
end

export @k_str
"""
    k_str(s::String)

Make a key

```jldoctest
julia> using Keys

julia> k"a"
.a
```
"""
macro k_str(s::String)
    esc(:($Key{$(quot(Symbol(s)))}()))
end

replace_keys(anything) = anything
replace_keys(q::QuoteNode) = replace_keys(quot(q.value))
replace_keys(e::Expr) = @match e begin
    a_.b_ => :($(replace_keys(a)).$b)
    :(a_) => :($Key{$(quot(a))}())
    e_ => Expr(e.head, map(replace_keys, e.args)...)
end

export @keys
"""
    macro keys(e)

Make any symbol in e a key.

```jldoctest
julia> using Keys

julia> @keys (:a => 1, :b => 2)
(.a=>1, .b=>2)
```
"""
macro keys(e)
    esc(replace_keys(e))
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

julia> @keys key.((:a => 1, :b => 2.0))
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

julia> @keys value.((:a => 1, :b => 1.0))
(1, 1.0)
```
"""
value(keyed_tuple::Keyed) = keyed_tuple.second

export KeyedTuple
"""
    const KeyedTuple

A tuple with only [`Keyed`](@ref) values.
"""
const KeyedTuple = Tuple{Keyed, Vararg{Keyed}}

export @keyed
"""
    @keyed(args...)

Construct a [`KeyedTuple`](@ref). You can index them with symbols as
if they were a Dict. On 0.7, you can also access values with `.`. Duplicated
keys are allowed; will return the first match.

```jldoctest
julia> using Keys

julia> @keys keyed_tuple = (:a => 1, :b => 1.0)
(.a=>1, .b=>1.0)

julia> if VERSION >= v"0.7.0-DEV"
            keyed_tuple.b
        else
            @keys keyed_tuple[:b]
        end
1.0

julia> @keys keyed_tuple[(:a, :b)]
(.a=>1, .b=>1.0)

julia> @keys keyed_tuple[:c]
ERROR: Key .c not found
[...]

julia> @keys haskey(keyed_tuple, :b)
TypedBools.True()
```
"""
macro keyed(e::Expr)
    map!(e.args) do arg
        @match arg begin
            (akey_ = avalue_) => :($Keyed{$(quot(akey))}($avalue))
            any_ => any
        end
    end
    esc(e)
end

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

julia> @keys delete((:a => 1, :b => 1.0), :a)
(.b=>1.0,)
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

julia> @keys push((:a => 1, :b => 1.0), :b => "a", :c => 1 // 1)
(.a=>1, .b=>"a", .c=>1//1)
```
"""
push(k1::KeyedTuple, k2::Keyed...) = delete(k1, key.(k2)...)..., k2...

if VERSION >= v"0.7.0-DEV"
    @inline Base.getproperty(key::KeyedTuple, s::Symbol) = getindex(key, Key(s))
end

export map_values
"""
    map_values(f, key::KeyedTuple)

Map f over the values of a keyed tuple.

```jldoctest
julia> using Keys

julia> @keys map_values(x -> x + 1, (:a => 1, :b => 1.0))
(.a=>2, .b=>2.0)
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

julia> @keys rename((:a => 1, :b => "a"), :c => :a)
(.c=>1, .b=>"a")
```
"""
rename(keyed_tuple::KeyedTuple, replacements::PairOfKeys...) =
    rename(rename_single(first(replacements), keyed_tuple), tail(replacements)...)

export gather
"""
    gather(keyed_tuple::KeyedTuple, key_name::Key, value_name::Key, keys::Key...)

Gather values from a keyed tuple into key and value columns.

```jldoctest
julia> using Keys

julia> keyed_tuple = @keys (:a => "a", :b => 2, :c => 3)

julia> @keys gather(keyed_tuple, :key, :value, :b, :c)
((.a=>1, .key=>:b, .value=>2), (.a=>1, .key=>:c, .value=>3))
```
"""
gather(keyed_tuple::KeyedTuple, key_name::Key, value_name::Key, keys::Key...) =
    map(
        let withouts = delete(a_named_tuple, keys...), key_name = key_name, keyed_tuple = keyed_tuple
            key -> push(withouts, key_name => inner_value(key), value_name => a_named_tuple[key])
        end,
        keys
    )

end
