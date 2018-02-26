module Keys

import MacroTools
import RecurUnroll
import RecurUnroll: getindex_unrolled
import TypedBools

export Key
struct Key{K} end

Key(k) = Key{k}()

function Base.show(io::IO, k::Key{K}) where K
    print(io, ".")
    print(io, K)
end

const Keyed{K} = Tuple{Key{K}, V} where {K, V}

export key
key(k::Keyed) = k[1]
export value
value(k::Keyed) = k[2]
value(any) = any

export @keyed_tuple
"""
    @keyed_tuple args...

will create a regular tuple. If args contains assignments, then it will return
Keyed values. You can index them with [`Keys`](@ref) as if they were a Dict. On
0.7, you can also access values with `.`. Duplicated keys are allowed; will
return the first match.

```jldoctest
julia> using Keys, TypedBools, Base.Test

julia> k = @keyed_tuple a = 1 2.0 c = "c"
((.a, 1), 2.0, (.c, "c"))

julia> @inferred k[Key(:c)]
"c"

julia> k[Key(:d)]
ERROR: Key .d not found
[...]

julia> @inferred haskey(k, Key(:c))
TypedBools.True()

julia> @inferred Base.setindex(k, 3//1, Key(:c))
(a = 1, 2.0, c = 3//1)

julia> if VERSION > v"0.6.2"
            @inferred (k -> k.c)(k)
        else
            "c"
        end
"c"
```
"""
macro keyed_tuple(args...)
    Expr(:tuple, map(args) do item
        MacroTools.@match item begin
            (a_ = b_) => :(($(Key(a)), $b))
            any_ => any
        end
    end...) |> esc
end

match_key(::Keyed{K}, ::Key{K}) where K = TypedBools.True()
match_key(any, ::Key) = TypedBools.False()

head_error(::Tuple{}, k::Key) = error("Key $k not found")
head_error(t::Tuple, k::Key) = value(RecurUnroll.head(t))

which_key(t::Tuple, k::Key) = map(t) do keyed
    match_key(keyed, k)
end

Base.getindex(t::Tuple, k::Key) =
    head_error(getindex_unrolled(t, which_key(t, k)), k)
Base.haskey(t::Tuple, k::Key) = RecurUnroll.reduce_unrolled(|, which_key(t, k))

Base.setindex(t::Tuple, avalue, k::Key) =
    map(t) do keyed
        ifelse(match_key(keyed, k), (k, avalue), keyed)
    end

export delete
"""
    delete(k::KeyedTuple, key::Key)

Delete all values matching k

```jldoctest
julia> using Keys, Base.Test

julia> @inferred delete((@keyed_tuple a = 1 b = 2.0), Key(:b))
((.a, 1),)
```
"""
delete(t::Tuple, k::Key) = getindex_unrolled(t, map(!, which_key(t, k)))

if VERSION > v"0.6.2"
    keyed_tuple(n::NamedTuple) = map(keys(x)) do key
        (Key(x), getproperty(x, key))
    end
    # Potentially serious type piracy. However, absolutely necessary to get full
    # covariance. Will error if no Keys are used.
    Base.getproperty(t::Tuple, s::Symbol) = getindex(t, Key(s))
end

end
