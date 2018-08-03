export TypedBool
"""
    abstract TypedBool

There are two TypedBools: `True` and `False`. They can be converted to `Bool`s.
Logical operations are defined for them. Using TypedBools can lead to
type stability in cases where constant propogation is not working for Bools.

```jldoctest
julia> using Keys

julia> Bool(False())
false

julia> Bool(True())
true

julia> TypedBool(false)
False()

julia> TypedBool(true)
True()

julia> True() & True() & False()
False()

julia> False() & False() & True()
False()

julia> True() | True() | False()
True()

julia> False() | False() | True()
True()

```
"""
abstract type TypedBool end
@inline TypedBool(b::Bool) =
    if b
        True()
    else
        False()
    end

export True
struct True <: TypedBool end
export False
struct False <: TypedBool end

Base.Bool(::True) = true
Base.Bool(::False) = false
Base.convert(::Type{Bool}, ::True) = true
Base.convert(::Type{Bool}, ::False) = false

(&)(::False, ::False) = False()
(&)(::False, ::True) = False()
(&)(::True, ::False) = False()
(&)(::True, ::True) = True()

(|)(::False, ::False) = False()
(|)(::False, ::True) = True()
(|)(::True, ::False) = True()
(|)(::True, ::True) = True()

export not
"""
    not(x)

Negate a TypedBool

```jldoctest
julia> using Keys

julia> not(True())
False()

julia> not(False())
True()
```
"""
not(::False) = True()
not(::True) = False()

"""
    if_else(switch, new, old)

Typed-bool aware version of `ifelse`.

```julia
julia> using Keys

julia> if_else(true, 1, 0)
1

julia> if_else(True(), 1, 0)
1

julia> if_else(False(), 1, 0)
0
```
"""
if_else(b::Bool, new, old) = ifelse(b, new, old)  # generic fallback
if_else(::True, new, old) = new
if_else(::False, new, old) = old

export same_type
"""
    same_type(a, b)

Check whether `a` and `b` are the same type, return a typed bool.

```jldoctest
julia> using Keys

julia> same_type(Val{:a}(), Val{:a}())
True()

julia> same_type(Val{:a}(), Val{:b}())
False()
```
"""
same_type(a::T, b::T) where T = True()
same_type(a, b) = False()
