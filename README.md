# TraitWrappers.jl

A trait-system where the object is part of the trait type and accessible via the function `object`.

## Why?
The most popular (and only?) trait system in Julia is the Holy Traits. Please see [The Emergent Features of JuliaLang: Part II - Traits](https://invenia.github.io/blog/2019/11/06/julialang-features-part-2/) which discusses Holy Traits. Most of the examples and blogs on traits systems in Julia are based on using traits on one of the arguments. But in many use-cases, multiple arguments should receive the traits treatment. Holy Traits still works in those cases, but it can feel unsatisfying and can, sometimes, makes code harder to read. TraitWrapper.jl was concieved to solve these issues. The "why"s of TraitWrappers.jl are explored and illustrated with examples in the sections below.

## The `AbstractTraitWrapper` type
`AbstractTraitWrapper` type only defines one method which is `object(t::AbstractTraitWrapper)` that should return the object with the trait.

### Using `TraitWrappers.jl`

This is an example implementing an Iterable that is [`HasEltype()`](https://docs.julialang.org/en/v1/manual/interfaces/). The Holy Trait implementation looks like this

```julia
using Base: HasEltype

fn_holy(itr) = fn(IteratorEltype(itr), itr)

fn_holyn(::HasEltype, itr) = begin
	println("this itr has `eltype()` defined")
	println(itr)
end
```

The equivalent implementation using `TraitWrappers.jl` is

```julia
struct EltypeTypeTraitWrapper{T, I <: IteratorEltype} <: AbstractTraitWrapper
	object::T
	EltypeTypeTraitWrapper(t::T) where T = new{T, typeof(IteratorEltype(t))}(t)
end

typeof(EltypeTypeTraitWrapper{Number, HasEltype})

fn_tw(itr) = fn_tw(EltypeTypeTraitWrapper(itr))

fn_tw(itr::EltypeTypeTraitWrapper{T, HasEltype}) where T = begin
	println("this itr has `eltype()` defined")
	println(object(itr))
end
```

For a function with one argument that needs traits, TraitWrapper isn't as attractive. However, imagine if you have many arguments that can receive the traits treatment then Holy Traits can become harder to read. E.g.

```julia
fn_holy(a, b, c) = f(TraitA(a), TraitB(b), TraitC(c), a, b, c)

fn_holy(::SomeTraitA, ::SomeTraitB, ::SomeTraitC, a, b, c) = begin
	# do something to a, b, c
end
```

versus using TraitWrappers.jl

```julia
fn_tw(a, b, c) = f(TraitAWrapper(a), TraitBWrapper(b), TraitCWrapper(c))

fn_tw(a::TraitAWrapper1, b::TraitBWrapper1, c::TraitCWrappe1r) = begin
	# do something to object(a), object(b), object(c)
end
```

There are pros and cons to either approach but with TraitWrapper.jl, it's easier to see which argument relies on which trait and don't have to rely on positional conventions which can become unwieldy if some arguments rely on traits and some don't. TraitWrapper.jl enhances readability where there are many arguments that rely on traits.

Technically, you don't really need this package to implement the TraitWrapper idea. But using this package indicates that you are using `TraitWrappers` and can point here for explanation of the concept.

### Another Example

Another example of using TraitWrappers.jl lies in the [JLBoost.jl](https://github.com/xiaodaigh/JLBoost.jl) package. JLBoost.jl's tree boosting algorithm use a `predict` function to score out an iterable of trees on a `DataFrame`-like object.

Before the introduction of TraitWrappers.jl. the function signature looked like this

```julia
function predict(jlts::AbstractVector{T}, df::AbstractDataFrame) where T <:AbstractJLBoostTree
	mapreduce(x->predict(x, df), +, jlts)
end
```

The two arguments are `jlts` and `df` and as you can see it’s just using the `mapreduce` function. Actually, I don’t require `jlts` to be `AbstractVector{T<:AbstractJLBoostTree}` nor `df` to be AbstractDataFrame at all.

I just need `jlts` to be an iterable of with `eltype(jlts) == S<:AbstractJLBoostTree` and `df` to be something that supports the `df[!, column]` syntax. So naturally, traits fit nicely here. But with Holy traits the functions will look like

```julia
function predict(jlts, df)
    predict(Iterable(jlts), ColumnAccessible(df), jlts, df)
end

function predict(::Iterable{T}, ::ColumnAccessible, jlts, df) where T <:AbstractJLBoostTree
    mapreduce(x->predict(x, df), +, jlts)
end
```

this feels unsatisfying and the implementation using TraitWrappers.jl is

```julia
struct IterableTraitWrapper{T} <: AbstractTraitWrapper
   object::T
   IterableTraitWrapper(t::T) where T = begin
      if hasmethod(iterate, Tuple{T})
      	new{T}(t)
      else
         throw("This is not iterable")
      end
   end
end

struct ColumnAccessibleTraitWrapper{T} <: TraitWrapper{T}
   object::T
   ColumnAccessibleTraitWrapper(t::T) where T = begin
      if hasmethod(getindex, Tuple{T, typeof(!), Symbol})
      	 new{T}(t)
      else
         throw("This is not ColumnAccessible")
      end
   end
end
```

Now the my traits signature becomes like the below; it is easy to associate the traits with the arguments

```julia
function predict(jlts, df)
    predict(IterableTraitWrapper(jlts), ColumnAccessibleTraitWrapper(df))
end

function predict(jlts::IterableTraitWrapper, df::ColumnAccessible)
    mapreduce(x->predict(x, object(df)), +, object(jlts))
end
```

Finally, if  more traits are needed in a function signature, they can be added without having to double the number of arguments.

In conclusion, I hope you find that `TraitWrapper` makes it clearer which trait corresponds to which argument better, and it is easier to clearly express which argument is expected to have a certain trait.
