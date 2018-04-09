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

@inline Key(s::Symbol) = Key{s}()

const SomeKeys = NTuple{N, Key} where N

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
value(a_keyed_tuple::Keyed) = a_keyed_tuple.second

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

julia> @keys a_keyed_tuple = (:a => 1, :b => 1.0)
(.a=>1, .b=>1.0)

julia> if VERSION >= v"0.7.0-DEV"
            a_keyed_tuple.b
        else
            @keys a_keyed_tuple[:b]
        end
1.0

julia> @keys a_keyed_tuple[(:a, :b)]
(.a=>1, .b=>1.0)

julia> @keys a_keyed_tuple[:c]
ERROR: Key .c not found
[...]

julia> @keys haskey(a_keyed_tuple, :b)
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
first_error(a_keyed_tuple::KeyedTuple, key::Key) = value(first(a_keyed_tuple))

which_key(a_keyed_tuple::KeyedTuple, key::Union{Key, SomeKeys}) = map(
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

haskey(a_keyed_tuple::KeyedTuple, key::Key) =
    reduce_unrolled(|, which_key(a_keyed_tuple, key))

export delete
"""
    delete(a_keyed_tuple::KeyedTuple, keys::Key...)

Delete all keyed values matching keys.

```jldoctest
julia> using Keys

julia> @keys delete((:a => 1, :b => 1.0), :a)
(.b=>1.0,)
```
"""
delete(a_keyed_tuple::KeyedTuple, keys::Key...) =
    getindex_unrolled(a_keyed_tuple, map(
        not,
        which_key(a_keyed_tuple, keys)))

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
map_values(f, a_keyed_tuple::KeyedTuple) = map(
    let f = f
        keyed -> key(keyed) => f(value(keyed))
    end,
    a_keyed_tuple
)

rename_one(replacement::Keyed{K2, Key{K1}}, old_keyed::Keyed{K1}) where {K1, K2} =
    replacement.first => old_keyed.second
rename_one(replacement::Keyed, old_keyed::Keyed) = old_keyed

rename_single(replacement, ::Tuple{}) = ()
rename_single(replacement, a_keyed_tuple) =
    rename_one(replacement, first(a_keyed_tuple)),
    rename_single(replacement, tail(a_keyed_tuple))...

rename(a_keyed_tuple::KeyedTuple) = a_keyed_tuple

"""
    rename(a_keyed_tuple::KeyedTuple, replacements...)

Replacements should be pairs of keys; where the first key matches in
`a_keyed_tuple`, it will be replaced by the second.

```
julia> using Keys

julia> @keys rename((:a => 1, :b => "a"), :c => :a)
(.c=>1, .b=>"a")
```
"""
rename(a_keyed_tuple::KeyedTuple, replacements...) =
    rename(rename_single(first(replacements), a_keyed_tuple), tail(replacements)...)

end
