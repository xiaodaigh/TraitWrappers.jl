module TraitWrappers

export AbstractTraitWrapper, object

"""
	TraitWrapper{T}

Abtract type wrapper
"""
abstract type AbstractTraitWrapper end

"""
	object(t::TraitWrapper)

Return the object wrapped in the trait
"""
object(t::AbstractTraitWrapper) = t.object

include("IterableTraitWrapper.jl")

end # module
