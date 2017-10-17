module Keys

import MacroTools

using TypedBools
using RecurUnroll
using MappedArrays

import RecurUnroll: T0, getindex_unrolled, setindex_unrolled, mapfoldr_unrolled

export Key
struct Key{T <: Any} end
Key(x) = Key{x}()

export unkey
unkey(::Key{T}) where T = T
Base.Symbol(k::Key) = Symbol(unkey(k))

Base.show(io::IO, ::Key{T}) where T = begin
    print(io, ".")
    print(io, T)
end

export @key
"""
    macro key(e)

Make a Key

```jdoctest
julia> using Keys

julia> @key a
.a
```
"""
macro key(e)
    Key{e}()
end

export @keys
"""
    macro keys(es...)

Make Keys

```jdoctest
julia> using Keys

julia> @keys a b
(.a, .b)
```
"""
macro keys(es...)
    map(es) do e
        Key{e}()
    end
end

export KeyedTuple
"""
    struct KeyedTuple{K <: Unroll, V <: Unroll}

A keyed tuple can be indexed only with `Key`s (create
with [`@key`](@ref) or [`@keys`](@ref)). Keyed tuples can be manipulated
in a type-stable way because the keys are directly encoded into the type.
You can use repeated keys. `getindex` will take the last match when trying
to index at a repeated key; for all matches, use [`match_key`](@ref)
instead. A vector of tuples with consistent keys will conveniently print
as a markdown table. Arrays of keyed tuples will usefully print as tables.

```jldoctest
julia> using Keys, TypedBools, Base.Test

julia> k = KeyedTuple((@keys a b a), (1, 2.0, "a"))
(.a = 1, .b = 2.0, .a = "a")

julia> @inferred k[@key a]
"a"

julia> @inferred k[@key c]
ERROR: Key .c not found
[...]

julia> @inferred k[(True(), True(), False())]
(.a = 1, .b = 2.0)

julia> @inferred haskey(k, @key a)
true

julia> @inferred Base.setindex(k, 1, @key b)
(.a = 1, .b = 1, .a = "a")

julia> @inferred merge(k, KeyedTuple((@keys c d), (3, "4")))
(.a = 1, .b = 2.0, .a = "a", .c = 3, .d = "4")

julia> k2 = KeyedTuple((@keys a b a), (2, 3.0, "c"));

julia> [k, k2]
2 x 3 keyed table
| .a | .b  | .a |
| -- | --- | -- |
| 1  | 2.0 | a  |
| 2  | 3.0 | c  |
```
"""
struct KeyedTuple{K <: Tuple, V <: Tuple}
    keys::K
    values::V
end

Base.show(io::IO, p::Pair{T}) where T <: Key = begin
    print(io, first(p))
    print(io, " = ")
    show(io, last(p))
end

Base.show(io::IO, k::KeyedTuple) =
    show(io, map(k.keys, k.values) do key, value
        key => value
    end)

function which_key(keyed_tuple, key)
    map(
        let key = key
            akey -> typed(akey == key)
        end,
        keyed_tuple.keys
    )
end

export match_key
"""
    match_key(keyed_tuple, key)

Find all values matching key.

```jldoctest
julia> using Keys, Base.Test

julia> k = KeyedTuple((@keys a b a), (1, "a", 1.0))
(.a = 1, .b = "a", .a = 1.0)

julia> @inferred match_key(k, @key a)
(1, 1.0)
```
"""
match_key(keyed_tuple, key) =
    getindex_unrolled(keyed_tuple.values, which_key(keyed_tuple, key))

last_error(x, key) = last(x)
last_error(x::T0, key) = error("Key $key not found")

Base.getindex(k::KeyedTuple, key::Key) =
    last_error(match_key(k, key), key)

Base.setindex(k::KeyedTuple, value, key) =
    KeyedTuple(k.keys, setindex_unrolled(k.values, value, which_key(k, key)))

Base.merge(k1::KeyedTuple, k2::KeyedTuple) =
    KeyedTuple((k1.keys..., k2.keys...), (k1.values..., k2.values...))

Base.getindex(k::KeyedTuple, switches::Tuple) =
    KeyedTuple(
        getindex_unrolled(k.keys, switches),
        getindex_unrolled(k.values, switches)
    )

export delete
"""
    delete(k::KeyedTuple, key)

Delete all values matching k

```jldoctest
julia> using Keys, Base.Test

julia> @inferred delete(KeyedTuple((@keys a b), (1, 2)), @key a)
(.b = 2,)
```
"""
delete(k::KeyedTuple, key) = k[map(!, which_key(k, key))]

export fieldtypes
"""
    fieldtypes(any)

Get the field types of a type, wrapped in keys for protection.

```jldoctest
julia> using Keys, Base.Test

julia> @inferred fieldtypes(typeof((1, "a")))
(.Int64, .String)
```
"""
fieldtypes(any) = fieldtypes(Key(any))
function fieldtypes(keyed_type::Key)
    Base.@pure inner_function(i) = Key(fieldtype(unkey(keyed_type), i))
    ntuple(inner_function, Val(nfields(unkey(keyed_type))))
end

type_keys(t) = map(fieldtypes(fieldtype(t, :keys))) do key_type
    unkey(key_type)()
end
type_value_types(t) = fieldtypes(fieldtype(t, :values))

export keyed_types
"""
    keyed_types(t)

Construct a keyed tuple of the keyed element types from a KeyedTuple type.

```jldoctest
julia> using Keys, Base.Test

julia> keyed_types(typeof(KeyedTuple((@keys a b), (1, "a"))))
(.a = .Int64, .b = .String)
```
"""
keyed_types(t) = KeyedTuple(type_keys(t), type_value_types(t))

Base.haskey(k::KeyedTuple, key) =
    Bool(mapfoldr_unrolled(akey -> typed(akey == key), |, False(), k.keys))

export @unlock
"""
    macro unlock(collection, keys...)

Attach keys from a keyed tuple to the local environment. If a key is not found,
optionally specify a default.

```jldoctest
julia> using Keys

julia> k = KeyedTuple((@keys a b c), (1, 1//2, 1.0));

julia> @unlock k a b = 2 d = 4;

julia> b
1//2

julia> a + b + d
11//2

julia> @unlock k a*2
ERROR: Cannot parse unlock argument a * 2
[...]
```
"""
macro unlock(collection, keys...)
    safe_collection = gensym()
    quote
        $safe_collection = $collection
        $(map(keys) do akey
            MacroTools.@match akey begin
                key_Symbol => :($key = $safe_collection[$(Key(key))])
                (innerkey_ = value_) => begin
                    aKey = Key(innerkey)
                    :($innerkey =
                        if $haskey($safe_collection, $aKey)
                            $safe_collection[$aKey]
                        else
                            $value
                        end)
                end
                any_ => error("Cannot parse unlock argument $any")
            end
        end...)
    end |> esc
end

make_keywords(e) =
    if MacroTools.@capture e f_(args__)
        real_args = []
        keys = []
        values = []
        foreach(args) do arg
            MacroTools.@match arg begin
                ( key_ = value_ ) => push!(keys, key), push!(values, value)
                any_ => push!(real_args, arg)
            end
        end
        :($f($KeyedTuple(($(Key.(keys)...),), ($(values...),)), $(real_args...), ))
    else
        e
    end

export @keywords
"""
    @keywords(e)

Will transform any function call such that it is passed a keyed tuple of
keywords as the first argument.

```jldoctest
julia> using Keys

julia> put_together(k::KeyedTuple, x, y) = begin
            @unlock k left = "" sep = "" right = ""
            string(left, x, sep, y, right)
        end;

julia> @keywords put_together(1, 2)
"12"

julia> @keywords put_together(1, 2, left = '(', sep = ", ", right = ')')
"(1, 2)"
```
"""
macro keywords(e)
    make_keywords(e) |> esc
end

fix_dot(any) = any
fix_dot(e::Expr) = MacroTools.@match e begin
    (t_.s_ = a_) => :($set_field!($t, $(Key(s)), $a))
    t_.s_ => :($get_field($t, $(Key(s))))
    # ..(t_, s_) => :($mappedarray(i -> $get_field(i, $(Key(s))), $t))
    any_ => any
end

export get_field
"""
    get_field(t, v)

Overload to implement dot overloading [`@overload_dots`](@ref).
"""
function get_field(any, key)
    getfield(any, Symbol(key))
end

get_field(k::KeyedTuple, key) = getindex(k, key)

export set_field!
"""
    set_field!(t, v, a)

Overload for dot overloading within [`@overload_dots`](@ref).
"""
set_field!(any, key, value) = setfield!(any, Symbol(key), value)

export @overload_dots
"""
    @overload_dots e

Allows for type stable dot-overloading. Walks through an expression and replaces
`a.b` with `get_field(a, Key{:b}())` and `a.b = c` with
`set_field!(a, c, Key{:b}())`. Overload [`get_field`](@ref) and
[`set_field!`](@ref) for new types. Dot overloading already defined for keyed
tuples, and keyed tables. Dot overloading on keyed tables will return a
mappedarray of values.

```jldoctest
julia> using Keys, Base.Test

julia> mutable struct A
            b::Int
            c::String
        end;

julia> a = A(1, "c");

julia> @overload_dots a.b = 2;

julia> a.b
2

julia> k = KeyedTuple((@keys a b), (1, 2.5));

julia> test(k) = @overload_dots k.a + k.b;

julia> @inferred test(k)
3.5

julia> ks = [k, k];

julia> collect(@overload_dots ks.a)
2-element Array{Int64,1}:
 1
 1
```
"""
macro overload_dots(e)
    esc(MacroTools.prewalk(fix_dot, e))
end

export KeyedTable
const KeyedTable = AbstractVector{T} where T <: KeyedTuple{K, V} where V <: Tuple where K <: Tuple

get_field(k::KeyedTable, key) = mappedarray(row -> getindex(row, key), k)

show_row(io, atuple) = begin
    print(io, "| ")
    join(io, atuple, " | ")
    println(io, " |")
end

show_row(io, atuple, widths, n) =
    show_row(io, map(rpad, atuple, widths)[1:n])

function Base.summary(t::KeyedTable)
    "$(length(t)) x $(length(type_keys(eltype(t)))) keyed table"
end

struct Repeated
    text::String
    number::Int
end

function Base.show(io::IO, r::Repeated)
    text = r.text
    for i in 1:r.number
        print(io, text)
    end
end

function Base.showarray(io::IO, t::KeyedTable, ::Bool)
    println(io, summary(t))
    row_number, column_number = displaysize(io)
    limit = get(io, :limit, false)
    names = string.(type_keys(eltype(t)))
    # subset rows for long arrays
    subset =
        if limit
            t[1:min(row_number - 3, length(t))]
        else
            t
        end
    rows = map(subset) do row
        string.(row.values)
    end
    # find maximum widths for rows
    row_widths = mapreduce(
        row -> map(strwidth, row),
        (x, y) -> map(max, x, y),
        rows
    )
    # and then also for names
    widths = map(max, map(strwidth, names), row_widths)
    # figure out how many columns we can safely print
    if limit
        n = findfirst(x -> x > column_number - 2, cumsum([(widths .+ 3)...])) - 1
        if n == -1
            n = length(widths)
        end
    else
        n = length(widths)
    end

    if n > 0
        show_row(io, names, widths, n)
        show_row(io, (Repeated("-", i) for i in [widths...][1:n]))
        for row in rows
            show_row(io, row, widths, n)
        end
        nothing
    else
        nothing
    end
end

export @keyword_definition
"""
    @keyword_definition e

Transform a regular function definition with keywords such that if can be used
with the type-stable `@keyword` macro.

```jldoctest
julia> using Keys

julia> @keyword_definition test(a, b; c = 1, d = 2) = a + b + c + d;

julia> @keywords test(1, 2, c = 3)
8
```
"""
macro keyword_definition(e)
    f, args, kwargs, body = MacroTools.@match e begin
        function f_(args__; kwargs__)
            body__
        end => f, args, kwargs, body
        function f_(args__)
            body__
        end => f, args, (), body
        (f_(args__; kwargs__) = body_) => f, args, kwargs, (body,)
        any_ => error("$e is not in a standard function definition")
    end

    k = gensym()
    keys = map(kwargs) do kwarg
        MacroTools.@match kwarg begin
            key_Symbol => key
            (key_ = value_) => key
            any_ => error("Cannot decompose assignment $kwarg")
        end
    end
    quote
        function $f($k::$KeyedTuple, $(args...))
            $Keys.@unlock $k $(kwargs...)
            $(body...)
        end
    end |> esc
end

end
