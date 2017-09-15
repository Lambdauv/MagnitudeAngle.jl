using MagnitudeAngle
using Base.Test
using Unitful.°

# write your own tests here
@testset "Constructors" begin
    @test_throws ArgumentError MagAngle(-1, 15°)
    @test_throws TypeError MagAngle{String}(1+im, 2.0)
    @test MagAngle{Float64}(1.0, 12°) isa MagAngle{Float64}
    @test MagAngle{Float64}(2) isa MagAngle{Float64}
    @test MagAngle(1, π) isa MagAngle{Float64}
end

@testset "Conversion" begin
    @test convert(MagAngle{Float64}, 3.01) === MagAngle(3.01,0)
    @test convert(MagAngle{Float64}, 1+sqrt(3)*im) ≈ MagAngle(2.0, 60.0°)
    @test convert(Float64, MagAngle(3.0,0.0)) === 3.0
    @test_throws InexactError convert(Float64, MagAngle(3.0,10°))

    let z = MagAngle(1.0,0.0)
        @test convert(MagAngle, z) === z
    end
    @test convert(MagAngle, 1+sqrt(3)*im) ≈ MagAngle(2.0, 60°)
    @test convert(MagAngle, 2.0) == MagAngle(2.0, 0)
    @test convert(typeof(MagAngle(3,π)), 0) == MagAngle{Float64}(0,0)
end

@testset "Promotion" begin
    @test promote_type(MagAngle{Int}, Float64) == MagAngle{Float64}
    @test promote_type(MagAngle{Int}, MagAngle{Float64}) == MagAngle{Float64}

    @test real(MagAngle(1.1, π)) == 1.1*cos(π)
    @test imag(MagAngle(1.1, π)) == 1.1*sin(π)
end

@testset "is_xxx_" begin
    let z = MagAngle(2.1, 21°)
        @test !isreal(z)
        @test !isinteger(z)
        @test isfinite(z)
        @test !isnan(z)
        @test !isinf(z)
        @test !iszero(z)
        @test flipsign(z, -1) === -z
    end

    let z = MagAngle(2.0, 0°)
        @test isreal(z)
        @test isinteger(z)
    end

    let z = MagAngle(Inf, 0°)
        @test !isfinite(z)
    end

    let z = MagAngle(NaN, 0°)
        @test isnan(z)
    end

    let z = MagAngle(0.0, 22°)
        @test iszero(z)
    end
end

@testset "Equality" begin
    let z = MagAngle(2.1, 21°)
        @test z == z
        @test z != MagAngle(2.2, 21°)
        @test z != MagAngle(2.1, 0°)
        @test z != 2.1
        @test 2.1 != z
        @test z == 1.9605188956441237 + 0.7525726940451306*im
        @test 1.9605188956441237 + 0.7525726940451306*im == z
        @test z != 1.2 + 3.4*im
        @test isequal(z,z)
        # @test !isequal(z,z+z) #need +
    end
end

@testset "Misc. math" begin
    let z = MagAngle(2.1, 21°)
        @test conj(z) == MagAngle(2.1, -21°)
        @test abs(z) === 2.1
        @test angle(z) == 21°
        @test abs2(z) === 4.41
        @test inv(z)*z == MagAngle(1.0, 0°)
    end
end

@testset "Basic math" begin
    let z = MagAngle(sqrt(3), 90°)
        @test -z == MagAngle(sqrt(3), -90°)
        @test z+z ≈ MagAngle(2*sqrt(3), 90°)       #needs isapprox
        @test z+MagAngle(1, 0) ≈ MagAngle(2, 60°)
        @test z-MagAngle(1, 0) ≈ MagAngle(2, 120°)
        @test z*z ≈ MagAngle(3, π)
        @test 1+z ≈ MagAngle(2, 60°)
        @test z+1 ≈ MagAngle(2, 60°)
        @test 1-z ≈ MagAngle(2, 300°)
        @test z-1 ≈ MagAngle(2, 120°)
        @test sqrt(3) * z ≈ MagAngle(3, 90°)
        @test z * sqrt(3) ≈ MagAngle(3, 90°)
    end
    @test sqrt(MagAngle(3, 180°)) == MagAngle(sqrt(3), 90°)
    @test 3 / MagAngle(3, 10°) ≈ MagAngle(1, -10°)
    @test MagAngle(3, 10°) / 3 ≈ MagAngle(1, 10°)
    @test MagAngle(3, 10°) / MagAngle(2, 5°) ≈ MagAngle(1.5, 5°)
end
