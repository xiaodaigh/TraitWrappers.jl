using TraitWrappers
using Test

using Base:IteratorEltype, IteratorSize

@testset "IterableTraitWrapper" begin
    a = IterableTraitWrapper(1:8)
    @test IteratorEltype(a) == IteratorEltype(1:8)
    @test IteratorSize(a) == IteratorSize(1:8)
    @test iterate(a) == iterate(1:8)
    @test iterate(a, 2) == iterate(1:8, 2)
    @test eltype(a) == eltype(1:8)
    @test length(a) == length(1:8)
    @test size(a) == size(1:8)
end
