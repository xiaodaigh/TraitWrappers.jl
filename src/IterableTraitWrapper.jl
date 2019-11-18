"""
	IterableWrapper(iter)


Wraps a Iterable object
"""

import Base: iterate, eltype, length, size
export IterableTraitWrapper#, IteratorEltype, IteratorSize, iterate, eltype, length, size

struct IterableTraitWrapper{T} <: AbstractTraitWrapper
	object::T
	IterableTraitWrapper(t::T) where T = new{T}(t)
end

IteratorEltype(t::IterableTraitWrapper) = IteratorEltype(object(t))
IteratorSize(t::IterableTraitWrapper) = IteratorSize(object(t))
iterate(t::IterableTraitWrapper) = iterate(object(t))
iterate(t::IterableTraitWrapper, state) = iterate(object(t), state)
eltype(t::IterableTraitWrapper) = eltype(object(t))
length(t::IterableTraitWrapper) = length(object(t))
size(t::IterableTraitWrapper) = size(object(t))
