using ImageNetDataset
using Test
using Aqua
using JET

@testset "ImageNetDataset.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(ImageNetDataset)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(ImageNetDataset; target_defined_modules=true)
    end
    # Write your tests here.
end
