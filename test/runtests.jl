using ImageNetDataset
using Test
using Aqua
using JET
using JuliaFormatter

@testset "ImageNetDataset.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(ImageNetDataset; ambiguities=false)
    end
    @testset "Code linting (JET.jl)" begin
        if VERSION >= v"1.10"
            JET.test_package(ImageNetDataset; target_defined_modules=true)
        end
    end
    @testset "Code formatting (JuliaFormatter.jl)" begin
        @test format(ImageNetDataset; verbose=false, overwrite=false)
    end
    # Write your tests here.
end
