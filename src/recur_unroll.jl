const T0 = Tuple{}

argtail(x, rest...) = rest
tail(x) = argtail(x...)

reduce_unrolled(reducer, ::T0) = Base._empty_reduce_error()
reduce_unrolled(reducer, args) = reduce_unrolled(
    reducer,
    first(args),
    tail(args)
)
reduce_unrolled(reducer, default, args::T0) = default

export reduce_unrolled
"""
```jldoctest
julia> using Keys

julia> reduce_unrolled(&, (True(), False(), True()))
False()
```
"""
reduce_unrolled(reducer, default, args) =
    reducer(default, reduce_unrolled(reducer, first(args), tail(args)))

export getindex_unrolled

const T0 = Tuple{}

export getindex_unrolled
getindex_unrolled(into::T0, switch::T0) = ()
getindex_unrolled(into, switch::T0) = ()
getindex_unrolled(into::T0, switch) = ()
"""
    getindex_unrolled(into, switch)

```jldoctest
julia> using Keys

julia> getindex_unrolled((1, "a", 1.0), (True(), False(), True()))
(1, 1.0)
```
"""
Base.@pure function getindex_unrolled(into, switch)
    next = getindex_unrolled(tail(into), tail(switch))
    if_else(first(switch), (first(into), next...), next)
end

export setindex_many_unrolled
"""
    setindex_many_unrolled(old, new, switch, default = missing)

Fill `old` with `new` where `switch` is true. If you run out of new values,
fill with default instead.

```jldoctest
julia> using Keys

julia> setindex_many_unrolled(
            (1, "a", 1.0),
            (2,),
            (True(), False(), True()),
            0
        )
(2, "a", 0)
```
"""
setindex_many_unrolled(::T0, ::T0, ::T0, default = missing) = ()
setindex_many_unrolled(::T0, ::T0, switch, default = missing) = ()
setindex_many_unrolled(::T0, new, ::T0, default = missing) = ()
setindex_many_unrolled(::T0, new, switch, default = missing) = ()
setindex_many_unrolled(old, ::T0, ::T0, default = missing) = ()
setindex_many_unrolled(old, ::T0, switch, default = missing) =
    map(old, switch) do aold, aswitch
        if_else(aswitch, default, aold)
    end
setindex_many_unrolled(old, new, ::T0, default = missing) = ()
function setindex_many_unrolled(old, new, switch, default = missing)
    first_tuple, tail_tuple = if_else(
        first(switch),
        (first(new), tail(new)),
        (first(old), new)
    )
    first_tuple, setindex_many_unrolled(
        tail(old),
        tail_tuple,
        tail(switch),
    default)...
end

export find_unrolled
find_unrolled(t) = find_unrolled(t, 1)
find_unrolled(t::T0, n) = ()

"""
```jldoctest
julia> using Keys

julia> find_unrolled((True(), False(), True()))
(1, 3)
```
"""
function find_unrolled(t, n)
    next = find_unrolled(tail(t), n + 1)
    if_else(first(t), (n, next...), next)
end

export flatten_unrolled
"""
    flatten_unrolled(x)

```jldoctest
julia> using Keys

julia> flatten_unrolled(((1, 2.0), ("c", 4//4)))
(1, 2.0, "c", 1//1)
```
"""
flatten_unrolled(x) = first(x)..., flatten_unrolled(tail(x))...
flatten_unrolled(::T0) = ()

export product_unrolled
"""
    product_unrolled(x, y)

```jldoctest
julia> using Keys

julia> product_unrolled((1, 2.0), ("c", 4//4))
((1, "c"), (2.0, "c"), (1, 1//1), (2.0, 1//1))
```
"""
product_unrolled(x, y) = flatten_unrolled(map(
    let x = x
        y1 ->
            map(
                let y1 = y1
                    x1 -> (x1, y1)
                end,
                x
            )
    end,
    y
))

export filter_unrolled
"""
    filter_unrolled(f, x)

```jldoctest
julia> using Keys

julia> filter_unrolled(pair -> same_type(pair[1], pair[2]), ((1, 2), (1, "a")))
((1, 2),)
```
"""
filter_unrolled(f, x) = getindex_unrolled(x, map(f, x))
